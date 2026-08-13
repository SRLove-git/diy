import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thinkorigin/live/live_widgets.dart';

void main() {
  testWidgets('LivePage：点击文本框聚焦，点击文本框以外空白处收起键盘', (tester) async {
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3.0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部纯文本：点击它代表「文本框以外的空白区域」。
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('标题'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  focusNode: focusNode,
                  decoration: const InputDecoration(hintText: '输入内容'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 初始未聚焦。
    expect(focusNode.hasFocus, isFalse);

    // 点击文本框 → 获得焦点（键盘弹出），不会被外层手势误伤收起。
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    // 点击文本框以外的区域 → 失焦（键盘收起）。
    await tester.tap(find.text('标题'));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);

    // 再次点击文本框仍可正常聚焦。
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });
}
