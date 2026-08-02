import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/appointment_api.dart';
import 'experience_summary_page.dart';

/// 上钟/计时/下钟页：核销后进入上钟，显示实时时长，主按钮「下钟」
class ServiceTimerPage extends StatefulWidget {
  const ServiceTimerPage({super.key, required this.appointmentId});

  final int appointmentId;

  @override
  State<ServiceTimerPage> createState() => _ServiceTimerPageState();
}

class _ServiceTimerPageState extends State<ServiceTimerPage> {
  bool _inService = false; // false = 等待上钟, true = 服务中
  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _loading = true;
  String? _error;
  bool _submitting = false;

  // 预约信息
  String _storeName = '';
  String _tableName = '';

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    try {
      final resp =
          await ApiClient.instance.get('/appointments/${widget.appointmentId}');
      final appt = resp.data as Map<String, dynamic>;
      if (!mounted) return;

      final status = appt['status'] as String;
      final startStr = appt['serviceStartTime'] as String?;

      setState(() {
        _storeName = appt['storeName'] as String? ?? '';
        _tableName = appt['tableName'] as String? ?? '';
        _loading = false;

        if (status == 'in_service' && startStr != null) {
          _inService = true;
          _startTime = DateTime.parse(startStr);
          _elapsed = DateTime.now().difference(_startTime!);
          _startTicking();
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppointmentApi.messageOf(e);
      });
    }
  }

  Future<void> _clockIn() async {
    setState(() => _submitting = true);
    try {
      final resp = await ApiClient.instance
          .post('/appointments/${widget.appointmentId}/clockin');
      final appt = resp.data as Map<String, dynamic>;
      if (!mounted) return;

      final startStr = appt['serviceStartTime'] as String;
      setState(() {
        _inService = true;
        _startTime = DateTime.parse(startStr);
        _elapsed = Duration.zero;
        _submitting = false;
      });
      _startTicking();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = AppointmentApi.messageOf(e);
      });
    }
  }

  Future<void> _clockOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认下钟'),
        content: Text('已体验 ${_formatDuration(_elapsed)}，确认结束体验吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认下钟'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    _timer?.cancel();
    setState(() => _submitting = true);
    try {
      final resp = await ApiClient.instance
          .post('/appointments/${widget.appointmentId}/clockout');
      if (!mounted) return;

      final appt = resp.data as Map<String, dynamic>;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ExperienceSummaryPage(
            appointmentId: widget.appointmentId,
            elapsed: _elapsed,
            startTime: _startTime!,
            endTime: DateTime.now(),
          ),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      _startTicking();
      setState(() {
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppointmentApi.messageOf(e))),
      );
    }
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime == null || !mounted) return;
      setState(() => _elapsed = DateTime.now().difference(_startTime!));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('体验中')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('体验中')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_storeName.isNotEmpty) ...[
              Text(
                _storeName,
                style: const TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 15,
                ),
              ),
              if (_tableName.isNotEmpty)
                Text(
                  '桌位 $_tableName',
                  style: const TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 32),
            ],
            // 状态图标
            Icon(
              _inService ? Icons.access_time_filled : Icons.login,
              size: 64,
              color: _inService ? const Color(0xFFE8633A) : const Color(0xFF2E9E5B),
            ),
            const SizedBox(height: 20),
            // 状态文字
            Text(
              _inService ? '服务中' : '已核销，等待上钟',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _inService
                  ? '尽情享受手作时光'
                  : '准备好后点击下方按钮开始体验',
              style: const TextStyle(color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 32),
            if (_inService && _startTime != null) ...[
              // 上钟时间
              const Text(
                '上钟时间',
                style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(_startTime!),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 20),
              // 使用时长（页面焦点）
              const Text(
                '使用时长',
                style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(_elapsed),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8633A),
                  letterSpacing: 4,
                ),
              ),
            ],
            const Spacer(),
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFD9453E), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            if (!_inService)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _submitting ? null : _clockIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9E5B),
                  ),
                  child: Text(_submitting ? '上钟中…' : '上钟 · 开始体验'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _submitting ? null : _clockOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD9453E),
                    side: const BorderSide(color: Color(0xFFD9453E)),
                  ),
                  child: Text(_submitting ? '处理中…' : '下钟 · 结束体验'),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
