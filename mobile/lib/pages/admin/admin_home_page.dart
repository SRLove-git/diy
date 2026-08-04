import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../checkin/scan_checkin_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_members_page.dart';
import 'admin_notifications_page.dart';
import 'admin_orders_page.dart';
import 'admin_posts_page.dart';
import 'admin_reports_page.dart';
import 'admin_stores_page.dart';
import 'admin_users_page.dart';

/// 管理后台首页：管理端功能入口宫格（数据看板 / 门店 / 订单 / 作品 / 用户 / 举报 / 通知）
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final nickname = AuthService.instance.user?.nickname.isNotEmpty == true
        ? AuthService.instance.user!.nickname
        : '管理员';

    const entries = [
      (
        icon: Icons.dashboard_outlined,
        label: '数据看板',
        page: AdminDashboardPage(),
      ),
      (icon: Icons.store_outlined, label: '门店管理', page: AdminStoresPage()),
      (
        icon: Icons.receipt_long_outlined,
        label: '订单管理',
        page: AdminOrdersPage(),
      ),
      (icon: Icons.article_outlined, label: '作品审核', page: AdminPostsPage()),
      (icon: Icons.people_outline, label: '用户管理', page: AdminUsersPage()),
      (icon: Icons.report_outlined, label: '举报处理', page: AdminReportsPage()),
      (
        icon: Icons.notifications_outlined,
        label: '通知管理',
        page: AdminNotificationsPage(),
      ),
      (
        icon: Icons.card_membership_outlined,
        label: '会员运营',
        page: AdminMembersPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('管理后台')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 顶部欢迎卡片
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF718D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '你好，$nickname',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '管理平台全部功能已集成到手机端',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '功能入口',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            // 功能宫格
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length + 1, // +1 为扫码核销快捷入口
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (context, i) {
                if (i == entries.length) {
                  return _EntryItem(
                    icon: Icons.qr_code_scanner,
                    label: '扫码核销',
                    onTap: () => _push(context, const ScanCheckInPage()),
                  );
                }
                final e = entries[i];
                return _EntryItem(
                  icon: e.icon,
                  label: e.label,
                  onTap: () => _push(context, e.page),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 入口项：图标 + 标签 + 箭头
class _EntryItem extends StatelessWidget {
  const _EntryItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 26, color: colors.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
