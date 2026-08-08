import 'package:flutter/material.dart';

/// 设计规范（对齐 UI 原型：白底、深色主文字、浅色按钮的黑白极简体系）
abstract class LiveColors {
  static const bg = Color(0xFFFFFFFF);
  static const card = Color(0xFFF7F7F8);
  static const cardBorder = Color(0xFFE8E8EC);
  static const divider = Color(0xFFF0F0F2);
  /// 卡片描边 / 分隔线（对齐设计稿 --line: #EFEFEF）
  static const line = Color(0xFFEFEFEF);
  static const textPrimary = Color(0xFF141414);
  static const textSecondary = Color(0xFF8E8E93);
  static const textTertiary = Color(0xFFC7C7CC);
  /// 主操作/强调色：深色（对齐设计稿黑色图标、黑色 Tab 高亮）
  static const brand = Color(0xFF141414);
  /// 浅色辅助底
  static const brandLight = Color(0xFFF3F3F5);
  /// 活动标签蓝（对齐活动卡片标签色）
  static const blue = Color(0xFF4D8CE3);
  static const danger = Color(0xFFFF3B30);
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFFD54F);
  static const inputBg = Color(0xFFF7F7F8);
  static const black = Color(0xFF141414);
}

abstract class LiveTheme {
  static ThemeData get data => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: LiveColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: LiveColors.brand,
          primary: LiveColors.brand,
          surface: LiveColors.bg,
        ),
        fontFamily: 'PingFang SC',
        appBarTheme: const AppBarTheme(
          backgroundColor: LiveColors.bg,
          foregroundColor: LiveColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: LiveColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: LiveColors.inputBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: LiveColors.textTertiary, fontSize: 14),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xE6141414),
        ),
      );
}

String fmtTime(DateTime? t, {bool withYear = false}) {
  if (t == null) return '';
  final now = DateTime.now();
  final d = t.toLocal();
  final hm = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  if (d.year == now.year && d.month == now.month && d.day == now.day) return hm;
  final md = '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  if (d.year == now.year) return '$md $hm';
  return withYear ? '${d.year}-$md $hm' : '$md $hm';
}

String fmtCount(int n) {
  if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}w';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

String fmtDuration(int seconds) {
  if (seconds <= 0) return '';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
