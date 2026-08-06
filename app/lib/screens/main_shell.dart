import 'package:flutter/material.dart';

import '../core/chat_service.dart';
import 'community/community_page.dart';
import 'home/home_page.dart';
import 'messages/messages_page.dart';
import 'profile/profile_page.dart';
import 'reels/reels_page.dart';

/// 主框架：底部五 Tab（首页 / Reels / 社区 / 消息 / 我的）
///
/// 与新版 UI 的 Tab 结构保持一致，IndexedStack 保留各页状态；
/// 消息 Tab 展示 [ChatService.totalUnread] 角标。
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // 登录后连接聊天实时通道并预拉会话/群聊缓存
    ChatService.instance.ensureConnected();
    ChatService.instance.refreshConversations();
    ChatService.instance.refreshGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomePage(),
          ReelsPage(),
          CommunityPage(),
          MessagesPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: ChatService.instance,
        builder: (context, _) {
          final unread = ChatService.instance.totalUnread;
          return _GlassNav(
            index: _index,
            unread: unread,
            onChanged: (i) => setState(() => _index = i),
          );
        },
      ),
    );
  }
}

class _GlassNav extends StatelessWidget {
  const _GlassNav({
    required this.index,
    required this.unread,
    required this.onChanged,
  });

  final int index;
  final int unread;
  final ValueChanged<int> onChanged;

  static const _tabs = [
    (icon: Icons.home_outlined, active: Icons.home, label: '首页'),
    (icon: Icons.smart_display_outlined, active: Icons.smart_display, label: 'Reels'),
    (icon: Icons.explore_outlined, active: Icons.explore, label: '社区'),
    (icon: Icons.chat_bubble_outline, active: Icons.chat_bubble, label: '消息'),
    (icon: Icons.person_outline, active: Icons.person, label: '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: Color(0xFFEDEDED))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    selected: index == i,
                    icon: index == i ? _tabs[i].active : _tabs[i].icon,
                    label: _tabs[i].label,
                    badge: i == 3 && unread > 0 ? unread : 0,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.badge,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 24,
                color: selected
                    ? const Color(0xFFED4956)
                    : const Color(0xFFA8A8A8),
              ),
              if (badge > 0)
                Positioned(
                  right: -12,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFED4956),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: selected
                  ? const Color(0xFF111111)
                  : const Color(0xFFA8A8A8),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
