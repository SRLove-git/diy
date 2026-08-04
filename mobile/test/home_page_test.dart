import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:diy_mobile/pages/home_page.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:1/api');
  });

  Future<void> pumpHome(WidgetTester tester, {required Size size}) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: HomePage(loadActiveAppointments: false)),
    );
    await tester.pump();
  }

  testWidgets('首页在常见手机宽度展示所有核心模块', (tester) async {
    await pumpHome(tester, size: const Size(390, 844));

    expect(find.text('拾染爱恋'), findsOneWidget);
    expect(find.text('到店预约'), findsOneWidget);
    expect(find.text('到店核销'), findsOneWidget);
    expect(find.text('会员套餐'), findsOneWidget);
    expect(find.text('创意拼豆手作工坊'), findsOneWidget);
    expect(find.text('热门推荐'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('首页在窄屏宽度没有布局溢出', (tester) async {
    await pumpHome(tester, size: const Size(320, 720));

    expect(find.text('预约手作时间'), findsOneWidget);
    expect(find.text('快速开始制作'), findsOneWidget);
    expect(find.text('查看会员权益'), findsOneWidget);
    final exception = tester.takeException();
    expect(
      exception,
      isNull,
      reason: exception is FlutterError ? exception.toStringDeep() : null,
    );
  });
}
