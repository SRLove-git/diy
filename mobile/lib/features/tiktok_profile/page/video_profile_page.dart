import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/auth_service.dart';
import '../provider/profile_videos_controller.dart';
import '../widget/video_grid_card.dart';
import '../widget/video_grid_footer.dart';
import 'fullscreen_video_page.dart';

/// 抖音风格个人主页视频页（page 页面层）
///
/// 结构对齐需求：
/// 1. 顶部：沉浸式状态栏 + 返回箭头 + 用户昵称 + 更多菜单按钮；
/// 2. 中部：2 列视频封面瀑布流（SliverGrid，2px 间距、宽高比 0.8），
///    每格展示视频封面 + 播放次数浮标；
/// 3. 交互：下拉刷新、上拉分页加载更多、双击封面爱心点赞；
/// 4. 点击封面进入全屏上下滑动播放页（[FullscreenVideoPage]）。
///
/// 状态管理使用 Provider（[ProfileVideosController]），
/// 播放页复用同一实例，互动数据返回后自动同步回作品墙。
class VideoProfilePage extends StatefulWidget {
  const VideoProfilePage({super.key, this.userId, this.nickname});

  /// 作者用户 ID；为空表示当前登录用户
  final int? userId;

  /// 顶部昵称；为空时取登录用户昵称，兜底 `srlovice`
  final String? nickname;

  @override
  State<VideoProfilePage> createState() => _VideoProfilePageState();
}

class _VideoProfilePageState extends State<VideoProfilePage> {
  /// 顶部昵称：传入 > 登录用户 > 截图兜底
  String get _nickname {
    final n = widget.nickname ?? AuthService.instance.user?.nickname ?? '';
    return n.trim().isNotEmpty ? n : 'srlovice';
  }

  /// 进入全屏播放页：传入作品快照 + 同一个 Provider 实例，
  /// 播放页内点赞/收藏/评论等变化会实时同步回作品墙。
  void _openPlayer(BuildContext context, int index) {
    final ctrl = context.read<ProfileVideosController>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPage(
          videos: ctrl.videos,
          initialIndex: index,
          controller: ctrl,
          nickname: _nickname,
        ),
      ),
    );
  }

  /// 顶部「更多」菜单
  void _openMoreMenu(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C24),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTile(
                icon: Icons.ios_share_rounded,
                label: '分享主页',
                onTap: () => _toast('分享主页功能开发中'),
              ),
              _SheetTile(
                icon: Icons.refresh_rounded,
                label: '刷新作品列表',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  ctx.read<ProfileVideosController>().refresh();
                },
              ),
              _SheetTile(
                icon: Icons.cancel_outlined,
                label: '取消',
                onTap: () => Navigator.of(sheetCtx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileVideosController(userId: widget.userId)..refresh(),
      child: Consumer<ProfileVideosController>(
        builder: (context, ctrl, _) {
          // 上拉分页：剩余距离不足 400px 时触发下一页加载
          // （放在 Consumer 作用域内，保证能读取到 Provider）
          return Scaffold(
            backgroundColor: const Color(0xFF0F0F0F),
            body: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.axis == Axis.vertical &&
                    n.metrics.extentAfter < 400) {
                  ctrl.loadMore();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: ctrl.refresh,
                color: Palette.accent,
                backgroundColor: const Color(0xFF20202A),
                displacement: 56,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    _buildTopBar(context),
                    ..._buildContent(context, ctrl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ──── 顶部区域 ────

  /// 沉浸式顶栏：返回箭头 + 昵称 + 更多菜单（固定吸顶）
  Widget _buildTopBar(BuildContext ctx) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0F0F0F),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 52,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: _TopBarButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
      title: Text(
        _nickname,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _TopBarButton(
            icon: Icons.more_horiz_rounded,
            onTap: () => _openMoreMenu(ctx),
          ),
        ),
      ],
    );
  }

  // ──── 内容区域 ────

  List<Widget> _buildContent(BuildContext context, ProfileVideosController ctrl) {
    // 首次加载：骨架屏
    if (ctrl.loading) return [_buildSkeleton()];
    // 加载失败且无数据：错误态
    if (ctrl.error != null && ctrl.videos.isEmpty) {
      return [_buildError(ctrl)];
    }
    // 空数据：空态
    if (ctrl.videos.isEmpty) return [_buildEmpty()];

    return [
      // 2 列瀑布流：间距 2px、宽高比 0.8（需求硬性要求）
      SliverPadding(
        padding: EdgeInsets.zero,
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final item = ctrl.videos[i];
              return VideoGridCard(
                item: item,
                onTap: () => _openPlayer(context, i),
                onDoubleTap: () => ctrl.toggleLike(item),
              );
            },
            childCount: ctrl.videos.length,
          ),
        ),
      ),
      // 尾部：上拉分页加载状态 / 没有更多
      SliverToBoxAdapter(
        child: VideoGridFooter(
          loading: ctrl.loadingMore,
          hasMore: ctrl.hasMore,
        ),
      ),
    ];
  }

  /// 骨架屏：与真实网格同规格的占位格
  Widget _buildSkeleton() {
    return SliverPadding(
      padding: EdgeInsets.zero,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => const ColoredBox(
            color: Color(0xFF16161C),
            child: Center(
              child: Icon(
                Icons.movie_outlined,
                color: Color(0xFF2C2C36),
                size: 34,
              ),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildError(ProfileVideosController ctrl) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFF555566),
              size: 52,
            ),
            const SizedBox(height: 14),
            const Text(
              '作品加载失败',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: ctrl.refresh,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '重新加载',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              color: Color(0xFF555566),
              size: 56,
            ),
            SizedBox(height: 14),
            Text(
              '还没有发布作品',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            SizedBox(height: 6),
            Text(
              '发布短视频后，作品会展示在这里',
              style: TextStyle(color: Color(0xFF777788), fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// 顶栏圆形按钮
class _TopBarButton extends StatelessWidget {
  const _TopBarButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 21, color: Colors.white),
        ),
      ),
    );
  }
}

/// 更多菜单项
class _SheetTile extends StatelessWidget {
  const _SheetTile({
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 21),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
            ),
          ],
        ),
      ),
    );
  }
}
