import 'package:flutter/material.dart';

/// 全局语义配色：对齐《个人页面设计初稿》白色模式 / 黑色模式
///
/// 页面里不再直接写死颜色，统一通过 [AppColors.of] 取主题色，
/// 保证切到深色模式时整站自动换色。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.placeholder,
    required this.danger,
  });

  /// 品牌主色（按钮 / 链接 / 选中态）
  final Color primary;

  /// 卡片 / 面板底色
  final Color surface;

  /// 主要文字
  final Color textPrimary;

  /// 次级文字
  final Color textSecondary;

  /// 分割线 / 边框
  final Color divider;

  /// 占位 / 禁用底
  final Color placeholder;

  /// 危险操作（退出登录等）
  final Color danger;

  /// 白色模式（默认）—— 简洁年轻风
  static const light = AppColors(
    primary: Color(0xFFFF6B6B),
    surface: Color(0xFFF8F9FC),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFFA0A0B0),
    divider: Color(0xFFE8E8EC),
    placeholder: Color(0xFFF0F0F4),
    danger: Color(0xFFD9453E),
  );

  /// 黑色模式
  static const dark = AppColors(
    primary: Color(0xFFFF6B6B),
    surface: Color(0xFF12121A),
    textPrimary: Color(0xFFF0F0F5),
    textSecondary: Color(0xFF888896),
    divider: Color(0xFF2A2A35),
    placeholder: Color(0xFF1E1E28),
    danger: Color(0xFFFF6B6B),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({
    Color? primary,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? placeholder,
    Color? danger,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      placeholder: placeholder ?? this.placeholder,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
