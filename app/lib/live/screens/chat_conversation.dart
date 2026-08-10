part of 'chat_screens.dart';

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
  bool _voiceMode = false;
  bool _willCancel = false;
  double _dragDy = 0;
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

  // ===== 语音消息：按住说话（对齐 Pixso 63-语音长按）=====
  /// 麦克风按钮：文本模式 ↔ 语音模式（按住说话）切换。
  void _toggleVoiceMode() {
    FocusScope.of(context).unfocus();
    setState(() => _voiceMode = !_voiceMode);
  }

  /// 按下「按住 说话」：开始录音。
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
          _willCancel = false;
        });
      }
      _dragDy = 0;
    } catch (e) {
      if (mounted) showLiveSnack(context, '录音启动失败：$e');
    }
  }

  /// 按住期间上滑累计超过阈值 → 标记为取消（松开发送改为松开取消）。
  void _updateRecordDrag(Offset delta) {
    _dragDy += delta.dy;
    final willCancel = _dragDy < -60;
    if (willCancel != _willCancel && mounted) {
      setState(() => _willCancel = willCancel);
    }
  }

  /// 松开手指：send=true 上传并发送，否则丢弃。
  Future<void> _finishRecord({required bool send}) async {
    _recordTimer?.cancel();
    final path = _recordPath;
    final seconds = _recordSeconds;
    if (mounted) {
      setState(() {
        _recording = false;
        _willCancel = false;
        _recordSeconds = 0;
      });
    }
    _dragDy = 0;
    if (path == null) {
      // 录音未真正启动（如权限被拒），本次抬手直接忽略。
      try {
        await _recorder.stop();
      } catch (_) {
        // 未在录音，忽略
      }
      return;
    }
    if (!send) {
      await _discardRecord(path);
      return;
    }
    try {
      final finalPath = await _recorder.stop();
      final file = File(finalPath ?? path);
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
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {
        // 临时文件清理失败不影响发送
      }
    }
  }

  /// 取消录音：停止并删除临时文件。
  Future<void> _discardRecord(String? path) async {
    try {
      await _recorder.stop();
    } catch (_) {
      // 录音可能尚未真正启动
    }
    _recordPath = null;
    try {
      final f = File(path ?? '');
      if (await f.exists()) await f.delete();
    } catch (_) {
      // 临时文件清理失败不影响
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

  /// 拍摄：调起相机拍照 → 上传（/api/uploads/images，folder=chat）→ 作为图片消息发送。
  Future<void> _takePhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      final url = await UploadService.instance.uploadImage(
        bytes,
        picked.name.isEmpty
            ? 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg'
            : picked.name,
        folder: 'chat',
      );
      if (mounted) await _sendImage(url);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } catch (e) {
      if (mounted) showLiveSnack(context, '拍照失败：$e');
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

  /// “+”面板是否展开（键盘式：面板紧贴输入框下端，代替键盘位置）。
  bool _attachPanelOpen = false;

  void _toggleAttachPanel() {
    FocusScope.of(context).unfocus();
    setState(() => _attachPanelOpen = !_attachPanelOpen);
  }

  void _closeAttachPanel() {
    if (_attachPanelOpen) setState(() => _attachPanelOpen = false);
  }

  /// 相册 / 拍摄 / 文件 / 名片面板（内联在输入框下方，像键盘一样滑出）。
  Widget _buildAttachPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: LiveColors.bg,
        border: Border(top: BorderSide(color: LiveColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _AttachItem(
              icon: Icons.photo_library_outlined,
              label: '相册',
              onTap: () {
                _closeAttachPanel();
                _pickImages();
              },
            ),
            _AttachItem(
              icon: Icons.photo_camera_outlined,
              label: '拍摄',
              onTap: () {
                _closeAttachPanel();
                _takePhoto();
              },
            ),
            _AttachItem(
              icon: Icons.description_outlined,
              label: '文件',
              onTap: () {
                _closeAttachPanel();
                showLiveSnack(context, '文件功能敬请期待');
              },
            ),
            _AttachItem(
              icon: Icons.person_outline,
              label: '名片',
              onTap: () {
                _closeAttachPanel();
                showLiveSnack(context, '名片功能敬请期待');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = AuthStore.instance.userId;
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
                    IconButton(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: LiveColors.textPrimary,
                      ),
                      onPressed: () => LiveRoutes.pushId(
                        context,
                        RoutePaths.chatGroupSettings,
                        widget.groupId!,
                      ),
                    ),
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: LiveColors.textPrimary),
                      onPressed: () async {
                        await LiveRoutes.push(
                          context,
                          RoutePaths.chatInfo,
                          extra: {
                            'peerId': widget.peerId,
                            'peerName': widget.peerName,
                            'peerAvatar': widget.peerAvatar,
                            'conversationId': widget.conversationId ?? 0,
                          },
                        );
                        // 从聊天信息页返回（可能清空过聊天记录 / 调整过置顶）后重新拉取消息，
                        // 让清空效果在回到聊天页时立即生效。
                        if (mounted) _loadMessages();
                      },
                    ),
                  ],
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
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
                                // 单聊/群聊都显示双方头像（我自己的头像在右侧）
                                showAvatar: true,
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
                // 按住说话录音浮层（对齐用户设计稿：压暗消息区 + 居中绿色圆角面板 + 提示文字）
                if (_recording)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xBF141414),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 290,
                              padding: const EdgeInsets.symmetric(
                                vertical: 22,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFAAEA7A),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: _RecordingWaveform(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _willCancel ? '松开 取消' : '松开发送 · 上滑取消',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _willCancel
                                    ? const Color(0xFFFF3B30)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 键盘弹出时输入栏跟随键盘上移（viewInsets 补偿）。
          // 补偿逻辑隔离在 _KeyboardInsetBox 内，键盘动画期间只重建输入栏，
          // 消息列表等主体不再逐帧重建，键盘启动更流畅。
          _KeyboardInsetBox(
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
                              onPressed: _toggleVoiceMode,
                              icon: _voiceMode
                                  ? Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF141414),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.mic,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.mic_none,
                                      color: LiveColors.textSecondary,
                                      size: 25,
                                    ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _voiceMode
                                  ? _VoiceHoldButton(
                                      onStart: _startRecord,
                                      onMove: _updateRecordDrag,
                                      onEnd: () =>
                                          _finishRecord(send: !_willCancel),
                                      onCancel: () =>
                                          _finishRecord(send: false),
                                    )
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
                                        onTap: () => _closeAttachPanel(),
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
                            IconButton(
                              onPressed: _toggleAttachPanel,
                              icon: const Icon(Icons.add_circle_outline, color: LiveColors.textSecondary, size: 24),
                            ),
                            if (!_voiceMode) ...[
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
                                      colors: [
                                        Color(0xFF333333),
                                        Color(0xFF141414),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: _sending
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
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
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _toggleVoiceMode,
                              icon: _voiceMode
                                  ? Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF141414),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.mic,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.mic_none,
                                      color: LiveColors.textSecondary,
                                      size: 22,
                                    ),
                            ),
                            Expanded(
                              child: _voiceMode
                                  ? _VoiceHoldButton(
                                      onStart: _startRecord,
                                      onMove: _updateRecordDrag,
                                      onEnd: () =>
                                          _finishRecord(send: !_willCancel),
                                      onCancel: () =>
                                          _finishRecord(send: false),
                                    )
                                  : TextField(
                                      controller: _inputCtrl,
                                      minLines: 1,
                                      maxLines: 4,
                                      onTap: () => _closeAttachPanel(),
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
                              onPressed: _showEmojiPanel,
                              icon: const Icon(Icons.emoji_emotions_outlined, color: LiveColors.textSecondary, size: 22),
                            ),
                            IconButton(
                              onPressed: _toggleAttachPanel,
                              icon: const Icon(Icons.add_circle_outline, color: LiveColors.textSecondary, size: 24),
                            ),
                            if (!_voiceMode) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _sending ? null : _send,
                                icon: _sending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: LiveColors.brand),
                                      )
                                    : const Icon(
                                        Icons.send,
                                        color: LiveColors.brand,
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
            ),
            // “+”面板：像键盘一样紧贴输入框下端弹出（相册 / 拍摄 / 文件 / 名片）
            if (_attachPanelOpen) _buildAttachPanel(),
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
      // 图片消息：无背景、无内边距，图片本身就是气泡（圆角展示）
      padding: isImage
          ? EdgeInsets.zero
          : (isGroup
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 11)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 9)),
      decoration: BoxDecoration(
        color: isImage
            ? Colors.transparent
            : (message.isRecalled
                ? LiveColors.card
                : (isGroup ? (isMine ? null : LiveColors.card) : bubbleColor)),
        gradient: !isImage &&
                isGroup &&
                !message.isRecalled &&
                isMine
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
            if (isMine && showAvatar)
              Padding(
                padding: const EdgeInsets.only(left: 8),
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
