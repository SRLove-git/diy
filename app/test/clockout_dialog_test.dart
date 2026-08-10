import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_ui_app/live/screens/appointment_screens.dart';

void main() {
  Widget host() => MaterialApp(
        home: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showClockOutConfirmDialog(context),
              child: const Text('下钟'),
            ),
          ),
        ),
      );

  testWidgets('下钟弹窗展示说明与两个按钮', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('下钟'));
    await tester.pumpAndSettle();

    expect(find.text('结束体验'), findsOneWidget);
    expect(find.textContaining('停止计时'), findsOneWidget);
    expect(find.text('再想想'), findsOneWidget);
    expect(find.text('确认下钟'), findsOneWidget);
  });

  testWidgets('点“再想想”返回 false 且不关闭页面', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('下钟'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('再想想'));
    await tester.pumpAndSettle();

    expect(find.text('结束体验'), findsNothing);
  });

  testWidgets('点“确认下钟”返回 true 并关闭弹窗', (tester) async {
    final result = <bool?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                result.add(await showClockOutConfirmDialog(context));
              },
              child: const Text('下钟'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('下钟'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认下钟'));
    await tester.pumpAndSettle();

    expect(result, [true]);
    expect(find.text('结束体验'), findsNothing);
  });
}
