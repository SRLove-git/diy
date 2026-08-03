import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../core/local_chat_store.dart';
import '../../widgets/state_widgets.dart';

enum _SendState { pending, sent, failed }

class _ViewMsg {
  _ViewMsg({required this.message, this.state = _SendState.sent, this.localPath});
  ChatMessage message;
  _SendState state;

  /// 图片本地路径：上传/确认前用于本地预览，发送失败重发时复用
  String? localPath;
}

/// 常用表情（微信风格：表情作为文本消息的一部分发送）
const _emojis = [
  '😀', '😁', '😂', '🤣', '😃', '😄', '😅', '😆',
  '😉', '😊', '😋', '😎', '😍', '😘', '🥰', '😗',
  '🙂', '🤗', '🤩', '🤔', '🤨', '😐', '😑', '😶',
  '🙄', '😏', '😣', '😥', '😮', '🤐', '😯', '😪',
  '😫', '😴', '😌', '😛', '😜', '😝', '🤤', '😒',
  '😓', '😔', '😕', '🙃', '🤑', '😲', '☹️', '🙁',
  '😖', '😞', '😟', '😤', '😢', '😭', '😦', '😧',
  '😨', '😩', '🤯', '😬', '😰', '😱', '🥵', '🥶',
  '😳', '🤪', '😵', '😡', '😠', '🤬', '😷', '🤒',
  '🤕', '🤢', '🤮', '🤧', '😇', '🥳', '🥺', '🤠',
  '🤡', '🤥', '🤫', '🤭', '🧐', '🤓', '😈', '👿',
  '💀', '👻', '❤️', '🧡', '💛', '💚', '💙', '💜',
  '🖤', '🤍', '💔', '💕', '💞', '💓', '💗', '💖',
  '💘', '💝', '👍', '👎', '👌', '🤝', '👏', '🙌',
  '🙏', '💪', '✌️', '🤞', '👊', '🤛', '🤜', '🤟',
];

/// 聊天页：单聊会话（文本/表情/图片消息）
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversation});

  final Conversation conversation;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgs = <_ViewMsg>[]; // 新的在前（配合 reverse ListView）
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final _rand = Random();
  StreamSubscription<ChatEvent>? _sub;
  bool _loading = true;
  String? _error;
  int? _nextCursor;
  bool _loadingMore = false;
  bool _showEmoji = false;
  /// 是否已把本地缓存 sender_id=0 的本机消息修正为真实 id
  bool _fixedLocalSender = false;

  /// 当前用户 id：实时读取（登录态恢复时 _fetchMe 异步，initState 阶段 user 可能为 null，
  /// 若固定成 0 会导致所有消息被判定为"对方"，出现全部在左侧的显示错误）
  int get _meId => AuthService.instance.user?.id ?? 0;

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_onAuthChanged);
    _fixLocalSenderIds();
    ChatService.instance.ensureConnected();
    // 首帧后再标记已读：markRead 内部会 notifyListeners，
    // 路由切换的 build 阶段同步通知会触发 "setState during build" 异常
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ChatService.instance.markRead(widget.conversation.id);
    });
    _sub = ChatService.instance.events.listen(_onEvent);
    _loadHistory();
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    _sub?.cancel();
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  /// user 就绪/变化后重新渲染，让气泡按最新 meId 自动归位
  void _onAuthChanged() {
    _fixLocalSenderIds();
    if (mounted) setState(() {});
  }

  /// 登录态恢复后将本地缓存与当前内存中 sender_id=0 的本机消息修正为真实 id
  void _fixLocalSenderIds() {
    final uid = _meId;
    if (uid <= 0 || _fixedLocalSender) return;
    _fixedLocalSender = true;
    LocalChatStore.instance.fixSenderIds(uid);
    for (final vm in _msgs) {
      if (vm.message.senderId == 0) {
        vm.message = vm.message.copyWith(senderId: uid);
      }
    }
  }

  void _onEvent(ChatEvent event) {
    if (event is NewMessageEvent) {
      final m = event.message;
      if (m.conversationId != widget.conversation.id) return;
      setState(() {
        if (!_msgs.any((vm) => vm.message.id != null && vm.message.id == m.id)) {
          _msgs.insert(0, _ViewMsg(message: m));
        }
      });
      // 对方消息：本地回执已读
      ChatService.instance.markRead(widget.conversation.id);
    } else if (event is ReadEvent) {
      if (event.conversationId != widget.conversation.id) return;
      final readAt = event.readAt ?? DateTime.now();
      setState(() {
        for (final vm in _msgs) {
          if (vm.message.senderId == _meId && vm.message.readAt == null) {
            vm.message = vm.message.copyWith(readAt: readAt);
          }
        }
      });
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // 1) 秒开：本地缓存先上屏（弱网/离线也能查看历史与待发消息）
    try {
      final local = await LocalChatStore.instance
          .messages(widget.conversation.id, limit: 100);
      if (mounted && local.isNotEmpty) {
        setState(() {
          _msgs
            ..clear()
            ..addAll(local.reversed.map((m) {
              final st = m.status;
              return _ViewMsg(
                message: m.toChatMessage(),
                state: st == LocalMsgStatus.failed
                    ? _SendState.failed
                    : st == LocalMsgStatus.sending
                        ? _SendState.pending
                        : _SendState.sent,
              );
            }));
          _loading = false; // 有本地数据即先展示
        });
      }
    } catch (_) {
      // 本地库异常：忽略，走服务端
    }
    // 2) 服务端同步（失败保留本地缓存，不阻断浏览）
    try {
      final r = await ChatApi.fetchMessages(widget.conversation.id);
      if (mounted) {
        setState(() {
          // 保留本地尚未确认/发送失败的消息（pending/failed，服务端还没有的）
          final keepLocal = _msgs
              .where((vm) =>
                  vm.state == _SendState.pending ||
                  vm.state == _SendState.failed)
              .toList();
          _msgs
            ..clear()
            ..addAll(r.items.reversed.map((m) => _ViewMsg(message: m)));
          for (final p in keepLocal.reversed) {
            final sid = p.message.id;
            if (sid != null && r.items.any((m) => m.id == sid)) continue;
            if (!_msgs
                .any((vm) => vm.message.clientMsgId == p.message.clientMsgId)) {
              _msgs.insert(0, p);
            }
          }
          _nextCursor = r.nextCursor;
        });
      }
    } catch (_) {
      // 服务端失败：本地缓存已展示，弱网可用
      if (mounted && _msgs.isEmpty) {
        setState(() => _error = '加载失败，请重试');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final r = await ChatApi.fetchMessages(widget.conversation.id, cursor: cursor);
      if (mounted) {
        setState(() {
          _msgs.addAll(r.items.map((m) => _ViewMsg(message: m)));
          _nextCursor = r.nextCursor;
        });
      }
    } catch (_) {
      // 失败忽略，下次滚动到顶部再试
    } finally {
      _loadingMore = false;
    }
  }

  String _genMsgId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_rand.nextInt(1 << 32)}';

  /// 本地待发送消息上屏
  void _insertPending(ChatMessage local, {String? localPath}) {
    setState(() =>
        _msgs.insert(0, _ViewMsg(message: local, state: _SendState.pending, localPath: localPath)));
  }

  /// 发送结果回写：confirmed 非空替换为服务端消息；否则标记失败（保留本地预览/路径）
  void _applyResult(String clientMsgId, ChatMessage? confirmed, ChatMessage fallback) {
    if (!mounted) return;
    setState(() {
      final idx = _msgs.indexWhere((vm) => vm.message.clientMsgId == clientMsgId);
      if (idx < 0) return;
      // 保留 ReadEvent 已设置的 readAt 与图片本地路径（可能是 _onEvent 期间写入的）
      final preservedReadAt = _msgs[idx].message.readAt;
      final localPath = _msgs[idx].localPath;
      _msgs[idx] = confirmed != null
          ? _ViewMsg(
              message: preservedReadAt != null
                  ? confirmed.copyWith(readAt: preservedReadAt)
                  : confirmed,
              localPath: localPath,
            )
          : _ViewMsg(message: fallback, state: _SendState.failed, localPath: localPath);
    });
  }

  void _replaceMsg(_ViewMsg old, _ViewMsg neu) {
    final idx = _msgs.indexWhere((m) => identical(m, old));
    if (idx >= 0) setState(() => _msgs[idx] = neu);
  }

  /// 发送文本消息（含表情）
  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    setState(() => _showEmoji = false);
    final clientMsgId = _genMsgId();
    final local = ChatMessage(
      id: null,
      conversationId: widget.conversation.id,
      senderId: _meId,
      content: text,
      createdAt: DateTime.now(),
      clientMsgId: clientMsgId,
    );
    _insertPending(local);
    final confirmed = await ChatService.instance.sendMessage(
      conversationId: widget.conversation.id,
      content: text,
      clientMsgId: clientMsgId,
    );
    _applyResult(clientMsgId, confirmed, local);
  }

  /// 选择图片并发送：本地预览 → 上传 → 发消息
  Future<void> _sendImage() async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
    } catch (_) {
      return;
    }
    if (picked == null || !mounted) return;
    setState(() => _showEmoji = false);
    final clientMsgId = _genMsgId();
    final local = ChatMessage(
      id: null,
      conversationId: widget.conversation.id,
      senderId: _meId,
      contentType: 'image',
      content: '',
      createdAt: DateTime.now(),
      clientMsgId: clientMsgId,
    );
    _insertPending(local, localPath: picked.path);
    await _uploadAndSend(clientMsgId, picked.path, local);
  }

  /// 上传图片并发送（失败时以 fallback 标记失败态）
  Future<void> _uploadAndSend(
    String clientMsgId,
    String filePath,
    ChatMessage fallback,
  ) async {
    String? url;
    try {
      url = await ChatApi.uploadImage(filePath);
    } catch (_) {
      url = null;
    }
    if (url == null) {
      _applyResult(clientMsgId, null, fallback);
      return;
    }
    final confirmed = await ChatService.instance.sendMessage(
      conversationId: widget.conversation.id,
      content: url,
      clientMsgId: clientMsgId,
      contentType: 'image',
    );
    _applyResult(clientMsgId, confirmed, fallback.copyWith(content: url));
  }

  /// 失败消息重发：上传失败的图片重新走 上传→发送；其余直接重发
  void _resend(_ViewMsg vm) {
    final clientMsgId = _genMsgId();
    if (vm.message.contentType == 'image' && vm.message.content.isEmpty && vm.localPath != null) {
      final retry = vm.message.copyWith(clientMsgId: clientMsgId, content: '');
      _replaceMsg(vm, _ViewMsg(message: retry, state: _SendState.pending, localPath: vm.localPath));
      _uploadAndSend(clientMsgId, vm.localPath!, retry);
      return;
    }
    final retry = vm.message.copyWith(clientMsgId: clientMsgId);
    _replaceMsg(vm, _ViewMsg(message: retry, state: _SendState.pending, localPath: vm.localPath));
    ChatService.instance
        .sendMessage(
          conversationId: widget.conversation.id,
          content: vm.message.content,
          clientMsgId: clientMsgId,
          contentType: vm.message.contentType,
        )
        .then((confirmed) => _applyResult(clientMsgId, confirmed, retry));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildTitle()),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessages()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  /// 标题 + 在线状态圆点（presence 实时刷新）
  Widget _buildTitle() {
    final colors = AppColors.of(context);
    return ListenableBuilder(
      listenable: ChatService.instance,
      builder: (context, _) {
        final online =
            ChatService.instance.isPeerOnline(widget.conversation.peerId);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _title(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: online
                    ? const Color(0xFF34C759)
                    : colors.textSecondary.withValues(alpha: 0.35),
              ),
            ),
          ],
        );
      },
    );
  }

  String _title() {
    final n = widget.conversation.peerNickname;
    return n.isEmpty ? '用户 #${widget.conversation.peerId}' : n;
  }

  Widget _buildMessages() {
    if (_loading) return const LoadingWidget();
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _loadHistory);
    }
    if (_msgs.isEmpty) {
      return const EmptyWidget(icon: Icons.chat_bubble_outline, message: '打个招呼吧');
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _msgs.length + 1, // 末尾一项：顶部加载更多
      itemBuilder: (_, i) {
        if (i == _msgs.length) {
          if (_nextCursor == null) return const SizedBox(height: 4);
          // 滚动到顶部可见时加载更早的消息
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
          return const Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final vm = _msgs[i];
        return _MessageBubble(
          vm: vm,
          meId: _meId,
          meAvatar: AuthService.instance.user?.avatar ?? '',
          meNickname: AuthService.instance.user?.nickname ?? '',
          peerAvatar: widget.conversation.peerAvatar,
          peerNickname: widget.conversation.peerNickname,
          onResend: () => _resend(vm),
        );
      },
    );
  }

  Widget _buildInputBar() {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.image_outlined, color: colors.textSecondary),
                  tooltip: '发送图片',
                  onPressed: _loading ? null : _sendImage,
                ),
                IconButton(
                  icon: Icon(
                    _showEmoji
                        ? Icons.keyboard_alt_outlined
                        : Icons.emoji_emotions_outlined,
                    color: colors.textSecondary,
                  ),
                  tooltip: '表情',
                  onPressed: () {
                    setState(() => _showEmoji = !_showEmoji);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _input,
                    focusNode: _inputFocus,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: '发消息…',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: colors.placeholder.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _send,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
          if (_showEmoji) _buildEmojiPanel(),
        ],
      ),
    );
  }

  Widget _buildEmojiPanel() {
    final colors = AppColors.of(context);
    return Container(
      height: 184,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: _emojis.length,
        itemBuilder: (_, i) => InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // 追加到输入框末尾（表情作为文本消息内容发送）
            // selection 在无光标时可能为无效值（offset=-1），此时回退到文本末尾
            final sel = _input.selection;
            final pos = (sel.isValid && sel.extentOffset >= 0)
                ? sel.extentOffset
                : _input.text.length;
            final text = _input.text;
            _input.text = text.substring(0, pos) + _emojis[i] + text.substring(pos);
            _input.selection = TextSelection.fromPosition(
              TextPosition(offset: pos + _emojis[i].length),
            );
            _inputFocus.requestFocus();
          },
          child: Center(
            child: Text(_emojis[i], style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.vm,
    required this.meId,
    required this.onResend,
    this.meAvatar = '',
    this.meNickname = '',
    this.peerAvatar = '',
    this.peerNickname = '',
  });

  final _ViewMsg vm;
  final int meId;
  final VoidCallback onResend;
  final String meAvatar;
  final String meNickname;
  final String peerAvatar;
  final String peerNickname;

  @override
  Widget build(BuildContext context) {
    final m = vm.message;
    final mine = m.senderId == meId;
    final isImage = m.contentType == 'image';
    final colors = AppColors.of(context);
    final bubble = Container(
      padding: isImage
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: isImage
          ? null
          : BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
      decoration: isImage
          ? null
          : BoxDecoration(
              color: mine ? colors.primary : colors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(mine ? 16 : 4),
                bottomRight: Radius.circular(mine ? 4 : 16),
              ),
            ),
      child: isImage ? _buildImage(context, colors) : _buildText(colors),
    );
    // 微信风格：对方头像在左，自己头像在右
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine) ...[
            _AvatarBubble(avatar: peerAvatar, nickname: peerNickname),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                bubble,
                if (mine)
                  Padding(
                    padding: const EdgeInsets.only(right: 4, bottom: 2),
                    child: _buildStatus(colors),
                  ),
              ],
            ),
          ),
          if (mine) ...[
            const SizedBox(width: 8),
            _AvatarBubble(avatar: meAvatar, nickname: meNickname),
          ],
        ],
      ),
    );
  }

  Widget _buildText(AppColors colors) {
    final mine = vm.message.senderId == meId;
    return Text(
      vm.message.content,
      style: TextStyle(
        fontSize: 15,
        height: 1.4,
        color: mine ? Colors.white : colors.textPrimary,
      ),
    );
  }

  Widget _buildImage(BuildContext context, AppColors colors) {
    final m = vm.message;
    Widget image;
    if (m.content.isNotEmpty) {
      image = Image.network(
        ChatApi.resolveUrl(m.content),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(
                width: 120,
                height: 120,
                color: colors.placeholder,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
        errorBuilder: (_, _, _) => Container(
          width: 120,
          height: 120,
          color: colors.placeholder,
          child: Icon(Icons.broken_image_outlined, color: colors.textSecondary),
        ),
      );
    } else if (vm.localPath != null) {
      // 上传中/失败：展示本地文件预览
      image = Image.file(File(vm.localPath!), fit: BoxFit.cover);
    } else {
      image = Container(
        width: 120,
        height: 120,
        color: colors.placeholder,
        child: Icon(Icons.image_outlined, color: colors.textSecondary),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 220,
          maxHeight: 280,
        ),
        child: image,
      ),
    );
  }

  Widget _buildStatus(AppColors colors) {
    switch (vm.state) {
      case _SendState.pending:
        return Text(
          '发送中…',
          style: TextStyle(fontSize: 10, color: colors.textSecondary),
        );
      case _SendState.failed:
        return InkWell(
          onTap: onResend,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 14, color: colors.danger),
              const SizedBox(width: 3),
              Text(
                '发送失败，点击重发',
                style: TextStyle(fontSize: 10, color: colors.textSecondary),
              ),
            ],
          ),
        );
      case _SendState.sent:
        return Text(
          vm.message.readAt != null ? '已读' : '已发送',
          style: TextStyle(fontSize: 10, color: colors.textSecondary),
        );
    }
  }
}

/// 消息头像：支持 http(s)/本地相对路径网络图，缺失时显示昵称首字占位
class _AvatarBubble extends StatelessWidget {
  const _AvatarBubble({required this.avatar, required this.nickname});

  final String avatar;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final url = avatar.trim();
    final hasImage = url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.placeholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              ChatApi.resolveUrl(url),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initial(colors),
            )
          : _initial(colors),
    );
  }

  /// 首字占位：中文按字符取首字，避免 String[0] 截断多字节字符
  Widget _initial(AppColors colors) {
    final name = nickname.trim();
    final initial = name.isEmpty
        ? '?'
        : String.fromCharCode(name.runes.first);
    return Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: 16, color: colors.textSecondary),
      ),
    );
  }
}
