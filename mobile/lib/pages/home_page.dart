import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/app_colors.dart';
import '../core/appointment_api.dart';
import '../core/auth_service.dart';
import 'booking/booking_flow_page.dart';
import 'checkin/my_checkin_qr_page.dart';
import 'checkin/scan_checkin_page.dart';
import 'checkin/service_timer_page.dart';

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

  // 进行中的服务（可多个并行）：退出上钟页后回到主页仍可看到实时时长
  List<Appointment> _activeAppts = [];
  Timer? _tickTimer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadActive();
    // 每秒刷新已上钟时长
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted &&
          _activeAppts.any(
            (a) => a.status == 'in_service' && a.serviceStartTime != null,
          )) {
        setState(() {});
      }
    });
    // 轮询预约状态：核销/上钟/下钟后主页状态自动更新
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _loadActive());
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  /// 拉取当前用户进行中的服务（已核销待上钟 / 服务中），支持多个并行
  Future<void> _loadActive() async {
    try {
      final resp = await ApiClient.instance.get('/appointments');
      if (!mounted) return;
      final active = (resp.data as List)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .where((a) => a.status == 'in_service' || a.status == 'checked_in')
          .toList();
      setState(() => _activeAppts = active);
    } on DioException {
      // 拉取失败忽略，保持上一次状态
    }
  }

  Future<void> _openActiveService(Appointment appt) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceTimerPage(appointmentId: appt.id),
      ),
    );
    _loadActive();
  }

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
                // 进行中的服务（可多个并行）：已核销待上钟 / 服务中实时时长
                if (_activeAppts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    '进行中的服务',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final appt in _activeAppts) ...[
                    _ActiveServiceCard(
                      appt: appt,
                      inService: appt.status == 'in_service',
                      elapsed: appt.serviceStartTime != null
                          ? DateTime.now()
                              .difference(DateTime.parse(appt.serviceStartTime!))
                          : Duration.zero,
                      onTap: () => _openActiveService(appt),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
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

/// 首页进行中的服务卡片：已核销（待上钟）或服务中（实时时长），点击回到上钟页
class _ActiveServiceCard extends StatelessWidget {
  const _ActiveServiceCard({
    required this.appt,
    required this.inService,
    required this.elapsed,
    required this.onTap,
  });

  final Appointment appt;
  final bool inService;
  final Duration elapsed;
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: inService
                      ? const Color(0xFF2E9E5B)
                      : colors.placeholder,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  inService ? Icons.timer_outlined : Icons.login,
                  color: inService ? Colors.white : colors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.storeName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${appt.date} ${appt.startTime}-${appt.endTime} · 桌位 ${appt.tableName}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (inService) ...[
                    Text(
                      _formatDuration(elapsed),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E9E5B),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '服务中',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '已核销',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '待上钟',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// HH:mm:ss 时长格式化（与上钟页一致）
String _formatDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
