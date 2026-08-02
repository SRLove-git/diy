import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/main.dart';

void main() {
  testWidgets('未登录时展示登录页', (WidgetTester tester) async {
    await tester.pumpWidget(const DiyApp());

    // 登录页元素
    expect(find.text('DIY 手作工坊'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
  });
}
