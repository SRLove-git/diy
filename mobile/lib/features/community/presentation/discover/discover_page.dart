import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// =============================================================================
// 数据模型
// =============================================================================

/// 帖子类型
enum PostType { image, video, grid }

/// 社区发现页帖子模型
class DiscoverPost {
  const DiscoverPost({
    required this.id,
    required this.image,
    this.images = const [],
    required this.title,
    required this.username,
    required this.avatar,
    required this.likes,
    this.type = PostType.image,
    this.duration = '',
    this.aspectRatio = 3 / 4,
  });

  final int id;
  final String image;
  final List<String> images;
  final String title;
  final String username;
  final String avatar;
  final int likes;
  final PostType type;
  final String duration;
  final double aspectRatio;
}

/// 模拟数据：至少 12 条帖子
List<DiscoverPost> generateMockPosts() {
  return const [
    // 1. 单图 - 美乐蒂作品
    DiscoverPost(
      id: 1,
      image: 'https://picsum.photos/seed/diy1/400/520',
      title: '做了超可爱的美乐蒂～\n少女心爆棚💗',
      username: '草莓奶油',
      avatar: 'https://picsum.photos/seed/ava1/100/100',
      likes: 328,
      aspectRatio: 3 / 4,
    ),
    // 2. 视频教程
    DiscoverPost(
      id: 2,
      image: 'https://picsum.photos/seed/diy2/400/580',
      title: '拼豆入门教程｜零基础也能做出超萌挂件',
      username: '手作达人Lily',
      avatar: 'https://picsum.photos/seed/ava2/100/100',
      likes: 1205,
      type: PostType.video,
      duration: '03:28',
      aspectRatio: 3 / 4.3,
    ),
    // 3. 单图 - 库洛米
    DiscoverPost(
      id: 3,
      image: 'https://picsum.photos/seed/diy3/400/480',
      title: '库洛米也太适合做拼豆了吧🖤',
      username: '暗黑甜心',
      avatar: 'https://picsum.photos/seed/ava3/100/100',
      likes: 256,
      aspectRatio: 1 / 1.2,
    ),
    // 4. 四宫格 - 制作过程
    DiscoverPost(
      id: 4,
      image: 'https://picsum.photos/seed/diy4a/400/500',
      images: [
        'https://picsum.photos/seed/diy4a/200/200',
        'https://picsum.photos/seed/diy4b/200/200',
        'https://picsum.photos/seed/diy4c/200/200',
        'https://picsum.photos/seed/diy4d/200/200',
      ],
      title: '星黛露制作全过程✨每一步都好治愈',
      username: '兔兔收集家',
      avatar: 'https://picsum.photos/seed/ava4/100/100',
      likes: 891,
      type: PostType.grid,
      aspectRatio: 3 / 4,
    ),
    // 5. 单图
    DiscoverPost(
      id: 5,
      image: 'https://picsum.photos/seed/diy5/400/540',
      title: '新品预告！玉桂狗系列明天上线☁️',
      username: '拾染爱恋官方',
      avatar: 'https://picsum.photos/seed/ava5/100/100',
      likes: 2103,
      aspectRatio: 3 / 4.1,
    ),
    // 6. 视频
    DiscoverPost(
      id: 6,
      image: 'https://picsum.photos/seed/diy6/400/470',
      title: '30秒看完一块拼豆的诞生🎬',
      username: '拼豆小天才',
      avatar: 'https://picsum.photos/seed/ava6/100/100',
      likes: 667,
      type: PostType.video,
      duration: '00:30',
      aspectRatio: 1 / 1.1,
    ),
    // 7. 单图 - Hello Kitty
    DiscoverPost(
      id: 7,
      image: 'https://picsum.photos/seed/diy7/400/600',
      title: '给闺蜜做了一套Hello Kitty杯垫🎀超满意',
      username: '粉色泡泡糖',
      avatar: 'https://picsum.photos/seed/ava7/100/100',
      likes: 445,
      aspectRatio: 2 / 3,
    ),
    // 8. 四宫格 - 配色分享
    DiscoverPost(
      id: 8,
      image: 'https://picsum.photos/seed/diy8a/400/490',
      images: [
        'https://picsum.photos/seed/diy8a/200/200',
        'https://picsum.photos/seed/diy8b/200/200',
        'https://picsum.photos/seed/diy8c/200/200',
        'https://picsum.photos/seed/diy8d/200/200',
      ],
      title: '今日配色灵感｜奶油马卡龙色系组合🎨',
      username: '配色美学',
      avatar: 'https://picsum.photos/seed/ava8/100/100',
      likes: 532,
      type: PostType.grid,
      aspectRatio: 3 / 4,
    ),
    // 9. 单图
    DiscoverPost(
      id: 9,
      image: 'https://picsum.photos/seed/diy9/400/510',
      title: '周末宅家做了一天手工，太解压了😌',
      username: '治愈系手作',
      avatar: 'https://picsum.photos/seed/ava9/100/100',
      likes: 167,
      aspectRatio: 3 / 4.1,
    ),
    // 10. 视频
    DiscoverPost(
      id: 10,
      image: 'https://picsum.photos/seed/diy10/400/560',
      title: '无火香薰蜡烛手作🕯️过程太美了',
      username: '香气日记',
      avatar: 'https://picsum.photos/seed/ava10/100/100',
      likes: 943,
      type: PostType.video,
      duration: '05:12',
      aspectRatio: 3 / 4.2,
    ),
    // 11. 单图 - 布丁狗
    DiscoverPost(
      id: 11,
      image: 'https://picsum.photos/seed/diy11/400/530',
      title: '布丁狗钥匙扣🔑越看越可爱',
      username: '每天都要可爱',
      avatar: 'https://picsum.photos/seed/ava11/100/100',
      likes: 208,
      aspectRatio: 3 / 4,
    ),
    // 12. 单图 - 作品合集
    DiscoverPost(
      id: 12,
      image: 'https://picsum.photos/seed/diy12/400/490',
      title: '入坑一个月，看看我的作品全家福👨‍👩‍👧‍👦',
      username: '新手小裁缝',
      avatar: 'https://picsum.photos/seed/ava12/100/100',
      likes: 789,
      aspectRatio: 1 / 1.2,
    ),
  ];
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

// =============================================================================
// 配色常量
// =============================================================================

class DiscoverColors {
  DiscoverColors._();

  static const pageBg = Color(0xFFFFFBFC);
  static const primary = Color(0xFFFF718D);
  static const primaryLight = Color(0x1AFF718D); // ~10% opacity
  static const cardBg = Colors.white;
  static const titleColor = Color(0xFF333333);
  static const usernameColor = Color(0xFF666666);
  static const unselectedText = Color(0xFF999999);
  static const unselectedBg = Color(0xFFFFF0F3);
  static const searchIcon = Color(0xFF333333);
}

// =============================================================================
// DiscoverPage - 社区发现主页
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

  final List<DiscoverPost> _posts = generateMockPosts();

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
                  onChanged: (i) => setState(() => _topTabIndex = i),
                ),
                CategoryBar(
                  selectedIndex: _categoryIndex,
                  onChanged: (i) => setState(() => _categoryIndex = i),
                ),
                Expanded(child: PostGrid(posts: _posts)),
              ],
            ),
            // 悬浮发布按钮
            Positioned(right: 20, bottom: 16, child: _buildFab()),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Material(
      elevation: 6,
      shadowColor: DiscoverColors.primary.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF718D), Color(0xFFFF8FA6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

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
                          height: 3,
                          decoration: BoxDecoration(
                            color: selected
                                ? DiscoverColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
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
                onPressed: () {},
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
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? DiscoverColors.primaryLight
                    : DiscoverColors.unselectedBg,
                borderRadius: BorderRadius.circular(20),
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
  const PostGrid({super.key, required this.posts});

  final List<DiscoverPost> posts;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: posts.length,
      itemBuilder: (context, index) => PostCard(post: posts[index]),
    );
  }
}

// =============================================================================
// PostCard - 帖子卡片
// =============================================================================

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final DiscoverPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DiscoverColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildImageArea(), _buildTextArea(), _buildUserInfo()],
      ),
    );
  }

  /// 图片区域（单图 / 四宫格 / 视频封面）
  Widget _buildImageArea() {
    final w = post.type == PostType.grid
        ? _buildGridImages()
        : _buildSingleImage();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: w,
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
            if (post.duration.isNotEmpty)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    post.duration,
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
    final images = post.images.length >= 4
        ? post.images.take(4).toList()
        : post.images;
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
          ClipOval(
            child: Image.network(
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
          const Icon(
            Icons.favorite_border_rounded,
            color: DiscoverColors.usernameColor,
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
    );
  }
}
