import 'package:flutter/material.dart';

/// 社区页专属配色
///
/// 页面底色 / 卡片 / 边框跟随系统深色模式切换，
/// 文字色沿用全局 [AppColors]，避免引入重复语义。
class CommunityPalette {
  const CommunityPalette({required this.isDark});

  factory CommunityPalette.of(BuildContext context) => CommunityPalette(
        isDark: Theme.of(context).brightness == Brightness.dark,
      );

  final bool isDark;

  /// 页面背景
  Color get pageBackground => isDark ? const Color(0xFF0B0B0F) : const Color(0xFFF8F9FC);

  /// 信息流卡片底色
  Color get card => isDark ? const Color(0xFF18181F) : Colors.white;

  /// 卡片描边（深色模式下阴影不可见，用描边替代层级）
  Color get cardBorder => isDark ? const Color(0xFF26262E) : const Color(0x14000000);

  /// 卡片悬浮阴影
  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: isDark ? const Color(0x66000000) : const Color(0x14000000),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// 故事未读渐变环（暖橙 → 粉 → 紫，原创配色）
  static const List<Color> storyGradient = [
    Color(0xFFFF6A88),
    Color(0xFFFF9A5A),
    Color(0xFF7A5CFF),
  ];

  /// 故事已读环
  Color get storySeen => isDark ? const Color(0xFF3A3A44) : const Color(0xFFDDDDDD);

  /// 头像兜底渐变组（按用户 id 取色，保证同一用户颜色稳定）
  static const List<List<Color>> avatarGradients = [
    [Color(0xFFFF6A88), Color(0xFFFF9A5A)],
    [Color(0xFF7A5CFF), Color(0xFF4E9BFF)],
    [Color(0xFFFFB347), Color(0xFFFF6A5A)],
    [Color(0xFF43D3A4), Color(0xFF34B3F1)],
    [Color(0xFFF5576C), Color(0xFFF093FB)],
    [Color(0xFF5B8DFF), Color(0xFF7C4DFF)],
  ];

  static List<Color> avatarGradientFor(int id) =>
      avatarGradients[id % avatarGradients.length];

  /// 点赞/收藏等交互高亮
  static const Color love = Color(0xFFFF4D6A);
}
