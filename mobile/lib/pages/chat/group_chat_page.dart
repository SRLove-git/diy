import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';

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
  });

  final int? id;
  final String? clientMsgId;
  final int senderId;
  final String contentType;
  final String content;
  final DateTime createdAt;
  final String authorNickname;
  bool pending;

  factory _ViewGroupMsg.fromServer(GroupMessage m) => _ViewGroupMsg(
        id: m.id,
        senderId: m.senderId,
        contentType: m.contentType,
        content: m.content,
        createdAt: m.createdAt,
        authorNickname: m.authorNickname,
      );
}

class _GroupChatPageState extends State<GroupChatPage> {
  /// 最新消息在前（reverse ListView 底部展示最新）
  final List<_ViewGroupMsg> _msgs = [];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  StreamSubscription<ChatEvent>? _sub;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  List<GroupMemberInfo> _members = [];
  int _sending = 0;

  int get _myId => AuthService.instance.user?.id ?? 0;
  String get _groupName => widget.group.name;

  @override
  void initState() {
    super.initState();
    _sub = ChatService.instance.events.listen(_onEvent);
    _load();
    _loadMembers();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onEvent(ChatEvent event) {
    if (event is! GroupNewMessageEvent) return;
    if (event.message.groupId != widget.group.id) return;
    if (!mounted) return;
    setState(() => _msgs.insert(0, _ViewGroupMsg.fromServer(event.message)));
    // 正在浏览的群，实时标记已读
    ChatService.instance.markGroupRead(widget.group.id, event.message.id);
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
    _inputCtrl.clear();
    final clientMsgId =
        '${DateTime.now().millisecondsSinceEpoch}-$_myId-g${_msgs.length}';
    setState(() {
      _msgs.insert(
        0,
        _ViewGroupMsg(
          clientMsgId: clientMsgId,
          senderId: _myId,
          contentType: 'text',
          content: text,
          createdAt: DateTime.now(),
          pending: true,
        ),
      );
      _sending++;
    });
    try {
      final confirmed = await ChatService.instance.sendGroupMessage(
        groupId: widget.group.id,
        content: text,
        clientMsgId: clientMsgId,
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
          return _GroupBubble(message: _msgs[index], isMine: _msgs[index].senderId == _myId);
        },
      ),
    );
  }

  Widget _buildInputBar(AppColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
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
    );
  }
}

class _GroupBubble extends StatelessWidget {
  const _GroupBubble({required this.message, required this.isMine});

  final _ViewGroupMsg message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
                    border: isMine ? null : Border.all(color: colors.divider),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: isMine ? Colors.white : colors.textPrimary,
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

String _formatTime(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}';
}
