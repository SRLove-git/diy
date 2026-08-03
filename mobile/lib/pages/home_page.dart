import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import 'booking/booking_flow_page.dart';
import 'checkin/my_checkin_qr_page.dart';
import 'checkin/scan_checkin_page.dart';

/// 首页：品牌名 + 顶部居中分段控件（拼豆 / 敬请期待）
/// 拼豆：三入口（预约/到店/会员套餐）；敬请期待：浅色占位卡片
/// 对齐《第一阶段UI设计指导》§四、§五
/// 管理员登录时「到店」变为「扫码核销」
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // 0=拼豆，1=敬请期待

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) {
            final isAdmin = AuthService.instance.isAdmin;
            return ListView(
              padding: const EdgeInsets.all(16),
            children: [
              // 顶部居中分段控件：拼豆 / 敬请期待
              Center(child: _buildSegment(colors)),
              const SizedBox(height: 16),
              if (_tabIndex == 0) ...[
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 18, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text('杭州', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _EntryCard(
                        icon: Icons.event_available,
                        label: '预约',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BookingFlowPage(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EntryCard(
                        icon: isAdmin
                            ? Icons.qr_code_scanner
                            : Icons.qr_code_2,
                        label: isAdmin ? '扫码核销' : '到店',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => isAdmin
                                ? const ScanCheckInPage()
                                : const MyCheckInQrPage(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _EntryCard(
                        icon: Icons.card_membership,
                        label: '会员套餐',
                        onTap: null,
                      ),
                    ),
                  ],
                ),
              ] else
                // 敬请期待：浅色占位卡片，不给按钮、不引导，保持简洁
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '敬请期待：更多手作项目即将上线',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
            ],
          );
        },
        ),
      ),
    );
  }

  /// 拼豆 / 敬请期待 分段控件，样式对齐社区页「最新/热门」
  Widget _buildSegment(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.placeholder,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HomeTab(
            label: '拼豆',
            active: _tabIndex == 0,
            onTap: () => setState(() => _tabIndex = 0),
          ),
          _HomeTab(
            label: '敬请期待',
            active: _tabIndex == 1,
            onTap: () => setState(() => _tabIndex = 1),
          ),
        ],
      ),
    );
  }
}

/// 分段控件子项
class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: active
            ? BoxDecoration(
                color: colors.textPrimary,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? colors.surface : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

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
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 28, color: colors.textPrimary),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
