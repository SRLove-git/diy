import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_ui_app/live/screens/member_screens.dart';

void main() {
  testWidgets('会员下单成功页：订单已提交，等待门店确认，不再提示开通成功', (tester) async {
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: MemberOrderSubmittedView(
          planName: '月卡会员',
          durationDays: 30,
          onDone: () => done = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('订单已提交'), findsOneWidget);
    expect(find.text('等待门店确认'), findsOneWidget);
    expect(find.textContaining('到店支付会员费用'), findsOneWidget);
    expect(find.textContaining('开通成功'), findsNothing);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });
}
