import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../features/community/domain/community_models.dart';
import '../model/tiktok_video_model.dart';

/// 播放页右侧悬浮操作栏（widget 组件层）
///
/// 抖音原生视觉：白色图标 + 数量文案竖排，点击区域带圆形涟漪。
/// 包含：点赞 / 评论 / 转发 / 收藏 / 更多。
///
/// 点赞与收藏图标在状态切换时带弹性放大动画，
/// 由组件监听 [TiktokVideoModel.liked] / [favorited] 变化自动触发。
class VideoActionRail extends StatefulWidget {
  const VideoActionRail({
    super.key,
    required this.item,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFavorite,
    required this.onMore,
  });

  /// 当前展示的作品（点赞/收藏状态驱动图标动画）
  final TiktokVideoModel item;

  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final VoidCallback onMore;

  @override
  State<VideoActionRail> createState() => _VideoActionRailState();
}

class _VideoActionRailState extends State<VideoActionRail>
    with TickerProviderStateMixin {
  /// 点赞图标弹性动画（状态切换时触发一次）
  late final AnimationController _likePop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _likeScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.4)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.4, end: 1.0)
          .chain(CurveTween(curve: Curves.elasticOut)),
      weight: 55,
    ),
  ]).animate(_likePop);

  /// 收藏图标弹性动画
  late final AnimationController _favPop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _favScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.4)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.4, end: 1.0)
          .chain(CurveTween(curve: Curves.elasticOut)),
      weight: 55,
    ),
  ]).animate(_favPop);

  @override
  void didUpdateWidget(VideoActionRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.liked != oldWidget.item.liked) {
      _likePop.forward(from: 0);
    }
    if (widget.item.favorited != oldWidget.item.favorited) {
      _favPop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _likePop.dispose();
    _favPop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailItem(
          icon: ScaleTransition(
            scale: _likeScale,
            child: Icon(
              item.liked
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              color: item.liked ? Palette.accent : Colors.white,
              size: 32,
            ),
          ),
          label: formatCount(item.likeCount),
          onTap: widget.onLike,
        ),
        const SizedBox(height: 20),
        _RailItem(
          icon: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 30,
          ),
          label: formatCount(item.commentCount),
          onTap: widget.onComment,
        ),
        const SizedBox(height: 20),
        _RailItem(
          icon: const Icon(
            Icons.ios_share_rounded,
            color: Colors.white,
            size: 30,
          ),
          label: formatCount(item.shareCount),
          onTap: widget.onShare,
        ),
        const SizedBox(height: 20),
        _RailItem(
          icon: ScaleTransition(
            scale: _favScale,
            child: Icon(
              item.favorited
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: item.favorited ? const Color(0xFFFFC94D) : Colors.white,
              size: 32,
            ),
          ),
          label: formatCount(item.favoriteCount),
          onTap: widget.onFavorite,
        ),
        const SizedBox(height: 20),
        _RailItem(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: Colors.white,
            size: 32,
          ),
          label: '更多',
          onTap: widget.onMore,
        ),
      ],
    );
  }
}

/// 单个操作项：图标 + 数字文案，圆形涟漪
class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkResponse(
            onTap: onTap,
            radius: 26,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: icon,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            height: 1,
            shadows: [
              Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
      ],
    );
  }
}
