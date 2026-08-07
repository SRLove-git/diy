import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diy_ui_app/interactive/prototype_app.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3.0;
    await tester.pumpWidget(const PrototypeApp());
    await tester.pumpAndSettle();
  }

  testWidgets('启动进入登录页（验证码登录）', (tester) async {
    await pumpApp(tester);
    expect(find.text('手作星球'), findsOneWidget);
    expect(find.text('登录 / 注册'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
  });

  testWidgets('手机号为空时点击登录提示校验', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('登录 / 注册'));
    await tester.pump();
    expect(find.text('请输入正确的手机号'), findsOneWidget);
  });

  testWidgets('进入密码登录页', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('密码登录'));
    await tester.pumpAndSettle();
    expect(find.text('使用密码登录'), findsOneWidget);
  });

  testWidgets('进入忘记密码 / 设置密码页', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('忘记密码'));
    await tester.pumpAndSettle();
    expect(find.text('设置新密码'), findsOneWidget);
    expect(find.text('重置密码'), findsOneWidget);
  });
}
