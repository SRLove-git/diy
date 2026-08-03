import 'package:flutter/material.dart';

/// 打开全屏图片查看器（共享元素动画：当前页面逐渐变暗，图片从原图位置放大铺满全屏；关闭时倒放缩回）
///
/// [heroTag] 需与缩略图外层 `Hero(tag: ...)` 的 tag 一致，二者配对完成飞行动画；
/// [precache] 用于提前解码原图，避免飞行过程中出现加载占位。
Future<void> showImageViewer(
  BuildContext context, {
  required Widget image,
  required Object heroTag,
  ImageProvider? precache,
}) async {
  if (precache != null) {
    try {
      await precacheImage(precache, context);
    } catch (_) {
      // 预加载失败不阻断查看（查看器内置加载/失败占位）
    }
  }
  if (!context.mounted) return;
  await Navigator.of(context).push(
    // 非不透明路由：下层页面保持可见并随过渡逐渐变暗，而不是从右侧滑入新页面
    PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => ImageViewerPage(image: image, heroTag: heroTag),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        // 与 Hero 飞行使用同一 easeInOut 曲线（见下方 Hero.curve），保证打开/关闭逐帧同步
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
        ),
        child: child,
      ),
    ),
  );
}

/// 网络图 → 查看器用的原图（contain 铺满 + 加载/失败占位）
Widget networkViewerImage(String url) => Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              ),
            ),
      errorBuilder: (_, _, _) => const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 56,
        ),
      ),
    );

/// 全屏图片查看页：黑底、单点关闭、双指缩放、双击放大/还原
class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    required this.image,
    required this.heroTag,
  });

  final Widget image;

  /// 与缩略图 Hero 相同的 tag（共享元素动画）
  final Object heroTag;

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  final _controller = TransformationController();
  Offset _doubleTapPos = Offset.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails d) => _doubleTapPos = d.localPosition;

  /// 关闭：直接倒放（从当前画面平滑缩回原图位置）。
  /// 注意不要在这里复位缩放——强制 Matrix4.identity 会让缩放态先跳回全屏再缩回。
  void _close() {
    Navigator.of(context).pop();
  }

  void _onDoubleTap() {
    final scale = _controller.value.getMaxScaleOnAxis();
    if (scale > 1.0) {
      _controller.value = Matrix4.identity();
      return;
    }
    // 以双击位置为中心放大：等效 translate(p*(1-s)) * scale(s)
    const s = 2.5;
    final x = _doubleTapPos.dx;
    final y = _doubleTapPos.dy;
    _controller.value = Matrix4(
      s, 0, 0, 0,
      0, s, 0, 0,
      0, 0, 1, 0,
      x - s * x, y - s * y, 0, 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              onDoubleTapDown: _onDoubleTapDown,
              onDoubleTap: _onDoubleTap,
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1.0,
                maxScale: 5.0,
                child: SizedBox.expand(
                  // 1) 与路由淡入淡出共用 easeInOut：开/关动画平滑且逐帧同步，关闭即为打开的精确倒放。
                  // 2) flightShuttleBuilder：飞行过程中始终显示查看器的 contain 原图，
                  //    否则默认会用缩略图（cover 裁切过）的内容撑满屏幕再缩回，关闭就不是精确倒放。
                  child: Hero(
                    tag: widget.heroTag,
                    curve: Curves.easeInOut,
                    flightShuttleBuilder: (_, _, _, _, _) => widget.image,
                    child: widget.image,
                  ),
                ),
              ),
            ),
          ),
          // 顶部关闭按钮
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    tooltip: '关闭',
                    onPressed: _close,
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
