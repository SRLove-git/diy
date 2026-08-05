import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 背景音乐跑马灯（widget 组件层）
///
/// 抖音式底部音乐条：音乐名过长时横向无缝滚动，末尾带一张旋转唱片。
/// 文案不溢出时静止展示，避免无意义动画。
///
/// 滚动实现：文案重复两份并排，通过 AnimationController 平移
/// `文字宽 + 间距` 的距离，循环播放即可实现首尾无缝衔接。
class MusicMarquee extends StatefulWidget {
  const MusicMarquee({
    super.key,
    required this.text,
    this.style,
    this.speed = 42,
    this.gap = 36,
    this.showDisc = true,
  });

  /// 音乐名（为空时不渲染）
  final String text;

  /// 文案样式
  final TextStyle? style;

  /// 滚动速度（逻辑像素/秒）
  final double speed;

  /// 两份文案之间的间隔
  final double gap;

  /// 是否在末尾展示旋转唱片
  final bool showDisc;

  @override
  State<MusicMarquee> createState() => _MusicMarqueeState();
}

class _MusicMarqueeState extends State<MusicMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this);
  bool _running = false;

  /// 文本渲染宽度（TextPainter 测量）
  double _textWidth(String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final style = widget.style ?? const TextStyle(color: Colors.white);
    if (text.isEmpty) return const SizedBox.shrink();

    final textWidth = _textWidth(text, style);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 15,
        ),
        const SizedBox(width: 6),
        // 音乐名可用宽度 = 容器剩余空间（右侧预留唱片 + 间距）
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final available =
                  constraints.maxWidth - (widget.showDisc ? 38.0 : 0.0);
              final overflow = textWidth > available;
              _syncAnimation(overflow, textWidth);
              return ClipRect(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) {
                    if (!overflow) {
                      return Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style,
                      );
                    }
                    final step = textWidth + widget.gap;
                    return Transform.translate(
                      offset: Offset(-step * _ctrl.value, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(text, maxLines: 1, style: style),
                          SizedBox(width: widget.gap),
                          Text(text, maxLines: 1, style: style),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (widget.showDisc) ...[
          const SizedBox(width: 10),
          const _MusicDisc(size: 24),
        ],
      ],
    );
  }

  /// 按文本宽度启停滚动，避免每次 build 都重建动画
  void _syncAnimation(bool overflow, double textWidth) {
    if (overflow && !_running) {
      final step = textWidth + widget.gap;
      final ms = (step / widget.speed * 1000).round().clamp(1500, 120000);
      _ctrl.duration = Duration(milliseconds: ms);
      _ctrl.repeat();
      _running = true;
    } else if (!overflow && _running) {
      _ctrl.stop();
      _running = false;
    }
  }
}

/// 旋转唱片：圆盘 + 中心黑点，约 6s 转一圈
class _MusicDisc extends StatefulWidget {
  const _MusicDisc({required this.size});

  final double size;

  @override
  State<_MusicDisc> createState() => _MusicDiscState();
}

class _MusicDiscState extends State<_MusicDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _spin,
      builder: (context, _) => Transform.rotate(
        angle: _spin.value * 2 * math.pi,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: [
                Color(0xFF2A2A33),
                Color(0xFF555566),
                Color(0xFF2A2A33),
              ],
            ),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: const BoxDecoration(
                color: Color(0xFF8A8A99),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
