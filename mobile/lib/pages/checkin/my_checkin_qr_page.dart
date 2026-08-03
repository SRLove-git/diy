import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/api_client.dart';
import '../../core/app_colors.dart';
import '../../core/appointment_api.dart';
import 'service_timer_page.dart';

/// 到店二维码核销页：展示待核销（booked）预约的二维码，到店出示由店员扫码核销
class MyCheckInQrPage extends StatefulWidget {
  const MyCheckInQrPage({super.key});

  @override
  State<MyCheckInQrPage> createState() => _MyCheckInQrPageState();
}

class _MyCheckInQrPageState extends State<MyCheckInQrPage> {
  List<Appointment> _booked = [];
  bool _loading = true;
  String? _error;

  // 用户端自动跳转：轮询预约状态，店员核销成功后自动进入上钟页
  final Set<int> _seenBookedIds = {};
  Timer? _timer;
  bool _navigating = false;
  bool _qrDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _load();
    // 服务端无推送机制，采用轮询检测核销状态变化
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await ApiClient.instance.get('/appointments');
      final list = resp.data as List;
      if (!mounted) return;
      final booked = list
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .where((a) => a.status == 'booked')
          .toList();
      setState(() {
        _booked = booked;
        _loading = false;
      });
      // 记录本次会话中展示过的待核销预约，用于轮询检测核销状态变化
      for (final a in booked) {
        _seenBookedIds.add(a.id);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppointmentApi.messageOf(e);
      });
    }
  }

  /// 轮询预约状态：原待核销预约被核销/上钟后，用户端自动跳转到上钟页
  Future<void> _checkStatus() async {
    if (_navigating || !mounted) return;
    try {
      final resp = await ApiClient.instance.get('/appointments');
      if (!mounted || _navigating) return;
      final list = resp.data as List;
      for (final e in list) {
        final appt = Appointment.fromJson(e as Map<String, dynamic>);
        if (_seenBookedIds.contains(appt.id) &&
            (appt.status == 'checked_in' || appt.status == 'in_service')) {
          _navigating = true;
          _timer?.cancel();
          _goToService(appt.id);
          return;
        }
      }
    } on DioException {
      // 轮询失败忽略，等待下一次
    }
  }

  void _goToService(int appointmentId) {
    // 若二维码弹窗处于打开状态，先关闭再跳转
    if (_qrDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _qrDialogOpen = false;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ServiceTimerPage(appointmentId: appointmentId),
      ),
    );
  }

  void _showQrDetail(Appointment appt) {
    setState(() => _qrDialogOpen = true);
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appt.storeName,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${appt.date} ${appt.startTime}-${appt.endTime} · 桌位 ${appt.tableName}',
                style: TextStyle(
                  color: AppColors.of(ctx).textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _QrCode(code: appt.code, size: 240),
              const SizedBox(height: 16),
              Text(
                '到店出示此二维码，由店员扫码核销',
                style: TextStyle(
                  color: AppColors.of(ctx).textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.of(ctx).textPrimary,
                    foregroundColor: AppColors.of(ctx).surface,
                  ),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _qrDialogOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('到店核销')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.textPrimary),
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _booked.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_2,
                            size: 64,
                            color: Color(0xFFD0D0D0),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '暂无待核销的预约',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _booked.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final appt = _booked[i];
                          return InkWell(
                            onTap: () => _showQrDetail(appt),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _QrCode(code: appt.code, size: 96),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appt.storeName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        _InfoLine(
                                          icon: Icons.calendar_today,
                                          text:
                                              '${appt.date} ${appt.startTime}-${appt.endTime}',
                                        ),
                                        const SizedBox(height: 4),
                                        _InfoLine(
                                          icon: Icons.table_bar,
                                          text:
                                              '桌位 ${appt.tableName} · ${appt.peopleCount} 人',
                                        ),
                                        const SizedBox(height: 4),
                                        _InfoLine(
                                          icon: Icons.confirmation_number,
                                          text: '预约码 ${appt.code}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: colors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _QrCode extends StatelessWidget {
  const _QrCode({required this.code, required this.size});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.divider),
      ),
      child: QrImageView(
        data: code,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
