part of 'chat_screens.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _accountCtrl = TextEditingController();
  List<User> _results = [];
  List<FollowUser> _following = [];
  final Set<int> _selectedGroup = {};
  String _tab = 'username'; // username / following
  bool _searching = false;

  @override
  void dispose() {
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final username = _accountCtrl.text.trim();
    if (username.isEmpty) return;
    setState(() => _searching = true);
    try {
      final users = await UserService.instance.searchByUsername(username);
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
          // 顶部分段器：用户名搜索 / 我的关注（对齐设计稿 25-添加好友）
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
                    ('username', '用户名搜索'),
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
          // 用户名搜索 Tab：搜索框 + 结果卡片
          if (_tab == 'username') ...[
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
                        controller: _accountCtrl,
                        decoration: const InputDecoration(
                          hintText: '输入对方用户名',
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
                  ? const EmptyView(text: '输入用户名搜索好友', icon: Icons.person_search_outlined)
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

/// 用户名搜索结果行（对齐设计稿：头像 + 名称/副标题 + 「添加 / 已添加」按钮）。
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
                    '@${user.username ?? ''} · ${user.location.isEmpty ? '未填地区' : user.location}',
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
class ChatInfoScreen extends StatefulWidget {
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

  @override
  State<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  bool _pinned = false;
  bool _muted = false;
  bool _notify = true;

  Future<void> _deleteConversation() async {
    try {
      await ChatService.instance.deleteConversation(widget.conversationId);
      if (!mounted) return;
      {
        // 提示先于导航插入顶层 Overlay，随后一次性回到会话列表。
        // 不要在同一帧连续 pop 两个 route（聊天信息 + 单聊），
        // 否则会触发 InheritedElement 依赖残留断言（_dependents.isEmpty）。
        showLiveSnack(context, '会话已删除');
        // 等退场中的路由（单聊 + 聊天信息）稳定后再切回 Shell Tab，
        // 避免外层路由与 Shell 页面在过渡期同时携带相同 page key，
        // 触发 '!keyReservation.contains(key)' 断言（flutter/flutter#140586）。
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        LiveRoutes.switchTab(context, 3);
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _togglePin(bool v) async {
    setState(() => _pinned = v);
    if (widget.conversationId <= 0) return;
    try {
      await ChatService.instance.pinConversation(widget.conversationId, v);
    } on ApiException catch (e) {
      if (mounted) {
        showLiveSnack(context, e.message);
        setState(() => _pinned = !v);
      }
    }
  }

  Future<void> _clearMessages() async {
    final ok = await showDesignConfirmDialog(
      context,
      avatarUrl: widget.peerAvatar,
      name: widget.peerName,
      title: '清空聊天记录',
      message: '清空后你这边将不再显示与该好友的聊天记录，对端不受影响。确定清空吗？',
      confirmLabel: '清空',
      confirmColor: const Color(0xFFFF3B30),
    );
    if (ok != true || !mounted) return;
    try {
      await ChatService.instance.clearMessages(widget.conversationId);
      if (mounted) showLiveSnack(context, '聊天记录已清空');
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _blockUser() async {
    final ok = await showDesignConfirmDialog(
      context,
      avatarUrl: widget.peerAvatar,
      name: widget.peerName,
      title: '将「${widget.peerName}」加入黑名单',
      message: '加入黑名单后 TA 将无法给你发消息，你也不会再收到 TA 的消息',
      confirmLabel: '加入',
      confirmColor: const Color(0xFFFF3B30),
    );
    if (ok != true || !mounted) return;
    try {
      await ChatService.instance.setBlocked(widget.peerId, true);
      if (!mounted) return;
      showLiveSnack(context, '已加入黑名单');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      LiveRoutes.switchTab(context, 3);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
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
                // 头像圆环 + 昵称 + 在线（对齐 Pixso 51-聊天信息）
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF333333), Color(0xFF141414)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Avatar(
                        url: widget.peerAvatar,
                        name: widget.peerName,
                        size: 72,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    widget.peerName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 8, color: LiveColors.success),
                    SizedBox(width: 4),
                    Text(
                      '在线',
                      style: TextStyle(
                        fontSize: 11,
                        color: LiveColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                // 个人信息卡
                _InfoCard(
                  children: [
                    _InfoIconRow(
                      icon: Icons.person_outline,
                      title: '个人资料',
                      desc: '昵称 · 签名 · 地区',
                      onTap: () => LiveRoutes.pushId(
                        context,
                        RoutePaths.userDetail,
                        widget.peerId,
                      ),
                    ),
                    const Divider(height: 1, color: LiveColors.divider),
                    _InfoIconRow(
                      icon: Icons.person_search_outlined,
                      title: '查看 TA 的主页',
                      desc: '作品 · 粉丝 · 关注',
                      onTap: () => LiveRoutes.pushId(
                        context,
                        RoutePaths.userDetail,
                        widget.peerId,
                      ),
                    ),
                  ],
                ),
                // 设置卡：置顶 / 免打扰 / 通知 / 清空
                _InfoCard(
                  children: [
                    _InfoSwitchRow(
                      title: '置顶聊天',
                      value: _pinned,
                      onChanged: _togglePin,
                    ),
                    const Divider(height: 1, color: LiveColors.divider),
                    _InfoSwitchRow(
                      title: '消息免打扰',
                      value: _muted,
                      onChanged: (v) => setState(() => _muted = v),
                    ),
                    const Divider(height: 1, color: LiveColors.divider),
                    _InfoSwitchRow(
                      title: '消息通知',
                      value: _notify,
                      onChanged: (v) => setState(() => _notify = v),
                    ),
                    const Divider(height: 1, color: LiveColors.divider),
                    _InfoChevronRow(
                      title: '清空聊天记录',
                      onTap: _clearMessages,
                    ),
                  ],
                ),
                // 危险操作卡（浅红底 + 浅红分隔线）
                _InfoCard(
                  danger: true,
                  children: [
                    _DangerRow(label: '加入黑名单', onTap: _blockUser),
                    const Divider(height: 1, color: Color(0xFFFFE3E3)),
                    _DangerRow(label: '删除会话', onTap: _deleteConversation),
                    const Divider(height: 1, color: Color(0xFFFFE3E3)),
                    _DangerRow(
                      label: '投诉',
                      onTap: () => showLiveSnack(context, '投诉功能敬请期待'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 设置卡片容器：白底 / 浅红底，圆角 16，内衬 4/16。
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children, this.danger = false});

  final List<Widget> children;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFFF7F7) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: danger ? const Color(0xFFFFE3E3) : LiveColors.divider,
        ),
      ),
      child: Column(children: children),
    );
  }
}

/// 个人信息行：浅色图标块 + 标题/描述 + 右箭头。
class _InfoIconRow extends StatelessWidget {
  const _InfoIconRow({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: LiveColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: LiveColors.textTertiary,
                    ),
                  ),
                ],
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

/// 设置行：标题 + 设计稿开关（44×26 圆角滑块）。
class _InfoSwitchRow extends StatelessWidget {
  const _InfoSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: LiveColors.textPrimary,
              ),
            ),
          ),
          _DesignSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// 普通跳转行：标题 + 右箭头（清空聊天记录）。
class _InfoChevronRow extends StatelessWidget {
  const _InfoChevronRow({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LiveColors.textPrimary,
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

/// 红色危险操作行（加入黑名单 / 删除会话 / 投诉）。
class _DangerRow extends StatelessWidget {
  const _DangerRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: LiveColors.danger,
          ),
        ),
      ),
    );
  }
}

/// 设计稿开关：44×26 圆角，开=黑底白钮靠右，关=浅灰底白钮靠左。
class _DesignSwitch extends StatelessWidget {
  const _DesignSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF141414) : const Color(0xFFE4E4E8),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
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
                            separatorBuilder: (_, _) => const Divider(height: 1, color: LiveColors.divider),
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
