import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import 'group_manage_page.dart';
import 'message_action_sheet.dart';

/// 群聊页面（文字消息）
///
/// 支持：历史分页、实时收发（WS 优先 / REST 兜底）、发送中状态、
/// 进入自动标记已读。群成员消息展示发送者昵称。
class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key, required this.group});

  final GroupChat group;

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _ViewGroupMsg {
  _ViewGroupMsg({
    this.id,
    this.clientMsgId,
    required this.senderId,
    required this.contentType,
    required this.content,
    required this.createdAt,
    this.authorNickname = '',
    this.pending = false,
    this.replyToId,
    this.replyPreview,
    this.forwarded = false,
    this.recalledAt,
  });

  final int? id;
  final String? clientMsgId;
  final int senderId;
  final String contentType;
  final String content;
  final DateTime createdAt;
  final String authorNickname;
  bool pending;

  /// 引用消息 ID（同一群内的消息）
  final int? replyToId;

  /// 被引用消息快照预览
  final String? replyPreview;

  /// 是否为转发消息
  final bool forwarded;

  /// 撤回时间；非空 = 已撤回
  DateTime? recalledAt;

  factory _ViewGroupMsg.fromServer(GroupMessage m) => _ViewGroupMsg(
        id: m.id,
        senderId: m.senderId,
        contentType: m.contentType,
        content: m.content,
        createdAt: m.createdAt,
        authorNickname: m.authorNickname,
        replyToId: m.replyToId,
        replyPreview: m.replyPreview,
        forwarded: m.forwarded,
        recalledAt: m.recalledAt,
      );
}

class _GroupChatPageState extends State<GroupChatPage> {
  /// 最新消息在前（reverse ListView 底部展示最新）
  final List<_ViewGroupMsg> _msgs = [];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  StreamSubscription<ChatEvent>? _sub;
  StreamSubscription<ChatEvent>? _groupEventSub;
  /// 当前引用中的群消息（输入栏上方显示引用条）
  _ViewGroupMsg? _replyTo;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  List<GroupMemberInfo> _members = [];
  int _sending = 0;

  /// 页面已因解散/被移出/主动退出而关闭；防止 WS 事件与群管理页返回结果
  /// 两条路径重复 pop 把下层路由弹掉（黑屏卡死）。
  bool _closed = false;

  int get _myId => AuthService.instance.user?.id ?? 0;
  late String _groupName;

  @override
  void initState() {
    super.initState();
    _groupName = widget.group.name;
    _sub = ChatService.instance.events.listen(_onEvent);
    // 群成员变化 / 被移出事件（独立订阅，避免与消息渲染互相干扰）
    _groupEventSub = ChatService.instance.events.listen(_onGroupEvent);
    _load();
    _loadMembers();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _groupEventSub?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onEvent(ChatEvent event) {
    if (event is GroupNewMessageEvent) {
      if (event.message.groupId != widget.group.id) return;
      if (!mounted) return;
      setState(() => _msgs.insert(0, _ViewGroupMsg.fromServer(event.message)));
      // 正在浏览的群，实时标记已读
      ChatService.instance.markGroupRead(widget.group.id, event.message.id);
      return;
    }
    if (event is GroupMessageRecalledEvent) {
      if (event.groupId != widget.group.id) return;
      if (!mounted) return;
      setState(() {
        for (final m in _msgs) {
          if (m.id == event.messageId && m.recalledAt == null) {
            m.recalledAt = event.recalledAt ?? DateTime.now();
          }
        }
      });
      if (_replyTo?.id == event.messageId) {
        setState(() => _replyTo = null);
      }
    }
  }

  void _onGroupEvent(ChatEvent event) {
    if (event is GroupMemberChangedEvent &&
        event.groupId == widget.group.id) {
      // 成员/群信息变化（拉人/退出/踢人/改名）：刷新成员数与群名
      _loadMembers();
      ChatService.instance.refreshGroups().then((_) {
        if (mounted) _syncGroupInfo();
      });
      return;
    }
    if (event is GroupRemovedEvent && event.groupId == widget.group.id) {
      _closeWithToast(
        event.reason == 'dissolved' ? '群聊已解散' : '你已被移出群聊',
      );
    }
  }

  /// 关闭群聊页（幂等）：WS 群解散/移出事件与群管理页返回结果都会触发关闭，
  /// 只允许第一次生效，避免重复 pop。
  void _closeWithToast(String message) {
    if (_closed || !mounted) return;
    _closed = true;
    _toast(message);
    Navigator.of(context).pop();
  }

  /// 右上角入口：打开群管理（成员列表 / 拉人 / 退出 / 解散）
  Future<void> _openManage() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => GroupManagePage(group: widget.group)),
    );
    if (!mounted) return;
    if (result == 'left') {
      _closeWithToast('已退出群聊');
      return;
    }
    if (result == 'dissolved' || result == 'removed') {
      // 'removed'：群管理页已先收到 WS 解散事件自行关闭
      _closeWithToast('群聊已解散');
      return;
    }
    _loadMembers();
    ChatService.instance.refreshGroups().then((_) {
      if (mounted) _syncGroupInfo();
    });
  }

  /// 从群缓存同步群名（重命名后刷新标题）
  void _syncGroupInfo() {
    for (final g in ChatService.instance.groups) {
      if (g.id == widget.group.id && g.name != _groupName) {
        setState(() => _groupName = g.name);
        return;
      }
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await GroupApi.fetchMessages(widget.group.id);
      if (!mounted) return;
      setState(() {
        _msgs
          ..clear()
          ..addAll(result.items.reversed.map(_ViewGroupMsg.fromServer));
        _hasMore = result.nextCursor != null;
        _loading = false;
      });
      _markReadIfNeeded();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败，请重试';
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore || _msgs.isEmpty) return;
    setState(() => _loadingMore = true);
    final oldestId = _msgs.last.id ?? 0;
    try {
      final result = await GroupApi.fetchMessages(
        widget.group.id,
        cursor: oldestId,
      );
      if (!mounted) return;
      setState(() {
        _msgs.addAll(result.items.reversed.map(_ViewGroupMsg.fromServer));
        _hasMore = result.nextCursor != null;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _loadMembers() async {
    try {
      final members = await GroupApi.fetchMembers(widget.group.id);
      if (mounted) setState(() => _members = members);
    } catch (_) {
      // 成员加载失败不影响聊天
    }
  }

  void _markReadIfNeeded() {
    final lastId = _msgs.isEmpty ? 0 : (_msgs.first.id ?? 0);
    if (lastId > 0) {
      ChatService.instance.markGroupRead(widget.group.id, lastId);
    }
  }

  bool _onScroll(ScrollNotification notification) {
    // 滚到顶部加载更早消息
    if (notification.metrics.pixels <= 60) _loadMore();
    return false;
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending > 0) return;
    final replyTo = _replyTo;
    _inputCtrl.clear();
    final clientMsgId =
        '${DateTime.now().millisecondsSinceEpoch}-$_myId-g${_msgs.length}';
    setState(() {
      _replyTo = null;
      _msgs.insert(
        0,
        _ViewGroupMsg(
          clientMsgId: clientMsgId,
          senderId: _myId,
          contentType: 'text',
          content: text,
          createdAt: DateTime.now(),
          pending: true,
          replyToId: replyTo?.id,
          replyPreview: replyTo != null ? _groupPreviewOf(replyTo) : null,
        ),
      );
      _sending++;
    });
    try {
      final confirmed = await ChatService.instance.sendGroupMessage(
        groupId: widget.group.id,
        content: text,
        clientMsgId: clientMsgId,
        replyToId: replyTo?.id,
      );
      if (!mounted) return;
      setState(() {
        final i = _msgs.indexWhere((m) => m.clientMsgId == clientMsgId);
        if (i >= 0) {
          if (confirmed != null) {
            _msgs[i] = _ViewGroupMsg.fromServer(confirmed);
          } else {
            _msgs.removeAt(i);
          }
        }
      });
      if (confirmed == null) _toast('发送失败，请重试');
    } finally {
      if (mounted) setState(() => _sending--);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ---------- 群消息长按操作：引用 / 复制 / 转发 / 删除 / 撤回 ----------

  Future<void> _showMessageActions(_ViewGroupMsg vm) async {
    if (vm.recalledAt != null) return;
    final mine = vm.senderId == _myId;
    final age = DateTime.now().difference(vm.createdAt);
    final canRecall = mine &&
        vm.id != null &&
        !vm.pending &&
        age < const Duration(minutes: 2) &&
        vm.recalledAt == null;
    final action = await showMessageActionSheet(
      context,
      contentType: vm.contentType,
      canRecall: canRecall,
      // 发送中的本地消息无引用目标，不可引用
      canQuote: vm.id != null,
    );
    if (action == null || !mounted) return;
    switch (action) {
      case MessageAction.copy:
        await Clipboard.setData(ClipboardData(text: vm.content));
        _toast('已复制');
        break;
      case MessageAction.quote:
        FocusScope.of(context).unfocus();
        setState(() => _replyTo = vm);
        break;
      case MessageAction.forward:
        await _forwardGroupMessage(vm);
        break;
      case MessageAction.recall:
        await _recallGroupMessage(vm);
        break;
      case MessageAction.delete:
        await _deleteGroupMessage(vm);
        break;
    }
  }

  /// 转发群消息到单聊会话（原样发送，标记 forwarded）
  Future<void> _forwardGroupMessage(_ViewGroupMsg vm) async {
    if (vm.content.isEmpty) {
      _toast('该消息发送中或发送失败，暂不可转发');
      return;
    }
    await showForwardPicker(
      context,
      onForward: (conv) async {
        final clientMsgId =
            '${DateTime.now().microsecondsSinceEpoch}-$_myId-f${_msgs.length}';
        final confirmed = await ChatService.instance.sendMessage(
          conversationId: conv.id,
          content: vm.content,
          clientMsgId: clientMsgId,
          contentType: vm.contentType,
          forwarded: true,
        );
        if (!mounted) return;
        if (confirmed != null) {
          _toast(
            '已转发给 ${conv.peerNickname.isEmpty ? '用户 #${conv.peerId}' : conv.peerNickname}',
          );
        } else {
          _toast('转发失败，请重试');
        }
      },
    );
  }

  /// 删除群消息（仅对自己隐藏，其他成员仍可见）
  Future<void> _deleteGroupMessage(_ViewGroupMsg vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除消息'),
        content: const Text('删除后仅自己不可见，其他成员仍可看到这条消息'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final id = vm.id;
    if (id != null) {
      final ok = await ChatService.instance
          .deleteGroupMessage(widget.group.id, id);
      if (!ok) {
        if (mounted) _toast('删除失败，请重试');
        return;
      }
    }
    setState(() => _msgs.removeWhere((m) => identical(m, vm)));
    if (_replyTo == vm) setState(() => _replyTo = null);
  }

  /// 撤回群消息（仅自己、2 分钟内；撤回后提示「重新编辑」）
  Future<void> _recallGroupMessage(_ViewGroupMsg vm) async {
    final id = vm.id;
    if (id == null) return;
    final recalled = await ChatService.instance
        .recallGroupMessage(widget.group.id, id);
    if (!mounted) return;
    if (recalled == null) {
      _toast('撤回失败：发送超过 2 分钟的消息不能撤回');
      return;
    }
    setState(() => vm.recalledAt = recalled.recalledAt ?? DateTime.now());
    if (_replyTo == vm) setState(() => _replyTo = null);
    // 二次编辑：原内容放回输入框
    final text = vm.content;
    if (vm.contentType == 'text' && text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已撤回'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '重新编辑',
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _inputCtrl.text = text;
                _inputCtrl.selection =
                    TextSelection.collapsed(offset: text.length);
              });
            },
          ),
        ),
      );
    } else {
      _toast('已撤回');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(_groupName, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 1),
            Text(
              '${_members.length} 人',
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openManage,
            tooltip: '群管理',
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessages(colors)),
            _buildInputBar(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(AppColors colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: _load, child: const Text('重试')),
          ],
        ),
      );
    }
    if (_msgs.isEmpty) {
      return Center(
        child: Text(
          '群聊已建立，来发第一条消息吧',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView.builder(
        controller: _scrollCtrl,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: _msgs.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _msgs.length) {
            return _loadingMore
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : const SizedBox(height: 40);
          }
          return _GroupBubble(
            message: _msgs[index],
            isMine: _msgs[index].senderId == _myId,
            onLongPress: () => _showMessageActions(_msgs[index]),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyTo != null) _buildReplyBar(colors),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: '发消息…',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: colors.placeholder.withValues(alpha: 0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 58,
                  height: 38,
                  child: FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: const Text('发送', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 引用条：显示在输入栏上方，展示被引用群消息预览
  Widget _buildReplyBar(AppColors colors) {
    final vm = _replyTo!;
    final preview = vm.replyPreview != null
        ? chatPreviewText(vm.replyPreview)
        : chatPreviewText(_groupPreviewOf(vm));
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 4),
      color: colors.surface,
      child: Row(
        children: [
          Icon(Icons.format_quote_rounded,
              size: 18, color: colors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              preview.isEmpty ? '引用消息' : '引用：$preview',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: '取消引用',
            onPressed: () => setState(() => _replyTo = null),
          ),
        ],
      ),
    );
  }
}

class _GroupBubble extends StatelessWidget {
  const _GroupBubble({
    required this.message,
    required this.isMine,
    required this.onLongPress,
  });

  final _ViewGroupMsg message;
  final bool isMine;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // 已撤回：整行替换为居中小字提示
    if (message.recalledAt != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child: Text(
            isMine ? '你撤回了一条消息' : '${message.authorNickname} 撤回了一条消息',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ),
      );
    }
    final nickname = message.authorNickname.isEmpty
        ? '用户 #${message.senderId}'
        : message.authorNickname;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                nickname,
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
            ),
          ],
          Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: GestureDetector(
                  onLongPress: onLongPress,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 260),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isMine ? colors.primary : colors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(isMine ? 14 : 4),
                        bottomRight: Radius.circular(isMine ? 4 : 14),
                      ),
                      border:
                          isMine ? null : Border.all(color: colors.divider),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // 引用消息：气泡顶部展示被引用内容快照
                        if (message.replyToId != null)
                          _GroupQuote(
                            preview: chatPreviewText(message.replyPreview),
                            isMine: isMine,
                            colors: colors,
                          ),
                        if (message.contentType == 'image')
                          Text(
                            '[图片]',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: isMine
                                  ? Colors.white
                                  : colors.textPrimary,
                            ),
                          )
                        else if (message.contentType == 'voice')
                          Text(
                            '[语音]',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: isMine
                                  ? Colors.white
                                  : colors.textPrimary,
                            ),
                          )
                        else if (message.contentType == 'video')
                          Text(
                            '[视频]',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: isMine
                                  ? Colors.white
                                  : colors.textPrimary,
                            ),
                          )
                        else
                          Text(
                            message.content,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.4,
                              color: isMine
                                  ? Colors.white
                                  : colors.textPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isMine && message.pending) ...[
                const SizedBox(width: 6),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.6),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(fontSize: 10, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _GroupQuote extends StatelessWidget {
  const _GroupQuote({
    required this.preview,
    required this.isMine,
    required this.colors,
  });

  final String preview;
  final bool isMine;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isMine
            ? Colors.white.withValues(alpha: 0.16)
            : colors.placeholder.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              color: isMine ? Colors.white70 : colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              preview.isEmpty ? '引用消息' : preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isMine ? Colors.white70 : colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 群消息快照预览（本地待发送群消息的引用条用）
String _groupPreviewOf(_ViewGroupMsg m) {
  if (m.contentType == 'image') return 'image:';
  if (m.contentType == 'voice') return 'voice:';
  if (m.contentType == 'video') return 'video:';
  final text = m.content.trim();
  return 'text:${text.length > 50 ? text.substring(0, 50) : text}';
}

String _formatTime(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}';
}
