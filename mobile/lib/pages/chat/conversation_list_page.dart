import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../widgets/state_widgets.dart';
import 'add_friend_page.dart';
import 'chat_page.dart';
import 'create_group_page.dart';
import 'group_chat_page.dart';
import '../community/user_profile_page.dart';

/// 列表筛选
enum _Filter { all, unread }

/// 会话列表页（消息 Tab）
///
/// 对齐《聊天页面设计初稿》：导航栏（我的头像 + "聊天" + 筛选）、搜索栏、
/// 聊天列表（圆形头像 / 加粗昵称 / 灰色预览 / 时间戳 / 蓝色未读圆点）、
/// 长按条目弹出操作菜单（置顶 / 标已读 / 删除）。
class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key, this.onTapAvatar});

  /// 点击导航栏头像（通常切换到底部"我的" Tab）
  final VoidCallback? onTapAvatar;

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  StreamSubscription<ChatEvent>? _sub;
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  _Filter _filter = _Filter.all;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ChatService.instance.ensureConnected();
    // 实时事件（新消息/已读）会更新 service 缓存，这里统一触发重建
    _sub = ChatService.instance.events.listen((_) {
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final results = await Future.wait([
      ChatService.instance.refreshConversations(),
      ChatService.instance.refreshGroups(),
    ]);
    if (mounted) {
      setState(() {
        _loading = false;
        _loaded = true;
        if (!results.every((ok) => ok)) _error = '加载失败，请下拉重试';
      });
    }
  }

  /// 按筛选 + 搜索词过滤
  List<Conversation> _visible(List<Conversation> all) {
    final q = _query.trim().toLowerCase();
    return all
        .where((c) {
          if (_filter == _Filter.unread && c.unreadCount == 0) return false;
          if (q.isEmpty) return true;
          final name = c.peerNickname.toLowerCase();
          final preview = c.lastMessageText.toLowerCase();
          return name.contains(q) || preview.contains(q);
        })
        .toList(growable: false);
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final hm =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (day == today) return hm;
    if (t.year == now.year) {
      return '${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
    }
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }

  void _openChat(Conversation conv) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ChatPage(conversation: conv)))
        .then((_) => ChatService.instance.refreshConversations());
  }

  /// 点击会话头像：跳转对方个人主页
  void _openUserProfile(Conversation conv) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfilePage(
          userId: conv.peerId,
          nickname: conv.peerNickname,
          avatar: conv.peerAvatar,
        ),
      ),
    );
  }

  void _openGroupChat(GroupChat group) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => GroupChatPage(group: group)))
        .then((_) => ChatService.instance.refreshGroups());
  }

  /// 右上角加号菜单：发起群聊 / 添加好友
  void _openAddMenu() {
    final colors = AppColors.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.group_add_outlined, color: colors.primary),
              title: const Text('发起群聊'),
              subtitle: const Text('选择已关注的好友，一起聊天'),
              onTap: () {
                Navigator.pop(ctx);
                _openCreateGroup();
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt_outlined, color: colors.primary),
              title: const Text('添加好友'),
              subtitle: const Text('通过手机号搜索并添加'),
              onTap: () {
                Navigator.pop(ctx);
                _openAddFriend();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateGroup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateGroupPage()),
    );
    ChatService.instance.refreshGroups();
  }

  void _openAddFriend() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddFriendPage()),
    );
  }

  /// 长按条目：底部操作菜单（置顶 / 标已读 / 删除）
  void _showActions(Conversation conv) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final colors = AppColors.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                conv.pinned ? '已置顶 · 点击取消' : '会话操作',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: Icon(
                  conv.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: colors.primary,
                ),
                title: Text(conv.pinned ? '取消置顶' : '置顶'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await ChatService.instance.pinConversation(
                    conv.id,
                    !conv.pinned,
                  );
                  _toast(ok ? (conv.pinned ? '已取消置顶' : '已置顶') : '操作失败，请重试');
                },
              ),
              if (conv.unreadCount > 0)
                ListTile(
                  leading: Icon(Icons.done_all, color: colors.primary),
                  title: const Text('标为已读'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ChatService.instance.markRead(conv.id);
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.danger),
                title: Text('删除会话', style: TextStyle(color: colors.danger)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(conv);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(Conversation conv) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除会话'),
        content: Text('将删除与 ${_displayName(conv)} 的会话及全部消息（对双方生效），且不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ChatService.instance.deleteConversation(conv.id);
              _toast(ok ? '会话已删除' : '删除失败，请重试');
            },
            child: Text(
              '删除',
              style: TextStyle(color: AppColors.of(ctx).danger),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(Conversation conv) {
    final n = conv.peerNickname;
    return n.isEmpty ? '用户 #${conv.peerId}' : n;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              // 头像跟随登录用户实时变化（修改头像后自动刷新）
              leading: ListenableBuilder(
                listenable: AuthService.instance,
                builder: (context, _) => _buildAvatar(),
              ),
              title: const Text('聊天'),
              actions: [
                _buildFilterButton(),
                IconButton(
                  tooltip: '发起群聊 / 添加好友',
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: _openAddMenu,
                ),
              ],
            ),
            _buildSearchBar(),
            Expanded(
              child: ListenableBuilder(
                listenable: ChatService.instance,
                builder: (context, _) =>
                    _buildList(_visible(ChatService.instance.conversations)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 导航栏左侧：当前用户头像（点击切到底部"我的" Tab）
  Widget _buildAvatar() {
    final me = AuthService.instance.user;
    final colors = AppColors.of(context);
    final avatar = me?.avatar ?? '';
    final valid =
        avatar.startsWith('http://') ||
        avatar.startsWith('https://') ||
        avatar.startsWith('/uploads/');
    return InkWell(
      onTap: widget.onTapAvatar,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.placeholder,
          ),
          clipBehavior: Clip.antiAlias,
          child: valid
              ? Image.network(
                  ChatApi.resolveUrl(avatar),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _initial(me?.nickname ?? '我'),
                )
              : _initial(me?.nickname ?? '我'),
        ),
      ),
    );
  }

  Widget _initial(String text) {
    return Center(
      child: Text(
        text.isEmpty ? '我' : text.characters.first,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// 导航栏右侧：筛选下拉（全部 / 未读）
  Widget _buildFilterButton() {
    final colors = AppColors.of(context);
    return PopupMenuButton<_Filter>(
      tooltip: '筛选',
      onSelected: (f) => setState(() => _filter = f),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _Filter.all,
          child: Row(
            children: [
              if (_filter == _Filter.all)
                Icon(Icons.check, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              const Text('全部'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _Filter.unread,
          child: Row(
            children: [
              if (_filter == _Filter.unread)
                Icon(Icons.check, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              const Text('未读'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _filter == _Filter.all ? '全部' : '未读',
              style: TextStyle(fontSize: 15, color: colors.textPrimary),
            ),
            Icon(Icons.arrow_drop_down, color: colors.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: '搜索',
          prefixIcon: Icon(Icons.search, size: 20, color: colors.textSecondary),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: colors.placeholder.withValues(alpha: 0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Conversation> convs) {
    if (_loading && !_loaded) return const LoadingWidget();
    if (_error != null && !_loaded) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    final groups = ChatService.instance.groups;
    if (groups.isEmpty && ChatService.instance.conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            EmptyWidget(
              icon: Icons.chat_bubble_outline,
              message: '暂无会话\n去社区找感兴趣的作者聊聊吧',
            ),
          ],
        ),
      );
    }
    if (groups.isEmpty && convs.isEmpty) {
      // 搜索 / 筛选无结果
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            EmptyWidget(icon: Icons.search_off, message: '没有匹配的会话'),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          if (groups.isNotEmpty) ...[
            _sectionHeader('群聊'),
            for (final g in groups)
              _GroupTile(
                group: g,
                timeText: _formatTime(g.lastMessageAt),
                onTap: () => _openGroupChat(g),
              ),
          ],
          if (convs.isNotEmpty) ...[
            if (groups.isNotEmpty) _sectionHeader('聊天'),
            for (var i = 0; i < convs.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 80,
                  color: AppColors.of(context).divider,
                ),
              _ConversationTile(
                conversation: convs[i],
                timeText: _formatTime(convs[i].lastMessageAt),
                onTap: () => _openChat(convs[i]),
                onTapAvatar: () => _openUserProfile(convs[i]),
                onLongPress: () => _showActions(convs[i]),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

/// 群聊条目
class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.timeText,
    required this.onTap,
  });

  final GroupChat group;
  final String timeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final avatar = group.memberAvatars.isNotEmpty
        ? group.memberAvatars.first
        : '';
    final validAvatar =
        avatar.startsWith('http://') ||
        avatar.startsWith('https://') ||
        avatar.startsWith('/uploads/');
    final hasUnread = group.unreadCount > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.placeholder,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: validAvatar
                      ? Image.network(
                          ChatApi.resolveUrl(avatar),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _groupIcon(colors),
                        )
                      : _groupIcon(colors),
                ),
                // 群聊标识角标
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 10,
                      color: Colors.white,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (timeText.isNotEmpty)
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.lastMessageText.isEmpty
                              ? '${group.memberCount} 人群聊'
                              : group.lastMessageText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupIcon(AppColors colors) {
    return Center(
      child: Icon(
        Icons.groups_rounded,
        size: 24,
        color: colors.textSecondary,
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.timeText,
    required this.onTap,
    required this.onTapAvatar,
    required this.onLongPress,
  });

  final Conversation conversation;
  final String timeText;
  final VoidCallback onTap;
  final VoidCallback onTapAvatar;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final nickname = conversation.peerNickname.isEmpty
        ? '用户 #${conversation.peerId}'
        : conversation.peerNickname;
    final hasUnread = conversation.unreadCount > 0;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTapAvatar,
              behavior: HitTestBehavior.opaque,
              child: _avatar(context, nickname, conversation.peerAvatar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (conversation.pinned) ...[
                        Icon(
                          Icons.push_pin,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                      ],
                      Expanded(
                        child: Text(
                          nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (timeText.isNotEmpty)
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessageText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      // 品牌色圆点 = 未读消息（条目级）
                      if (hasUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context, String nickname, String avatar) {
    final colors = AppColors.of(context);
    final valid =
        avatar.startsWith('http://') ||
        avatar.startsWith('https://') ||
        avatar.startsWith('/uploads/');
    // 对端在线状态（presence 事件实时更新）
    final online =
        ChatService.instance.isPeerOnline(conversation.peerId) ||
        conversation.peerOnline;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.placeholder,
          ),
          clipBehavior: Clip.antiAlias,
          child: valid
              ? Image.network(
                  ChatApi.resolveUrl(avatar),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _initial(nickname),
                )
              : _initial(nickname),
        ),
        // 右下角在线小圆点
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? Palette.success : colors.placeholder,
              border: Border.all(color: colors.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initial(String nickname) {
    return Center(
      child: Text(
        nickname.characters.first,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
