import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../api/api_config.dart';
import '../../api/api_client.dart';
import '../../api/auth_store.dart';
import '../../api/chat_services.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key, this.root = false});

  final bool root;

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  List<ConversationItem> _convs = [];
  List<GroupItem> _groups = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ChatService.instance.conversations(),
        GroupService.instance.mine(),
      ]);
      if (mounted) {
        setState(() {
          _convs = (results[0] as Page<ConversationItem>).items;
          _groups = (results[1] as Page<GroupItem>).items;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 长按会话项：弹出操作菜单（对齐 Pixso 42-会话-长按菜单）。
  Future<void> _showConversationMenu(_ChatListItem item, Offset globalPos) async {
    final overlaySize = MediaQuery.of(context).size;
    const menuW = 199.0;
    const menuH = 150.0;
    double left = globalPos.dx;
    if (left + menuW > overlaySize.width) {
      left = overlaySize.width - menuW - 12;
    }
    double top = globalPos.dy;
    if (top + menuH > overlaySize.height - 60) {
      top = overlaySize.height - menuH - 60;
    }

    final convId = item.group?.id ?? item.conv?.id ?? 0;
    final isGroup = item.group != null;
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, overlaySize.width - left - menuW, 0),
      items: const [
        PopupMenuItem<String>(
          value: 'pin',
          height: 45,
          child: Text('置顶聊天', style: TextStyle(fontSize: 13, color: LiveColors.textPrimary)),
        ),
        PopupMenuItem<String>(
          value: 'unread',
          height: 45,
          child: Text('标为未读', style: TextStyle(fontSize: 13, color: LiveColors.textPrimary)),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          height: 45,
          child: Text('删除会话', style: TextStyle(fontSize: 13, color: LiveColors.danger)),
        ),
      ],
      color: LiveColors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case 'pin':
        try {
          if (isGroup) {
            showLiveSnack(context, '群聊暂不支持置顶');
          } else {
            await ChatService.instance.pinConversation(convId, true);
            if (mounted) showLiveSnack(context, '已置顶');
            _load();
          }
        } on ApiException catch (e) {
          if (mounted) showLiveSnack(context, e.message);
        }
      case 'unread':
        if (mounted) showLiveSnack(context, '标为未读功能敬请期待');
      case 'delete':
        // 等 showMenu 的 route 完全退场后再弹确认框，
        // 避免同帧 pop（菜单）+ push（对话框）触发 _dependents.isEmpty 断言。
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('删除会话', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            content: Text('删除后将清空与「${item.name}」的聊天记录，确定删除吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消', style: TextStyle(color: LiveColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除', style: TextStyle(color: LiveColors.danger)),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
        try {
          if (isGroup) {
            await GroupService.instance.dissolve(convId);
          } else {
            await ChatService.instance.deleteConversation(convId);
          }
          if (mounted) {
            showLiveSnack(context, '已删除');
            _load();
          }
        } on ApiException catch (e) {
          if (mounted) showLiveSnack(context, e.message);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <_ChatListItem>[
      for (final g in _groups)
        _ChatListItem.group(g),
      for (final c in _convs)
        _ChatListItem.conv(c),
    ]..sort((a, b) {
        final at = a.lastAt;
        final bt = b.lastAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });

    return LivePage(
      child: Column(
        children: [
          // 标题「聊天」居中对齐，右侧保留添加好友入口
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  '聊天',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: LiveColors.textPrimary,
                  ),
                ),
                Positioned(
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.person_add_alt, color: LiveColors.textPrimary),
                    onPressed: () => LiveRoutes.push(
                      context,
                      RoutePaths.chatAddFriend,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 搜索框：位于「聊天」正下方（对齐设计稿 21-会话列表）
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: LiveColors.inputBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: LiveColors.textTertiary),
                  const SizedBox(width: 8),
                  Text(
                    '搜索',
                    style: const TextStyle(fontSize: 15, color: LiveColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : items.isEmpty
                        ? const EmptyView(text: '暂无会话，去添加好友开始聊天吧')
                        : RefreshIndicator(
                            onRefresh: () async => _load(),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                indent: 76,
                                color: LiveColors.divider,
                              ),
                              itemBuilder: (_, i) => _ConversationTile(
                                item: items[i],
                                onLongPress: (pos) =>
                                    _showConversationMenu(items[i], pos),
                                onTap: () async {
                                  final it = items[i];
                                  if (it.group != null) {
                                    await LiveRoutes.push(
                                      context,
                                      RoutePaths.chatDetail,
                                      extra: {
                                        'groupId': it.group!.id,
                                        'groupName': it.group!.name,
                                      },
                                    );
                                  } else {
                                    final c = it.conv!;
                                    await LiveRoutes.push(
                                      context,
                                      RoutePaths.chatDetail,
                                      extra: {
                                        'conversationId': c.id,
                                        'peerId': c.peerId,
                                        'peerName': c.peerNickname,
                                        'peerAvatar': c.peerAvatar,
                                      },
                                    );
                                  }
                                  // 从聊天页返回后重新拉取列表，刷新未读角标/最后消息
                                  if (mounted) _load();
                                },
                              ),
                            ),
                          ),
                          ),
        ],
      ),
    );
  }
}

/// 录音中提示条（替换输入框显示）。
class _RecordingChip extends StatelessWidget {
  const _RecordingChip({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LiveColors.inputBg,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            color: LiveColors.danger,
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            '正在录音 ${_fmtSec(seconds)} · 点击结束并发送',
            style: const TextStyle(fontSize: 13, color: LiveColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// 语音消息内容解析：content 为 {"url": "...", "duration": 秒} JSON。
class _VoiceData {
  const _VoiceData({required this.url, required this.duration});

  final String url;
  final int duration;

  static _VoiceData? tryParse(String content) {
    try {
      final map = jsonDecode(content);
      if (map is Map<String, dynamic>) {
        return _VoiceData(
          url: (map['url'] as String?) ?? '',
          duration: ((map['duration'] as num?) ?? 0).toInt(),
        );
      }
    } catch (_) {
      // 非 JSON 视为无效语音数据
    }
    return null;
  }
}

String _fmtSec(int s) {
  final m = s ~/ 60;
  final sec = s % 60;
  return '$m:${sec.toString().padLeft(2, '0')}';
}

/// 会话列表预览：把服务端的 voice:/image:/video:/text: 前缀转成可读文案。
String _previewText(String raw) {
  if (raw.startsWith('voice:')) return '[语音]';
  if (raw.startsWith('image:')) return '[图片]';
  if (raw.startsWith('video:')) return '[视频]';
  if (raw.startsWith('recalled:')) return '消息已撤回';
  if (raw.startsWith('text:')) return raw.substring(5);
  return raw;
}

/// Pixso 居中确认弹窗（40-群聊踢人确认 / 34-居中确认）：
/// 半透明遮罩 + 312 宽圆角白卡 + 成员头像 + 标题 + 说明 + 取消/确认按钮。
Future<bool?> showMemberActionDialog(
  BuildContext context, {
  required GroupMember member,
  required bool setAdmin,
}) {
  final title = setAdmin
      ? '将「${member.nickname}」设为管理员'
      : '将「${member.nickname}」移出群聊';
  final message = setAdmin
      ? '设为管理员后 TA 可协助管理群成员（添加 / 移出成员），确定设为管理员吗？'
      : '移出后 TA 将无法查看群聊消息，其他成员仍可重新邀请';
  final confirmLabel = setAdmin ? '设为管理员' : '移出';
  final confirmColor = setAdmin
      ? const Color(0xFF141414)
      : const Color(0xFFFF3B30);
  return showDialog<bool>(
    context: context,
    // 遮罩 rgba(20,20,20,.42)，与设计稿一致
    barrierColor: const Color(0x6B141414),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 39),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 312),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x38141414), // rgba(20,20,20,.22)
                blurRadius: 64,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Avatar(url: member.avatar, name: member.nickname, size: 40),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141414),
                  letterSpacing: -0.2,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                  height: 1.6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 22, 0, 22),
                child: Row(
                  children: [
                    Expanded(
                      child: _DialogActionButton(
                        label: '取消',
                        backgroundColor: const Color(0xFFF7F7F8),
                        foregroundColor: const Color(0xFF141414),
                        onTap: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogActionButton(
                        label: confirmLabel,
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        onTap: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 设计稿弹窗按钮：高 46、圆角 15、字号 15 加粗。
class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 46,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatListItem {
  const _ChatListItem.group(this.group) : conv = null;
  const _ChatListItem.conv(this.conv) : group = null;

  final GroupItem? group;
  final ConversationItem? conv;

  DateTime? get lastAt => group?.lastMessageAt ?? conv?.lastMessageAt;
  int get unread => (group?.unreadCount ?? 0) + (conv?.unreadCount ?? 0);
  String get name => group?.name ?? conv?.peerNickname ?? '';
  String get preview =>
      _previewText(group?.lastMessagePreview ?? conv?.lastMessagePreview ?? '暂无消息');
  String get avatar => conv?.peerAvatar ?? '';
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final _ChatListItem item;
  final VoidCallback onTap;
  final void Function(Offset globalPosition) onLongPress;

  @override
  Widget build(BuildContext context) {
    final avatar = item.group != null
        ? (item.group!.memberAvatars.isNotEmpty
            ? item.group!.memberAvatars.first
            : '')
        : item.avatar;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
            Stack(
              children: [
                Avatar(url: avatar, name: item.name, size: 50),
                if (item.unread > 0)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                        color: LiveColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item.unread > 99 ? '99+' : '${item.unread}',
                        style: const TextStyle(color: Colors.white, fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmtTime(item.lastAt),
                  style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary),
                ),
                if (item.group != null)
                  Text('${item.group!.memberCount} 人',
                      style: const TextStyle(fontSize: 10, color: LiveColors.textTertiary)),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.conversationId,
    this.groupId,
    this.peerId = 0,
    this.peerName = '',
    this.peerAvatar = '',
    this.groupName = '',
  });

  final int? conversationId;
  final int? groupId;
  final int peerId;
  final String peerName;
  final String peerAvatar;
  final String groupName;

  bool get isGroup => groupId != null;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// 键盘弹出前（无键盘遮挡时）的窗口高度，用于计算画布缩放比例。
  double? _noKeyboardHeight;
  final _inputCtrl = TextEditingController();
  final List<ChatMessage> _messages = [];
  // 初始为 false：initState 里的首次 _loadMessages 需要能正常进入，
  // 否则 _loadMessages 开头的 `if (_loading) return;` 会拦截首次加载，
  // 导致历史消息永不加载、退出重进后消息消失。
  bool _loading = false;
  bool _sending = false;
  String? _error;
  int? _nextCursor;
  final _scrollCtrl = ScrollController();
  bool _hasMore = false;
  /// 群成员（导航栏成员头像 + 标题成员数），群聊进入时拉取
  List<GroupMember> _groupMembers = [];
  // ===== 语音消息（录音 / 播放） =====
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  StreamSubscription<void>? _playerCompleteSub;
  bool _recording = false;
  Timer? _recordTimer;
  int _recordSeconds = 0;
  String? _recordPath;
  int? _playingMessageId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    if (widget.isGroup) _loadGroupMeta();
    // 语音播放自然结束后清除播放中状态（手动停止由 _toggleVoicePlay 处理）。
    _playerCompleteSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingMessageId = null);
    });
  }

  Future<void> _loadGroupMeta() async {
    try {
      final members = await GroupService.instance.members(widget.groupId!);
      if (mounted) setState(() => _groupMembers = members);
    } catch (_) {
      // 成员信息拉取失败不阻塞聊天页
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.viewInsets.bottom == 0) {
      _noKeyboardHeight = mediaQuery.size.height;
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    _playerCompleteSub?.cancel();
    _player.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool earlier = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final cursor = earlier ? (_nextCursor ?? 0) : 0;
      if (widget.isGroup) {
        final result = await GroupService.instance.messages(widget.groupId!, cursor: cursor);
        if (!mounted) return;
        setState(() {
          if (earlier && result.items.isNotEmpty) {
            _messages.insertAll(0, result.items);
          } else if (!earlier) {
            _messages
              ..clear()
              ..addAll(result.items);
          }
          _nextCursor = result.nextCursor;
          _hasMore = result.nextCursor != null;
        });
      } else {
        final result = await ChatService.instance.messages(widget.conversationId!, cursor: cursor);
        if (!mounted) return;
        setState(() {
          if (earlier && result.items.isNotEmpty) {
            _messages.insertAll(0, result.items);
          } else if (!earlier) {
            _messages
              ..clear()
              ..addAll(result.items);
          }
          _nextCursor = result.nextCursor;
          _hasMore = result.nextCursor != null;
        });
      }
      if (!earlier) {
        // 标记已读
        if (widget.isGroup) {
          final last = _messages.isNotEmpty ? _messages.last.id : 0;
          GroupService.instance.markRead(widget.groupId!, last).catchError((_) {});
        } else {
          ChatService.instance.markRead(widget.conversationId!).catchError((_) {});
        }
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        // 列表为反向（reverse: true），滚动偏移 0 即底部（最新消息）。
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final msg = widget.isGroup
          ? await GroupService.instance.sendMessage(widget.groupId!, text)
          : await ChatService.instance.sendMessage(widget.conversationId!, text);
      if (mounted) {
        _inputCtrl.clear();
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ===== 语音消息：录音 → 上传 → 发送 =====
  Future<void> _toggleRecord() async {
    if (_recording) {
      await _stopRecordAndSend();
    } else {
      await _startRecord();
    }
  }

  Future<void> _startRecord() async {
    try {
      final ok = await _recorder.hasPermission();
      if (!ok) {
        if (mounted) showLiveSnack(context, '需要麦克风权限才能发送语音');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
      _recordPath = path;
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordSeconds++);
      });
      if (mounted) {
        setState(() {
          _recording = true;
          _recordSeconds = 0;
        });
      }
    } catch (e) {
      if (mounted) showLiveSnack(context, '录音启动失败：$e');
    }
  }

  Future<void> _stopRecordAndSend() async {
    _recordTimer?.cancel();
    final path = _recordPath;
    final seconds = _recordSeconds;
    if (mounted) {
      setState(() {
        _recording = false;
        _recordSeconds = 0;
      });
    }
    try {
      final finalPath = await _recorder.stop();
      final file = File(finalPath ?? path ?? '');
      if (seconds < 1 || !await file.exists()) {
        if (mounted && seconds < 1) showLiveSnack(context, '说话时间太短，请重试');
        return;
      }
      final bytes = await file.readAsBytes();
      final url = await UploadService.instance.uploadAudio(
        bytes,
        'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
        contentType: 'audio/mp4',
      );
      final content = jsonEncode({'url': url, 'duration': seconds});
      final msg = widget.isGroup
          ? await GroupService.instance.sendMessage(
              widget.groupId!,
              content,
              contentType: 'voice',
            )
          : await ChatService.instance.sendMessage(
              widget.conversationId!,
              content,
              contentType: 'voice',
            );
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } catch (e) {
      if (mounted) showLiveSnack(context, '发送语音失败：$e');
    } finally {
      _recordPath = null;
      try {
        final f = File(path ?? '');
        if (await f.exists()) await f.delete();
      } catch (_) {
        // 临时文件清理失败不影响发送
      }
    }
  }

  /// 点击语音气泡：播放 / 停止。
  Future<void> _toggleVoicePlay(ChatMessage msg) async {
    final voice = _VoiceData.tryParse(msg.content);
    if (voice == null || voice.url.isEmpty) {
      if (mounted) showLiveSnack(context, '语音数据无效');
      return;
    }
    try {
      if (_playingMessageId == msg.id) {
        await _player.stop();
        if (mounted) setState(() => _playingMessageId = null);
        return;
      }
      await _player.stop();
      await _player.play(UrlSource(ApiConfig.resolve(voice.url)));
      if (mounted) setState(() => _playingMessageId = msg.id);
    } catch (e) {
      if (mounted) {
        setState(() => _playingMessageId = null);
        showLiveSnack(context, '语音播放失败');
      }
    }
  }

  /// 长按消息气泡：弹出操作菜单（对齐 Pixso 36-聊天-长按气泡菜单）。
  Future<void> _showMessageMenu(ChatMessage msg, Offset globalPos) async {
    // 长按消息弹出操作菜单前先收起键盘，避免键盘遮挡菜单。
    FocusScope.of(context).unfocus();
    final overlaySize = MediaQuery.of(context).size;
    const menuW = 170.0;
    const menuH = 310.0;
    // 菜单位置：优先显示在气泡右侧，右侧放不下则靠左
    double left = globalPos.dx + 16;
    if (left + menuW > overlaySize.width) {
      left = globalPos.dx - menuW - 8;
    }
    double top = globalPos.dy - menuH / 2;
    if (top < 80) top = 80;
    if (top + menuH > overlaySize.height - 40) {
      top = overlaySize.height - menuH - 40;
    }

    final items = <PopupMenuEntry<String>>[
      for (final (key, label) in const [
        ('copy', '复制'),
        ('forward', '转发'),
        ('favorite', '收藏'),
        ('recall', '撤回'),
        ('delete', '删除'),
        ('multi', '多选'),
      ])
        PopupMenuItem<String>(
          value: key,
          height: 48,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: key == 'delete'
                  ? const Color(0xFFFF5A5A)
                  : Colors.white,
            ),
          ),
        ),
    ];
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, overlaySize.width - left - menuW, 0),
      items: items,
      color: const Color(0xE6141416),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
      shadowColor: Colors.black38,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: msg.content));
        if (mounted) showLiveSnack(context, '已复制');
      case 'forward':
        if (mounted) showLiveSnack(context, '转发功能敬请期待');
      case 'favorite':
        if (mounted) showLiveSnack(context, '收藏功能敬请期待');
      case 'recall':
        if (msg.senderId != AuthStore.instance.userId) {
          if (mounted) showLiveSnack(context, '仅能撤回自己发送的消息');
        } else {
          if (mounted) showLiveSnack(context, '撤回功能敬请期待');
        }
      case 'delete':
        await _deleteMessage(msg);
      case 'multi':
        if (mounted) showLiveSnack(context, '多选功能敬请期待');
    }
  }

  Future<void> _deleteMessage(ChatMessage msg) async {
    try {
      if (widget.isGroup) {
        await GroupService.instance.deleteMessage(widget.groupId!, msg.id);
      } else {
        await ChatService.instance.deleteMessage(widget.conversationId!, msg.id);
      }
      if (mounted) {
        setState(() => _messages.removeWhere((m) => m.id == msg.id));
        showLiveSnack(context, '已删除');
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _sendImage(String url) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final msg = widget.isGroup
          ? await GroupService.instance.sendMessage(
              widget.groupId!,
              url,
              contentType: 'image',
            )
          : await ChatService.instance.sendMessage(
              widget.conversationId!,
              url,
              contentType: 'image',
            );
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final picked = await ImagePicker().pickMultiImage(limit: 3);
      if (picked.isEmpty) return;
      for (final f in picked) {
        final bytes = await f.readAsBytes();
        final url = await UploadService.instance.uploadImage(
          bytes,
          f.name.isEmpty ? 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg' : f.name,
          folder: 'chat',
        );
        if (mounted) await _sendImage(url);
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } catch (e) {
      if (mounted) showLiveSnack(context, '选择图片失败：$e');
    }
  }

  void _showEmojiPanel() {
    const emojis = [
      '😀', '😂', '😍', '😭', '😡', '👍', '👏', '🎉',
      '❤️', '🎨', '🧩', '🌟', '✨', '🔥', '🙏', '😴',
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: LiveColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 8,
            shrinkWrap: true,
            children: emojis
                .map(
                  (e) => InkWell(
                    onTap: () {
                      _inputCtrl.text += e;
                      Navigator.of(context).pop();
                    },
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showAttachPanel() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: LiveColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachItem(
                icon: Icons.photo_library_outlined,
                label: '相册',
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImages();
                },
              ),
              _AttachItem(
                icon: Icons.photo_camera_outlined,
                label: '拍摄',
                onTap: () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) showLiveSnack(context, '拍摄功能敬请期待');
                  });
                },
              ),
              _AttachItem(
                icon: Icons.description_outlined,
                label: '文件',
                onTap: () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) showLiveSnack(context, '文件功能敬请期待');
                  });
                },
              ),
              _AttachItem(
                icon: Icons.person_outline,
                label: '名片',
                onTap: () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) showLiveSnack(context, '名片功能敬请期待');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = AuthStore.instance.userId;
    // 外层 LiveHost 用 FittedBox 把 440x956 画布缩放到屏幕，
    // 输入栏的 viewInsets 补偿需按缩放比例放大，才能在屏幕上
    // 恰好把输入框顶到键盘上沿。
    final mediaQuery = MediaQuery.of(context);
    final canvasHeight = _noKeyboardHeight ?? mediaQuery.size.height;
    final canvasScale = math.min(
      mediaQuery.size.width / 440,
      canvasHeight / 956,
    );
    return LivePage(
      // 单聊页：键盘弹出时页面不压缩，键盘覆盖页面下半部分，
      // 输入栏通过 viewInsets 补偿浮在键盘上方，消息列表保持原尺寸。
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          LiveAppBar(
            title: widget.isGroup
                ? (_groupMembers.isNotEmpty
                    ? '${widget.groupName} (${_groupMembers.length})'
                    : widget.groupName)
                : widget.peerName,
            actions: widget.isGroup
                ? [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _GroupNavAvatars(
                        members: _groupMembers,
                        onTap: () => LiveRoutes.pushId(
                          context,
                          RoutePaths.chatGroupSettings,
                          widget.groupId!,
                        ),
                      ),
                    ),
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: LiveColors.textPrimary),
                      onPressed: () => LiveRoutes.push(
                        context,
                        RoutePaths.chatInfo,
                        extra: {
                          'peerId': widget.peerId,
                          'peerName': widget.peerName,
                          'peerAvatar': widget.peerAvatar,
                          'conversationId': widget.conversationId ?? 0,
                        },
                      ),
                    ),
                  ],
          ),
          Expanded(
            child: _error != null && _messages.isEmpty
                ? ErrorView(message: _error!, onRetry: _loadMessages)
                : _messages.isEmpty
                    ? const EmptyView(text: '暂无消息，说点什么吧', icon: Icons.chat_bubble_outline)
                    : ListView.builder(
                        controller: _scrollCtrl,
                        // 聊天列表反向布局：索引 0 在底部（最新消息）。
                        // 键盘弹出 / 输入框多行变高时，列表底部保持锚定在
                        // 输入栏上沿，最新消息始终可见，不会被输入栏或键盘覆盖。
                        reverse: true,
                        padding: const EdgeInsets.all(18),
                        itemCount: _messages.length + (_hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          final total = _messages.length + (_hasMore ? 1 : 0);
                          // 反向列表里“加载更早消息”位于顶部（最后一个索引）。
                          if (_hasMore && i == total - 1) {
                            return Center(
                              child: TextButton(
                                onPressed: () => _loadMessages(earlier: true),
                                child: const Text('加载更早消息',
                                    style: TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
                              ),
                            );
                          }
                          // 反向索引映射：列表顺序 i（0=最新）→ 数组下标 orig。
                          final orig = _messages.length - 1 - i;
                          final msg = _messages[orig];
                          final isMine = msg.senderId == me;
                          // 群聊：系统消息居中展示；普通消息按天插入时间分隔
                          if (msg.contentType == 'system') {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  msg.content,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: LiveColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }
                          final showTime = widget.isGroup &&
                              (orig == 0 ||
                                  !_sameDay(
                                    _messages[orig - 1].createdAt,
                                    msg.createdAt,
                                  ));
                          return Column(
                            children: [
                              if (showTime)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 2),
                                  child: Center(
                                    child: Text(
                                      fmtTime(msg.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: LiveColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                              _Bubble(
                                message: msg,
                                isMine: isMine,
                                isGroup: widget.isGroup,
                                showAvatar: widget.isGroup && !isMine,
                                isPlaying: _playingMessageId == msg.id,
                                onVoiceTap: () => _toggleVoicePlay(msg),
                                onLongPress: (globalPos) =>
                                    _showMessageMenu(msg, globalPos),
                              ),
                            ],
                          );
                        },
                      ),
          ),
          // 键盘弹出时输入栏跟随键盘上移（viewInsets 补偿），
          // 避免键盘盖住输入框。
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom / canvasScale,
            ),
            child: SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: LiveColors.bg,
                  border: Border(top: BorderSide(color: LiveColors.divider)),
                ),
                child: widget.isGroup
                    // 群聊输入栏：对齐 Pixso 23-群聊（语音 / 胶囊输入 / 表情 / 发送）
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: _toggleRecord,
                              icon: Icon(
                                _recording
                                    ? Icons.stop_circle_outlined
                                    : Icons.mic_none,
                                color: _recording
                                    ? LiveColors.danger
                                    : LiveColors.textSecondary,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _recording
                                  ? _RecordingChip(seconds: _recordSeconds)
                                  : Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 47),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: LiveColors.inputBg,
                                        borderRadius: BorderRadius.circular(21),
                                      ),
                                      child: TextField(
                                        controller: _inputCtrl,
                                        minLines: 1,
                                        maxLines: 4,
                                        style: const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          hintText: '@ 提及成员…',
                                          hintStyle: TextStyle(
                                              fontSize: 13,
                                              color: LiveColors.textTertiary),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: _showEmojiPanel,
                              icon: const Icon(Icons.emoji_emotions_outlined, color: LiveColors.textSecondary, size: 25),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _sending ? null : _send,
                              child: Container(
                                width: 62,
                                height: 43,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF333333), Color(0xFF141414)],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: _sending
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text(
                                        '发送',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _toggleRecord,
                              icon: Icon(
                                _recording
                                    ? Icons.stop_circle_outlined
                                    : Icons.mic_none,
                                color: _recording
                                    ? LiveColors.danger
                                    : LiveColors.textSecondary,
                                size: 22,
                              ),
                            ),
                            IconButton(
                              onPressed: _showEmojiPanel,
                              icon: const Icon(Icons.emoji_emotions_outlined, color: LiveColors.textSecondary, size: 22),
                            ),
                            Expanded(
                              child: _recording
                                  ? _RecordingChip(seconds: _recordSeconds)
                                  : TextField(
                                      controller: _inputCtrl,
                                      minLines: 1,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: '发送消息…',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                        isDense: true,
                                      ),
                                    ),
                            ),
                            IconButton(
                              onPressed: _showAttachPanel,
                              icon: const Icon(Icons.add_circle_outline, color: LiveColors.textSecondary, size: 24),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _sending ? null : _send,
                              icon: _sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: LiveColors.brand),
                                    )
                                  : const Icon(Icons.send, color: LiveColors.brand),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.isMine,
    required this.isGroup,
    required this.showAvatar,
    required this.onLongPress,
    this.isPlaying = false,
    this.onVoiceTap,
  });

  final ChatMessage message;
  final bool isMine;
  final bool isGroup;
  final bool showAvatar;
  final void Function(Offset globalPosition) onLongPress;
  final bool isPlaying;
  final VoidCallback? onVoiceTap;

  @override
  Widget build(BuildContext context) {
    final isImage = message.contentType == 'image';
    final isVoice = message.contentType == 'voice';
    final isVideo = message.contentType == 'video';
    final bubbleColor =
        isMine ? LiveColors.brand : LiveColors.card;
    final textColor = isMine ? Colors.white : LiveColors.textPrimary;

    Widget bubbleContent;
    if (isImage) {
      bubbleContent = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 150,
          height: 110,
          child: GestureDetector(
            onTap: () => LiveRoutes.push(
              context,
              RoutePaths.viewer,
              extra: message.content,
            ),
            child: NetImage(url: message.content),
          ),
        ),
      );
    } else if (isVoice) {
      final voice = _VoiceData.tryParse(message.content);
      bubbleContent = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onVoiceTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.graphic_eq : Icons.mic,
              size: 18,
              color: textColor,
            ),
            const SizedBox(width: 8),
            Text(
              isPlaying
                  ? '播放中…'
                  : '语音 ${voice?.duration ?? 0}″',
              style: TextStyle(fontSize: 13, color: textColor),
            ),
          ],
        ),
      );
    } else if (isVideo) {
      bubbleContent = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline, size: 18, color: Colors.white),
          SizedBox(width: 6),
          Text('视频消息', style: TextStyle(fontSize: 13, color: Colors.white)),
        ],
      );
    } else {
      bubbleContent = Text(
        message.isRecalled ? '消息已撤回' : message.content,
        style: TextStyle(
          fontSize: 14,
          color: message.isRecalled ? LiveColors.textTertiary : textColor,
          height: 1.4,
        ),
      );
    }

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.62),
      padding: isGroup
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 11)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: message.isRecalled
            ? LiveColors.card
            : (isGroup ? (isMine ? null : LiveColors.card) : bubbleColor),
        gradient:
            isGroup && !message.isRecalled && isMine
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF333333), Color(0xFF141414)],
                  )
                : null,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isGroup ? 16 : 14),
          topRight: Radius.circular(isGroup ? 16 : 14),
          bottomLeft: Radius.circular(isMine ? (isGroup ? 4 : 14) : 16),
          bottomRight: Radius.circular(isMine ? 16 : (isGroup ? 4 : 14)),
        ),
      ),
      child: bubbleContent,
    );

    return GestureDetector(
      // 长按消息气泡呼出操作菜单（复制/转发/收藏/撤回/删除/多选）
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) =>
          onLongPress(details.globalPosition),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine && showAvatar)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: isGroup
                    ? _GradientAvatar(
                        name: message.author?.nickname ?? '',
                        size: 36,
                      )
                    : Avatar(
                        url: message.author?.avatar ?? '',
                        name: message.author?.nickname ?? '',
                        size: 36,
                      ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                if (isGroup && !isMine && showAvatar && message.author != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      '@${message.author!.displayName}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: LiveColors.textSecondary,
                      ),
                    ),
                  ),
                if (message.replyPreview != null &&
                    message.replyPreview!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Colors.white12
                          : LiveColors.divider,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      message.replyPreview!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMine
                            ? Colors.white70
                            : LiveColors.textTertiary,
                      ),
                    ),
                  ),
                bubble,
                // 单聊保留时间/已读小字；群聊按设计稿仅以居中时间分隔展示
                if (!isGroup) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fmtTime(message.createdAt),
                        style: const TextStyle(fontSize: 10, color: LiveColors.textTertiary),
                      ),
                      if (isMine && message.readAt != null) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '已读',
                          style: TextStyle(fontSize: 10, color: LiveColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// 群聊导航栏右侧：最多 3 个成员小头像（对齐 Pixso 23-群聊）。
class _GroupNavAvatars extends StatelessWidget {
  const _GroupNavAvatars({required this.members, required this.onTap});

  final List<GroupMember> members;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var shown = members.take(3).toList();
    if (shown.isEmpty) {
      shown = [const GroupMember(id: 0, userId: 0, nickname: '群')];
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              _GradientAvatar(name: shown[i].nickname, size: 25),
            ],
          ],
        ),
      ),
    );
  }
}

/// 渐变圆形头像（白字首字，对齐设计稿 div.av 系列渐变）。
class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar({required this.name, required this.size});

  final String name;
  final double size;

  static const _palettes = [
    [Color(0xFF36D1DC), Color(0xFF5B86E5)],
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    [Color(0xFF667EEA), Color(0xFF764EA2)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
  ];

  @override
  Widget build(BuildContext context) {
    final initial =
        name.trim().isNotEmpty ? name.characters.first : '群';
    final palette = _palettes[
        (name.hashCode % _palettes.length).abs() % _palettes.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.44),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette,
          ),
        ),
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * (size <= 28 ? 0.36 : 0.34),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 两条消息是否同一天（用于群聊居中时间分隔）。
bool _sameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 长按消息气泡操作菜单（对齐 Pixso 36-聊天-长按气泡菜单）：
/// 深色半透明圆角面板，包含 复制 / 转发 / 收藏 / 撤回 / 删除 / 多选。
class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  List<GroupMember> _members = [];
  String _groupName = '';
  bool _loading = true;
  String? _error;
  bool _busy = false;
  bool _muted = false;
  bool _pinned = false;
  bool _isOwner = false;
  bool _isAdmin = false;

  /// 仅群主 / 管理员可进入「群成员管理」
  bool get _canManage => _isOwner || _isAdmin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        GroupService.instance.members(widget.groupId),
        GroupService.instance.mine(),
      ]);
      final members = results[0] as List<GroupMember>;
      final groups = (results[1] as Page<GroupItem>).items;
      final group = groups.where((g) => g.id == widget.groupId).firstOrNull;
      final me = AuthStore.instance.userId;
      if (mounted) {
        setState(() {
          _members = members;
          _groupName = group?.name ?? '';
          _isOwner = group?.ownerId == me ||
              members.any((m) => m.role == 'owner' && m.userId == me);
          _isAdmin = members.any((m) => m.role == 'admin' && m.userId == me);
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _kick(GroupMember m) async {
    final ok = await showMemberActionDialog(
      context,
      member: m,
      setAdmin: false,
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await GroupService.instance.kick(widget.groupId, m.userId);
      if (mounted) {
        showLiveSnack(context, '已移出');
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setRole(GroupMember m, String role) async {
    if (!_isOwner || m.role == 'owner') return;
    if (role == 'admin') {
      final ok = await showMemberActionDialog(
        context,
        member: m,
        setAdmin: true,
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await GroupService.instance.setRole(widget.groupId, m.userId, role);
      if (mounted) {
        showLiveSnack(
          context,
          role == 'admin' ? '已设为管理员' : '已取消管理员',
        );
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 群聊设置页长按成员：设为管理员 / 取消管理员 / 移出群聊（对齐 Pixso）。
  Future<void> _showMemberMenu(GroupMember m) async {
    if (!_canManage ||
        m.role == 'owner' ||
        m.userId == AuthStore.instance.userId) {
      return;
    }
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: LiveColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Text(
                m.nickname,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Divider(height: 1, color: LiveColors.divider),
              if (_isOwner && m.role != 'admin')
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: LiveColors.textPrimary,
                  ),
                  title: const Text(
                    '设为管理员',
                    style: TextStyle(fontSize: 15, color: LiveColors.textPrimary),
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'set_admin'),
                ),
              if (_isOwner && m.role == 'admin')
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: LiveColors.textPrimary,
                  ),
                  title: const Text(
                    '取消管理员',
                    style: TextStyle(fontSize: 15, color: LiveColors.textPrimary),
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'unset_admin'),
                ),
              ListTile(
                leading: const Icon(
                  Icons.person_remove_outlined,
                  color: LiveColors.danger,
                ),
                title: const Text(
                  '移出群聊',
                  style: TextStyle(fontSize: 15, color: LiveColors.danger),
                ),
                onTap: () => Navigator.pop(sheetContext, 'kick'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    // 等弹层完全退场后再执行后续操作（可能弹确认框），
    // 避免退出中的 route 与新 route 同帧共享 InheritedElement。
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    switch (action) {
      case 'set_admin':
        await _setRole(m, 'admin');
        break;
      case 'unset_admin':
        await _setRole(m, 'member');
        break;
      case 'kick':
        await _kick(m);
        break;
    }
  }

  Future<void> _leaveOrDissolve() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('退出群聊'),
        content: const Text('确定要退出该群聊吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('退出')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await GroupService.instance.leave(widget.groupId);
      if (mounted) {
        showLiveSnack(context, '已退出群聊');
        // 等确认弹窗完全退场后再导航，避免同一帧内弹层与新 route
        // 叠加触发 InheritedElement 依赖残留断言（_dependents.isEmpty）。
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        LiveRoutes.switchTab(context, 3);
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addMembers() async {
    try {
      final following = await FollowService.instance.following();
      if (!mounted) return;
      final currentIds = _members.map((m) => m.userId).toSet();
      final candidates = following.where((u) => !currentIds.contains(u.id)).toList();
      if (candidates.isEmpty) {
        showLiveSnack(context, '暂无可邀请的好友');
        return;
      }
      final selected = <int>{};
      await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('邀请好友'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: candidates.map((u) {
                  return CheckboxListTile(
                    value: selected.contains(u.id),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        selected.add(u.id);
                      } else {
                        selected.remove(u.id);
                      }
                    }),
                    title: Text(u.nickname, style: const TextStyle(fontSize: 14)),
                    dense: true,
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              TextButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('邀请'),
              ),
            ],
          ),
        ),
      );
      if (selected.isNotEmpty) {
        await GroupService.instance.addMembers(widget.groupId, selected.toList());
        if (mounted) {
          showLiveSnack(context, '邀请成功');
          _load();
        }
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _rename() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('修改群名称'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '请输入新的群名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    // 等对话框退场动画结束后再释放控制器，避免 TextField 退场时
    // 使用已销毁的 controller 引发构建/卸载期异常。
    Future<void>.delayed(const Duration(milliseconds: 250), ctrl.dispose);
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await GroupService.instance.rename(widget.groupId, name);
      if (mounted) showLiveSnack(context, '群名称已修改');
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _dissolve() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('解散群聊'),
        content: const Text('解散后所有成员将无法查看该群聊，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('解散'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await GroupService.instance.dissolve(widget.groupId);
      if (mounted) {
        showLiveSnack(context, '群聊已解散');
        // 等确认弹窗完全退场后再导航，避免同一帧内弹层与新 route
        // 叠加触发 InheritedElement 依赖残留断言（_dependents.isEmpty）。
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        LiveRoutes.switchTab(context, 3);
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          const LiveAppBar(title: '群聊设置'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          // 群头像 + 群名 + 群公告（对齐设计稿）
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              // 渐变圆环头像
                              Container(
                                width: 81,
                                height: 81,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF333333), Color(0xFF141414)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(2),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '群',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _groupName.isEmpty ? '手作同好会' : _groupName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: LiveColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '群公告：每周三拼豆主题日，欢迎分享作品 🎨',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: LiveColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 群成员标题 + 管理
                          Row(
                            children: [
                              Text(
                                '群成员 ${_members.length}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: LiveColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              if (_canManage)
                                InkWell(
                                  onTap: () => LiveRoutes.pushId(
                                    context,
                                    RoutePaths.chatGroupManage,
                                    widget.groupId,
                                  ),
                                  child: const Text(
                                    '管理 ›',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: LiveColors.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 成员横向单行（对齐 Pixso：固定宽度单元 + 末尾添加按钮）
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var i = 0; i < _members.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  _GroupMemberCell(
                                    member: _members[i],
                                    isOwner: _members[i].role == 'owner',
                                    isAdmin: _members[i].role == 'admin',
                                    onLongPress:
                                        (_canManage &&
                                                _members[i].role != 'owner' &&
                                                _members[i].userId !=
                                                    AuthStore.instance.userId)
                                            ? () => _showMemberMenu(_members[i])
                                            : null,
                                  ),
                                ],
                                const SizedBox(width: 8),
                                _GroupMemberAdd(onTap: _addMembers),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 设置卡片
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: LiveColors.card,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _GroupOption(
                                  label: '修改群名称',
                                  onTap: _rename,
                                ),
                                const Divider(height: 1, color: LiveColors.divider),
                                _GroupOption(
                                  label: '群公告',
                                  onTap: () => showLiveSnack(context, '群公告编辑敬请期待'),
                                ),
                                const Divider(height: 1, color: LiveColors.divider),
                                _GroupSwitchOption(
                                  label: '消息免打扰',
                                  value: _muted,
                                  onChanged: (v) => setState(() => _muted = v),
                                ),
                                const Divider(height: 1, color: LiveColors.divider),
                                _GroupSwitchOption(
                                  label: '置顶聊天',
                                  value: _pinned,
                                  onChanged: (v) => setState(() => _pinned = v),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // 退出 / 解散卡片（浅红底红字）
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 19),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7F7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: _busy
                                  ? null
                                  : _isOwner
                                      ? _dissolve
                                      : _leaveOrDissolve,
                              child: Center(
                                child: _busy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: LiveColors.danger,
                                        ),
                                      )
                                    : Text(
                                        _isOwner ? '解散群聊' : '退出群聊',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: LiveColors.danger,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              '群主可解散群聊',
                              style: TextStyle(
                                fontSize: 11,
                                color: LiveColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

/// 群成员横向单元（对齐设计稿：渐变圆头像 + 名字 + 角色标签，长按移出）。
class _GroupMemberCell extends StatelessWidget {
  const _GroupMemberCell({
    required this.member,
    required this.isOwner,
    required this.isAdmin,
    this.onLongPress,
  });

  final GroupMember member;
  final bool isOwner;
  final bool isAdmin;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 67,
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                member.nickname.isEmpty ? '友' : member.nickname.characters.first,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              member.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: LiveColors.textPrimary),
            ),
            const SizedBox(height: 3),
            if (isOwner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF333333), Color(0xFF141414)],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Text(
                  '群主',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            else if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: LiveColors.card,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Text(
                  '管理员',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: LiveColors.textSecondary,
                  ),
                ),
              )
            else
              const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

/// 群成员末尾「+」添加入口（对齐设计稿 margin_wrapper240）。
class _GroupMemberAdd extends StatelessWidget {
  const _GroupMemberAdd({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 67,
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: LiveColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: LiveColors.divider),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 20, color: LiveColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              '添加',
              style: TextStyle(fontSize: 11, color: LiveColors.textSecondary),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _GroupOption extends StatelessWidget {
  const _GroupOption({required this.label, this.value, required this.onTap});

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
            ),
            const Spacer(),
            if (value != null)
              Text(value!, style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
            const Icon(Icons.chevron_right, size: 18, color: LiveColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _GroupSwitchOption extends StatelessWidget {
  const _GroupSwitchOption({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF141414),
          ),
        ],
      ),
    );
  }
}

/// 群成员管理页（对齐 Pixso 64-群成员管理）：仅群主 / 管理员可进入。
/// 群主可见「群主管理」（改群名 / 群公告 / 群主转让 / 解散群聊）；
/// 群主与管理员共同能力为成员管理（添加 / 删除成员、长按成员单独管理）。
class GroupMemberManageScreen extends StatefulWidget {
  const GroupMemberManageScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupMemberManageScreen> createState() =>
      _GroupMemberManageScreenState();
}

class _GroupMemberManageScreenState extends State<GroupMemberManageScreen> {
  List<GroupMember> _members = [];
  String _groupName = '';
  bool _loading = true;
  bool _busy = false;
  String? _error;
  bool _isOwner = false;
  bool _isAdmin = false;
  int? _meId;

  bool get _canManage => _isOwner || _isAdmin;

  @override
  void initState() {
    super.initState();
    _meId = AuthStore.instance.userId;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        GroupService.instance.members(widget.groupId),
        GroupService.instance.mine(),
      ]);
      final members = results[0] as List<GroupMember>;
      final groups = (results[1] as Page<GroupItem>).items;
      final group = groups.where((g) => g.id == widget.groupId).firstOrNull;
      if (mounted) {
        setState(() {
          _members = members;
          _groupName = group?.name ?? '';
          _isOwner = group?.ownerId == _meId ||
              members.any((m) => m.role == 'owner' && m.userId == _meId);
          _isAdmin = members.any((m) => m.role == 'admin' && m.userId == _meId);
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addMembers() async {
    try {
      final following = await FollowService.instance.following();
      if (!mounted) return;
      final currentIds = _members.map((m) => m.userId).toSet();
      final candidates =
          following.where((u) => !currentIds.contains(u.id)).toList();
      if (candidates.isEmpty) {
        showLiveSnack(context, '暂无可邀请的好友');
        return;
      }
      final selected = <int>{};
      await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('邀请好友'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: candidates.map((u) {
                  return CheckboxListTile(
                    value: selected.contains(u.id),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        selected.add(u.id);
                      } else {
                        selected.remove(u.id);
                      }
                    }),
                    title: Text(u.nickname, style: const TextStyle(fontSize: 14)),
                    dense: true,
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('邀请'),
              ),
            ],
          ),
        ),
      );
      if (selected.isNotEmpty && mounted) {
        await GroupService.instance.addMembers(
          widget.groupId,
          selected.toList(),
        );
        if (mounted) {
          showLiveSnack(context, '邀请成功');
          _load();
        }
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _kick(GroupMember m) async {
    final ok = await showMemberActionDialog(
      context,
      member: m,
      setAdmin: false,
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await GroupService.instance.kick(widget.groupId, m.userId);
      if (mounted) {
        showLiveSnack(context, '已移出');
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteMembers() async {
    final removable = _members
        .where((m) => m.userId != _meId && m.role != 'owner')
        .where((m) => !(_isAdmin && m.role == 'admin'))
        .toList();
    if (removable.isEmpty) {
      showLiveSnack(context, '暂无可删除的成员');
      return;
    }
    final selected = <int>{};
    final ok = await showModalBottomSheet<List<int>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: LiveColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '移出成员',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: StatefulBuilder(
                  builder: (context, setSheet) => ListView(
                    shrinkWrap: true,
                    children: [
                      for (final m in removable)
                        CheckboxListTile(
                          value: selected.contains(m.userId),
                          onChanged: (v) => setSheet(() {
                            if (v == true) {
                              selected.add(m.userId);
                            } else {
                              selected.remove(m.userId);
                            }
                          }),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            m.nickname,
                            style: const TextStyle(fontSize: 14),
                          ),
                          dense: true,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: selected.isEmpty ? '请选择成员' : '移出（${selected.length}）',
                onTap: selected.isEmpty
                    ? null
                    : () => Navigator.pop(sheetContext, selected.toList()),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == null || ok.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      for (final uid in ok) {
        await GroupService.instance.kick(widget.groupId, uid);
      }
      if (mounted) {
        showLiveSnack(context, '已移出 ${ok.length} 名成员');
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rename() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('修改群名称'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '请输入新的群名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    // 等对话框退场动画结束后再释放控制器，避免 TextField 退场时
    // 使用已销毁的 controller 引发构建/卸载期异常。
    Future<void>.delayed(const Duration(milliseconds: 250), ctrl.dispose);
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await GroupService.instance.rename(widget.groupId, name);
      if (mounted) {
        showLiveSnack(context, '群名称已修改');
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _setRole(GroupMember m, String role) async {
    if (!_isOwner || m.role == 'owner') return;
    if (role == 'admin') {
      final ok = await showMemberActionDialog(
        context,
        member: m,
        setAdmin: true,
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await GroupService.instance.setRole(widget.groupId, m.userId, role);
      if (mounted) {
        showLiveSnack(
          context,
          role == 'admin' ? '已设为管理员' : '已取消管理员',
        );
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _transferOwner() async {
    final candidates =
        _members.where((m) => m.userId != _meId && m.role != 'owner').toList();
    if (candidates.isEmpty) {
      showLiveSnack(context, '暂无可转让的成员');
      return;
    }
    final target = await showModalBottomSheet<GroupMember>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: LiveColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '选择新群主',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              for (final m in candidates)
                ListTile(
                  leading: Avatar(url: m.avatar, name: m.nickname, size: 36),
                  title: Text(
                    m.nickname,
                    style: const TextStyle(fontSize: 15),
                  ),
                  onTap: () => Navigator.pop(sheetContext, m),
                ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
    if (target == null || !mounted) return;
    // 等弹层完全退场（默认 250ms 退场动画）后再弹确认框，避免退出中的
    // route 与新 route 同帧共享 InheritedElement，触发 _dependents.isEmpty。
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('群主转让'),
        content: Text('确定将群主转让给 ${target.nickname} 吗？转让后你将变为普通成员。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('转让'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await GroupService.instance.transferOwner(widget.groupId, target.userId);
      if (mounted) {
        showLiveSnack(context, '群主已转让给 ${target.nickname}');
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _dissolve() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('解散群聊'),
        content: const Text('解散后所有成员将无法查看该群聊，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('解散'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await GroupService.instance.dissolve(widget.groupId);
      if (mounted) {
        showLiveSnack(context, '群聊已解散');
        // 等确认弹窗完全退场后再导航，避免同一帧内弹层与新 route
        // 叠加触发 InheritedElement 依赖残留断言（_dependents.isEmpty）。
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        LiveRoutes.switchTab(context, 3);
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showMemberMenu(GroupMember m) async {
    if (!_canManage || m.role == 'owner' || m.userId == _meId) return;
    // 先关闭弹层并返回操作项，await 后再执行后续操作；
    // 避免「同帧内 pop + 立刻弹确认框 / setState」触发
    // InheritedElement 依赖残留断言（_dependents.isEmpty）。
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: LiveColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Text(
                m.nickname,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Divider(height: 1, color: LiveColors.divider),
              if (_isOwner && m.role != 'admin')
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: LiveColors.textPrimary,
                  ),
                  title: const Text(
                    '设为管理员',
                    style: TextStyle(fontSize: 15, color: LiveColors.textPrimary),
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'set_admin'),
                ),
              if (_isOwner && m.role == 'admin')
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: LiveColors.textPrimary,
                  ),
                  title: const Text(
                    '取消管理员',
                    style: TextStyle(fontSize: 15, color: LiveColors.textPrimary),
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'unset_admin'),
                ),
              ListTile(
                leading: const Icon(
                  Icons.person_remove_outlined,
                  color: LiveColors.danger,
                ),
                title: const Text(
                  '移出群聊',
                  style: TextStyle(fontSize: 15, color: LiveColors.danger),
                ),
                onTap: () => Navigator.pop(sheetContext, 'kick'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    // 等弹层完全退场（默认 250ms 退场动画）后再执行后续操作（可能弹确认框 /
    // 提示），避免退出中的 route 与新 route 同帧共享 InheritedElement，
    // 触发 _dependents.isEmpty 断言。
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    switch (action) {
      case 'set_admin':
        await _setRole(m, 'admin');
      case 'unset_admin':
        await _setRole(m, 'member');
      case 'kick':
        await _kick(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          LiveAppBar(
            title: '群成员管理',
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: Text(
                    '${_members.length} 人',
                    style: const TextStyle(
                      fontSize: 13,
                      color: LiveColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : !_canManage
                        ? const EmptyView(
                            text: '仅群主和管理员可管理群成员',
                            icon: Icons.lock_outline,
                          )
                        : ListView(
                            padding: const EdgeInsets.all(18),
                            children: [
                              // 群信息卡（头像 + 群名 + 群公告 + 修改）
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: LiveColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const _GroupAvatarRing(
                                      size: 48,
                                      fontSize: 16,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _groupName.isEmpty
                                                ? '手作同好会'
                                                : _groupName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: LiveColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            '群公告：每周三拼豆主题日，欢迎分享作品 🎨',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: LiveColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _rename,
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: LiveColors.card,
                                          border: Border.all(
                                            color: LiveColors.divider,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Text(
                                          '修改',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: LiveColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Text(
                                    '群成员 ${_members.length}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: LiveColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    '长按成员可单独管理',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: LiveColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: LiveColors.bg,
                                  border: Border.all(
                                    color: const Color(0xFFEFEFEF),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 12,
                                  children: [
                                    for (final m in _members)
                                      _GroupMemberCell(
                                        member: m,
                                        isOwner: m.role == 'owner',
                                        isAdmin: m.role == 'admin',
                                        onLongPress: () =>
                                            _showMemberMenu(m),
                                      ),
                                    _GroupMemberAdd(onTap: _addMembers),
                                    _GroupMemberDelete(onTap: _deleteMembers),
                                  ],
                                ),
                              ),
                              if (_isOwner) ...[
                                const SizedBox(height: 18),
                                const Text(
                                  '群主管理',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: LiveColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: LiveColors.card,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      _GroupManageOption(
                                        icon: Icons.edit_outlined,
                                        label: '修改群名称',
                                        onTap: _rename,
                                      ),
                                      const Divider(
                                        height: 1,
                                        color: LiveColors.divider,
                                      ),
                                      _GroupManageOption(
                                        icon: Icons.notes_outlined,
                                        label: '群公告',
                                        onTap: () => showLiveSnack(
                                          context,
                                          '群公告编辑敬请期待',
                                        ),
                                      ),
                                      const Divider(
                                        height: 1,
                                        color: LiveColors.divider,
                                      ),
                                      _GroupManageOption(
                                        icon: Icons.group_outlined,
                                        label: '群主转让',
                                        onTap: _transferOwner,
                                      ),
                                      const Divider(
                                        height: 1,
                                        color: LiveColors.divider,
                                      ),
                                      _GroupManageOption(
                                        icon: Icons.delete_outline,
                                        label: '解散群聊',
                                        danger: true,
                                        onTap: _dissolve,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Center(
                                child: Text(
                                  _isOwner
                                      ? '群主可添加 / 删除成员、转让群主或解散群聊'
                                      : '管理员可添加 / 删除成员',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: LiveColors.textTertiary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}

/// 群成员管理页「删除成员」入口（红色圆形垃圾桶，对齐设计稿 64）。
class _GroupMemberDelete extends StatelessWidget {
  const _GroupMemberDelete({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 67,
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.delete_outline,
                size: 20,
                color: LiveColors.danger,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '删除',
              style: TextStyle(fontSize: 11, color: LiveColors.danger),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

/// 群主管理行（图标 + 文案 + 右侧箭头，危险项红色，对齐设计稿 64）。
class _GroupManageOption extends StatelessWidget {
  const _GroupManageOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? LiveColors.danger : LiveColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: LiveColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 群头像圆环（对齐设计稿：墨色描边 + 白色内圈 + 渐变群字）。
class _GroupAvatarRing extends StatelessWidget {
  const _GroupAvatarRing({required this.size, required this.fontSize});

  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF333333), Color(0xFF141414)],
        ),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '群',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _phoneCtrl = TextEditingController();
  List<User> _results = [];
  List<FollowUser> _following = [];
  final Set<int> _selectedGroup = {};
  String _tab = 'phone'; // phone / following
  bool _searching = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    setState(() => _searching = true);
    try {
      final users = await UserService.instance.searchByPhone(phone);
      if (mounted) setState(() => _results = users);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _openChat(User u) async {
    try {
      final conv = await ChatService.instance.createConversation(u.id);
      if (!mounted) return;
      LiveRoutes.push(
        context,
        RoutePaths.chatDetail,
        extra: {
          'conversationId': conv.id,
          'peerId': u.id,
          'peerName': u.displayName,
          'peerAvatar': u.avatar,
        },
      );
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _loadFollowing() async {
    try {
      final list = await FollowService.instance.following();
      if (mounted) setState(() => _following = list);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _createGroup() async {
    if (_selectedGroup.isEmpty) {
      showLiveSnack(context, '请至少选择 1 位好友');
      return;
    }
    try {
      final group = await GroupService.instance.create(
        '手作群聊（${_selectedGroup.length + 1} 人）',
        _selectedGroup.toList(),
      );
      if (!mounted) return;
      LiveRoutes.push(
        context,
        RoutePaths.chatDetail,
        extra: {'groupId': group.id, 'groupName': group.name},
      );
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          const LiveAppBar(title: '添加好友'),
          // 顶部分段器：手机号搜索 / 我的关注（对齐设计稿 25-添加好友）
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: LiveColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  for (final t in [
                    ('phone', '手机号搜索'),
                    ('following', '我的关注'),
                  ])
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 38,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _tab == t.$1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: _tab == t.$1
                              ? const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() => _tab = t.$1);
                            if (t.$1 == 'following') _loadFollowing();
                          },
                          borderRadius: BorderRadius.circular(17),
                          child: Center(
                            child: Text(
                              t.$2,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _tab == t.$1 ? FontWeight.w600 : FontWeight.w400,
                                color: _tab == t.$1
                                    ? LiveColors.textPrimary
                                    : LiveColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 手机号搜索 Tab：搜索框 + 结果卡片
          if (_tab == 'phone') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
              child: Container(
                height: 59,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: LiveColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: LiveColors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '输入对方手机号',
                          hintStyle: TextStyle(fontSize: 15, color: LiveColors.textTertiary),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 15),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    InkWell(
                      onTap: _searching ? null : _search,
                      child: _searching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: LiveColors.brand),
                            )
                          : const Text(
                              '搜索',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: LiveColors.textPrimary,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _results.isEmpty
                  ? const EmptyView(text: '输入手机号搜索好友', icon: Icons.person_search_outlined)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: LiveColors.bg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              for (var i = 0; i < _results.length; i++) ...[
                                _SearchResultRow(
                                  user: _results[i],
                                  onTap: () => _openChat(_results[i]),
                                ),
                                if (i != _results.length - 1)
                                  const Divider(
                                    height: 1,
                                    indent: 62,
                                    color: LiveColors.divider,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
          // 发起群聊区块（对齐设计稿：标题 + 勾选好友列表 + 创建按钮）
          if (_tab == 'following') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
              child: Row(
                children: [
                  const Text(
                    '发起群聊',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '勾选好友 ›',
                    style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _following.isEmpty
                  ? const EmptyView(text: '还没有关注任何人', icon: Icons.person_outline)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: LiveColors.bg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              for (var i = 0; i < _following.length; i++) ...[
                                _GroupMemberRow(
                                  user: _following[i],
                                  selected: _selectedGroup.contains(_following[i].id),
                                  onTap: () {
                                    setState(() {
                                      if (!_selectedGroup.add(_following[i].id)) {
                                        _selectedGroup.remove(_following[i].id);
                                      }
                                    });
                                  },
                                ),
                                if (i != _following.length - 1)
                                  const Divider(
                                    height: 1,
                                    indent: 62,
                                    color: LiveColors.divider,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
          // 底部创建群聊按钮（对齐设计稿：黑底白字圆角 16）
          if (_tab == 'following')
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                child: PrimaryButton(
                  label: '创建群聊（${_selectedGroup.length + 1} 人）',
                  color: LiveColors.brand,
                  textColor: Colors.white,
                  borderRadius: 16,
                  onTap: _createGroup,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 手机号搜索结果行（对齐设计稿：头像 + 名称/副标题 + 「添加 / 已添加」按钮）。
class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Avatar(url: user.avatar, name: user.displayName, size: 45),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.phone} · ${user.location.isEmpty ? '未填地区' : user.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: LiveColors.brand,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                '添加',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            ],
          ),
        ),
    );
  }
}

/// 发起群聊勾选好友行（对齐设计稿：头像 + 名称/已选状态 + 单选圈）。
class _GroupMemberRow extends StatelessWidget {
  const _GroupMemberRow({
    required this.user,
    required this.selected,
    required this.onTap,
  });

  final FollowUser user;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Avatar(url: user.avatar, name: user.nickname, size: 45),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selected ? '已选择' : '未选择',
                    style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? LiveColors.brand : LiveColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: LiveColors.brand,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 51-单聊设置（聊天信息）。
class ChatInfoScreen extends StatelessWidget {
  const ChatInfoScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.peerAvatar,
    required this.conversationId,
  });

  final int peerId;
  final String peerName;
  final String peerAvatar;
  final int conversationId;

  Future<void> _deleteConversation(BuildContext context) async {
    try {
      await ChatService.instance.deleteConversation(conversationId);
      if (context.mounted) {
        // 提示先于导航插入顶层 Overlay，随后一次性回到会话列表。
        // 不要在同一帧连续 pop 两个 route（聊天信息 + 单聊），
        // 否则会触发 InheritedElement 依赖残留断言（_dependents.isEmpty）。
        showLiveSnack(context, '会话已删除');
        // 等退场中的路由（单聊 + 聊天信息）稳定后再切回 Shell Tab，
        // 避免外层路由与 Shell 页面在过渡期同时携带相同 page key，
        // 触发 '!keyReservation.contains(key)' 断言（flutter/flutter#140586）。
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!context.mounted) return;
        LiveRoutes.switchTab(context, 3);
      }
    } on ApiException catch (e) {
      if (context.mounted) showLiveSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '聊天信息'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Avatar(url: peerAvatar, name: peerName, size: 76),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    peerName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LiveColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    '在线',
                    style: TextStyle(fontSize: 12.6, color: LiveColors.success),
                  ),
                ),
                const SizedBox(height: 24),
                _ChatInfoRow(
                  icon: Icons.block,
                  label: '黑名单管理',
                  onTap: () => LiveRoutes.push(context, RoutePaths.chatBlocks),
                ),
                _ChatInfoRow(
                  icon: Icons.delete_outline,
                  label: '删除会话',
                  danger: true,
                  onTap: () => _deleteConversation(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInfoRow extends StatelessWidget {
  const _ChatInfoRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: LiveColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? LiveColors.danger : LiveColors.textPrimary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: danger ? LiveColors.danger : LiveColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 18, color: LiveColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _AttachItem extends StatelessWidget {
  const _AttachItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: LiveColors.textPrimary),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11.6, color: LiveColors.textSecondary)),
        ],
      ),
    );
  }
}

class BlocksScreen extends StatefulWidget {
  const BlocksScreen({super.key});

  @override
  State<BlocksScreen> createState() => _BlocksScreenState();
}

class _BlocksScreenState extends State<BlocksScreen> {
  List<User> _blocks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final blocks = await ChatService.instance.blocks();
      if (mounted) setState(() => _blocks = blocks);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unblock(User u) async {
    try {
      await ChatService.instance.setBlocked(u.id, false);
      if (mounted) {
        showLiveSnack(context, '已解除拉黑');
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '黑名单管理'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _blocks.isEmpty
                        ? const EmptyView(text: '暂无拉黑用户')
                        : ListView.separated(
                            padding: const EdgeInsets.all(18),
                            itemCount: _blocks.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: LiveColors.divider),
                            itemBuilder: (_, i) {
                              final u = _blocks[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Avatar(url: u.avatar, name: u.nickname, size: 44),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(u.displayName,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: LiveColors.textPrimary)),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _unblock(u),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        foregroundColor: LiveColors.brand,
                                        side: const BorderSide(color: LiveColors.brand),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('解除拉黑', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
