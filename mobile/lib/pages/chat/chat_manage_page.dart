import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../community/user_profile_page.dart';

/// 私聊聊天信息页（单聊右上角入口，参照微信「聊天信息」布局）
///
/// - 顶部：对方头像 + 昵称（在线状态圆点）
/// - 中部：置顶聊天 / 查看个人主页
/// - 底部：删除聊天
class ChatManagePage extends StatefulWidget {
  const ChatManagePage({
    super.key,
    required this.conversation,
    this.onBlockChanged,
  });

  final Conversation conversation;

  /// 拉黑状态变化回调（聊天页据此刷新输入栏提示）
  final ValueChanged<bool>? onBlockChanged;

  @override
  State<ChatManagePage> createState() => _ChatManagePageState();
}

class _ChatManagePageState extends State<ChatManagePage> {
  late bool _pinned;
  late bool _blockedByMe;
  bool _busy = false;

  int get _peerId => widget.conversation.peerId;
  String get _peerName => widget.conversation.peerNickname.isEmpty
      ? '用户 #$_peerId'
      : widget.conversation.peerNickname;
  String get _peerAvatar => widget.conversation.peerAvatar;

  @override
  void initState() {
    super.initState();
    _pinned = widget.conversation.pinned;
    _blockedByMe = widget.conversation.peerBlockedByMe;
  }

  /// 置顶 / 取消置顶：成功后 ChatService 同步更新会话列表排序
  Future<void> _togglePinned(bool pinned) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _pinned = pinned;
    });
    final ok = await ChatService.instance
        .pinConversation(widget.conversation.id, pinned);
    if (!mounted) return;
    if (!ok) {
      setState(() => _pinned = !pinned);
      _toast('操作失败，请稍后再试');
    }
    setState(() => _busy = false);
  }

  /// 查看对方个人主页
  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfilePage(
          userId: _peerId,
          nickname: widget.conversation.peerNickname,
          avatar: widget.conversation.peerAvatar,
        ),
      ),
    );
  }

  /// 删除聊天：成功后返回聊天页并关闭（会话列表同步移除）
  Future<void> _deleteConversation() async {
    final ok = await _confirmDanger(
      title: '删除聊天',
      message: '删除后该会话将从列表移除，确定删除吗？',
      action: '删除',
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final success = await ChatService.instance
        .deleteConversation(widget.conversation.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (success) {
      Navigator.of(context).pop('deleted');
    } else {
      _toast('删除失败，请稍后再试');
    }
  }

  /// 拉黑 / 移出黑名单：成功后同步聊天页状态并更新会话缓存
  Future<void> _toggleBlock() async {
    if (_busy) return;
    final blocking = !_blockedByMe;
    if (blocking) {
      final ok = await _confirmDanger(
        title: '加入黑名单',
        message: '加入黑名单后，你们将无法互发消息，确定加入吗？',
        action: '加入',
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      final rel = await ChatApi.setBlock(_peerId, blocked: blocking);
      if (!mounted) return;
      setState(() => _blockedByMe = rel.blockedByMe);
      ChatService.instance.updateConversationBlocked(
        widget.conversation.id,
        blockedByMe: rel.blockedByMe,
        blockedByPeer: rel.blockedByPeer,
      );
      widget.onBlockChanged?.call(rel.blockedByMe);
      _toast(blocking ? '已加入黑名单' : '已移出黑名单');
    } catch (_) {
      if (mounted) _toast('操作失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirmDanger({
    required String title,
    required String message,
    required String action,
  }) {
    final colors = AppColors.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: colors.danger),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.placeholder,
      appBar: AppBar(title: const Text('聊天信息')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 8),
            _buildPeerHeader(colors),
            const SizedBox(height: 8),
            _buildPinRow(colors),
            const SizedBox(height: 8),
            _buildProfileRow(colors),
            const SizedBox(height: 8),
            _buildBlockRow(colors),
            const SizedBox(height: 8),
            _buildDangerRow(colors),
          ],
        ),
      ),
    );
  }

  /// 最上方：对方头像 + 昵称 + 在线状态
  Widget _buildPeerHeader(AppColors colors) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          _PeerAvatar(
            avatar: _peerAvatar,
            nickname: _peerName,
            size: 72,
            colors: colors,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _peerName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ListenableBuilder(
                listenable: ChatService.instance,
                builder: (context, _) {
                  final online =
                      ChatService.instance.isPeerOnline(_peerId);
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: online
                          ? Palette.success
                          : colors.textSecondary.withValues(alpha: 0.35),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 置顶聊天（微信样式：行内 Switch）
  Widget _buildPinRow(AppColors colors) {
    return Material(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          children: [
            const Expanded(
              child: Text('置顶聊天', style: TextStyle(fontSize: 15)),
            ),
            Switch(
              value: _pinned,
              onChanged: _busy ? null : _togglePinned,
            ),
          ],
        ),
      ),
    );
  }

  /// 查看个人主页
  Widget _buildProfileRow(AppColors colors) {
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: _busy ? null : _openProfile,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              const Expanded(
                child: Text('查看个人主页', style: TextStyle(fontSize: 15)),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  /// 拉黑 / 移出黑名单（微信样式：行内红色文字操作）
  Widget _buildBlockRow(AppColors colors) {
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: _busy ? null : _toggleBlock,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(
                _blockedByMe
                    ? Icons.person_off_outlined
                    : Icons.block_outlined,
                size: 20,
                color: _blockedByMe ? colors.textSecondary : colors.danger,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _blockedByMe ? '移出黑名单' : '加入黑名单',
                  style: TextStyle(
                    fontSize: 15,
                    color: _blockedByMe ? colors.textSecondary : colors.danger,
                  ),
                ),
              ),
              if (_blockedByMe)
                Text(
                  '已拉黑',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 底部红色按钮：删除聊天
  Widget _buildDangerRow(AppColors colors) {
    return Container(
      color: colors.surface,
      child: InkWell(
        onTap: _busy ? null : _deleteConversation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: Text(
              '删除聊天',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 对方头像（圆形，缺失时显示昵称首字占位）
class _PeerAvatar extends StatelessWidget {
  const _PeerAvatar({
    required this.avatar,
    required this.nickname,
    required this.size,
    required this.colors,
  });

  final String avatar;
  final String nickname;
  final double size;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final url = avatar.trim();
    final hasImage = url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.placeholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              ChatApi.resolveUrl(url),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initial(),
            )
          : _initial(),
    );
  }

  /// 首字占位：中文按字符取首字，避免 String[0] 截断多字节字符
  Widget _initial() {
    final name = nickname.trim();
    final initial = name.isEmpty ? '?' : String.fromCharCode(name.runes.first);
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
