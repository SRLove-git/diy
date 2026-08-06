import 'dart:ui';

/// 预设滤镜（ColorFilter.matrix 实现，不依赖第三方）。
///
/// 滤镜以 ID 存储到作品（如 'black'），信息流/发布页/编辑页
/// 通过 [filterOf] 取出矩阵统一渲染，保证所见即所得。
class PhotoFilter {
  const PhotoFilter(this.id, this.name, this.matrix);

  /// 滤镜唯一标识（'' 表示原图）
  final String id;

  /// 展示名称
  final String name;

  /// 颜色矩阵（ColorFilter.matrix）
  final List<double> matrix;

  /// 生成渲染用的 ColorFilter
  ColorFilter get colorFilter => ColorFilter.matrix(matrix);
}

/// 全部预设滤镜
const List<PhotoFilter> kPhotoFilters = [
  PhotoFilter('', '原图', _identity),
  PhotoFilter('black', '黑白', _grayscale),
  PhotoFilter('warm', '暖阳', _warm),
  PhotoFilter('cool', '冷调', _cool),
  PhotoFilter('vivid', '鲜亮', _vivid),
  PhotoFilter('film', '胶片', _faded),
  PhotoFilter('sunset', '暮色', _sunset),
  PhotoFilter('sepia', '复古', _sepia),
];

/// 按 ID 取滤镜（未知 ID 回退原图）
PhotoFilter filterOf(String id) {
  for (final f in kPhotoFilters) {
    if (f.id == id) return f;
  }
  return kPhotoFilters.first;
}

const List<double> _identity = [
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// 黑白
const List<double> _grayscale = [
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// 暖阳：增强红黄
const List<double> _warm = [
  1.12, 0, 0, 0, 12, //
  0, 1.02, 0, 0, 0, //
  0, 0, 0.88, 0, -6, //
  0, 0, 0, 1, 0, //
];

/// 冷调：增强蓝
const List<double> _cool = [
  0.9, 0, 0, 0, 0, //
  0, 1.0, 0, 0, 0, //
  0, 0, 1.18, 0, 10, //
  0, 0, 0, 1, 0, //
];

/// 鲜亮：提升饱和度
const List<double> _vivid = [
  1.2, -0.08, -0.08, 0, 0, //
  -0.08, 1.2, -0.08, 0, 0, //
  -0.08, -0.08, 1.2, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// 胶片：降低对比 + 轻微提亮
const List<double> _faded = [
  0.92, 0, 0, 0, 18, //
  0, 0.92, 0, 0, 18, //
  0, 0, 0.92, 0, 18, //
  0, 0, 0, 1, 0, //
];

/// 暮色：暖紫调
const List<double> _sunset = [
  1.12, 0, 0, 0, 14, //
  0, 0.96, 0, 0, -4, //
  0, 0, 1.04, 0, 16, //
  0, 0, 0, 1, 0, //
];

/// 复古：棕褐
const List<double> _sepia = [
  0.393, 0.769, 0.189, 0, 0, //
  0.349, 0.686, 0.168, 0, 0, //
  0.272, 0.534, 0.131, 0, 0, //
  0, 0, 0, 1, 0, //
];
