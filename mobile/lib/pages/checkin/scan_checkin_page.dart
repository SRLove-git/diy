import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/api_client.dart';
import '../../core/app_colors.dart';
import '../../core/appointment_api.dart';
import 'checkin_page.dart';
import 'service_timer_page.dart';

/// 扫码核销页（管理员/店员）：扫描顾客二维码 → 确认核销 → 上钟/下钟
class ScanCheckInPage extends StatefulWidget {
  const ScanCheckInPage({super.key});

  @override
  State<ScanCheckInPage> createState() => _ScanCheckInPageState();
}

class _ScanCheckInPageState extends State<ScanCheckInPage> {
  final _controller = MobileScannerController();
  bool _processing = false;
  bool _torchOn = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      // 仅接受 6 位数字预约码（二维码内容即预约码）
      if (raw != null && RegExp(r'^\d{6}$').hasMatch(raw)) {
        _previewAndConfirm(raw);
        return;
      }
    }
  }

  Future<void> _previewAndConfirm(String code) async {
    setState(() {
      _processing = true;
      _error = null;
    });
    try {
      final resp = await ApiClient.instance.get('/appointments/code/$code');
      if (!mounted) return;
      setState(() => _processing = false);
      _showConfirm(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = AppointmentApi.messageOf(e);
      });
      // 短暂提示后自动消失，避免阻塞继续扫码
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && _error != null) setState(() => _error = null);
    }
  }

  Future<void> _showConfirm(Map<String, dynamic> appt) async {
    final status = appt['status'] as String;
    final booked = status == 'booked';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(booked ? '确认核销' : '无法核销'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appt['storeName'] as String? ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${appt['date']} ${appt['startTime']}-${appt['endTime']}\n'
              '桌位 ${appt['tableName']} · ${appt['peopleCount']} 人\n'
              '预约码 ${appt['code']}',
              style: TextStyle(
                color: AppColors.of(ctx).textPrimary,
                height: 1.6,
              ),
            ),
            if (!booked) ...[
              const SizedBox(height: 8),
              Text(
                _statusLabel(status),
                style: TextStyle(color: AppColors.of(ctx).danger),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(ctx).textPrimary,
            ),
            child: Text(booked ? '取消' : '关闭'),
          ),
          if (booked)
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _doCheckIn(appt['code'] as String);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.of(ctx).textPrimary,
                foregroundColor: AppColors.of(ctx).surface,
              ),
              child: const Text('确认核销'),
            ),
        ],
      ),
    );
  }

  Future<void> _doCheckIn(String code) async {
    setState(() => _processing = true);
    try {
      final resp = await ApiClient.instance.post(
        '/appointments/checkin',
        data: {'code': code},
      );
      if (!mounted) return;
      setState(() => _processing = false);
      final appt = resp.data as Map<String, dynamic>;
      await _showSuccess(appt['id'] as int);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = AppointmentApi.messageOf(e);
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && _error != null) setState(() => _error = null);
    }
  }

  Future<void> _showSuccess(int appointmentId) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          size: 48,
          color: Color(0xFF2E9E5B),
        ),
        title: const Text('核销成功'),
        content: const Text('已核销，可开始上钟。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ServiceTimerPage(appointmentId: appointmentId),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(ctx).textPrimary,
            ),
            child: const Text('开始上钟'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(ctx).textPrimary,
              foregroundColor: AppColors.of(ctx).surface,
            ),
            child: const Text('继续扫码'),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'checked_in':
        return '该预约已核销，不可重复核销';
      case 'in_service':
        return '该预约服务中';
      case 'completed':
        return '该预约已完成';
      case 'cancelled':
        return '该预约已取消';
      default:
        return '该预约当前无法核销';
    }
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (!mounted) return;
    setState(
      () => _torchOn = _controller.value.torchState == TorchState.on,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码核销'),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: '手电筒',
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '无法访问相机，请检查相机权限后重试',
                        style: TextStyle(
                          color: AppColors.of(context).textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // 扫描框
                IgnorePointer(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                if (_processing)
                  Container(
                    color: Colors.black.withAlpha(90),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Container(
            color: colors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '将顾客预约二维码对准扫描框',
                  style: TextStyle(color: colors.textPrimary),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(color: colors.danger, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckInPage()),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                  ),
                  icon: const Icon(Icons.keyboard),
                  label: const Text('手动输入预约码'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
