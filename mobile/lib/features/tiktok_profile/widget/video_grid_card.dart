import 'package:flutter/material.dart';

import '../../../features/community/domain/community_models.dart';
import '../model/tiktok_video_model.dart';
import 'like_burst.dart';

/// 作品墙网格封面卡片（widget 组件层）
///
/// 抖音式两列宫格单元：封面全铺 + 左下播放量浮标 + 右下时长角标。
/// 单击进入全屏播放页，双击触发爱心点赞动画（[LikeBurst]）并回调外层
/// 执行点赞逻辑。
///
/// 注意：单元格不设圆角、间距由 SliverGrid 的 2px spacing 控制，
/// 与抖音个人主页作品墙视觉一致。
class VideoGridCard extends StatefulWidget {
  const VideoGridCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDoubleTap,
    this.onLongPress,
    this.photoCount = 0,
  });

  final TiktokVideoModel item;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  /// 长按（个人主页 Tab 用于删除作品）
  final VoidCallback? onLongPress;

  /// 笔记照片张数；> 0 时右下角展示「照片数」角标替代视频时长
  final int photoCount;

  @override
  State<VideoGridCard> createState() => _VideoGridCardState();
}

class _VideoGridCardState extends State<VideoGridCard> {
  final GlobalKey<LikeBurstState> _burstKey = GlobalKey<LikeBurstState>();

  /// 双击：先播放爱心动画，再交给外层执行点赞（点赞与动画解耦）
  void _onDoubleTap() {
    _burstKey.currentState?.trigger();
    widget.onDoubleTap();
  }

  /// 时长格式化 mm:ss
  String _fmtDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onDoubleTap: _onDoubleTap,
        onLongPress: widget.onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 封面
            if (item.cover.isNotEmpty)
              Image.network(
                item.cover,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, sync) {
                  if (sync || frame != null) return child;
                  return _placeholder();
                },
                errorBuilder: (_, _, _) => _placeholder(),
              )
            else
              _placeholder(),

            // 底部微渐变，保证浮标可读
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.6, 1.0],
                    colors: [Colors.transparent, Colors.black38],
                  ),
                ),
              ),
            ),

            // 左下：播放量浮标
            Positioned(
              left: 8,
              bottom: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      formatCount(item.viewCount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 右下：时长角标（视频）或照片数角标（笔记）
            if (widget.photoCount > 0)
              Positioned(
                right: 7,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 11,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.photoCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (!item.isPhoto && item.duration > Duration.zero)
              Positioned(
                right: 7,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _fmtDuration(item.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                ),
              ),

            // 双击点赞爱心
            LikeBurst(key: _burstKey, size: 72),
          ],
        ),
      ),
    );
  }

  /// 封面加载中/失败占位
  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFF16161C),
      child: Center(
        child: Icon(Icons.movie_outlined, color: Color(0xFF3A3A48), size: 34),
      ),
    );
  }
}
