import 'package:flutter/material.dart';

import '../core/auth_service.dart';
import 'booking/booking_flow_page.dart';
import 'checkin/my_checkin_qr_page.dart';
import 'checkin/scan_checkin_page.dart';

/// 首页：品牌名 + 拼豆三入口（预约/到店/会员套餐）+ 敬请期待
/// 对齐《第一阶段UI设计指导》§五
/// 管理员登录时「到店」变为「扫码核销」
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DIY 手作工坊')),
      body: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) {
          final isAdmin = AuthService.instance.isAdmin;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18, color: Color(0xFF8A8A8A)),
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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '敬请期待：更多手作项目即将上线',
                  style: TextStyle(color: Color(0xFF8A8A8A)),
                ),
              ),
            ],
          );
        },
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 28, color: const Color(0xFFE8633A)),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
