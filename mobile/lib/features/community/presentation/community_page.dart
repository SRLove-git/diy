import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/auth_service.dart';
import '../../../core/chat_api.dart';
import '../../../widgets/state_widgets.dart';
import '../../../pages/community/user_profile_page.dart';
import '../data/api_community_repository.dart';
import '../domain/community_models.dart';
import '../domain/community_repository.dart';
import 'community_palette.dart';
import 'widgets/community_sheets.dart';
import 'widgets/feed_card.dart';
import 'publish_post_page.dart';

/// 社区频道信息流页：Header + 搜索栏 + 动态 Feed
///
/// 结构：SafeArea > CustomScrollView（SliverAppBar / 搜索栏 / Feed 列表）。
/// 数据经 [CommunityRepository] 注入，当前为真实 API 实现（[ApiCommunityRepository]），
/// 测试时替换为 [MockCommunityRepository] 即可。
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key, required this.onSwitchTab});

  /// 切换底部主 Tab（首页/发现/消息/个人主页），由外层壳注入
  final ValueChanged<int> onSwitchTab;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final CommunityRepository _repository = ApiCommunityRepository();

  final List<FeedPost> _posts = [];
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
      final posts = await _repository.fetchFeed();
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(posts);
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败，请下拉重试';
        });
      }
    }
  }

  // --- 交互 ---

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onAvatarTap() => widget.onSwitchTab(3); // 切到个人主页
  void _onSearchTap() => _showToast('找频道 / 找内容（演示）');

  /// 点击帖子作者头像：打开用户主页展示页面
  void _openUserProfile(FeedPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserProfilePage(post: post)),
    );
  }

  Future<void> _onLike(FeedPost post) async {
    final liked = !post.liked;
    setState(() => _apply(post, (p) => p.copyWith(
          liked: liked,
          likeCount: math.max(0, post.likeCount + (liked ? 1 : -1)),
        )));
    try {
      await _repository.toggleLike(post.id);
    } catch (_) {
      if (mounted) setState(() => _apply(post, (p) => p.copyWith(liked: !liked)));
    }
  }

  /// 用派生副本替换列表中的原帖
  void _apply(FeedPost post, FeedPost Function(FeedPost) fn) {
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i >= 0) _posts[i] = fn(_posts[i]);
  }

  Future<void> _onComment(FeedPost post) async {
    final comments = await _repository.fetchComments(post.id);
    if (!mounted) return;
    final auth = AuthService.instance.user;
    await showCommentSheet(
      context,
      post: post,
      comments: comments,
      currentUser: CommunityUser(
        id: auth?.id ?? 0,
        nickname: auth?.nickname ?? '我',
        avatarUrl: auth?.avatar ?? '',
      ),
    );
  }

  void _onShare(FeedPost post) => showShareSheet(context);

  /// 打开发布页面，返回后自动刷新列表
  Future<void> _openPublish() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PublishPostPage()),
    );
    _load();
  }

  // --- 视图 ---

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: _load,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const _SkeletonFeed();

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AppErrorWidget(message: _error!, onRetry: _load),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildAppBar(),
        _buildSearchBar(),
        if (_posts.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyWidget(
              icon: Icons.brush_outlined,
              message: '还没有动态，来发布第一个吧',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList.builder(
              itemCount: _posts.length,
              itemBuilder: (_, i) {
                final post = _posts[i];
                return _EntranceItem(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FeedCard(
                      post: post,
                      onAvatarTap: () => _openUserProfile(post),
                      onLike: () => _onLike(post),
                      onComment: () => _onComment(post),
                      onShare: () => _onShare(post),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// 顶部 Header：70px，左侧 40x40 头像 + 「频道」，右侧 用户/收藏 icon
  Widget _buildAppBar() {
    final palette = CommunityPalette.of(context);
    final colors = AppColors.of(context);
    return SliverAppBar(
      pinned: true,
      backgroundColor: palette.pageBackground,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: 0,
      leadingWidth: 64,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: _onAvatarTap,
            // 跟随登录用户实时头像：上传/修改后自动同步
            child: ListenableBuilder(
              listenable: AuthService.instance,
              builder: (context, _) => _buildHeaderAvatar(colors),
            ),
          ),
        ),
      ),
      title: Text(
        '社区',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.camera_alt_outlined, color: colors.textPrimary, size: 24),
          onPressed: _openPublish,
          tooltip: '发新帖',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// 左上角头像：跟随登录用户实时头像；未设置/加载失败时显示占位图标。
  /// 兼容 http(s) 与服务端相对路径（/uploads/...），统一解析为绝对地址。
  Widget _buildHeaderAvatar(AppColors colors) {
    final avatar = AuthService.instance.user?.avatar ?? '';
    final valid = avatar.startsWith('http://') ||
        avatar.startsWith('https://') ||
        avatar.startsWith('/uploads/');
    return ClipOval(
      child: valid
          ? Image.network(
              ChatApi.resolveUrl(avatar),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              cacheWidth: 120,
              errorBuilder: (_, _, _) => _avatarFallback(colors),
            )
          : _avatarFallback(colors),
    );
  }

  Widget _avatarFallback(AppColors colors) => Container(
        width: 40,
        height: 40,
        color: colors.primary,
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
      );

  /// 搜索栏：48 高，圆角 24
  Widget _buildSearchBar() {
    final colors = AppColors.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: GestureDetector(
          onTap: _onSearchTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: colors.placeholder,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded,
                    color: colors.textSecondary, size: 22),
                const SizedBox(width: 8),
                Text(
                  '找频道/找内容',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 信息流入场动画：淡入 + 上浮（懒加载触发展示）
class _EntranceItem extends StatefulWidget {
  const _EntranceItem({required this.child});

  final Widget child;

  @override
  State<_EntranceItem> createState() => _EntranceItemState();
}

class _EntranceItemState extends State<_EntranceItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// 首屏骨架屏：静态灰块（加载中占位）
class _SkeletonFeed extends StatelessWidget {
  const _SkeletonFeed();

  @override
  Widget build(BuildContext context) {
    const block = Color(0xFFECECF0);
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 70),
      itemCount: 3,
      itemBuilder: (_, _) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      const BoxDecoration(color: block, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 12,
                      decoration: BoxDecoration(
                          color: block,
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                          color: block,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Container(
                decoration: BoxDecoration(
                  color: block,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
