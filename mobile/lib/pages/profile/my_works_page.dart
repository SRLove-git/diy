import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../core/post_api.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/state_widgets.dart';
import '../community/post_detail_page.dart';
import '../shoot_page.dart';

/// 我的作品 —— 现代化作品墙
///
/// 渐变头部 + 数据概览 + 双列卡片网格，骨架屏加载，
/// 下拉刷新与删除、查看大图等交互全部保留。
class MyWorksPage extends StatefulWidget {
  const MyWorksPage({super.key});

  @override
  State<MyWorksPage> createState() => _MyWorksPageState();
}

class _MyWorksPageState extends State<MyWorksPage> {
  final _posts = <Post>[];
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
      final result = await PostApi.fetchMine();
      if (mounted) {
        setState(() {
          _posts.clear();
          _posts.addAll(result.items);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = '加载失败，请下拉重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _totalLikes => _posts.fold(0, (sum, p) => sum + p.likeCount);
  int get _totalComments => _posts.fold(0, (sum, p) => sum + p.commentCount);
  int get _totalViews => _posts.fold(0, (sum, p) => sum + p.viewCount);

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('MM-dd HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  static String _fmtCount(int n) =>
      n >= 10000 ? '${(n / 10000).toStringAsFixed(1)}万' : '$n';

  void _openPublish() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShootPage()),
    );
  }

  /// 删除作品（二次确认）
  Future<void> _deletePost(Post post) async {
    final colors = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('删除作品'),
        content: const Text('删除后不可恢复，确定删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await PostApi.deletePost(post.id);
      if (!mounted) return;
      setState(() => _posts.removeWhere((p) => p.id == post.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已删除'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('删除失败，请稍后再试'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        color: colors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildHeader(context),
            ..._buildContent(context),
          ],
        ),
      ),
    );
  }

  // ---------- 头部 ----------

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 184,
      backgroundColor: AppColors.of(context).primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: _HeaderCircleButton(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.maybePop(context),
      ),
      actions: [
        _HeaderCircleButton(
          icon: Icons.add_rounded,
          onTap: _openPublish,
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF3040), Color(0xFFFF7E63)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 6, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '个人作品',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${_posts.length} 件作品',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatItem(label: '作品', value: _fmtCount(_posts.length)),
                      _StatItem(label: '获赞', value: _fmtCount(_totalLikes)),
                      _StatItem(label: '评论', value: _fmtCount(_totalComments)),
                      _StatItem(label: '浏览', value: _fmtCount(_totalViews)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- 内容区 ----------

  List<Widget> _buildContent(BuildContext context) {
    if (_loading) {
      return [_SkeletonGrid()];
    }
    if (_error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorWidget(message: _error!, onRetry: _load),
        ),
      ];
    }
    if (_posts.isEmpty) {
      return [_buildEmpty(context)];
    }
    return [_buildGrid(context)];
  }

  Widget _buildGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardW = (width - 20 * 2 - 12) / 2;
    final coverH = cardW * 4 / 3;
    const contentH = 114.0;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: coverH + contentH,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _WorkCard(
            post: _posts[i],
            coverH: coverH,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailPage(postId: _posts[i].id),
                ),
              );
            },
            onDelete: () => _deletePost(_posts[i]),
            formatTime: _formatTime,
          ),
          childCount: _posts.length,
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = AppColors.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFE3E8), Color(0xFFFFF1E3)],
                  ),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 44,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '还没有发布作品',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '发布你的第一件手作，和同好们分享',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _openPublish,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('去发布作品'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- 头部小组件 ----------

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- 作品卡片 ----------

class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.post,
    required this.coverH,
    required this.onTap,
    required this.onDelete,
    required this.formatTime,
  });

  final Post post;
  final double coverH;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(String) formatTime;

  /// 封面图：优先 medias 首项，其次 images 首项，兼容 /uploads/ 相对路径
  String _coverOf(Post post) {
    final mediaList = post.medias.isNotEmpty
        ? post.medias
        : post.images
            .map(
              (url) => PostMedia(type: 'image', url: url, aspectRatio: 4 / 5),
            )
            .toList();
    if (mediaList.isEmpty) return '';
    final raw = mediaList.first.url;
    return raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : ChatApi.resolveUrl(raw);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cover = _coverOf(post);
    final title = post.title.isNotEmpty ? post.title : post.content;

    return _PressableCard(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? colors.divider
                : colors.divider.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面 + 信息叠加
            SizedBox(
              height: coverH,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (cover.isNotEmpty)
                    Hero(
                      tag: 'post-img-${post.id}-0',
                      child: GestureDetector(
                        onTap: () => showImageViewer(
                          context,
                          image: networkViewerImage(cover),
                          heroTag: 'post-img-${post.id}-0',
                          precache: NetworkImage(cover),
                        ),
                        child: Image.network(
                          cover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: colors.placeholder,
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: colors.placeholder,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  // 底部渐变，保证叠加信息可读
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black26,
                            Colors.black45,
                          ],
                          stops: [0.35, 0.75, 1],
                        ),
                      ),
                    ),
                  ),
                  // 点赞 / 评论胶囊
                  Positioned(
                    left: 10,
                    bottom: 8,
                    child: Row(
                      children: [
                        _CoverPill(
                          icon: Icons.favorite_rounded,
                          text: _MyWorksPageState._fmtCount(post.likeCount),
                        ),
                        const SizedBox(width: 6),
                        _CoverPill(
                          icon: Icons.chat_bubble_rounded,
                          text: _MyWorksPageState._fmtCount(post.commentCount),
                        ),
                      ],
                    ),
                  ),
                  // 删除按钮
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onDelete,
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 文字信息
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 37,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 16,
                    child: Text(
                      post.tags.map((t) => '#$t').join(' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(post.createdAt),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: colors.textSecondary,
                        ),
                      ),
                      if (post.viewCount > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 12,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _MyWorksPageState._fmtCount(post.viewCount),
                              style: TextStyle(
                                fontSize: 10.5,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
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
}

class _CoverPill extends StatelessWidget {
  const _CoverPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// 卡片按压微交互：按下轻微缩放
class _PressableCard extends StatefulWidget {
  const _PressableCard({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ---------- 骨架屏 ----------

class _SkeletonGrid extends StatefulWidget {
  @override
  State<_SkeletonGrid> createState() => _SkeletonGridState();
}

class _SkeletonGridState extends State<_SkeletonGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween(begin: 0.45, end: 0.9).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final width = MediaQuery.of(context).size.width;
    final cardW = (width - 20 * 2 - 12) / 2;
    final coverH = cardW * 4 / 3;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: coverH + 114,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => FadeTransition(
            opacity: _opacity,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.divider.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: coverH, color: colors.placeholder),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.placeholder,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: cardW * 0.55,
                          decoration: BoxDecoration(
                            color: colors.placeholder,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 10,
                          width: cardW * 0.4,
                          decoration: BoxDecoration(
                            color: colors.placeholder,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}
