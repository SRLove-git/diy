import 'dart:math' as math;

import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
      bottomBar: const LiveTabBar(current: 3),
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
                      const AddFriendScreen(),
                      resizeToAvoidBottomInset: false,
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
                                onTap: () {
                                  final it = items[i];
                                  if (it.group != null) {
                                    LiveRoutes.push(
                                      context,
                                      ChatScreen(groupId: it.group!.id, groupName: it.group!.name),
                                      resizeToAvoidBottomInset: false,
                                    );
                                  } else {
                                    final c = it.conv!;
                                    LiveRoutes.push(
                                      context,
                                      ChatScreen(
                                        conversationId: c.id,
                                        peerId: c.peerId,
                                        peerName: c.peerNickname,
                                        peerAvatar: c.peerAvatar,
                                      ),
                                      resizeToAvoidBottomInset: false,
                                    );
                                  }
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

class _ChatListItem {
  const _ChatListItem.group(this.group) : conv = null;
  const _ChatListItem.conv(this.conv) : group = null;

  final GroupItem? group;
  final ConversationItem? conv;

  DateTime? get lastAt => group?.lastMessageAt ?? conv?.lastMessageAt;
  int get unread => (group?.unreadCount ?? 0) + (conv?.unreadCount ?? 0);
  String get name => group?.name ?? conv?.peerNickname ?? '';
  String get preview => group?.lastMessagePreview ?? conv?.lastMessagePreview ?? '暂无消息';
  String get avatar => conv?.peerAvatar ?? '';
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.item, required this.onTap});

  final _ChatListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = item.group != null
        ? (item.group!.memberAvatars.isNotEmpty
            ? item.group!.memberAvatars.first
            : '')
        : item.avatar;
    return InkWell(
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

  @override
  void initState() {
    super.initState();
    _loadMessages();
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
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
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
            title: widget.isGroup ? widget.groupName : widget.peerName,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz, color: LiveColors.textPrimary),
                onPressed: widget.isGroup
                    ? () => LiveRoutes.push(
                        context,
                        GroupSettingsScreen(groupId: widget.groupId!),
                      )
                    : () => LiveRoutes.push(
                        context,
                        ChatInfoScreen(
                          peerId: widget.peerId,
                          peerName: widget.peerName,
                          peerAvatar: widget.peerAvatar,
                          conversationId: widget.conversationId ?? 0,
                        ),
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
                        padding: const EdgeInsets.all(18),
                        itemCount: _messages.length + (_hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == 0 && _hasMore) {
                            return Center(
                              child: TextButton(
                                onPressed: () => _loadMessages(earlier: true),
                                child: const Text('加载更早消息',
                                    style: TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
                              ),
                            );
                          }
                          final msg = _messages[i - (_hasMore ? 1 : 0)];
                          final isMine = msg.senderId == me;
                          return _Bubble(
                            message: msg,
                            isMine: isMine,
                            showAvatar: widget.isGroup && !isMine,
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
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                decoration: const BoxDecoration(
                  color: LiveColors.bg,
                  border: Border(top: BorderSide(color: LiveColors.divider)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          showLiveSnack(context, '语音消息敬请期待'),
                      icon: const Icon(Icons.mic_none, color: LiveColors.textSecondary, size: 22),
                    ),
                    IconButton(
                      onPressed: _showEmojiPanel,
                      icon: const Icon(Icons.emoji_emotions_outlined, color: LiveColors.textSecondary, size: 22),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: '发送消息…',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMine, required this.showAvatar});

  final ChatMessage message;
  final bool isMine;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final isImage = message.contentType == 'image';
    final isVoice = message.contentType == 'voice';
    final isVideo = message.contentType == 'video';
    final bubbleColor = isMine ? LiveColors.brand : LiveColors.card;
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
              ImageViewerPage(url: message.content),
            ),
            child: NetImage(url: message.content),
          ),
        ),
      );
    } else if (isVoice) {
      bubbleContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.graphic_eq, size: 18, color: textColor),
          const SizedBox(width: 6),
          Text('语音消息', style: TextStyle(fontSize: 13, color: textColor)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: message.isRecalled ? LiveColors.card : bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isMine ? 14 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 14),
        ),
      ),
      child: bubbleContent,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine && showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Avatar(
                url: message.author?.avatar ?? '',
                name: message.author?.nickname ?? '',
                size: 36,
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMine && showAvatar && message.author != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      message.author!.displayName,
                      style: const TextStyle(fontSize: 10, color: LiveColors.textTertiary),
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
            ),
          ),
        ],
      ),
    );
  }
}

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  List<GroupMember> _members = [];
  bool _loading = true;
  String? _error;
  bool _busy = false;
  bool _muted = false;
  bool _pinned = false;
  bool _isOwner = false;

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
      final members = await GroupService.instance.members(widget.groupId);
      if (mounted) {
        setState(() {
          _members = members;
          _isOwner = members.any(
            (m) =>
                m.role == 'owner' &&
                m.userId == AuthStore.instance.userId,
          );
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _kick(GroupMember m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('移出群聊'),
        content: Text('确定将 ${m.nickname} 移出群聊吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('移出')),
        ],
      ),
    );
    if (ok != true) return;
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
    ctrl.dispose();
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
          const LiveAppBar(title: '群设置'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: LiveColors.card,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: const BoxDecoration(
                                    color: LiveColors.textPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '群',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '群名称',
                                        style: const TextStyle(
                                          fontSize: 15,
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
                                          fontSize: 11.6,
                                          color: LiveColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _GroupOption(
                            label: '修改群名称',
                            onTap: _rename,
                          ),
                          _GroupOption(
                            label: '群公告',
                            value: '每周三拼豆主题日',
                            onTap: () =>
                                showLiveSnack(context, '群公告编辑敬请期待'),
                          ),
                          _GroupSwitchOption(
                            label: '消息免打扰',
                            value: _muted,
                            onChanged: (v) => setState(() => _muted = v),
                          ),
                          _GroupSwitchOption(
                            label: '置顶聊天',
                            value: _pinned,
                            onChanged: (v) => setState(() => _pinned = v),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('群成员', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              Text('${_members.length} 人',
                                  style: const TextStyle(fontSize: 13, color: LiveColors.textTertiary)),
                              const Spacer(),
                              TextButton(
                                onPressed: _addMembers,
                                child: const Text('邀请',
                                    style: TextStyle(fontSize: 13, color: LiveColors.brand)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._members.map(
                            (m) => _MemberRow(
                              member: m,
                              isOwner: m.role == 'owner',
                              onKick: m.role == 'owner' ? null : () => _kick(m),
                            ),
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: _isOwner ? '解散群聊' : '退出群聊',
                            textColor: LiveColors.danger,
                            loading: _busy,
                            onTap: _busy
                                ? null
                                : _isOwner
                                    ? _dissolve
                                    : _leaveOrDissolve,
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.isOwner, this.onKick});

  final GroupMember member;
  final bool isOwner;
  final VoidCallback? onKick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Avatar(url: member.avatar, name: member.nickname, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.nickname,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
            ),
          ),
          if (isOwner)
            const TagChip(label: '群主')
          else if (onKick != null)
            InkWell(
              onTap: onKick,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Text('移出',
                    style: TextStyle(fontSize: 12, color: LiveColors.danger)),
              ),
            ),
        ],
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: LiveColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
            ),
            const Spacer(),
            if (value != null)
              Text(value!, style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: LiveColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: LiveColors.textPrimary,
          ),
        ],
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
        ChatScreen(
          conversationId: conv.id,
          peerId: u.id,
          peerName: u.displayName,
          peerAvatar: u.avatar,
        ),
        resizeToAvoidBottomInset: false,
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
        ChatScreen(groupId: group.id, groupName: group.name),
        resizeToAvoidBottomInset: false,
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
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ChatService.instance.deleteConversation(conversationId);
      if (context.mounted) {
        nav.pop();
        nav.pop();
        // 连续 pop 后等待下一帧再提示，避免 context 处于 deactivate 过程。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          messenger.showSnackBar(const SnackBar(content: Text('会话已删除')));
        });
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
                  onTap: () => LiveRoutes.push(context, const BlocksScreen()),
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
