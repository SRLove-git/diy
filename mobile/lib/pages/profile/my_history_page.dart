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

/// 观看历史页
///
/// 结构与点赞与收藏页一致：
/// - 顶部「帖子 / 视频」分类切换；
/// - 帖子（默认）：社区 Feed 卡片布局，按浏览时间倒序展示；
/// - 视频：作品墙两列封面网格，点击进入全屏播放页，按浏览时间倒序展示。
class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  State<MyHistoryPage> createState() => _MyHistoryPageState();
}

enum _HistoryCategory { post, video }

class _MyHistoryPageState extends State<MyHistoryPage> {
  _HistoryCategory _category = _HistoryCategory.post;

  /// 帖子浏览记录（社区 Feed 布局）
  final List<FeedPost> _posts = [];
  bool _loading = true;
  String? _error;

  /// 视频浏览记录（作品墙网格布局）
  final List<TiktokVideoModel> _videos = [];
  bool _videosLoading = false;
  bool _videosError = false;
  bool _videosLoaded = false;

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
      final result = await PostApi.fetchHistory();
      Map<int, bool> likedMap = {};
      try {
        likedMap = await PostApi.batchLiked(result.items.map((p) => p.id).toList());
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(
            result.items
                .map((p) => ApiCommunityRepository.toFeedPost(
                      p,
                      liked: likedMap[p.id] ?? false,
                    ))
                .toList(),
          );
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

  Future<void> _loadVideos() async {
    setState(() {
      _videosLoading = true;
      _videosError = false;
    });
    try {
      final result = await VideoApi.fetchHistory();
      if (!mounted) return;
      setState(() {
        _videos
          ..clear()
          ..addAll(result.items.map((v) => TiktokVideoModel(video: v)));
        _videosLoading = false;
        _videosLoaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _videosLoading = false;
          _videosError = true;
        });
      }
    }
  }

  void _onCategoryChanged(_HistoryCategory category) {
    if (category == _category) return;
    setState(() => _category = category);
    // 视频历史懒加载：首次切换到视频标签时才请求
    if (category == _HistoryCategory.video &&
        !_videosLoaded &&
        !_videosLoading) {
      _loadVideos();
    }
  }

  Future<void> _refresh() =>
      _category == _HistoryCategory.post ? _load() : _loadVideos();

  // ──── 帖子交互 ────

  Future<void> _togglePostLike(FeedPost post) async {
    final target = !post.liked;
    setState(() {
      final i = _posts.indexWhere((p) => p.id == post.id);
      if (i >= 0) {
        _posts[i] = _posts[i].copyWith(
          liked: target,
          likeCount: post.likeCount + (target ? 1 : -1),
        );
      }
    });
    try {
      await PostApi.toggleLike(post.id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final i = _posts.indexWhere((p) => p.id == post.id);
        if (i >= 0) {
          _posts[i] = _posts[i].copyWith(
            liked: post.liked,
            likeCount: post.likeCount,
          );
        }
      });
    }
  }

  void _openPostDetail(FeedPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id)),
    );
  }

  // ──── 视频交互 ────

  void _openVideoPlayer(int index) {
    final nickname = AuthService.instance.user?.nickname ?? '';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPage(
          videos: List.of(_videos),
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
        title: const Text('观看历史'),
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
          child: _category == _HistoryCategory.post
              ? _buildPostsSection()
              : _buildVideoSection(),
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
            _categoryItem(colors, _HistoryCategory.post, '帖子', Icons.article_outlined),
            _categoryItem(colors, _HistoryCategory.video, '视频', Icons.videocam_outlined),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(
    AppColors colors,
    _HistoryCategory category,
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

  /// 帖子：社区页 Feed 布局
  Widget _buildPostsSection() {
    if (_loading) return const LoadingWidget();
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

    if (_posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const EmptyWidget(
              icon: Icons.history,
              message: '暂无浏览记录',
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _buildPostCard(_posts[i]),
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

  /// 视频：作品墙两列封面网格，点击进入全屏播放页
  Widget _buildVideoSection() {
    if (_videosLoading) return const LoadingWidget();
    if (_videosError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AppErrorWidget(message: '加载失败，请下拉重试', onRetry: _loadVideos),
          ),
        ],
      );
    }

    if (_videos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const EmptyWidget(
              icon: Icons.history,
              message: '暂无视频浏览记录',
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
      itemCount: _videos.length,
      itemBuilder: (_, i) => VideoGridCard(
        item: _videos[i],
        onTap: () => _openVideoPlayer(i),
        onDoubleTap: () {},
      ),
    );
  }
}
