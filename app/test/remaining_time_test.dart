import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thinkorigin/api/models.dart';
import 'package:thinkorigin/live/screens/appointment_screens.dart';
import 'package:thinkorigin/live/screens/member_screens.dart';

import 'l10n_test_utils.dart';

Appointment inServiceAppointment({
  required DateTime serviceStartTime,
  required DateTime serviceEndTime,
}) =>
    Appointment.fromJson({
      'id': 1,
      'type': 'store',
      'userId': 1,
      'storeName': '拼豆',
      'tableName': 'A1',
      'date': '2026-08-13',
      'startTime': '10:00',
      'endTime': '12:00',
      'peopleCount': 2,
      'code': '123456',
      'amount': '39.8',
      'originalAmount': '39.8',
      'payStatus': 'unpaid',
      'payMethod': '',
      'status': 'in_service',
      'serviceStartTime': serviceStartTime.toIso8601String(),
      'serviceEndTime': serviceEndTime.toIso8601String(),
    });

void main() {
  group('会员剩余天数', () {
    test('已过期（active 但 expireAt 已过）：显示 0 而非负数', () {
      final membership = Membership.fromJson({
        'status': 'active',
        'expireAt': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      });
      expect(memberRemainingDays(membership, DateTime.now()), 0);
    });

    test('即将到期不足 1 天：显示 0 而非负数', () {
      final membership = Membership.fromJson({
        'status': 'active',
        'expireAt': DateTime.now()
            .add(const Duration(hours: 2))
            .toIso8601String(),
      });
      expect(memberRemainingDays(membership, DateTime.now()), 0);
    });

    test('未开通：显示 0', () {
      expect(
        memberRemainingDays(
          Membership.fromJson({'status': 'none', 'expireAt': null}),
          DateTime.now(),
        ),
        0,
      );
    });
  });

  group('服务中计时卡剩余时间', () {
    testWidgets('已超过结束时间：显示 00:00:00 而非负数', (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(
        l10nApp(
          home: TimerCard(
            appointment: inServiceAppointment(
              serviceStartTime: now.subtract(const Duration(hours: 2)),
              serviceEndTime: now.subtract(const Duration(minutes: 5)),
            ),
            onAction: () {},
          ),
        ),
      );

      expect(find.text('00:00:00'), findsOneWidget);
      expect(find.textContaining('-'), findsNothing);

      // 释放树，取消每秒刷新的周期定时器
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('结束时间晚于当前：正常显示剩余 HH:MM:SS', (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(
        l10nApp(
          home: TimerCard(
            appointment: inServiceAppointment(
              serviceStartTime: now,
              serviceEndTime: now.add(const Duration(hours: 1, minutes: 2)),
            ),
            onAction: () {},
          ),
        ),
      );

      expect(find.textContaining(RegExp(r'^01:0[12]:\d{2}$')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
