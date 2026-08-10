part of 'chat_screens.dart';

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
    if (_busy) return;
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出群聊'),
        content: const Text('确定要退出该群聊吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('退出')),
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
        builder: (dialogContext) => StatefulBuilder(
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
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, selected),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('修改群名称'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '请输入新的群名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('解散群聊'),
        content: const Text('解散后所有成员将无法查看该群聊，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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
  const _GroupOption({required this.label, required this.onTap}) : value = null;

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
        builder: (dialogContext) => StatefulBuilder(
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
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, selected),
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
    if (_busy) return;
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('修改群名称'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '请输入新的群名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
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
    if (_busy) return;
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('群主转让'),
        content: Text('确定将群主转让给 ${target.nickname} 吗？转让后你将变为普通成员。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('转让'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (_busy) return;
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('解散群聊'),
        content: const Text('解散后所有成员将无法查看该群聊，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('解散'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (_busy) return;
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

