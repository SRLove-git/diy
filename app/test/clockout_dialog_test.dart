import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thinkorigin/live/screens/appointment_screens.dart';

import 'l10n_test_utils.dart';

void main() {
  Widget host() => l10nApp(
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
      l10nApp(
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

  testWidgets('嵌套导航器（Tab 分支）下点“再想想”只关弹窗，不误 pop 外层页面', (tester) async {
    // 模拟 go_router StatefulShellRoute：页面在嵌套 Navigator 中，
    // showDialog 默认推到根 Navigator。修复前用外层 context pop 会误弹外层页面。
    await tester.pumpWidget(
      l10nApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              body: Builder(
                builder: (outerContext) => Center(
                  child: TextButton(
                    onPressed: () => showClockOutConfirmDialog(outerContext),
                    child: const Text('下钟'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('下钟'), findsOneWidget);
    await tester.tap(find.text('下钟'));
    await tester.pumpAndSettle();
    expect(find.text('结束体验'), findsOneWidget);

    await tester.tap(find.text('再想想'));
    await tester.pumpAndSettle();

    // 修复后：弹窗关闭、外层页面保留
    expect(find.text('结束体验'), findsNothing);
    expect(find.text('下钟'), findsOneWidget);
  });
}
