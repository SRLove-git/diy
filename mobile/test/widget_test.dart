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
    expect(find.text('拾染爱恋'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
  });

  testWidgets('全局主题使用统一品牌色和纯白背景', (tester) async {
    await tester.pumpWidget(const DiyApp());

    final context = tester.element(find.text('拾染爱恋'));
    final theme = Theme.of(context);
    expect(theme.colorScheme.primary, const Color(0xFFFF3040));
    expect(theme.scaffoldBackgroundColor, Colors.white);
    expect(theme.inputDecorationTheme.filled, isTrue);
  });
}
