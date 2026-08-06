import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/chat_api.dart';
import '../../../../core/post_api.dart';
import '../../../../pages/community/author_profile_page.dart';
import '../../../../pages/community/post_detail_page.dart';
import '../publish_post_page.dart';
import 'discover_search_page.dart';

// =============================================================================
// 数据模型
// =============================================================================

/// 帖子类型
enum PostType { image, video, grid, text }

/// 社区发现页帖子模型（由后端 [Post] 映射而来）
class DiscoverPost {
  const DiscoverPost({
    required this.id,
    required this.userId,
    required this.image,
    this.images = const [],
    required this.title,
    required this.username,
    required this.avatar,
    required this.likes,
    this.type = PostType.image,
    this.duration,
    this.aspectRatio = 3 / 4,
    this.liked = false,
  });

  final int id;
  final int userId;
  final String image;
  final List<String> images;
  final String title;
  final String username;
  final String avatar;
  final int likes;
  final PostType type;

  /// 视频时长（秒）
  final double? duration;
  final double aspectRatio;
  final bool liked;

  /// 将后端作品映射为发现页卡片模型
  factory DiscoverPost.fromPost(Post p) {
    var mediaList = p.medias
        .where((m) => m.url.trim().isNotEmpty)
        .toList();
    if (mediaList.isEmpty) {
      mediaList = p.images
          .where((u) => u.trim().isNotEmpty)
          .map((u) => PostMedia(type: 'image', url: u, aspectRatio: 4 / 5))
          .toList();
    }
    final cover = mediaList.isEmpty ? '' : mediaList.first.url;
    final aspectRatio =
        mediaList.isEmpty ? 3 / 4 : (mediaList.first.aspectRatio ?? 3 / 4);
    final hasVideo = mediaList.any((m) => m.type == 'video');
    final imageUrls = mediaList
        .where((m) => m.type == 'image')
        .map((m) => m.url)
        .take(4)
        .toList();

    double? videoDur;
    for (final m in mediaList) {
      if (m.type == 'video' && m.duration != null) {
        videoDur = m.duration;
        break;
      }
    }

    return DiscoverPost(
      id: p.id,
      userId: p.userId,
      image: ChatApi.resolveUrl(cover),
      images: imageUrls.map(ChatApi.resolveUrl).toList(),
      title: p.content,
      username: p.author?.nickname ?? '用户 #${p.userId}',
      avatar: (p.author != null && p.author!.avatar.isNotEmpty)
          ? ChatApi.resolveUrl(p.author!.avatar)
          : '',
      likes: p.likeCount,
      type: mediaList.isEmpty
          ? PostType.text
          : hasVideo
              ? PostType.video
              : (imageUrls.length >= 2 ? PostType.grid : PostType.image),
      duration: videoDur,
      aspectRatio: aspectRatio,
    );
  }

  DiscoverPost copyWith({int? likes, bool? liked}) => DiscoverPost(
        id: id,
        userId: userId,
        image: image,
        images: images,
        title: title,
        username: username,
        avatar: avatar,
        likes: likes ?? this.likes,
        type: type,
        duration: duration,
        aspectRatio: aspectRatio,
        liked: liked ?? this.liked,
      );
}

/// 点赞数格式化
String _formatLikeCount(int n) {
  if (n >= 10000) {
    final v = n / 10000;
    return '${v.toStringAsFixed(1)}w';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return '${v.toStringAsFixed(1)}k';
  }
  return '$n';
}

/// 视频时长格式化（秒 → mm:ss）
String formatDuration(double? seconds) {
  if (seconds == null || seconds <= 0) return '';
  final total = seconds.round();
  final m = (total ~/ 60).toString().padLeft(2, '0');
  final s = (total % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

// =============================================================================
// 配色常量
// =============================================================================

class DiscoverColors {
  DiscoverColors._();

  static const pageBg = Palette.background;
  static const primary = Palette.primary;
  static const primaryLight = Palette.primaryTint;
  static const cardBg = Palette.surface;
  static const titleColor = Palette.textPrimary;
  static const usernameColor = Palette.textSecondary;
  static const unselectedText = Palette.textTertiary;
  static const unselectedBg = Palette.surfaceAlt;
  static const searchIcon = Palette.textPrimary;
}

// =============================================================================
// DiscoverPage - 社区发现主页（真实接口数据）
// =============================================================================

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key, required this.onSwitchTab});

  final ValueChanged<int> onSwitchTab;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  int _topTabIndex = 0; // 0=发现, 1=关注
  int _categoryIndex = 0; // 推荐/最新/热门...

  final List<DiscoverPost> _posts = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  static const _pageSize = 20;
  static const _categories = ['推荐', '最新', '热门', '教程', '日常', '活动'];

  bool get _isFollowing => _topTabIndex == 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 按当前 Tab / 分类拉取数据
  Future<({List<DiscoverPost> items, int total})> _fetch({required int page}) async {
    if (_isFollowing) {
      final r = await PostApi.fetchFollowing(page: page);
      return (
        items: r.items.map(DiscoverPost.fromPost).toList(),
        total: r.total,
      );
    }
    switch (_categories[_categoryIndex]) {
      case '最新':
        final r = await PostApi.fetchLatest(page: page);
        return (
          items: r.items.map(DiscoverPost.fromPost).toList(),
          total: r.total,
        );
      case '推荐':
      case '热门':
        final r = await PostApi.fetchHot(page: page);
        return (
          items: r.items.map(DiscoverPost.fromPost).toList(),
          total: r.total,
        );
      default:
        // 教程 / 日常 / 活动：按关键词搜索
        final r = await PostApi.fetchLatest(page: page, q: _categories[_categoryIndex]);
        return (
          items: r.items.map(DiscoverPost.fromPost).toList(),
          total: r.total,
        );
    }
  }

  /// 批量加载点赞状态（未登录 / 失败时忽略）
  Future<Map<int, bool>> _fetchLiked(List<int> ids) async {
    if (ids.isEmpty) return {};
    try {
      return await PostApi.batchLiked(ids);
    } catch (_) {
      return {};
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
    });
    try {
      final result = await _fetch(page: 1);
      final likedMap = await _fetchLiked(result.items.map((p) => p.id).toList());
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(
            result.items
                .map((p) => p.copyWith(liked: likedMap[p.id] ?? false)),
          );
        _hasMore = result.items.length >= _pageSize;
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

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _fetch(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _posts.addAll(result.items);
        _page += 1;
        _hasMore = result.items.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// 切换 Tab / 分类时重置并刷新
  void _onTabChanged(int i) {
    if (i == _topTabIndex) return;
    setState(() => _topTabIndex = i);
    _load();
  }

  void _onCategoryChanged(int i) {
    if (i == _categoryIndex) return;
    setState(() => _categoryIndex = i);
    _load();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 400) {
      _loadMore();
    }
    return false;
  }

  /// 点赞 / 取消点赞（乐观更新，失败回滚）
  Future<void> _toggleLike(DiscoverPost post) async {
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i < 0) return;
    final liked = !post.liked;
    setState(() {
      _posts[i] = post.copyWith(
        liked: liked,
        likes: (post.likes + (liked ? 1 : -1)).clamp(0, 1 << 31),
      );
    });
    try {
      await PostApi.toggleLike(post.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _posts[i] = post);
    }
  }

  void _openDetail(DiscoverPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id)),
    );
  }

  void _openAuthor(DiscoverPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AuthorProfilePage(userId: post.userId)),
    );
  }

  Future<void> _openPublish() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PublishPostPage()),
    );
    _load();
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DiscoverSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiscoverColors.pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TopTabBar(
                  selectedIndex: _topTabIndex,
                  onChanged: _onTabChanged,
                  onSearch: _openSearch,
                ),
                if (!_isFollowing)
                  CategoryBar(
                    selectedIndex: _categoryIndex,
                    onChanged: _onCategoryChanged,
                  ),
                Expanded(
                  child: RefreshIndicator(
                    color: DiscoverColors.primary,
                    onRefresh: _load,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScroll,
                      child: _buildBody(),
                    ),
                  ),
                ),
              ],
            ),
            // 悬浮发布按钮
            Positioned(right: 20, bottom: 16, child: _buildFab()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const _DiscoverSkeleton();
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 48, color: DiscoverColors.usernameColor),
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: DiscoverColors.usernameColor, fontSize: 14)),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _load, child: const Text('重试')),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (_posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isFollowing
                        ? Icons.favorite_border_rounded
                        : Icons.brush_outlined,
                    size: 48,
                    color: DiscoverColors.usernameColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isFollowing ? '关注的人还没有发布作品' : '还没有作品，来发布第一个吧',
                    style: const TextStyle(
                        color: DiscoverColors.usernameColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return PostGrid(
      posts: _posts,
      hasMore: _hasMore,
      loadingMore: _loadingMore,
      onTapPost: _openDetail,
      onLikePost: _toggleLike,
      onTapAuthor: _openAuthor,
    );
  }

  Widget _buildFab() {
    return Material(
      elevation: 6,
      shadowColor: DiscoverColors.primary.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _openPublish,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: DiscoverColors.primary,
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// =============================================================================
// TopTabBar - 顶部 Tab（发现 / 关注）
// =============================================================================

class TopTabBar extends StatelessWidget {
  const TopTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.onSearch,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onSearch;

  static const _tabs = ['发现', '关注'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: DiscoverColors.pageBg,
      child: Stack(
        children: [
          // 居中 Tabs
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_tabs.length, (i) {
                final selected = i == selectedIndex;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 28,
                      right: i == _tabs.length - 1 ? 0 : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tabs[i],
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: selected
                                ? const Color(0xFF1A1A1A)
                                : DiscoverColors.unselectedText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: selected ? 20 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: selected
                                ? DiscoverColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // 右侧搜索图标
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.search_rounded,
                  color: DiscoverColors.searchIcon,
                  size: 24,
                ),
                onPressed: onSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CategoryBar - 横向滚动分类胶囊
// =============================================================================

class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _categories = ['推荐', '最新', '热门', '教程', '日常', '活动'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: DiscoverColors.pageBg,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? DiscoverColors.primaryLight
                    : DiscoverColors.unselectedBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? DiscoverColors.primary
                      : const Color(0xFF666666),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// PostGrid - 瀑布流内容区
// =============================================================================

class PostGrid extends StatelessWidget {
  const PostGrid({
    super.key,
    required this.posts,
    this.hasMore = false,
    this.loadingMore = false,
    this.onTapPost,
    this.onLikePost,
    this.onTapAuthor,
  });

  final List<DiscoverPost> posts;
  final bool hasMore;
  final bool loadingMore;
  final ValueChanged<DiscoverPost>? onTapPost;
  final ValueChanged<DiscoverPost>? onLikePost;
  final ValueChanged<DiscoverPost>? onTapAuthor;

  @override
  Widget build(BuildContext context) {
    final showFooter = hasMore || loadingMore || posts.isNotEmpty;
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= posts.length) {
          return loadingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '没有更多了',
                      style: TextStyle(
                        fontSize: 12,
                        color: DiscoverColors.usernameColor,
                      ),
                    ),
                  ),
                );
        }
        final post = posts[index];
        return PostCard(
          post: post,
          onTap: onTapPost == null ? null : () => onTapPost!(post),
          onLike: onLikePost == null ? null : () => onLikePost!(post),
          onTapAuthor:
              onTapAuthor == null ? null : () => onTapAuthor!(post),
        );
      },
    );
  }
}

// =============================================================================
// PostCard - 帖子卡片
// =============================================================================

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onTapAuthor,
  });

  final DiscoverPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onTapAuthor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DiscoverColors.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: DiscoverColors.primary, width: 0.6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageArea(),
            // 纯文字卡片已在媒体区展示正文，标题区不再重复
            if (post.type != PostType.text) _buildTextArea(),
            _buildUserInfo(),
          ],
        ),
      ),
    );
  }

  /// 图片区域（单图 / 四宫格 / 视频封面）
  Widget _buildImageArea() {
    if (post.type == PostType.text) return _buildTextTile();
    final w = post.type == PostType.grid
        ? _buildGridImages()
        : _buildSingleImage();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      child: w,
    );
  }

  /// 纯文字帖子卡片：暖色渐变 + 正文预览，替代图片占位
  Widget _buildTextTile() {
    final title = post.title.trim();
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Palette.iconBgOrange, Palette.accentLight],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: DiscoverColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '纯文字',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DiscoverColors.primary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title.isEmpty ? '分享一条纯文字动态' : title,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF3D3836),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 单图 / 视频封面
  Widget _buildSingleImage() {
    return AspectRatio(
      aspectRatio: post.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.image,
            fit: BoxFit.cover,
            cacheWidth: 600,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFFF0EEF2),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFFC0C0CC),
                size: 28,
              ),
            ),
          ),
          // 视频类型：播放按钮 + 时长标签
          if (post.type == PostType.video) ...[
            Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF333333),
                  size: 22,
                ),
              ),
            ),
            if (formatDuration(post.duration).isNotEmpty)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formatDuration(post.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// 四宫格图片
  Widget _buildGridImages() {
    final images =
        post.images.length >= 4 ? post.images.take(4).toList() : post.images;
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: images.map((url) {
          return Image.network(
            url,
            fit: BoxFit.cover,
            cacheWidth: 300,
            errorBuilder: (_, _, _) =>
                Container(color: const Color(0xFFF0EEF2)),
          );
        }).toList(),
      ),
    );
  }

  /// 标题文字（最多两行）
  Widget _buildTextArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Text(
        post.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: DiscoverColors.titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 用户信息 + 点赞
  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        children: [
          // 头像
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapAuthor,
            child: ClipOval(
              child: post.avatar.isEmpty
                  ? Container(
                      width: 24,
                      height: 24,
                      color: DiscoverColors.primaryLight,
                      child: Center(
                        child: Text(
                          post.username.isNotEmpty ? post.username[0] : '?',
                          style: const TextStyle(
                            color: DiscoverColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : Image.network(
                      post.avatar,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      cacheWidth: 72,
                      errorBuilder: (_, _, _) => Container(
                        width: 24,
                        height: 24,
                        color: DiscoverColors.primaryLight,
                        child: Center(
                          child: Text(
                            post.username.isNotEmpty ? post.username[0] : '?',
                            style: const TextStyle(
                              color: DiscoverColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 6),
          // 用户名
          Expanded(
            child: Text(
              post.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: DiscoverColors.usernameColor,
              ),
            ),
          ),
          // 点赞
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLike,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: post.liked
                      ? DiscoverColors.primary
                      : DiscoverColors.usernameColor,
                  size: 16,
                ),
                const SizedBox(width: 3),
                Text(
                  _formatLikeCount(post.likes),
                  style: const TextStyle(
                    fontSize: 12,
                    color: DiscoverColors.usernameColor,
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

/// 首屏骨架屏
class _DiscoverSkeleton extends StatelessWidget {
  const _DiscoverSkeleton();

  @override
  Widget build(BuildContext context) {
    const block = Color(0xFFECECF0);
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (_, i) => Container(
        height: 180 + (i % 3) * 40,
        decoration: BoxDecoration(
          color: block,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
