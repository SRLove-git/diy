import 'package:flutter/material.dart' hide Page;
import 'package:image_picker/image_picker.dart';

import '../../api/api_client.dart';
import '../../api/chat_services.dart';
import '../../api/content_services.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../../main.dart' show GalleryPage;
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';
import 'appointment_screens.dart';
import 'auth_screens.dart';
import 'chat_screens.dart';
import 'member_screens.dart';
import 'notifications_screen.dart';
import 'post_screens.dart';
import 'video_screens.dart';

/// 我的主页
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.root = false});

  final bool root;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _me;
  FollowStatus? _follow;
  List<Post> _posts = [];
  List<Video> _videos = [];
  bool _loading = true;
  String? _error;
  int _tab = 0; // 0 帖子 1 笔记 2 视频

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
      final me = await AuthService.instance.me();
      final results = await Future.wait([
        FollowService.instance.status(me.id),
        CommunityService.instance.mine(),
        VideoService.instance.mine(),
      ]);
      if (mounted) {
        setState(() {
          _me = me;
          _follow = results[0] as FollowStatus;
          _posts = (results[1] as Page<Post>).items;
          _videos = (results[2] as Page<Video>).items;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Post> get _textPosts =>
      _posts.where((p) => p.mediaUrls.isEmpty).toList();
  List<Post> get _notePosts =>
      _posts.where((p) => p.mediaUrls.isNotEmpty).toList();

  int get _totalLikes =>
      _posts.fold(0, (s, p) => s + p.likeCount) +
      _videos.fold(0, (s, v) => s + v.likeCount);

  @override
  Widget build(BuildContext context) {
    return LivePage(
      bottomBar: const LiveTabBar(current: 4),
      child: Column(
        children: [
          const LiveAppBar(
            title: '我的',
            actions: [_ProfileMenuButton()],
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _me == null
                        ? const EmptyView()
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView(
                              padding: const EdgeInsets.all(18),
                              children: [
                                _ProfileHeader(
                                  user: _me!,
                                  follow: _follow,
                                  worksCount: _posts.length + _videos.length,
                                  totalLikes: _totalLikes,
                                  onEdit: () async {
                                    await LiveRoutes.push(context, const EditProfileScreen());
                                    _load();
                                  },
                                  onFans: () => LiveRoutes.push(
                                    context,
                                    FollowScreen(targetId: _me!.id, initialTab: 'followers'),
                                  ),
                                  onShare: () =>
                                      showLiveSnack(context, '已复制主页分享链接（模拟）'),
                                ),
                                const SizedBox(height: 18),
                                _ProfileTabs(
                                  tab: _tab,
                                  counts: (
                                    _textPosts.length,
                                    _notePosts.length,
                                    _videos.length,
                                  ),
                                  onChanged: (t) => setState(() => _tab = t),
                                ),
                                const SizedBox(height: 10),
                                if (_tab == 0)
                                  _WorksGrid(
                                    posts: _textPosts,
                                    textStyle: true,
                                    onTapPost: (p) => LiveRoutes.push(
                                      context,
                                      PostDetailScreen(postId: p.id),
                                    ),
                                    emptyText: '还没有发布帖子',
                                  )
                                else if (_tab == 1)
                                  _WorksGrid(
                                    posts: _notePosts,
                                    onTapPost: (p) => LiveRoutes.push(
                                      context,
                                      PostDetailScreen(postId: p.id),
                                    ),
                                    emptyText: '还没有发布笔记',
                                  )
                                else
                                  _VideoGrid(
                                    videos: _videos,
                                    onTapVideo: (v) => LiveRoutes.push(
                                      context,
                                      VideoDetailScreen(videoId: v.id),
                                    ),
                                    emptyText: '还没有发布视频',
                                  ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/// 粉丝 / 关注 胶囊分段器（对齐原稿 33-关注与粉丝）。
class _FollowTabs extends StatelessWidget {
  const _FollowTabs({
    required this.tab,
    required this.followerCount,
    required this.followingCount,
    required this.onChanged,
  });

  final String tab;
  final int followerCount;
  final int followingCount;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('followers', '粉丝 ${fmtCount(followerCount)}'),
      ('following', '关注 ${fmtCount(followingCount)}'),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LiveColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final t in tabs)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: tab == t.$1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: tab == t.$1
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
                  onTap: () => onChanged(t.$1),
                  borderRadius: BorderRadius.circular(17),
                  child: Center(
                    child: Text(
                      t.$2,
                      style: TextStyle(
                        fontSize: 12.6,
                        fontWeight: tab == t.$1
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: tab == t.$1
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
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.follow,
    required this.worksCount,
    required this.totalLikes,
    required this.onEdit,
    required this.onFans,
    required this.onShare,
  });

  final User user;
  final FollowStatus? follow;
  final int worksCount;
  final int totalLikes;
  final VoidCallback onEdit;
  final VoidCallback onFans;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final joinYear = user.createdAt?.year;
    final joinMonth = user.createdAt?.month;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Avatar(url: user.avatar, name: user.nickname, size: 76),
            const SizedBox(width: 18),
            Expanded(
              child: Row(
                children: [
                  _StatColumn(
                    label: '作品',
                    value: '${fmtCount(worksCount)}',
                  ),
                  const _StatDivider(),
                  _StatColumn(
                    label: '粉丝',
                    value: '${fmtCount(follow?.followerCount ?? 0)}',
                    onTap: onFans,
                  ),
                  const _StatDivider(),
                  _StatColumn(
                    label: '获赞',
                    value: '${fmtCount(totalLikes)}',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          user.displayName,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: LiveColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          user.bio.isEmpty
              ? '@${user.phone}'
              : '@${user.phone} · ${user.bio}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12.6, color: LiveColors.textSecondary),
        ),
        const SizedBox(height: 3),
        Text(
          '手作星球${joinYear != null ? ' ${joinYear} 年 ${joinMonth ?? ''} 月入驻' : ''}'
          '${user.location.isNotEmpty ? ' · ${user.location}' : ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.6, color: LiveColors.textTertiary),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: '编辑资料',
                height: 50,
                onTap: onEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: '分享主页',
                height: 50,
                onTap: onShare,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: LiveColors.textPrimary),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 11.6, color: LiveColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 26, color: LiveColors.divider);
  }
}

/// 帖子 / 笔记 / 视频 分段切换（胶囊样式）。
class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({
    required this.tab,
    required this.counts,
    required this.onChanged,
  });

  final int tab;
  final (int, int, int) counts;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = [
      '帖子 ${counts.$1}',
      '笔记 ${counts.$2}',
      '视频 ${counts.$3}',
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LiveColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 38,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: tab == i ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: tab == i
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
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(17),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12.6,
                        fontWeight: tab == i ? FontWeight.w700 : FontWeight.w400,
                        color: tab == i
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
    );
  }
}

/// 帖子 / 作品九宫格（封面 + 左下角点赞数）。
class _ContentTab extends StatelessWidget {
  const _ContentTab({required this.tab, required this.onChanged});

  final int tab;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LiveColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final t in [('作品', 0), ('视频', 1)])
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 38,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: tab == t.$2 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: tab == t.$2
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
                  onTap: () => onChanged(t.$2),
                  borderRadius: BorderRadius.circular(17),
                  child: Center(
                    child: Text(
                      t.$1,
                      style: TextStyle(
                        fontSize: 12.6,
                        fontWeight: tab == t.$2 ? FontWeight.w700 : FontWeight.w400,
                        color: tab == t.$2
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
    );
  }
}

class _WorksGrid extends StatelessWidget {
  const _WorksGrid({
    required this.posts,
    required this.onTapPost,
    required this.emptyText,
    this.textStyle = false,
  });

  final List<Post> posts;
  final ValueChanged<Post> onTapPost;
  final String emptyText;
  final bool textStyle;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return EmptyView(text: emptyText, icon: Icons.article_outlined);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.96,
      ),
      itemCount: posts.length,
      itemBuilder: (_, i) {
        final p = posts[i];
        final urls = p.mediaUrls;
        return InkWell(
          onTap: () => onTapPost(p),
          borderRadius: BorderRadius.circular(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                urls.isEmpty || textStyle
                    ? Container(
                        color: LiveColors.card,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '文字帖',
                              style: TextStyle(fontSize: 10, color: LiveColors.textTertiary),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                p.content,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.6,
                                  color: LiveColors.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : NetImage(url: urls.first),
                if (!textStyle || urls.isNotEmpty)
                  Positioned(
                    left: 6,
                    bottom: 5,
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, size: 11, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          '${fmtCount(p.likeCount)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VideoGrid extends StatelessWidget {
  const _VideoGrid({required this.videos, required this.onTapVideo, required this.emptyText});

  final List<Video> videos;
  final ValueChanged<Video> onTapVideo;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return EmptyView(text: emptyText, icon: Icons.videocam_outlined);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.62,
      ),
      itemCount: videos.length,
      itemBuilder: (_, i) {
        final v = videos[i];
        return InkWell(
          onTap: () => onTapVideo(v),
          borderRadius: BorderRadius.circular(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(url: v.cover),
                const Center(
                  child: Icon(Icons.play_circle_outline, size: 30, color: Colors.white70),
                ),
                Positioned(
                  left: 6,
                  bottom: 5,
                  child: Text(
                    '${fmtCount(v.viewCount)} 次播放',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileMenuButton extends StatelessWidget {
  const _ProfileMenuButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: LiveColors.textPrimary),
      onPressed: () => LiveRoutes.push(context, const ProfileMenuScreen()),
    );
  }
}

/// 「我的主页-菜单」：右侧抽屉（我的服务）。
class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const ColoredBox(color: Color(0x66000000)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 343,
              color: LiveColors.bg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      children: [
                        const Text(
                          '我的服务',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: LiveColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close,
                            size: 22,
                            color: LiveColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: LiveColors.divider),
                  _MenuEntryTile(
                    icon: Icons.confirmation_number_outlined,
                    title: '我的卡包',
                    subtitle: '优惠券 · 会员体验',
                    onTap: () {
                      LiveRoutes.pushAfterPop(context, const CouponsScreen());
                    },
                  ),
                  _MenuEntryTile(
                    icon: Icons.favorite_outline,
                    title: '点赞与收藏',
                    subtitle: '我喜欢的作品',
                    onTap: () {
                      LiveRoutes.pushAfterPop(context, const LikedFavoritesScreen());
                    },
                  ),
                  _MenuEntryTile(
                    icon: Icons.history,
                    title: '观看历史',
                    subtitle: '作品 · 视频浏览记录',
                    onTap: () {
                      LiveRoutes.pushAfterPop(context, const WatchHistoryScreen());
                    },
                  ),
                  _MenuEntryTile(
                    icon: Icons.receipt_long_outlined,
                    title: '我的订单',
                    subtitle: '预约 · 体验记录',
                    onTap: () {
                      LiveRoutes.pushAfterPop(context, const MyAppointmentsScreen());
                    },
                  ),
                  _MenuEntryTile(
                    icon: Icons.settings_outlined,
                    title: '设置',
                    subtitle: '账号与安全 · 通用',
                    onTap: () {
                      LiveRoutes.pushAfterPop(context, const SettingsScreen());
                    },
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Text(
                      '更多服务持续上线',
                      style: TextStyle(fontSize: 11.6, color: LiveColors.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuEntryTile extends StatelessWidget {
  const _MenuEntryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: LiveColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.6, color: LiveColors.textTertiary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: LiveColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// 他人主页
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.userId});

  final int userId;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  FollowStatus? _status;
  List<Post> _posts = [];
  List<Video> _videos = [];
  bool _loading = true;
  String? _error;
  int _tab = 0;
  bool _followBusy = false;

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
        FollowService.instance.status(widget.userId),
        CommunityService.instance.userPosts(widget.userId),
        VideoService.instance.userVideos(widget.userId),
      ]);
      if (mounted) {
        setState(() {
          _status = results[0] as FollowStatus;
          _posts = (results[1] as Page<Post>).items;
          _videos = (results[2] as Page<Video>).items;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final s = _status;
    if (s == null) return;
    setState(() => _followBusy = true);
    try {
      final status = await FollowService.instance.setFollow(widget.userId, !s.following);
      if (mounted) setState(() => _status = status);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '用户主页'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _status == null
                        ? const EmptyView()
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView(
                              padding: const EdgeInsets.all(18),
                              children: [
                                Row(
                                  children: [
                                    Avatar(
                                      url: _status!.avatar,
                                      name: _status!.nickname,
                                      size: 68,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _status!.nickname,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: LiveColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              StatRow(
                                                label: '关注',
                                                value: '${fmtCount(_status!.followingCount)}',
                                                onTap: () => LiveRoutes.push(
                                                  context,
                                                  FollowScreen(targetId: widget.userId, initialTab: 'following'),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              StatRow(
                                                label: '粉丝',
                                                value: '${fmtCount(_status!.followerCount)}',
                                                onTap: () => LiveRoutes.push(
                                                  context,
                                                  FollowScreen(targetId: widget.userId, initialTab: 'followers'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        label: _status!.following ? '已关注' : '关注',
                                        height: 42,
                                        color: _status!.following ? LiveColors.card : null,
                                        loading: _followBusy,
                                        onTap: _followBusy ? null : _toggleFollow,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlineButton(
                                        label: '私信',
                                        height: 42,
                                        onTap: () async {
                                          try {
                                            final conv = await ChatService.instance
                                                .createConversation(widget.userId);
                                            if (context.mounted) {
                                              LiveRoutes.push(
                                                context,
                                                ChatScreen(
                                                  conversationId: conv.id,
                                                  peerId: widget.userId,
                                                  peerName: _status!.nickname,
                                                  peerAvatar: _status!.avatar,
                                                ),
                                                resizeToAvoidBottomInset: false,
                                              );
                                            }
                                          } on ApiException catch (e) {
                                            if (context.mounted) showLiveSnack(context, e.message);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _ProfileTabs(
                                  tab: _tab,
                                  counts: (
                                    _posts.where((p) => p.mediaUrls.isEmpty).length,
                                    _posts.where((p) => p.mediaUrls.isNotEmpty).length,
                                    _videos.length,
                                  ),
                                  onChanged: (t) => setState(() => _tab = t),
                                ),
                                const SizedBox(height: 10),
                                if (_tab == 0)
                                  _WorksGrid(
                                    posts: _posts.where((p) => p.mediaUrls.isEmpty).toList(),
                                    textStyle: true,
                                    onTapPost: (p) => LiveRoutes.push(
                                      context,
                                      PostDetailScreen(postId: p.id),
                                    ),
                                    emptyText: 'TA 还没有发布帖子',
                                  )
                                else if (_tab == 1)
                                  _WorksGrid(
                                    posts: _posts.where((p) => p.mediaUrls.isNotEmpty).toList(),
                                    onTapPost: (p) => LiveRoutes.push(
                                      context,
                                      PostDetailScreen(postId: p.id),
                                    ),
                                    emptyText: 'TA 还没有发布笔记',
                                  )
                                else
                                  _VideoGrid(
                                    videos: _videos,
                                    onTapVideo: (v) => LiveRoutes.push(
                                      context,
                                      VideoDetailScreen(videoId: v.id),
                                    ),
                                    emptyText: 'TA 还没有发布视频',
                                  ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nicknameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  String _avatar = '';
  String _gender = 'secret';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    AuthService.instance.me().then((u) {
      if (!mounted) return;
      setState(() {
        _avatar = u.avatar;
        _gender = u.gender;
        _nicknameCtrl.text = u.nickname;
        _usernameCtrl.text = u.username ?? '';
        _bioCtrl.text = u.bio;
        _locationCtrl.text = u.location;
        _birthdayCtrl.text = u.birthday ?? '';
      });
    }).catchError((_) {});
  }

  @override
  void dispose() {
    for (final c in [
      _nicknameCtrl,
      _usernameCtrl,
      _bioCtrl,
      _locationCtrl,
      _birthdayCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final url = await UploadService.instance.uploadImage(bytes, picked.name, folder: 'avatar');
      if (mounted) setState(() => _avatar = url);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } catch (e) {
      if (mounted) showLiveSnack(context, '选择头像失败：$e');
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'nickname': _nicknameCtrl.text.trim(),
        if (_usernameCtrl.text.trim().isNotEmpty)
          'username': _usernameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'gender': _gender,
        if (_birthdayCtrl.text.trim().isNotEmpty) 'birthday': _birthdayCtrl.text.trim(),
        if (_avatar.isNotEmpty) 'avatar': _avatar,
      };
      await UserService.instance.updateMe(body);
      if (mounted) {
        showLiveSnack(context, '保存成功');
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '编辑资料'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Center(
                  child: InkWell(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        Avatar(url: _avatar, name: _nicknameCtrl.text, size: 84),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: LiveColors.brand,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.photo_camera, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _nicknameCtrl,
                  decoration: const InputDecoration(hintText: '昵称'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    hintText: '用户名（字母/数字/下划线）',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    '用户名一年内只能修改一次，设置后可用于用户名+密码登录',
                    style: TextStyle(fontSize: 11, color: LiveColors.textTertiary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: '个人简介'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(hintText: '所在地'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _birthdayCtrl,
                  decoration: const InputDecoration(hintText: '生日（YYYY-MM-DD）'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('性别 ', style: TextStyle(fontSize: 14, color: LiveColors.textSecondary)),
                    for (final g in [
                      ('secret', '保密'),
                      ('male', '男'),
                      ('female', '女'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: InkWell(
                          onTap: () => setState(() => _gender = g.$1),
                          child: Row(
                            children: [
                              Icon(
                                _gender == g.$1
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: _gender == g.$1 ? LiveColors.brand : LiveColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(g.$2,
                                  style: const TextStyle(fontSize: 14, color: LiveColors.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                PrimaryButton(
                  label: '保存',
                  loading: _saving,
                  onTap: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LikedFavoritesScreen extends StatefulWidget {
  const LikedFavoritesScreen({super.key});

  @override
  State<LikedFavoritesScreen> createState() => _LikedFavoritesScreenState();
}

class _LikedFavoritesScreenState extends State<LikedFavoritesScreen> {
  int _tab = 0; // 0 作品点赞 1 作品收藏 2 视频点赞
  List<Post> _posts = [];
  List<Video> _videos = [];
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
      if (_tab == 2) {
        final page = await VideoService.instance.myLikes();
        if (mounted) setState(() => _videos = page.items);
      } else {
        final page = _tab == 0
            ? await CommunityService.instance.myLikes()
            : await CommunityService.instance.favorites();
        if (mounted) setState(() => _posts = page.items);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '点赞与收藏'),
          _LikedTabs(tab: _tab, onChanged: (t) {
            setState(() => _tab = t);
            _load();
          }),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _tab == 2
                        ? (_videos.isEmpty
                            ? const EmptyView(text: '还没有点赞的视频')
                            : _VideoGrid(
                                videos: _videos,
                                onTapVideo: (v) => LiveRoutes.push(
                                  context,
                                  VideoDetailScreen(videoId: v.id),
                                ),
                                emptyText: '',
                              ))
                        : (_posts.isEmpty
                            ? EmptyView(
                                text: _tab == 0 ? '还没有点赞的作品' : '还没有收藏的作品')
                            : _WorksGrid(
                                posts: _posts,
                                onTapPost: (p) => LiveRoutes.push(
                                  context,
                                  PostDetailScreen(postId: p.id),
                                ),
                                emptyText: '',
                              )),
          ),
        ],
      ),
    );
  }
}

class _LikedTabs extends StatelessWidget {
  const _LikedTabs({required this.tab, required this.onChanged});

  final int tab;
  final ValueChanged<int> onChanged;

  static const _labels = ['作品点赞', '作品收藏', '视频点赞'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: LiveColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _labels.length; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: tab == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: tab == i
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
                    onTap: () => onChanged(i),
                    borderRadius: BorderRadius.circular(17),
                    child: Center(
                      child: Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 12.6,
                          fontWeight: tab == i ? FontWeight.w700 : FontWeight.w400,
                          color: tab == i
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
    );
  }
}

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  int _tab = 0;
  List<Post> _posts = [];
  List<Video> _videos = [];
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
        CommunityService.instance.history(),
        VideoService.instance.history(),
      ]);
      if (mounted) {
        setState(() {
          _posts = (results[0] as Page<Post>).items;
          _videos = (results[1] as Page<Video>).items;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('清空观看历史'),
        content: const Text('确定要清空观看历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _posts = [];
        _videos = [];
      });
      showLiveSnack(context, '已清空观看历史');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          LiveAppBar(
            title: '观看历史',
            actions: [
              TextButton(
                onPressed: _clear,
                child: const Text(
                  '清空',
                  style: TextStyle(fontSize: 13, color: LiveColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          _ContentTab(tab: _tab, onChanged: (t) => setState(() => _tab = t)),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _tab == 0
                        ? _posts.isEmpty
                            ? const EmptyView(text: '暂无作品浏览历史')
                            : _WorksGrid(
                                posts: _posts,
                                onTapPost: (p) => LiveRoutes.push(
                                  context,
                                  PostDetailScreen(postId: p.id),
                                ),
                                emptyText: '',
                              )
                        : _videos.isEmpty
                            ? const EmptyView(text: '暂无视频浏览历史')
                            : _VideoGrid(
                                videos: _videos,
                                onTapVideo: (v) => LiveRoutes.push(
                                  context,
                                  VideoDetailScreen(videoId: v.id),
                                ),
                                emptyText: '',
                              ),
          ),
        ],
      ),
    );
  }
}

/// 29-我的内容：作品 / 视频 / 点赞 / 收藏 / 历史。
class MyContentScreen extends StatefulWidget {
  const MyContentScreen({super.key});

  @override
  State<MyContentScreen> createState() => _MyContentScreenState();
}

class _MyContentScreenState extends State<MyContentScreen> {
  int _tab = 0; // 0作品 1视频 2点赞 3收藏 4历史
  List<Post> _posts = [];
  List<Video> _videos = [];
  bool _loading = true;
  String? _error;

  static const _labels = ['作品', '视频', '点赞', '收藏', '历史'];

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
      if (_tab == 1) {
        final v = await VideoService.instance.mine();
        if (mounted) setState(() => _videos = v.items);
      } else {
        final page = switch (_tab) {
          2 => await CommunityService.instance.myLikes(),
          3 => await CommunityService.instance.favorites(),
          4 => await CommunityService.instance.history(),
          _ => await CommunityService.instance.mine(),
        };
        if (mounted) setState(() => _posts = page.items);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '我的内容'),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: LiveColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _labels.length; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 34,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _tab == i ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _tab == i
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
                            setState(() => _tab = i);
                            _load();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              _labels[i],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w400,
                                color: _tab == i
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
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _tab == 1
                        ? (_videos.isEmpty
                            ? const EmptyView(text: '暂无视频')
                            : _VideoGrid(
                                videos: _videos,
                                onTapVideo: (v) => LiveRoutes.push(
                                  context,
                                  VideoDetailScreen(videoId: v.id),
                                ),
                                emptyText: '',
                              ))
                        : (_posts.isEmpty
                            ? const EmptyView(text: '暂无内容')
                            : _WorksGrid(
                                posts: _posts,
                                onTapPost: (p) => LiveRoutes.push(
                                  context,
                                  PostDetailScreen(postId: p.id),
                                ),
                                emptyText: '',
                              )),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '设置'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const _SettingGroupHeader('账号与安全'),
                _SettingRow(
                  icon: Icons.lock_outline,
                  label: '修改密码',
                  onTap: () => LiveRoutes.push(context, const SetPasswordScreen()),
                ),
                const SizedBox(height: 16),
                const _SettingGroupHeader('通用'),
                _SettingRow(
                  icon: Icons.notifications_outlined,
                  label: '消息通知',
                  onTap: () => LiveRoutes.push(context, const NotificationsScreen()),
                ),
                _SettingRow(
                  icon: Icons.card_giftcard_outlined,
                  label: '我的卡包',
                  onTap: () => LiveRoutes.push(context, const CouponsScreen()),
                ),
                _SettingRow(
                  icon: Icons.grid_view_outlined,
                  label: 'UI 预览（82 屏图库）',
                  onTap: () => LiveRoutes.push(context, const GalleryPage()),
                ),
                const SizedBox(height: 16),
                const _SettingGroupHeader('关于'),
                _SettingRow(
                  icon: Icons.info_outline,
                  label: '关于手作星球',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: '手作星球',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '发现手作 · 遇见同好',
                  ),
                ),
                const SizedBox(height: 28),
                _SettingRow(
                  icon: Icons.logout,
                  label: '退出登录',
                  danger: true,
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('退出登录'),
                        content: const Text('确定要退出当前账号吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('再想想'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('退出'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) await LiveRoutes.logout(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingGroupHeader extends StatelessWidget {
  const _SettingGroupHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: LiveColors.textSecondary,
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: LiveColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? LiveColors.danger : LiveColors.brand),
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

class FollowScreen extends StatefulWidget {
  const FollowScreen({super.key, required this.targetId, this.initialTab = 'followers'});

  final int targetId;
  final String initialTab;

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  late String _tab;
  List<FollowUser> _users = [];
  String _userName = '关注与粉丝';
  int _followerCount = 0;
  int _followingCount = 0;
  bool _loading = true;
  String? _error;
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        FollowService.instance.status(widget.targetId),
        _tab == 'followers'
            ? FollowService.instance.followers(widget.targetId)
            : FollowService.instance.followingFor(widget.targetId),
      ]);
      if (mounted) {
        final status = results[0] as FollowStatus;
        setState(() {
          _userName =
              status.nickname.isNotEmpty ? status.nickname : '关注与粉丝';
          _followerCount = status.followerCount;
          _followingCount = status.followingCount;
          _users = (results[1] as Page<FollowUser>).items;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(FollowUser u) async {
    setState(() => _busy.add(u.id));
    try {
      final status = await FollowService.instance.setFollow(u.id, !u.following);
      if (mounted) {
        setState(() {
          _users = _users.map((x) => x.id == u.id ? FollowUser(
                id: u.id,
                nickname: u.nickname,
                avatar: u.avatar,
                following: status.following,
              ) : x).toList();
        });
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy.remove(u.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          LiveAppBar(title: _userName),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: _FollowTabs(
              tab: _tab,
              followerCount: _followerCount,
              followingCount: _followingCount,
              onChanged: (key) {
                setState(() => _tab = key);
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _users.isEmpty
                        ? const EmptyView(text: '暂无用户')
                        : ListView.separated(
                            padding: const EdgeInsets.all(18),
                            itemCount: _users.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: LiveColors.divider),
                            itemBuilder: (_, i) {
                              final u = _users[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Avatar(url: u.avatar, name: u.nickname, size: 44),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        u.nickname,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 74,
                                      height: 34,
                                      child: _busy.contains(u.id)
                                          ? const Center(
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: LiveColors.brand),
                                              ),
                                            )
                                          : OutlinedButton(
                                              onPressed: () => _toggle(u),
                                              style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                foregroundColor: u.following ? LiveColors.textSecondary : LiveColors.brand,
                                                side: BorderSide(
                                                  color: u.following
                                                      ? LiveColors.divider
                                                      : LiveColors.brand,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(u.following ? '已关注' : '关注',
                                                  style: const TextStyle(fontSize: 12)),
                                            ),
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
