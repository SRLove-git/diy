import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/post_api.dart';
import '../../core/video_api.dart';
import '../../features/community/data/api_community_repository.dart';
import '../../features/community/domain/community_models.dart';
import '../../features/community/presentation/community_palette.dart';
import '../../features/community/presentation/widgets/community_sheets.dart';
import '../../features/community/presentation/widgets/feed_card.dart';
import '../../features/tiktok_profile/model/tiktok_video_model.dart';
import '../../features/tiktok_profile/page/fullscreen_video_page.dart';
import '../../features/tiktok_profile/widget/video_grid_card.dart';
import '../../widgets/state_widgets.dart';
import '../community/post_detail_page.dart';
import '../community/user_profile_page.dart';

/// 点赞与收藏页
///
/// 顶部「帖子 / 视频」分类切换：
/// - 帖子（默认）：只展示社区帖子，布局与社区频道页一致（[FeedCard]），
///   子分类为「我赞过的 / 我收藏的」；
/// - 视频：展示我赞过的视频（作品墙两列封面），视频收藏接口暂未提供，
///   收藏子分类先展示空态提示。
class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

enum _FavCategory { post, video }

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  _FavCategory _category = _FavCategory.post;

  /// 帖子：我赞过的 / 我收藏的（社区 Feed 布局）
  final List<FeedPost> _likedFeeds = [];
  final List<FeedPost> _favoriteFeeds = [];

  /// 视频：我赞过的
  final List<TiktokVideoModel> _likedVideos = [];

  bool _postsLoading = true;
  bool _videosLoading = false;
  bool _videosLoaded = false;
  String? _postsError;
  String? _videosError;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  // ──── 数据加载 ────

  Future<void> _loadPosts() async {
    setState(() {
      _postsLoading = true;
      _postsError = null;
    });
    try {
      final results = await Future.wait([
        PostApi.fetchLikedPosts(),
        PostApi.fetchFavorites(),
      ]);

      final liked = (results[0].items)
          .map((p) => ApiCommunityRepository.toFeedPost(p, liked: true))
          .toList();

      // 收藏列表单独批量查询点赞状态（未登录/失败时全部按未赞处理）
      final favoritePosts = results[1].items;
      Map<int, bool> likedMap = {};
      try {
        likedMap = await PostApi.batchLiked(favoritePosts.map((p) => p.id).toList());
      } catch (_) {}
      final favorites = favoritePosts
          .map((p) =>
              ApiCommunityRepository.toFeedPost(p, liked: likedMap[p.id] ?? false))
          .toList();

      if (!mounted) return;
      setState(() {
        _likedFeeds
          ..clear()
          ..addAll(liked);
        _favoriteFeeds
          ..clear()
          ..addAll(favorites);
        _postsLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _postsLoading = false;
          _postsError = '加载失败，请下拉重试';
        });
      }
    }
  }

  Future<void> _loadVideos() async {
    setState(() {
      _videosLoading = true;
      _videosError = null;
    });
    try {
      final result = await VideoApi.fetchMyLikedVideos();
      if (!mounted) return;
      setState(() {
        _likedVideos
          ..clear()
          ..addAll(
            result.items.map((v) => TiktokVideoModel(video: v)).toList(),
          );
        _videosLoading = false;
        _videosLoaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _videosLoading = false;
          _videosError = '加载失败，请下拉重试';
        });
      }
    }
  }

  void _onCategoryChanged(_FavCategory category) {
    if (category == _category) return;
    setState(() => _category = category);
    if (category == _FavCategory.video && !_videosLoaded && !_videosLoading) {
      _loadVideos();
    }
  }

  Future<void> _refresh() =>
      _category == _FavCategory.post ? _loadPosts() : _loadVideos();

  // ──── 帖子交互 ────

  Future<void> _togglePostLike(FeedPost post) async {
    final target = !post.liked;

    void apply(FeedPost Function(FeedPost) fn) {
      setState(() {
        _updateIn(_likedFeeds, post.id, fn);
        _updateIn(_favoriteFeeds, post.id, fn);
      });
    }

    apply(
      (p) => p.copyWith(
        liked: target,
        likeCount: post.likeCount + (target ? 1 : -1),
      ),
    );
    try {
      final serverLiked = await PostApi.toggleLike(post.id);
      if (!mounted) return;
      // 「我赞过的」里取消点赞后直接移除
      if (!serverLiked && _likedFeeds.any((p) => p.id == post.id)) {
        setState(() => _likedFeeds.removeWhere((p) => p.id == post.id));
      }
    } catch (_) {
      if (!mounted) return;
      apply(
        (p) => p.copyWith(liked: post.liked, likeCount: post.likeCount),
      );
    }
  }

  void _updateIn(
    List<FeedPost> list,
    int id,
    FeedPost Function(FeedPost) fn,
  ) {
    final i = list.indexWhere((p) => p.id == id);
    if (i >= 0) list[i] = fn(list[i]);
  }

  void _openPostDetail(FeedPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id)),
    );
  }

  // ──── 视频交互 ────

  Future<void> _toggleVideoLike(TiktokVideoModel item) async {
    final target = !item.liked;
    setState(() {
      final i = _likedVideos.indexWhere((v) => v.id == item.id);
      if (i >= 0) {
        _likedVideos[i] = item.copyWith(
          video: item.video.copyWith(
            liked: target,
            likeCount: item.likeCount + (target ? 1 : -1),
          ),
        );
      }
    });
    try {
      final serverLiked = await VideoApi.toggleLike(item.id);
      if (!mounted) return;
      if (!serverLiked) {
        setState(() => _likedVideos.removeWhere((v) => v.id == item.id));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final i = _likedVideos.indexWhere((v) => v.id == item.id);
        if (i >= 0) _likedVideos[i] = item;
      });
    }
  }

  void _openVideoPlayer(int index) {
    final nickname = AuthService.instance.user?.nickname ?? '';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPage(
          videos: List.of(_likedVideos),
          initialIndex: index,
          nickname: nickname,
        ),
      ),
    );
  }

  // ──── 视图 ────

  @override
  Widget build(BuildContext context) {
    final palette = CommunityPalette.of(context);
    return Scaffold(
      backgroundColor: palette.pageBackground,
      appBar: AppBar(
        title: const Text('点赞与收藏'),
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildCategorySwitch(),
        const SizedBox(height: 4),
        Expanded(
          child: _category == _FavCategory.post
              ? _buildPostsSection()
              : _buildVideosSection(),
        ),
      ],
    );
  }

  /// 顶部「帖子 / 视频」分类切换
  Widget _buildCategorySwitch() {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.searchBg,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          children: [
            _categoryItem(colors, _FavCategory.post, '帖子', Icons.article_outlined),
            _categoryItem(colors, _FavCategory.video, '视频', Icons.videocam_outlined),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(
    AppColors colors,
    _FavCategory category,
    String label,
    IconData icon,
  ) {
    final selected = _category == category;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onCategoryChanged(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? colors.primary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──── 帖子：社区页 Feed 布局 ────

  Widget _buildPostsSection() {
    if (_postsLoading) return const LoadingWidget();
    if (_postsError != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AppErrorWidget(message: _postsError!, onRetry: _loadPosts),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildSubTabBar(),
          Expanded(
            child: TabBarView(
              children: [
                _buildPostFeed(
                  _likedFeeds,
                  emptyIcon: Icons.favorite_border,
                  emptyText: '还没有点赞作品',
                ),
                _buildPostFeed(
                  _favoriteFeeds,
                  emptyIcon: Icons.bookmark_border,
                  emptyText: '还没有收藏作品',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabBar() {
    final colors = AppColors.of(context);
    return TabBar(
      labelColor: colors.textPrimary,
      unselectedLabelColor: colors.textSecondary,
      indicatorColor: colors.primary,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      tabs: const [
        Tab(text: '我赞过的'),
        Tab(text: '我收藏的'),
      ],
    );
  }

  Widget _buildPostFeed(
    List<FeedPost> posts, {
    required IconData emptyIcon,
    required String emptyText,
  }) {
    if (posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyWidget(icon: emptyIcon, message: emptyText),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _buildPostCard(posts[i]),
    );
  }

  Widget _buildPostCard(FeedPost post) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _openPostDetail(post),
      child: FeedCard(
        post: post,
        onAvatarTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => UserProfilePage(post: post)),
          );
        },
        onLike: () => _togglePostLike(post),
        onComment: () => _openPostDetail(post),
        onShare: () => showShareSheet(context, post: post),
      ),
    );
  }

  // ──── 视频：作品墙网格布局 ────

  Widget _buildVideosSection() {
    if (_videosLoading) return const LoadingWidget();
    if (_videosError != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AppErrorWidget(message: _videosError!, onRetry: _loadVideos),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildSubTabBar(),
          Expanded(
            child: TabBarView(
              children: [
                _buildVideoGrid(),
                _buildVideoFavoritesEmpty(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    if (_likedVideos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const EmptyWidget(
              icon: Icons.favorite_border,
              message: '还没有点赞视频',
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: _likedVideos.length,
      itemBuilder: (_, i) {
        final item = _likedVideos[i];
        return VideoGridCard(
          item: item,
          onTap: () => _openVideoPlayer(i),
          onDoubleTap: () => _toggleVideoLike(item),
        );
      },
    );
  }

  /// 视频收藏：后端暂未提供收藏接口，展示空态提示
  Widget _buildVideoFavoritesEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: const EmptyWidget(
            icon: Icons.bookmark_border,
            message: '视频收藏功能暂未开放，敬请期待',
          ),
        ),
      ],
    );
  }
}
