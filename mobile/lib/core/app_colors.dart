import 'package:flutter/material.dart';

/// 拾染爱恋全局语义配色。
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

  /// 浅色模式：与首页统一的粉白手作风格。
  static const light = AppColors(
    primary: Color(0xFFFF718D),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF333033),
    textSecondary: Color(0xFF8F898C),
    divider: Color(0xFFF0E5E8),
    placeholder: Color(0xFFFFF0F3),
    danger: Color(0xFFD9453E),
  );

  /// 黑色模式
  static const dark = AppColors(
    primary: Color(0xFFFF8FA6),
    surface: Color(0xFF1C191C),
    textPrimary: Color(0xFFF8F3F5),
    textSecondary: Color(0xFFAAA2A6),
    divider: Color(0xFF373037),
    placeholder: Color(0xFF2A2429),
    danger: Color(0xFFFF8A8A),
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
