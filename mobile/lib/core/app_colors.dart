import 'package:flutter/material.dart';

/// IDOL BEADS 全局语义配色。
///
/// 页面里不再直接写死颜色，统一通过 [AppColors.of] 取主题色，
/// 保证切到深色模式时整站自动换色。
///
/// 色板以「首页 / 社区页」为基准：粉红主色 [#FF3040]、辅助粉
/// [#FF718D]、纯白背景、[#161616] / [#737373] 两级文字。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.placeholder,
    required this.searchBg,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
  });

  /// 品牌主色（按钮 / 链接 / 选中态）
  final Color primary;

  /// 主色浅底（选中背景 / 标签底色）
  final Color primaryLight;

  /// 卡片 / 面板底色
  final Color surface;

  /// 主要文字
  final Color textPrimary;

  /// 次级文字
  final Color textSecondary;

  /// 三级文字（占位 / 未选中态）
  final Color textTertiary;

  /// 分割线 / 边框
  final Color divider;

  /// 占位 / 禁用底
  final Color placeholder;

  /// 搜索框 / 输入辅助底色
  final Color searchBg;

  /// 辅助粉（点赞 / 心动 / 品牌渐变）
  final Color accent;

  /// 成功（核销成功 / 可约 / 在线）
  final Color success;

  /// 警示（即将到期 / 人数预警 / 待处理）
  final Color warning;

  /// 危险操作（退出登录等）
  final Color danger;

  /// 浅色模式：纯白、中性灰与克制粉色强调。
  static const light = AppColors(
    primary: Color(0xFFFF3040),
    primaryLight: Color(0xFFFFE9EF),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF161616),
    textSecondary: Color(0xFF737373),
    textTertiary: Color(0xFF8E8E8E),
    divider: Color(0xFFDBDBDB),
    placeholder: Color(0xFFF5F5F5),
    searchBg: Color(0xFFF5F6FC),
    accent: Color(0xFFFF718D),
    success: Color(0xFF2E9E5B),
    warning: Color(0xFFE6A23C),
    danger: Color(0xFFD9453E),
  );

  /// 黑色模式
  static const dark = AppColors(
    primary: Color(0xFFFF5261),
    primaryLight: Color(0xFF3A2530),
    surface: Color(0xFF121212),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFA8A8A8),
    textTertiary: Color(0xFFB3B3B3),
    divider: Color(0xFF363636),
    placeholder: Color(0xFF262626),
    searchBg: Color(0xFF1E1E24),
    accent: Color(0xFFFF8199),
    success: Color(0xFF34C759),
    warning: Color(0xFFFFB300),
    danger: Color(0xFFFF8A8A),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    Color? placeholder,
    Color? searchBg,
    Color? accent,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
      placeholder: placeholder ?? this.placeholder,
      searchBg: searchBg ?? this.searchBg,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      searchBg: Color.lerp(searchBg, other.searchBg, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

/// 全局设计令牌（亮色模式常量）。
///
/// 页面内需要 const 的样式（如 `const TextStyle(color: ...)`）统一引用
/// 这里，避免散落魔法色值；与 [AppColors.light] 同源，保证主题一致。
/// 深色模式仍应优先使用 [AppColors.of] 取自适应色。
@immutable
class Palette {
  const Palette._();

  // ── 品牌色 ──
  /// 主色（按钮 / 选中态 / 品牌标识）
  static const primary = Color(0xFFFF3040);

  /// 主色浅底（选中背景 / 标签底色）
  static const primaryLight = Color(0xFFFFE9EF);

  /// 主色 8% 透明度（轻选中背景）
  static const primaryTint = Color(0x14FF3040);

  /// 主色按压态
  static const primaryDark = Color(0xFFD92B3A);

  /// 辅助粉（点赞 / 心动 / 品牌渐变）
  static const accent = Color(0xFFFF718D);

  /// 辅助粉深（渐变收尾 / 按压态）
  static const accentDark = Color(0xFFD94F70);

  /// 辅助粉浅底
  static const accentLight = Color(0xFFFFF0F3);

  /// 辅助粉 10% 透明度（轻点缀底）
  static const accentSoft = Color(0x1AFF718D);

  /// 辅助粉 20% 透明度（品牌阴影）
  static const accentTint = Color(0x33FF718D);

  // ── 语义状态色 ──
  /// 成功（核销成功 / 可约 / 在线）
  static const success = Color(0xFF2E9E5B);

  /// 成功浅底
  static const successLight = Color(0xFFEAF9F1);

  /// 警示（即将到期 / 待处理）
  static const warning = Color(0xFFE6A23C);

  /// 警示浅底
  static const warningLight = Color(0xFFFFF8ED);

  /// 危险（取消 / 封禁 / 不可约）
  static const danger = Color(0xFFD9453E);

  /// 危险浅底
  static const dangerLight = Color(0xFFFFF0F1);

  // ── 中性色 ──
  /// 页面背景
  static const background = Color(0xFFFFFFFF);

  /// 卡片 / 面板底色
  static const surface = Color(0xFFFFFFFF);

  /// 次级表面（占位 / 禁用底）
  static const surfaceAlt = Color(0xFFF5F5F5);

  /// 搜索框底色
  static const searchBg = Color(0xFFF5F6FC);

  /// 主要文字
  static const textPrimary = Color(0xFF161616);

  /// 次要文字
  static const textSecondary = Color(0xFF737373);

  /// 三级文字（未选中 / 辅助标签）
  static const textTertiary = Color(0xFF8E8E8E);

  /// 分割线 / 边框
  static const divider = Color(0xFFDBDBDB);

  /// 输入框描边
  static const inputBorder = Color(0xFFD0D0D0);

  // ── 首页低饱和图标底色 ──
  static const iconBgPink = Color(0xFFFFF0F3);
  static const iconBgPurple = Color(0xFFF3F0FF);
  static const iconBgYellow = Color(0xFFFFF8ED);
  static const iconBgTeal = Color(0xFFEDFAF8);
  static const iconBgOrange = Color(0xFFFFF3EE);
  static const iconBgGreen = Color(0xFFEAF9F1);

  // ── 辅助色板（首页渐变体系） ──
  static const purple = Color(0xFF7563EC);
  static const purpleLight = Color(0xFFB8A7FF);
  static const gold = Color(0xFFFFB347);

  /// 陶土橙（预约 / 待核销状态）
  static const orange = Color(0xFFE8633A);

  /// 珊瑚橙（品牌渐变）
  static const coral = Color(0xFFFF8A5B);

  // ── 品牌渐变 ──
  static const LinearGradient gradientPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9BB0), Color(0xFFFF6687)],
  );

  static const LinearGradient gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF718D), Color(0xFFD94F70)],
  );

  static const LinearGradient gradientPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA895FF), Color(0xFF7563EC)],
  );

  static const LinearGradient gradientSunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB8A7FF), Color(0xFFFF8199)],
  );
}
