import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/main.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:1/api');
  });

  testWidgets('未登录时展示登录页', (WidgetTester tester) async {
    await tester.pumpWidget(const DiyApp());

    // 登录页元素
    expect(find.text('IDOL BEADS'), findsOneWidget);
    expect(find.text('登录 / 注册'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
    // 微信式协议勾选
    expect(find.textContaining('未注册手机号登录时将自动注册'), findsOneWidget);
    expect(find.text('《用户协议》'), findsOneWidget);
  });

  testWidgets('全局主题使用 Instagram 风近黑主色和纯白背景', (tester) async {
    await tester.pumpWidget(const DiyApp());

    final context = tester.element(find.text('IDOL BEADS'));
    final theme = Theme.of(context);
    expect(theme.colorScheme.primary, const Color(0xFF111111));
    expect(theme.scaffoldBackgroundColor, Colors.white);
    expect(theme.inputDecorationTheme.filled, isTrue);
  });
}
