import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// 体验总结页：上钟时间 / 下钟时间 / 使用时长
class ExperienceSummaryPage extends StatelessWidget {
  const ExperienceSummaryPage({
    super.key,
    required this.appointmentId,
    required this.elapsed,
    required this.startTime,
    required this.endTime,
  });

  final int appointmentId;
  final Duration elapsed;
  final DateTime startTime;
  final DateTime endTime;

  String _formatTime(DateTime dt) {
    dt = dt.toLocal();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('体验总结')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 72, color: Color(0xFF2E9E5B)),
            const SizedBox(height: 16),
            Text(
              '体验结束',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '感谢您的光临，期待再次相遇',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 40),
            // 信息卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(label: '上钟时间', value: _formatTime(startTime)),
                  Divider(height: 24, color: colors.divider),
                  _InfoRow(label: '下钟时间', value: _formatTime(endTime)),
                  Divider(height: 24, color: colors.divider),
                  _InfoRow(
                    label: '使用时长',
                    value: _formatDuration(elapsed),
                    valueColor: colors.textPrimary,
                    valueBold: true,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.textPrimary,
                  foregroundColor: colors.surface,
                ),
                child: const Text('完成'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 15),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
