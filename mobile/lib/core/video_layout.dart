import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 视频画幅预设。数值统一使用 width / height。
class VideoAspectPreset {
  const VideoAspectPreset(this.label, this.ratio, this.description);

  final String label;
  final double ratio;
  final String description;

  static const portrait = VideoAspectPreset('9:16', 9 / 16, '竖屏全屏');
  static const portraitClassic = VideoAspectPreset('3:4', 3 / 4, '竖屏经典');
  static const square = VideoAspectPreset('1:1', 1, '方形');
  static const landscape = VideoAspectPreset('16:9', 16 / 9, '横屏');

  static const values = [portrait, portraitClassic, square, landscape];
}

double normalizeVideoAspectRatio(double? value, {double fallback = 9 / 16}) {
  if (value == null || !value.isFinite || value <= 0) return fallback;
  return value.clamp(0.35, 3.0).toDouble();
}

bool isLandscapeVideo(double? aspectRatio) =>
    normalizeVideoAspectRatio(aspectRatio) > 1.05;

/// 相机插件返回的是传感器横向宽高比；竖向预览时需要取倒数。
///
/// 方向以当前预览区域为准，而不是相机插件异步上报的设备方向。系统旋转时，
/// 预览区域尺寸会先更新，使用插件方向会短暂把比例翻转两次，造成画面拉伸。
double orientedCameraAspectRatio(
  double sensorAspectRatio, {
  required Size previewBounds,
}) {
  final sensor = normalizeVideoAspectRatio(sensorAspectRatio, fallback: 1);
  final isLandscape = previewBounds.width > previewBounds.height;
  return isLandscape ? sensor : 1 / sensor;
}

String videoAspectLabel(double? aspectRatio) {
  final ratio = normalizeVideoAspectRatio(aspectRatio);
  if ((ratio - 9 / 16).abs() < 0.08) return '9:16';
  if ((ratio - 3 / 4).abs() < 0.08) return '3:4';
  if ((ratio - 1).abs() < 0.08) return '1:1';
  if ((ratio - 16 / 9).abs() < 0.16) return '16:9';
  return '${ratio.toStringAsFixed(2)}:1';
}

/// 在给定区域内按目标画幅计算最大可用尺寸。
Size containAspectSize(Size bounds, double? aspectRatio) {
  final ratio = normalizeVideoAspectRatio(aspectRatio);
  var width = bounds.width;
  var height = width / ratio;
  if (height > bounds.height) {
    height = bounds.height;
    width = height * ratio;
  }
  return Size(math.max(0, width), math.max(0, height));
}

/// 将原始视频按 cover 方式放进指定画幅，避免 AspectRatio 在窄容器中溢出。
Widget coverVideoFrame({
  required Widget child,
  required double sourceAspectRatio,
}) {
  final source = normalizeVideoAspectRatio(sourceAspectRatio, fallback: 1);
  return ClipRect(
    child: FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(width: 100 * source, height: 100, child: child),
    ),
  );
}
