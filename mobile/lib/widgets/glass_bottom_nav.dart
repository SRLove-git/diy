import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// 玻璃拟态底部导航：更接近社交 App 的 liquid glass 底栏。
class GlassBottomNav extends StatefulWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    this.chatUnread = 0,
    this.items = const [
      (
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: '首页',
      ),
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

  /// 语义索引：0 首页 / 1 发现 / 2 消息 / 3 个人主页
  final int currentIndex;

  /// 选择 Tab，回调语义索引
  final ValueChanged<int> onSelect;

  /// 消息未读数（0 不显示徽章）
  final int chatUnread;

  /// 导航项
  final List<({IconData icon, IconData activeIcon, String label})> items;

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? const Color(0xFF18181F).withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.70);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.62);
    final shadow = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.42)
            : const Color(0x33231A20),
        blurRadius: 28,
        offset: const Offset(0, 14),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.36),
        blurRadius: 10,
        offset: const Offset(0, -1),
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: shadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: border, width: 0.8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.08 : 0.44),
                    Colors.white.withValues(alpha: isDark ? 0.03 : 0.14),
                  ],
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    Expanded(
                      child: _NavSlot(
                        tab: widget.items[i],
                        active: widget.currentIndex == i,
                        unread: widget.items[i].label == '消息'
                            ? widget.chatUnread
                            : 0,
                        onTap: () => widget.onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.tab,
    required this.active,
    required this.onTap,
    required this.unread,
  });

  final ({IconData icon, IconData activeIcon, String label}) tab;
  final bool active;
  final VoidCallback onTap;
  final int unread;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final primary = colors.primary;
    final inactive = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF8E8E9A)
        : const Color(0xFF9A9AA4);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    active ? tab.activeIcon : tab.icon,
                    size: 23,
                    color: active ? primary : inactive,
                  ),
                  if (unread > 0)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(minWidth: 14),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? primary : inactive,
                  letterSpacing: 0.1,
                ),
                child: Text(tab.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
