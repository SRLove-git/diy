part of 'chat_screens.dart';

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
                              separatorBuilder: (_, _) => const Divider(
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

/// 语音模式「按住 说话」按钮（对齐 Pixso 63：浅灰胶囊 + 麦克风图标）。
class _VoiceHoldButton extends StatelessWidget {
  const _VoiceHoldButton({
    required this.onStart,
    required this.onMove,
    required this.onEnd,
    required this.onCancel,
  });

  final VoidCallback onStart;
  final ValueChanged<Offset> onMove;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onStart(),
      onPointerMove: (e) => onMove(e.delta),
      onPointerUp: (_) => onEnd(),
      onPointerCancel: (_) => onCancel(),
      child: Container(
        height: 47,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(21),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_none, size: 18, color: Color(0xFF141414)),
            SizedBox(width: 8),
            Text(
              '按住 说话',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF141414),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 输入栏键盘补偿容器：只在此处订阅 viewInsets 变化并计算画布缩放，
/// 键盘弹出动画期间仅输入栏子树重建，聊天页主体（消息列表等）不逐帧重建。
class _KeyboardInsetBox extends StatefulWidget {
  const _KeyboardInsetBox({required this.child});

  final Widget child;

  @override
  State<_KeyboardInsetBox> createState() => _KeyboardInsetBoxState();
}

class _KeyboardInsetBoxState extends State<_KeyboardInsetBox> {
  /// 键盘弹出前（无键盘遮挡时）的窗口高度，用于计算画布缩放比例。
  double? _noKeyboardHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.of(context);
    if (mq.viewInsets.bottom == 0) {
      _noKeyboardHeight = mq.size.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 外层 LiveHost 用 FittedBox 把 440x956 画布缩放到屏幕，
    // 输入栏的 viewInsets 补偿需按缩放比例放大，才能恰好把输入框顶到键盘上沿。
    final mq = MediaQuery.of(context);
    final canvasHeight = _noKeyboardHeight ?? mq.size.height;
    final canvasScale = math.min(
      mq.size.width / 440,
      canvasHeight / 956,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom / canvasScale),
      child: widget.child,
    );
  }
}

/// 录音浮层内的深色波形条（对齐用户设计稿：绿色面板中的竖条波形）。
/// 录音期间定时刷新高度，模拟人声起伏动画。
class _RecordingWaveform extends StatefulWidget {
  const _RecordingWaveform();

  @override
  State<_RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<_RecordingWaveform> {
  static const int _barCount = 13;
  static const double _maxHeight = 38;
  static const double _minHeight = 8;
  final math.Random _random = math.Random();
  Timer? _timer;
  late List<double> _heights;

  double _nextHeight() {
    // 模拟人声节奏：大多数柱子落在中等高度区间，偶尔偏高或偏低。
    return _minHeight + (_maxHeight - _minHeight) * _random.nextDouble();
  }

  @override
  void initState() {
    super.initState();
    _heights = List.generate(_barCount, (_) => _nextHeight());
    _timer = Timer.periodic(const Duration(milliseconds: 160), (_) {
      if (mounted) {
        setState(() {
          _heights = List.generate(_barCount, (_) => _nextHeight());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 固定高度区域，柱子在其中起伏，绿色面板尺寸保持稳定。
    return SizedBox(
      height: _maxHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < _heights.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeInOut,
              width: 4,
              height: _heights[i],
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
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
Future<bool?> showDesignConfirmDialog(
  BuildContext context, {
  String? avatarUrl,
  String? name,
  required String title,
  required String message,
  required String confirmLabel,
  Color confirmColor = const Color(0xFFFF3B30),
}) {
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
              if (name != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Avatar(
                    url: avatarUrl ?? '',
                    name: name,
                    size: 40,
                  ),
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

/// 群成员管理确认弹窗（设为管理员 / 移出群聊），复用通用设计稿弹窗。
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
  return showDesignConfirmDialog(
    context,
    avatarUrl: member.avatar,
    name: member.nickname,
    title: title,
    message: message,
    confirmLabel: setAdmin ? '设为管理员' : '移出',
    confirmColor: setAdmin
        ? const Color(0xFF141414)
        : const Color(0xFFFF3B30),
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

