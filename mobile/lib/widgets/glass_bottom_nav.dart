import 'dart:ui';

import 'package:flutter/material.dart';

/// 玻璃拟态底部导航：半透明模糊背景 + 圆角 30 + 阴影
///
/// 四个入口：首页 / 发现 / 消息 / 个人主页，仅图标。
class GlassBottomNav extends StatefulWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    this.chatUnread = 0,
  });

  /// 语义索引：0 首页 / 1 发现 / 2 消息 / 3 个人主页
  final int currentIndex;

  /// 选择 Tab，回调语义索引
  final ValueChanged<int> onSelect;

  /// 消息未读数（0 不显示徽章）
  final int chatUnread;

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav> {
  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    (icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded),
    (icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? const Color(0xFF18181F).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.78);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : Colors.black.withValues(alpha: 0.05);
    final shadow = BoxShadow(
      color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 10),
    );

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(33),
          boxShadow: [shadow],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(33),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(33),
                border: Border.all(color: border, width: 0.8),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: _NavSlot(
                        tab: _tabs[i],
                        active: widget.currentIndex == i,
                        unread: i == 2 ? widget.chatUnread : 0,
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

/// 普通 Tab：仅图标，选中态高亮胶囊
class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.tab,
    required this.active,
    required this.onTap,
    required this.unread,
  });

  final ({IconData icon, IconData activeIcon}) tab;
  final bool active;
  final VoidCallback onTap;
  final int unread;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF465FFF);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: active ? primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                active ? tab.activeIcon : tab.icon,
                size: 22,
                color: active ? primary : inactive,
              ),
              if (unread > 0)
                Positioned(
                  top: -6,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
        ),
      ),
    );
  }
}
