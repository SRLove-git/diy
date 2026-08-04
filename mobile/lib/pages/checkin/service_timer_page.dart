import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_colors.dart';
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
  DateTime? _scheduledEnd; // 预约时段结束时刻（date + endTime），即下钟时间
  Timer? _timer;
  Timer? _pollTimer; // 轮询预约状态，检测服务端自动下钟
  bool _clockoutChecking = false; // 防止自动下钟检测并发请求
  Duration _elapsed = Duration.zero;
  Duration _remaining = Duration.zero; // 剩余时长（到预约时段结束）
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
      final endStr = appt['serviceEndTime'] as String?;

      // 服务端已自动下钟（预约时段到点），直接进入体验总结
      if (status == 'completed' && startStr != null && endStr != null) {
        _goToSummary(
          _parseServerDateTime(startStr),
          _parseServerDateTime(endStr),
        );
        return;
      }

      setState(() {
        _storeName = appt['storeName'] as String? ?? '';
        _tableName = appt['tableName'] as String? ?? '';
        _loading = false;

        if (status == 'in_service' && startStr != null) {
          _inService = true;
          _startTime = _parseServerDateTime(startStr);
          _scheduledEnd = _parseScheduledEnd(appt);
          _elapsed = DateTime.now().difference(_startTime!);
          _remaining = _computeRemaining();
          _startTicking();
          _startAutoClockoutPolling();
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
        _startTime = _parseServerDateTime(startStr);
        _scheduledEnd = _parseScheduledEnd(appt);
        _elapsed = Duration.zero;
        _remaining = _computeRemaining();
        _submitting = false;
      });
      _startTicking();
      _startAutoClockoutPolling();
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
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(ctx).textPrimary,
            ),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(ctx).textPrimary,
              foregroundColor: AppColors.of(ctx).surface,
            ),
            child: const Text('确认下钟'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    _timer?.cancel();
    setState(() => _submitting = true);
    try {
      await ApiClient.instance
          .post('/appointments/${widget.appointmentId}/clockout');
      if (!mounted) return;

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
      final now = DateTime.now();
      setState(() {
        if (_scheduledEnd != null && !now.isBefore(_scheduledEnd!)) {
          // 已到预约时段结束：使用时长锁定为预约时段时长，不再增长
          _elapsed = _scheduledEnd!.difference(_startTime!);
        } else {
          _elapsed = now.difference(_startTime!);
        }
        _remaining = _computeRemaining();
      });
      // 剩余时长到 0：乐观进入结算页，后台再同步服务端自动下钟
      if (_scheduledEnd != null && _remaining <= Duration.zero) {
        _optimisticClockout();
      }
    });
  }

  /// 预约时段到点：不等服务端响应，直接进入结算页（时长=预约时段时长），
  /// 后台再触发一次服务端自动下钟确认（detail 读取时服务端会自动置为已完成）
  void _optimisticClockout() {
    final start = _startTime!;
    final end = _scheduledEnd!;
    _timer?.cancel();
    _pollTimer?.cancel();
    _goToSummary(start, end);
    _syncServerClockout();
  }

  /// 后台确认服务端自动下钟（幂等；失败静默，服务端周期任务也会兜底下钟）
  Future<void> _syncServerClockout() async {
    if (_clockoutChecking) return;
    _clockoutChecking = true;
    try {
      await ApiClient.instance.get('/appointments/${widget.appointmentId}');
    } on DioException {
      // 忽略：服务端周期任务也会自动下钟
    } finally {
      _clockoutChecking = false;
    }
  }

  /// 解析预约时段结束时刻（date + endTime）
  DateTime? _parseScheduledEnd(Map<String, dynamic> appt) {
    final date = appt['date'] as String?;
    final endTime = appt['endTime'] as String?;
    if (date == null || endTime == null) return null;
    return DateTime.parse('${date}T$endTime:00');
  }

  /// 服务端时间带 UTC 偏移时，展示和预约时段都按设备本地时区处理。
  DateTime _parseServerDateTime(String value) =>
      DateTime.parse(value).toLocal();

  /// 距预约时段结束的剩余时长（已到点则返回 0）
  Duration _computeRemaining() {
    final end = _scheduledEnd;
    if (end == null) return Duration.zero;
    final left = end.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// 上钟后轮询预约状态：服务端到点自动下钟后，本页自动跳转体验总结
  void _startAutoClockoutPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkAutoClockout(),
    );
  }

  Future<void> _checkAutoClockout() async {
    if (!mounted || _submitting || !_inService || _clockoutChecking) return;
    _clockoutChecking = true;
    try {
      final resp =
          await ApiClient.instance.get('/appointments/${widget.appointmentId}');
      if (!mounted) return;
      final appt = resp.data as Map<String, dynamic>;
      final startStr = appt['serviceStartTime'] as String?;
      final endStr = appt['serviceEndTime'] as String?;
      if (appt['status'] == 'completed' && startStr != null && endStr != null) {
        _timer?.cancel();
        _pollTimer?.cancel();
        _goToSummary(
          _parseServerDateTime(startStr),
          _parseServerDateTime(endStr),
        );
      }
    } on DioException {
      // 轮询失败忽略，等待下一次
    } finally {
      _clockoutChecking = false;
    }
  }

  /// 跳转体验总结页
  void _goToSummary(DateTime start, DateTime end) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExperienceSummaryPage(
          appointmentId: widget.appointmentId,
          elapsed: end.difference(start),
          startTime: start,
          endTime: end,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
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
    final colors = AppColors.of(context);
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
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 15,
                ),
              ),
              if (_tableName.isNotEmpty)
                Text(
                  '桌位 $_tableName',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 32),
            ],
            // 状态图标
            Icon(
              _inService ? Icons.access_time_filled : Icons.login,
              size: 64,
              color: _inService ? colors.textPrimary : const Color(0xFF2E9E5B),
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
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 32),
            if (_inService && _startTime != null) ...[
              // 上钟时间 / 下钟时间
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimeInfo(label: '上钟时间', value: _formatTime(_startTime!)),
                  if (_scheduledEnd != null) ...[
                    const SizedBox(width: 48),
                    _TimeInfo(
                      label: '下钟时间',
                      value: _formatTime(_scheduledEnd!),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // 使用时长（页面焦点）
              Text(
                '使用时长',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(_elapsed),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  letterSpacing: 4,
                ),
              ),
              if (_scheduledEnd != null) ...[
                const SizedBox(height: 16),
                // 剩余时长（到预约时段结束）
                Text(
                  '剩余时长',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(_remaining),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _remaining <= const Duration(minutes: 10)
                        ? colors.danger
                        : colors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ],
            const Spacer(),
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: colors.danger, fontSize: 14),
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
                    foregroundColor: colors.danger,
                    side: BorderSide(color: colors.danger),
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

/// 上钟时间 / 下钟时间 信息列
class _TimeInfo extends StatelessWidget {
  const _TimeInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
