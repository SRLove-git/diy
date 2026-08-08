
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class PixDashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  const PixDashedBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dashLength = 5.0,
    this.gapLength = 0,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CustomRoundedDashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
        borderRadius: borderRadius,
      ),
      child: Padding(padding: EdgeInsets.all(strokeWidth / 2), child: child),
    );
  }
}

class _CustomRoundedDashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  _CustomRoundedDashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final rrect = borderRadius.toRRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      _drawDashedPath(canvas, metric, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, PathMetric metric, Paint paint) {
    var currentDistance = 0.0;
    var draw = true;

    while (currentDistance < metric.length) {
      final length = draw ? dashLength : gapLength;
      final nextDistance = min(currentDistance + length, metric.length);

      if (draw) {
        final path = metric.extractPath(currentDistance, nextDistance);
        canvas.drawPath(path, paint);
      }

      currentDistance = nextDistance;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! _CustomRoundedDashedBorderPainter ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}


