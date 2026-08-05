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
    this.darkOverlay = false,
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
  final bool darkOverlay;
  final List<({IconData icon, IconData activeIcon, String label})> items;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactive = darkOverlay
        ? Colors.white.withValues(alpha: 0.9)
        : isDark
        ? const Color(0xFFB3B3B3)
        : const Color(0xFF686868);
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
          selectedIconColor: darkOverlay ? Colors.white : colors.primary,
          selectedLabelColor: darkOverlay ? Colors.white : colors.primary,
          unselectedIconColor: inactive,
          unselectedLabelColor: inactive,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          indicatorColor: darkOverlay
              ? Colors.white.withValues(alpha: 0.16)
              : isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.38),
          settings: LiquidGlassSettings(
            thickness: darkOverlay ? 36 : 28,
            blur: darkOverlay ? 16 : 7,
            glassColor: darkOverlay
                ? const Color(0xFF15171A).withValues(alpha: 0.58)
                : isDark
                ? const Color(0xFF171717).withValues(alpha: 0.24)
                : Colors.white.withValues(alpha: 0.22),
            refractiveIndex: darkOverlay ? 1.24 : 1.32,
            saturation: darkOverlay ? 0.9 : 1.18,
            lightIntensity: darkOverlay ? 0.22 : 0.42,
            glowIntensity: darkOverlay ? 0.28 : 0.45,
            shadowElevation: darkOverlay ? 3 : 1,
          ),
          indicatorSettings: LiquidGlassSettings(
            thickness: darkOverlay ? 26 : 34,
            blur: darkOverlay ? 9 : 3,
            glassColor: darkOverlay
                ? Colors.white.withValues(alpha: 0.12)
                : colors.primary.withValues(alpha: 0.08),
            refractiveIndex: darkOverlay ? 1.3 : 1.42,
            saturation: darkOverlay ? 0.95 : 1.25,
            lightIntensity: darkOverlay ? 0.34 : 0.55,
            glowIntensity: darkOverlay ? 0.34 : 0.65,
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
