import 'package:flutter_test/flutter_test.dart';

import 'package:thinkorigin/live/screens/auth_screens.dart';

import 'l10n_test_utils.dart';

void main() {
  testWidgets('修改密码页展示原密码/新密码/确认新密码与提交按钮', (tester) async {
    await tester.pumpWidget(l10nApp(home: const ChangePasswordScreen()));
    await tester.pumpAndSettle();

    expect(find.text('修改登录密码'), findsOneWidget);
    expect(find.text('原密码'), findsOneWidget);
    expect(find.text('新密码（6-32 位）'), findsOneWidget);
    expect(find.text('确认新密码'), findsOneWidget);
    expect(find.text('确认修改'), findsOneWidget);
  });

  testWidgets('原密码为空时点击提交提示输入原密码', (tester) async {
    await tester.pumpWidget(l10nApp(home: const ChangePasswordScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('确认修改'));
    await tester.pump();
    await tester.pump();

    expect(find.text('请输入原密码'), findsOneWidget);
    // 等待 Toast 消失，避免测试 teardown 挂起
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
