import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../core/follow_api.dart';
import '../../widgets/state_widgets.dart';

/// 群聊信息页（群聊右上角入口，参照微信「聊天信息」布局）
///
/// - 顶部：成员头像网格（群主角标 +「邀请」格，点成员弹详情可移出）
/// - 中部：群聊名称（群主可修改）等设置行
/// - 底部：群主解散群聊 / 成员退出群聊
class GroupManagePage extends StatefulWidget {
  const GroupManagePage({super.key, required this.group});

  final GroupChat group;

  @override
  State<GroupManagePage> createState() => _GroupManagePageState();
}

class _GroupManagePageState extends State<GroupManagePage> {
  List<GroupMemberInfo> _members = [];
  late String _groupName;
  bool _loading = true;
  String? _error;
  bool _busy = false;
  StreamSubscription<ChatEvent>? _sub;

  /// 页面已关闭（REST 返回结果 / WS 解散事件都可能触发 pop），防止重复 pop
  bool _popped = false;

  /// 群主标识以服务端下发的 isOwner 为准（建群/刷新列表时计算）
  bool get _isOwner => widget.group.isOwner;

  /// 网格最多展示 3 行（微信样式），更多走「更多群成员」列表
  static const int _maxGridMembers = 15;

  @override
  void initState() {
    super.initState();
    _groupName = widget.group.name;
    _sub = ChatService.instance.events.listen(_onEvent);
    _load();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(ChatEvent event) {
    if (event is GroupMemberChangedEvent &&
        event.groupId == widget.group.id) {
      _load();
      ChatService.instance.refreshGroups().then((_) {
        if (mounted) _syncGroupName();
      });
      return;
    }
    if (event is GroupRemovedEvent && event.groupId == widget.group.id) {
      _close('removed');
    }
  }

  /// 关闭群管理页（幂等）
  void _close([String? result]) {
    if (_popped || !mounted) return;
    _popped = true;
    Navigator.of(context).pop(result);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final members = await GroupApi.fetchMembers(widget.group.id);
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '成员加载失败';
        });
      }
    }
  }

  /// 群重命名后从缓存同步新名称
  void _syncGroupName() {
    for (final g in ChatService.instance.groups) {
      if (g.id == widget.group.id && g.name != _groupName) {
        setState(() => _groupName = g.name);
        return;
      }
    }
  }

  Future<void> _openAddMembers() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _PickMembersPage(
          groupId: widget.group.id,
          existingMemberIds: _members.map((m) => m.id).toSet(),
        ),
      ),
    );
    if (added == true) {
      _toast('已加入群聊');
      _load();
      ChatService.instance.refreshGroups();
    }
  }

  Future<void> _renameGroup() async {
    final ctrl = TextEditingController(text: _groupName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改群聊名称'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '输入群聊名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == _groupName || !mounted) return;
    setState(() => _busy = true);
    try {
      await GroupApi.renameGroup(widget.group.id, name);
      if (!mounted) return;
      setState(() {
        _groupName = name;
        _busy = false;
      });
      _toast('群聊名称已修改');
      ChatService.instance.refreshGroups();
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _toast(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  /// 点成员头像：底部弹出成员详情，群主可在此移出
  void _openMemberSheet(GroupMemberInfo member) {
    final colors = AppColors.of(context);
    final nickname =
        member.nickname.isEmpty ? '用户 #${member.id}' : member.nickname;
    final isOwnerMember = member.id == widget.group.ownerId;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MemberAvatar(member: member, size: 64, colors: colors),
              const SizedBox(height: 10),
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isOwnerMember) ...[
                const SizedBox(height: 6),
                _OwnerBadge(colors: colors),
              ],
              const SizedBox(height: 18),
              if (_isOwner && !isOwnerMember) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmKick(member);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.danger,
                      side: BorderSide(color: colors.danger),
                      minimumSize: const Size.fromHeight(42),
                    ),
                    child: const Text('移出群聊'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  '关闭',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmKick(GroupMemberInfo member) async {
    final ok = await _confirmDanger(
      title: '移出群聊',
      message: '确定将「${_displayName(member)}」移出群聊吗？',
      action: '移出',
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await GroupApi.kickMember(widget.group.id, member.id);
      if (!mounted) return;
      _toast('已移出 ${_displayName(member)}');
      _load();
      ChatService.instance.refreshGroups();
    } catch (e) {
      if (mounted) _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leaveGroup() async {
    final ok = await _confirmDanger(
      title: '退出群聊',
      message: '退出后将无法查看该群的历史消息，确定退出吗？',
      action: '退出',
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await GroupApi.leaveGroup(widget.group.id);
      if (!mounted) return;
      _close('left');
      ChatService.instance.refreshGroups();
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _toast(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _dissolveGroup() async {
    final ok = await _confirmDanger(
      title: '解散群聊',
      message: '解散后所有成员将无法查看群消息，且不可恢复。确定解散吗？',
      action: '解散',
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await GroupApi.dissolveGroup(widget.group.id);
      if (!mounted) return;
      _close('dissolved');
      ChatService.instance.refreshGroups();
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _toast(e.toString().replaceFirst('Exception: ', ''));
      }
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

  String _displayName(GroupMemberInfo m) =>
      m.nickname.isEmpty ? '用户 #${m.id}' : m.nickname;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.placeholder,
      appBar: AppBar(
        title: Text('群聊信息（${_members.length}）'),
      ),
      body: SafeArea(
        child: _loading
            ? const LoadingWidget(message: '加载成员…')
            : _error != null
                ? AppErrorWidget(message: _error!, onRetry: _load)
                : _buildBody(colors),
      ),
    );
  }

  Widget _buildBody(AppColors colors) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 8),
        _buildMemberGrid(colors),
        if (_members.length > _maxGridMembers) ...[
          const SizedBox(height: 8),
          _buildMoreMembersRow(colors),
        ],
        const SizedBox(height: 8),
        _buildNameRow(colors),
        const SizedBox(height: 8),
        _buildDangerRow(colors),
      ],
    );
  }

  /// 顶部成员头像网格（微信样式：5 列 +「邀请」格）
  Widget _buildMemberGrid(AppColors colors) {
    final shown = _members.take(_maxGridMembers).toList();
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
        children: [
          for (final m in shown)
            _MemberGridCell(
              member: m,
              isOwner: m.id == widget.group.ownerId,
              colors: colors,
              onTap: _busy ? null : () => _openMemberSheet(m),
            ),
          // 「邀请」格：拉人进群
          _InviteCell(
            colors: colors,
            onTap: _busy ? null : _openAddMembers,
          ),
        ],
      ),
    );
  }

  /// 成员超过网格容量时的「更多群成员」入口
  Widget _buildMoreMembersRow(AppColors colors) {
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: _busy
            ? null
            : () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => GroupMembersPage(
                      group: widget.group,
                      onTapMember: _openMemberSheet,
                    ),
                  ),
                );
                _load();
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              const Expanded(
                child: Text('更多群成员', style: TextStyle(fontSize: 15)),
              ),
              Text(
                '共 ${_members.length} 人',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  /// 群聊名称行（群主可修改）
  Widget _buildNameRow(AppColors colors) {
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: _isOwner && !_busy ? _renameGroup : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              const Expanded(
                child: Text('群聊名称', style: TextStyle(fontSize: 15)),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  _groupName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: colors.textSecondary),
                ),
              ),
              if (_isOwner)
                Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  /// 底部红色按钮：解散（群主）/ 退出（成员）
  Widget _buildDangerRow(AppColors colors) {
    return Container(
      color: colors.surface,
      child: InkWell(
        onTap: _busy ? null : (_isOwner ? _dissolveGroup : _leaveGroup),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: Text(
              _isOwner ? '解散群聊' : '退出群聊',
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

/// 成员头像（圆形 + 群主角标）
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.member,
    required this.colors,
    this.size = 46,
    this.showOwnerBadge = true,
  });

  final GroupMemberInfo member;
  final AppColors colors;
  final double size;
  final bool showOwnerBadge;

  @override
  Widget build(BuildContext context) {
    final avatar = member.avatar;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.placeholder,
              ),
              clipBehavior: Clip.antiAlias,
              child: avatar.isEmpty
                  ? Center(
                      child: Text(
                        member.nickname.isEmpty
                            ? '#'
                            : member.nickname.characters.first,
                        style: TextStyle(
                          fontSize: size * 0.36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Image.network(
                      ChatApi.resolveUrl(avatar),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.person,
                        color: colors.textSecondary,
                      ),
                    ),
            ),
          ),
          if (showOwnerBadge)
            Positioned(
              right: -3,
              bottom: -2,
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                  border: Border.all(color: colors.surface, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '主',
                    style: TextStyle(
                      fontSize: size * 0.2,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

/// 群主标签（底部弹层内使用）
class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '群主',
        style: TextStyle(fontSize: 11, color: colors.primary),
      ),
    );
  }
}

/// 头像网格单元：头像 + 昵称
class _MemberGridCell extends StatelessWidget {
  const _MemberGridCell({
    required this.member,
    required this.isOwner,
    required this.colors,
    required this.onTap,
  });

  final GroupMemberInfo member;
  final bool isOwner;
  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final nickname =
        member.nickname.isEmpty ? '用户 #${member.id}' : member.nickname;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MemberAvatar(member: member, colors: colors, showOwnerBadge: isOwner),
          const SizedBox(height: 6),
          Text(
            nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// 「邀请」格：拉人进群
class _InviteCell extends StatelessWidget {
  const _InviteCell({required this.colors, required this.onTap});

  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.placeholder,
            ),
            child: Icon(Icons.add_rounded, color: colors.textSecondary),
          ),
          const SizedBox(height: 6),
          const Text('邀请', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

/// 全部群成员列表（群成员超网格容量时从「更多群成员」进入）
class GroupMembersPage extends StatefulWidget {
  const GroupMembersPage({
    super.key,
    required this.group,
    required this.onTapMember,
  });

  final GroupChat group;
  final void Function(GroupMemberInfo member) onTapMember;

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  List<GroupMemberInfo> _members = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<ChatEvent>? _sub;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _sub = ChatService.instance.events.listen(_onEvent);
    _load();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(ChatEvent event) {
    if (event is GroupMemberChangedEvent &&
        event.groupId == widget.group.id) {
      _load();
      return;
    }
    if (event is GroupRemovedEvent && event.groupId == widget.group.id) {
      if (_popped || !mounted) return;
      _popped = true;
      Navigator.of(context).pop();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final members = await GroupApi.fetchMembers(widget.group.id);
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '成员加载失败';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.placeholder,
      appBar: AppBar(title: Text('群成员（${_members.length}）')),
      body: _loading
          ? const LoadingWidget(message: '加载成员…')
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _members.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: colors.divider),
                  itemBuilder: (context, index) {
                    final m = _members[index];
                    final nickname = m.nickname.isEmpty
                        ? '用户 #${m.id}'
                        : m.nickname;
                    return Material(
                      color: colors.surface,
                      child: InkWell(
                        onTap: () => widget.onTapMember(m),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              _MemberAvatar(
                                member: m,
                                colors: colors,
                                size: 44,
                                showOwnerBadge: m.id == widget.group.ownerId,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  nickname,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              if (m.id == widget.group.ownerId)
                                _OwnerBadge(colors: colors),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

/// 拉人进群：从已关注用户中多选（已在群内成员不展示）
class _PickMembersPage extends StatefulWidget {
  const _PickMembersPage({
    required this.groupId,
    required this.existingMemberIds,
  });

  final int groupId;
  final Set<int> existingMemberIds;

  @override
  State<_PickMembersPage> createState() => _PickMembersPageState();
}

class _PickMembersPageState extends State<_PickMembersPage> {
  List<FollowUser> _candidates = [];
  final Set<int> _selected = {};
  bool _loading = true;
  String? _error;
  bool _adding = false;

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
      final list = await FollowApi.fetchFollowing();
      if (mounted) {
        setState(() {
          // 已在群内的成员不可再邀请
          _candidates =
              list.where((u) => !widget.existingMemberIds.contains(u.id)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败，请重试';
        });
      }
    }
  }

  Future<void> _add() async {
    if (_selected.isEmpty) {
      _toast('请选择要邀请的成员');
      return;
    }
    setState(() => _adding = true);
    try {
      await GroupApi.addMembers(widget.groupId, _selected.toList());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _adding = false);
        _toast(e.toString().replaceFirst('Exception: ', ''));
      }
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
      appBar: AppBar(title: const Text('拉人进群')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Text(
                  '从关注的人中选择',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '已选 ${_selected.length} 人',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(child: _buildMemberList(colors)),
          _buildAddBar(colors),
        ],
      ),
    );
  }

  Widget _buildMemberList(AppColors colors) {
    if (_loading) return const LoadingWidget(message: '加载关注列表…');
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    if (_candidates.isEmpty) {
      return const EmptyWidget(
        icon: Icons.person_search_outlined,
        message: '没有可邀请的关注用户\n群成员均已在这群人里',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _candidates.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: colors.divider),
      itemBuilder: (context, index) {
        final user = _candidates[index];
        final checked = _selected.contains(user.id);
        return InkWell(
          onTap: () {
            setState(() {
              checked ? _selected.remove(user.id) : _selected.add(user.id);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _avatar(user, colors),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.nickname.isEmpty ? '用户 #${user.id}' : user.nickname,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Icon(
                  checked
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: checked ? colors.primary : colors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _avatar(FollowUser user, AppColors colors) {
    final avatar = user.resolvedAvatar;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.placeholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatar.isEmpty
          ? Center(
              child: Text(
                user.nickname.isEmpty ? '#' : user.nickname.characters.first,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          : Image.network(
              avatar,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.person,
                color: colors.textSecondary,
              ),
            ),
    );
  }

  Widget _buildAddBar(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: FilledButton(
            onPressed: _adding ? null : _add,
            child: Text(_adding
                ? '添加中…'
                : '添加${_selected.isEmpty ? '' : '（${_selected.length}）'}'),
          ),
        ),
      ),
    );
  }
}
