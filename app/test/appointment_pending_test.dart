import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_ui_app/api/models.dart';
import 'package:diy_ui_app/live/screens/appointment_screens.dart';

Appointment makeAppointment({String status = 'pending'}) =>
    Appointment.fromJson({
      'id': 2,
      'type': 'store',
      'userId': 32,
      'storeName': '拼豆',
      'tableName': 'A1',
      'date': '2026-08-10',
      'startTime': '10:00',
      'endTime': '11:30',
      'peopleCount': 2,
      'code': '654321',
      'amount': '39.8',
      'originalAmount': '39.8',
      'payStatus': 'unpaid',
      'payMethod': '',
      'status': status,
    });

void main() {
  testWidgets('下单成功页：待确认状态提示等待门店确认，不展示核销码', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppointmentSuccessScreen(appointment: makeAppointment()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('预约已提交'), findsOneWidget);
    expect(find.text('等待门店确认'), findsOneWidget);
    expect(find.textContaining('到店出示预约码'), findsOneWidget);
    expect(find.textContaining('核销码'), findsNothing);
  });

  testWidgets('门店预约成功页：直接展示核销码，无需等待确认', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppointmentSuccessScreen(
          appointment: makeAppointment(status: 'booked'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('预约成功'), findsOneWidget);
    expect(find.text('654321'), findsOneWidget);
    expect(find.text('等待门店确认'), findsNothing);
  });
}
