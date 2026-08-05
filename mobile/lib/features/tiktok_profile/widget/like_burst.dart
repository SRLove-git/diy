import 'package:flutter/material.dart';

/// 双击点赞的爱心爆心动画（widget 组件层）
///
/// 抖音式交互：双击视频/封面时，画面中央弹出一颗粉色爱心，
/// 先放大到 130% 再回弹，同时逐渐淡出。
///
/// 用法：通过 [LikeBurstState] 触发，页面持有 GlobalKey：
///
/// ```dart
/// final _burstKey = GlobalKey<LikeBurstState>();
/// ...
/// LikeBurst(key: _burstKey, size: 96)
/// ...
/// _burstKey.currentState?.trigger();
/// ```
class LikeBurst extends StatefulWidget {
  const LikeBurst({
    super.key,
    this.size = 96,
    this.color = const Color(0xFFFF718D),
  });

  /// 爱心尺寸
  final double size;

  /// 爱心颜色（抖音粉）
  final Color color;

  @override
  State<LikeBurst> createState() => LikeBurstState();
}

class LikeBurstState extends State<LikeBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  /// 缩放：0.5 → 1.3（回弹）→ 1.0
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.5, end: 1.3)
          .chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 60,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.3, end: 1.0)
          .chain(CurveTween(curve: Curves.easeInOut)),
      weight: 40,
    ),
  ]).animate(_ctrl);

  /// 淡出：动画后半段透明度归零
  late final Animation<double> _opacity = Tween(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.45, 1)));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// 触发一次爱心动画（可连续双击，每次从头播放）
  void trigger() {
    if (!mounted) return;
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => Opacity(
            opacity: _ctrl.isAnimating ? _opacity.value : 0,
            child: Transform.scale(
              scale: _scale.value,
              child: Icon(
                Icons.favorite_rounded,
                color: widget.color,
                size: widget.size,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
