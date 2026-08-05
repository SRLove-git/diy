import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/app_colors.dart';

/// Apple Music 风格的液态玻璃主导航。
///
/// 使用库原生的浮动底板、可拖动透镜与形变反馈；短标签帮助用户快速
/// 识别入口，业务层仍只处理当前索引和点击回调。
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    this.chatUnread = 0,
    this.items = const [
      (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: '首页'),
      (
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: '发现',
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: '消息',
      ),
      (
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: '我的',
      ),
    ],
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final int chatUnread;
  final List<({IconData icon, IconData activeIcon, String label})> items;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactive = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF686868);
    // 压紧与 Home Indicator 的间距：只保留部分底部安全区，
    // 让悬浮胶囊更贴近屏幕底部（接近 iOS 26 悬浮栏的观感）。
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomPadding = math.max(3.0, bottomInset - 16);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: GlassTabBar.bottom(
          tabs: [
            for (final item in items)
              GlassTab(
                icon: _NavIcon(
                  icon: item.icon,
                  unread: item.label == '消息' ? chatUnread : 0,
                ),
                activeIcon: _NavIcon(
                  icon: item.activeIcon,
                  unread: item.label == '消息' ? chatUnread : 0,
                ),
                label: item.label,
                semanticLabel: item.label,
                glowColor: colors.primary,
              ),
          ],
          selectedIndex: currentIndex,
          onTabSelected: onSelect,
          quality: GlassQuality.premium,
          maskingQuality: MaskingQuality.high,
          horizontalPadding: 14,
          verticalPadding: 4,
          barHeight: 64,
          barBorderRadius: 30,
          iconSize: 23,
          iconLabelSpacing: 2,
          labelFontSize: 10,
          selectedIconColor: colors.primary,
          selectedLabelColor: colors.primary,
          unselectedIconColor: inactive,
          unselectedLabelColor: inactive,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          indicatorColor: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.38),
          settings: LiquidGlassSettings(
            thickness: 28,
            blur: 7,
            glassColor: isDark
                ? const Color(0xFF171717).withValues(alpha: 0.24)
                : Colors.white.withValues(alpha: 0.22),
            refractiveIndex: 1.32,
            saturation: 1.18,
            lightIntensity: 0.42,
            glowIntensity: 0.45,
            shadowElevation: 1,
          ),
          indicatorSettings: LiquidGlassSettings(
            thickness: 34,
            blur: 3,
            glassColor: colors.primary.withValues(alpha: 0.08),
            refractiveIndex: 1.42,
            saturation: 1.25,
            lightIntensity: 0.55,
            glowIntensity: 0.65,
            shadowElevation: 1,
          ),
          indicatorPinchStrength: 0.52,
          indicatorExpansion: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          magnification: 1.12,
          glowOpacity: 0.22,
          glowBlurRadius: 20,
          glowSpreadRadius: 3,
          interactionGlowColor: colors.primary,
          pressScale: 1.03,
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.unread});

  final IconData icon;
  final int unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (unread > 0)
          Positioned(
            top: -6,
            right: -10,
            child: Container(
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.of(context).primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
