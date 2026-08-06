import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

/// 社区页专属配色
///
/// 页面底色 / 卡片 / 边框跟随系统深色模式切换，
/// 文字色沿用全局 [AppColors]，避免引入重复语义。
class CommunityPalette {
  const CommunityPalette({required this.isDark});

  factory CommunityPalette.of(BuildContext context) =>
      CommunityPalette(isDark: Theme.of(context).brightness == Brightness.dark);

  final bool isDark;

  /// 页面背景
  Color get pageBackground => isDark ? const Color(0xFF000000) : Colors.white;

  /// 信息流卡片底色
  Color get card => isDark ? const Color(0xFF121212) : Colors.white;

  /// 卡片描边（深色模式下阴影不可见，用描边替代层级）
  Color get cardBorder =>
      isDark ? const Color(0xFF363636) : const Color(0xFFDBDBDB);

  /// 卡片悬浮阴影
  List<BoxShadow> get cardShadow => [
    BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
  ];

  /// 故事未读渐变环（Instagram 官方五色渐变）
  static const List<Color> storyGradient = [
    Color(0xFFFEDA75),
    Color(0xFFFA7E1E),
    Color(0xFFD62976),
    Color(0xFF962FBF),
    Color(0xFF4F5BD5),
  ];

  /// 故事已读环
  Color get storySeen =>
      isDark ? const Color(0xFF3A3A44) : const Color(0xFFDDDDDD);

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

  /// 点赞/收藏等交互高亮（IG 红）
  static const Color love = Palette.accent;
}
