import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../core/follow_api.dart';
import '../../core/local_chat_store.dart';
import '../community/user_profile_page.dart';
import '../../widgets/follow_button.dart';
import '../../widgets/image_viewer.dart';
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
  /// 表情面板是否显示
  bool _showEmoji = false;
  /// 语音输入模式（隐藏输入框，显示"按住说话"）
  bool _voiceMode = false;
  /// 加号面板（小功能）是否显示
  bool _showMore = false;

  // 语音录制
  AudioRecorder? _recorder;
  bool _recording = false;
  String? _recordingPath;
  DateTime? _recordStart;
  int _recordSec = 0;
  Timer? _recordTimer;
  /// 预取的临时目录（预热后按住即可直接开始）
  Directory? _voiceTempDir;
  /// 正在进行的录音启动任务（处理"未启动就松手"的竞态）
  Future<void>? _recordingStartFuture;

  // 语音播放
  AudioPlayer? _player;
  /// 当前正在播放的消息标识（id 或 clientMsgId）
  String? _playingKey;
  /// 已把本地缓存 sender_id=0 的本机消息修正为真实 id
  bool _fixedLocalSender = false;

  // 关注状态
  FollowStatus? _followStatus;
  bool _followBusy = false;

  /// 当前用户 id：实时读取（登录态恢复时 _fetchMe 异步，initState 阶段 user 可能为 null，
  /// 若固定成 0 会导致所有消息被判定为"对方"，出现全部在左侧的显示错误）
  int get _meId => AuthService.instance.user?.id ?? 0;

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_onAuthChanged);
    _inputFocus.addListener(_onInputFocusChanged);
    _fixLocalSenderIds();
    // 预热语音链路，缩短按住到真正开始录音的延迟
    unawaited(_warmUpVoice());
    ChatService.instance.ensureConnected();
    // 首帧后再标记已读：markRead 内部会 notifyListeners，
    // 路由切换的 build 阶段同步通知会触发 "setState during build" 异常
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ChatService.instance.markRead(widget.conversation.id);
    });
    _sub = ChatService.instance.events.listen(_onEvent);
    _loadHistory();
    _loadFollowStatus();
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    _inputFocus.removeListener(_onInputFocusChanged);
    _sub?.cancel();
    _recordTimer?.cancel();
    try {
      _recorder?.dispose();
    } catch (_) {}
    try {
      _player?.dispose();
    } catch (_) {}
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  /// 键盘获得焦点时收起表情/加号/语音面板
  void _onInputFocusChanged() {
    if (_inputFocus.hasFocus && (_showEmoji || _showMore || _voiceMode)) {
      setState(() {
        _showEmoji = false;
        _showMore = false;
        _voiceMode = false;
      });
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
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

  /// 加载当前用户与聊天对方的关注关系
  Future<void> _loadFollowStatus() async {
    try {
      final s = await FollowApi.status(widget.conversation.peerId);
      if (mounted) setState(() => _followStatus = s);
    } catch (_) {
      // 加载失败忽略，不影响聊天功能
    }
  }

  /// 切换关注状态
  Future<void> _toggleFollow(bool following) async {
    if (_followBusy) return;
    setState(() => _followBusy = true);
    try {
      final s = await FollowApi.setFollow(
        widget.conversation.peerId,
        following: following,
      );
      if (mounted) setState(() => _followStatus = s);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('操作失败，请重试')),
        );
      }
    } finally {
      if (mounted) setState(() => _followBusy = false);
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
    } else if (event is ChatLimitEvent) {
      // 聊天受限：移除占位气泡并清理本地留底，提示互相关注后可畅聊。
      // 仅当气泡确实被移除时才提示（WS 与 REST 兜底会各触发一次，去重）。
      var removed = false;
      setState(() {
        final before = _msgs.length;
        _msgs.removeWhere(
          (vm) => vm.message.clientMsgId == event.clientMsgId,
        );
        removed = _msgs.length != before;
      });
      if (removed) {
        LocalChatStore.instance.removeByClientMsgId(event.clientMsgId);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(event.reason)));
      }
      // 刷新关注状态，确保 banner 及时出现
      _loadFollowStatus();
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
  Future<void> _sendImage(ImageSource source) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
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

  /// 点击图片气泡：全屏查看（共享元素动画，从原图放大铺满全屏）
  Future<void> _openImageViewer(_ViewMsg vm) async {
    final m = vm.message;
    final heroTag = 'chat-img-${m.id ?? m.clientMsgId}';
    ImageProvider? precache;
    final Widget image;
    if (m.content.isNotEmpty) {
      final url = ChatApi.resolveUrl(m.content);
      precache = NetworkImage(url);
      image = Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                ),
              ),
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 56,
          ),
        ),
      );
    } else if (vm.localPath != null) {
      // 上传中/失败：查看本地文件原图
      final path = vm.localPath!;
      precache = FileImage(File(path));
      image = Image.file(File(path), fit: BoxFit.contain);
    } else {
      image = const Center(
        child: Icon(Icons.image_outlined, color: Colors.white54, size: 56),
      );
    }
    await showImageViewer(
      context,
      image: image,
      heroTag: heroTag,
      precache: precache,
    );
  }

  /// 失败消息重发：上传失败的图片/语音重新走 上传→发送；其余直接重发
  void _resend(_ViewMsg vm) {
    final clientMsgId = _genMsgId();
    if (vm.message.contentType == 'image' && vm.message.content.isEmpty && vm.localPath != null) {
      final retry = vm.message.copyWith(clientMsgId: clientMsgId, content: '');
      _replaceMsg(vm, _ViewMsg(message: retry, state: _SendState.pending, localPath: vm.localPath));
      _uploadAndSend(clientMsgId, vm.localPath!, retry);
      return;
    }
    // 语音上传失败（content 中 url 为空）：重新上传本地录音
    if (vm.message.contentType == 'voice' && vm.localPath != null) {
      final vi = _voiceInfo(vm.message);
      if (vi.url.isEmpty) {
        final retry = vm.message.copyWith(
          clientMsgId: clientMsgId,
          content: jsonEncode({'url': '', 'duration': vi.duration}),
        );
        _replaceMsg(vm, _ViewMsg(message: retry, state: _SendState.pending, localPath: vm.localPath));
        _uploadVoiceAndSend(clientMsgId, vm.localPath!, vi.duration, retry);
        return;
      }
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

  // ---------- 输入区面板切换 ----------

  void _toggleVoiceMode() {
    if (_voiceMode) {
      setState(() {
        _voiceMode = false;
        _showEmoji = false;
        _showMore = false;
      });
      _inputFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      setState(() {
        _voiceMode = true;
        _showEmoji = false;
        _showMore = false;
      });
    }
  }

  void _toggleEmoji() {
    if (_showEmoji) {
      setState(() => _showEmoji = false);
      _inputFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      setState(() {
        _showEmoji = true;
        _showMore = false;
        _voiceMode = false;
      });
    }
  }

  void _toggleMore() {
    if (_showMore) {
      setState(() => _showMore = false);
      _inputFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      setState(() {
        _showMore = true;
        _showEmoji = false;
        _voiceMode = false;
      });
    }
  }

  // ---------- 语音消息：录制 → 上传 → 发送 ----------

  AudioRecorder get _rec => _recorder ??= AudioRecorder();

  /// 语音消息唯一标识（用于定位播放中的气泡）
  String _msgKey(_ViewMsg vm) =>
      vm.message.id?.toString() ??
      vm.message.clientMsgId ??
      '${vm.message.createdAt}';

  /// 预热语音链路：预先检查麦克风权限并缓存临时目录，
  /// 这样按住按钮时不用再等这两步，启动更快
  Future<void> _warmUpVoice() async {
    try {
      await _rec.hasPermission();
      _voiceTempDir = await getTemporaryDirectory();
    } catch (_) {
      // 预热失败不阻塞页面，正式录音时再处理
    }
  }

  /// 开始录音（按住说话按下）：
  /// 先立即进入录音态给用户反馈，再异步做权限/目录/start
  Future<void> _startRecord() async {
    _recordSec = 0;
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _recording) setState(() => _recordSec++);
    });
    setState(() => _recording = true);

    final fut = _doStartRecord();
    _recordingStartFuture = fut;
    try {
      await fut;
    } on _RecordPermissionDenied {
      _resetRecordingUi();
      _toast('需要麦克风权限才能录音');
    } catch (_) {
      _resetRecordingUi();
      _toast('录音启动失败');
    }
  }

  /// 真正开始录音：权限 → 临时目录 → start
  Future<void> _doStartRecord() async {
    if (!await _rec.hasPermission()) throw _RecordPermissionDenied();
    if (await _rec.isRecording()) await _rec.stop();
    final dir = _voiceTempDir ?? await getTemporaryDirectory();
    final path = p.join(dir.path, 'voice_${_genMsgId()}.m4a');
    await _rec.start(const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path);
    _recordingPath = path;
    _recordStart = DateTime.now();
  }

  void _resetRecordingUi() {
    _recordTimer?.cancel();
    if (mounted) setState(() => _recording = false);
  }

  /// 松开结束录音：若录音还在启动中先等它完成，时长过短丢弃，否则上传发送
  Future<void> _stopRecord() async {
    final startFut = _recordingStartFuture;
    _recordingStartFuture = null;
    if (startFut != null) {
      // 启动有延迟，用户可能在真正开始前就松手了
      try {
        await startFut;
      } catch (_) {
        _resetRecordingUi();
        return;
      }
    }
    final path = _recordingPath;
    if (path == null) return;
    _recordingPath = null;
    _recordTimer?.cancel();
    setState(() => _recording = false);
    var dur = 0;
    try {
      await _rec.stop();
      dur = DateTime.now().difference(_recordStart ?? DateTime.now()).inSeconds;
    } catch (_) {}
    if (dur < 1) {
      _toast('说话时间太短');
      return;
    }
    await _sendVoice(path, dur);
  }

  /// 取消录音（如手势取消）：停止并删除临时文件
  void _cancelRecord() async {
    final startFut = _recordingStartFuture;
    _recordingStartFuture = null;
    _recordTimer?.cancel();
    if (mounted) setState(() => _recording = false);
    if (startFut != null) {
      try {
        await startFut;
      } catch (_) {
        return;
      }
    }
    final path = _recordingPath;
    _recordingPath = null;
    if (path == null) return;
    try {
      await _rec.stop();
    } catch (_) {}
    try {
      File(path).delete();
    } catch (_) {}
  }

  /// 发送语音消息：本地预览 → 上传 → 发消息
  Future<void> _sendVoice(String path, int duration) async {
    final clientMsgId = _genMsgId();
    final content = jsonEncode({'url': '', 'duration': duration});
    final local = ChatMessage(
      id: null,
      conversationId: widget.conversation.id,
      senderId: _meId,
      contentType: 'voice',
      content: content,
      createdAt: DateTime.now(),
      clientMsgId: clientMsgId,
    );
    _insertPending(local, localPath: path);
    await _uploadVoiceAndSend(clientMsgId, path, duration, local);
  }

  /// 上传语音并发送（失败时以 fallback 标记失败态）
  Future<void> _uploadVoiceAndSend(
    String clientMsgId,
    String filePath,
    int duration,
    ChatMessage fallback,
  ) async {
    String? url;
    try {
      url = await ChatApi.uploadAudio(filePath);
    } catch (_) {
      url = null;
    }
    if (url == null) {
      _applyResult(clientMsgId, null, fallback);
      return;
    }
    final content = jsonEncode({'url': url, 'duration': duration});
    final confirmed = await ChatService.instance.sendMessage(
      conversationId: widget.conversation.id,
      content: content,
      clientMsgId: clientMsgId,
      contentType: 'voice',
    );
    _applyResult(clientMsgId, confirmed, fallback.copyWith(content: content));
  }

  // ---------- 语音播放 ----------

  AudioPlayer get _pl {
    if (_player == null) {
      _player = AudioPlayer();
      _player!.onPlayerComplete.listen((_) {
        if (mounted && _playingKey != null) setState(() => _playingKey = null);
      });
    }
    return _player!;
  }

  /// 点击语音气泡：播放/暂停
  void _togglePlay(_ViewMsg vm) async {
    final key = _msgKey(vm);
    if (_playingKey == key) {
      try {
        await _pl.pause();
      } catch (_) {}
      if (mounted) setState(() => _playingKey = null);
      return;
    }
    try {
      await _pl.stop();
    } catch (_) {}
    final vi = _voiceInfo(vm.message);
    final src = vi.url.isNotEmpty
        ? UrlSource(ChatApi.resolveUrl(vi.url))
        : vm.localPath != null
            ? DeviceFileSource(vm.localPath!)
            : null;
    if (src == null) return;
    if (mounted) setState(() => _playingKey = key);
    try {
      await _pl.play(src);
    } catch (_) {
      if (mounted) setState(() => _playingKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildTitle()),
      body: SafeArea(
        // 录音中显示居中遮罩（麦克风 + 时长）
        child: Stack(
          children: [
            Column(
              children: [
                _buildFollowBanner(),
                Expanded(child: _buildMessages()),
                _buildInputBar(),
              ],
            ),
            if (_recording) _buildRecordingOverlay(),
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

  /// 关注状态提示条：互关显示绿色标签，未互关提示关注按钮
  Widget _buildFollowBanner() {
    final s = _followStatus;
    // 加载中或无状态时不显示（已互关也无需提示）
    if (s == null || s.mutual) return const SizedBox.shrink();
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: s.following
            ? const Color(0xFFF0F9EB)
            : const Color(0xFFFFF7E6),
        border: Border(
          bottom: BorderSide(color: colors.divider),
        ),
      ),
      child: Row(
        children: [
          Icon(
            s.following ? Icons.check_circle_outline : Icons.info_outline,
            size: 16,
            color: s.following
                ? const Color(0xFF34C759)
                : const Color(0xFFFF9500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s.following
                  ? '已关注，等待对方回关后即可畅聊'
                  : '关注对方后即可畅聊',
              style: TextStyle(
                fontSize: 13,
                color: s.following
                    ? const Color(0xFF2A7A3A)
                    : const Color(0xFF996A00),
              ),
            ),
          ),
          if (!s.following)
            FollowButton(
              following: false,
              enabled: !_followBusy,
              compact: true,
              onChanged: _toggleFollow,
            ),
        ],
      ),
    );
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
          peerId: widget.conversation.peerId,
          playing: _playingKey == _msgKey(vm),
          onPlay: () => _togglePlay(vm),
          onResend: () => _resend(vm),
          onTapImage: () => _openImageViewer(vm),
          imageHeroTag: 'chat-img-${vm.message.id ?? vm.message.clientMsgId}',
        );
      },
    );
  }

  /// 输入栏：微信风格 —— [语音切换] [输入框 / 按住说话] [表情] [加号]
  /// 输入有文字时"表情 + 加号"替换为"发送"按钮
  Widget _buildInputBar() {
    final colors = AppColors.of(context);
    final hasText = _input.text.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 6, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 左侧：语音输入切换
                IconButton(
                  icon: Icon(
                    _voiceMode ? Icons.keyboard_alt_outlined : Icons.mic_none,
                    color: colors.textSecondary,
                  ),
                  tooltip: _voiceMode ? '键盘' : '语音输入',
                  onPressed: _toggleVoiceMode,
                ),
                // 输入框 / 按住说话
                Expanded(
                  child: _voiceMode
                      ? _buildHoldToTalk()
                      : _buildTextField(colors),
                ),
                if (hasText) ...[
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
                ] else ...[
                  // 右侧：表情
                  IconButton(
                    icon: Icon(
                      _showEmoji
                          ? Icons.keyboard_alt_outlined
                          : Icons.emoji_emotions_outlined,
                      color: colors.textSecondary,
                    ),
                    tooltip: '表情',
                    onPressed: _toggleEmoji,
                  ),
                  // 再往右：加号（小功能面板）
                  IconButton(
                    icon: Icon(
                      _showMore ? Icons.close : Icons.add_circle_outline,
                      color: colors.textSecondary,
                    ),
                    tooltip: '更多功能',
                    onPressed: _toggleMore,
                  ),
                ],
              ],
            ),
          ),
          if (_showEmoji) _buildEmojiPanel(),
          if (_showMore) _buildMorePanel(),
        ],
      ),
    );
  }

  Widget _buildTextField(AppColors colors) {
    return TextField(
      controller: _input,
      focusNode: _inputFocus,
      minLines: 1,
      maxLines: 4,
      textInputAction: TextInputAction.newline,
      onChanged: (_) => setState(() {}),
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
    );
  }

  /// 语音输入模式：按住说话
  Widget _buildHoldToTalk() {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTapDown: (_) => _startRecord(),
      onTapUp: (_) => _stopRecord(),
      onTapCancel: _cancelRecord,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _recording
              ? colors.primary.withValues(alpha: 0.12)
              : colors.placeholder.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.divider),
        ),
        child: Text(
          _recording ? '松开 发送' : '按住 说话',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
    );
  }

  /// 加号面板（微信风格：4 列小功能）
  Widget _buildMorePanel() {
    final colors = AppColors.of(context);
    final items = <({IconData icon, Color color, String label, VoidCallback onTap})>[
      (
        icon: Icons.photo_library_outlined,
        color: const Color(0xFF5B7CFA),
        label: '图片',
        onTap: _loading ? () {} : () => _sendImage(ImageSource.gallery),
      ),
      (
        icon: Icons.photo_camera_outlined,
        color: const Color(0xFF34C759),
        label: '拍照',
        onTap: _loading ? () {} : () => _sendImage(ImageSource.camera),
      ),
      (
        icon: Icons.location_on_outlined,
        color: const Color(0xFFFF9500),
        label: '位置',
        onTap: () => _toast('功能开发中'),
      ),
      (
        icon: Icons.videocam_outlined,
        color: const Color(0xFFAF52DE),
        label: '视频通话',
        onTap: () => _toast('功能开发中'),
      ),
      (
        icon: Icons.folder_outlined,
        color: const Color(0xFF8E8E93),
        label: '文件',
        onTap: () => _toast('功能开发中'),
      ),
      (
        icon: Icons.badge_outlined,
        color: const Color(0xFFE74C3C),
        label: '名片',
        onTap: () => _toast('功能开发中'),
      ),
    ];
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.95,
        children: items
            .map(
              (it) => InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: it.onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: it.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(it.icon, size: 28, color: it.color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      it.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// 录音中遮罩：麦克风 + 松开发送 + 时长
  Widget _buildRecordingOverlay() {
    return Center(
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, color: Colors.white, size: 42),
            const SizedBox(height: 10),
            const Text(
              '松开 发送',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              '$_recordSec″',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
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

/// 麦克风权限被拒绝
class _RecordPermissionDenied implements Exception {}

/// 解析语音消息内容（{url, duration} JSON），兼容 content 直接存路径的旧数据
({String url, int duration}) _voiceInfo(ChatMessage m) {
  if (m.contentType != 'voice') return (url: '', duration: 0);
  try {
    final j = jsonDecode(m.content);
    if (j is Map<String, dynamic>) {
      return (
        url: (j['url'] ?? '').toString(),
        duration: (j['duration'] as num?)?.toInt() ?? 0,
      );
    }
  } catch (_) {}
  return (url: m.content, duration: 0);
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.vm,
    required this.meId,
    required this.onResend,
    required this.playing,
    required this.onPlay,
    required this.onTapImage,
    required this.imageHeroTag,
    required this.peerId,
    this.meAvatar = '',
    this.meNickname = '',
    this.peerAvatar = '',
    this.peerNickname = '',
  });

  final _ViewMsg vm;
  final int meId;
  final VoidCallback onResend;

  /// 语音消息是否正在播放
  final bool playing;
  final VoidCallback onPlay;

  /// 点击图片气泡：全屏查看
  final VoidCallback onTapImage;

  /// 图片共享元素动画的 Hero tag（与查看器内 Hero 配对）
  final Object imageHeroTag;
  final String meAvatar;
  final String meNickname;
  final String peerAvatar;
  final String peerNickname;

  /// 聊天对方用户 ID（点击头像跳转个人主页）
  final int peerId;

  @override
  Widget build(BuildContext context) {
    final m = vm.message;
    final mine = m.senderId == meId;
    final isImage = m.contentType == 'image';
    final isVoice = m.contentType == 'voice';
    final colors = AppColors.of(context);
    final bubble = Container(
      padding: (isImage || isVoice)
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
      child: isImage
          ? _buildImage(context, colors)
          : isVoice
              ? _buildVoice(colors)
              : _buildText(colors),
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
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfilePage(
                      userId: peerId,
                      nickname: peerNickname,
                      avatar: peerAvatar,
                    ),
                  ),
                );
              },
              child:
                  _AvatarBubble(avatar: peerAvatar, nickname: peerNickname),
            ),
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
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfilePage(
                      userId: meId,
                      nickname: meNickname,
                      avatar: meAvatar,
                    ),
                  ),
                );
              },
              child: _AvatarBubble(avatar: meAvatar, nickname: meNickname),
            ),
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

  /// 语音气泡：麦克风图标 + 时长，点击播放/暂停，宽度随时长增长
  Widget _buildVoice(AppColors colors) {
    final mine = vm.message.senderId == meId;
    final vi = _voiceInfo(vm.message);
    return InkWell(
      onTap: onPlay,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        // 不设固定宽度，由内容决定大小（避免短时长气泡内容溢出）
        constraints: const BoxConstraints(minWidth: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              playing ? Icons.graphic_eq : Icons.mic_none,
              size: 20,
              color: mine ? Colors.white : colors.textPrimary,
            ),
            const SizedBox(width: 10),
            Text(
              '${vi.duration}″',
              style: TextStyle(
                fontSize: 15,
                color: mine ? Colors.white : colors.textPrimary,
              ),
            ),
            // 时长越长气泡越宽（微信同款效果）
            SizedBox(width: min(vi.duration, 60) * 2.0),
          ],
        ),
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
    return Hero(
      tag: imageHeroTag,
      child: GestureDetector(
        onTap: onTapImage,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 220,
              maxHeight: 280,
            ),
            child: image,
          ),
        ),
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
