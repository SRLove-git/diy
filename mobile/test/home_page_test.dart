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

    expect(find.text('IDOL BEADS'), findsOneWidget);
    expect(find.text('到店预约'), findsOneWidget);
    expect(find.text('到店核销'), findsOneWidget);
    expect(find.text('会员套餐'), findsOneWidget);
    expect(find.text('创意拼豆手作工坊'), findsOneWidget);
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

  testWidgets('首页顶部展示拼豆/敬请期待切换，默认拼豆', (tester) async {
    await pumpHome(tester, size: const Size(390, 844));

    expect(find.text('拼豆'), findsOneWidget);
    expect(find.text('敬请期待'), findsOneWidget);
    expect(find.text('到店预约'), findsOneWidget);
  });

  testWidgets('切换到敬请期待后显示占位内容，隐藏拼豆模块', (tester) async {
    await pumpHome(tester, size: const Size(390, 844));

    await tester.tap(find.text('敬请期待'));
    await tester.pumpAndSettle();

    expect(find.text('到店预约'), findsNothing);
    expect(find.text('快速开始制作'), findsNothing);
    expect(find.text('更多精彩 DIY 手作板块正在筹备中'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('从敬请期待可切回拼豆板块', (tester) async {
    await pumpHome(tester, size: const Size(390, 844));

    await tester.tap(find.text('敬请期待'));
    await tester.pumpAndSettle();
    expect(find.text('到店预约'), findsNothing);

    await tester.tap(find.text('拼豆'));
    await tester.pumpAndSettle();

    expect(find.text('到店预约'), findsOneWidget);
    expect(find.text('更多精彩 DIY 手作板块正在筹备中'), findsNothing);
  });
}
