import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/app_colors.dart';
import '../core/appointment_api.dart';

/// 展示预约核销二维码的弹窗，供「到店核销」与「我的订单」复用
Future<void> showCheckInQrDialog(BuildContext context, Appointment appt) {
  return showDialog<void>(
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
            CheckInQrCode(code: appt.code, size: 240),
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
  );
}

/// 预约核销二维码组件（白底圆角卡片）
class CheckInQrCode extends StatelessWidget {
  const CheckInQrCode({super.key, required this.code, required this.size});

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
