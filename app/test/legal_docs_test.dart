import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thinkorigin/api/auth_store.dart';
import 'package:thinkorigin/interactive/prototype_app.dart';
import 'package:thinkorigin/live/legal_docs.dart';
import 'package:thinkorigin/live/live_router.dart';
import 'package:thinkorigin/live/live_routes.dart';
import 'package:thinkorigin/live/screens/legal_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('用户协议页渲染标题与正文', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    await tester.pumpWidget(const MaterialApp(
      home: LegalDocScreen(title: '用户协议', body: legalUserAgreementText),
    ));
    await tester.pumpAndSettle();

    expect(find.text('用户协议'), findsOneWidget);
    expect(find.text('Think Origin 手作工坊用户协议'), findsOneWidget);
    expect(find.text('一、协议的确认与接受'), findsOneWidget);
    expect(find.textContaining('客服邮箱'), findsNothing);

    // 文档较长：滚动到末尾确认完整内容可展示。
    await tester.scrollUntilVisible(
      find.text('三、账号注册与使用'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('三、账号注册与使用'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('客服邮箱'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('客服邮箱'), findsWidgets);
  });

  testWidgets('隐私政策页渲染标题与正文', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    await tester.pumpWidget(const MaterialApp(
      home: LegalDocScreen(title: '隐私政策', body: legalPrivacyPolicyText),
    ));
    await tester.pumpAndSettle();

    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('Think Origin 手作工坊隐私政策'), findsOneWidget);
    expect(find.text('二、我们收集的信息'), findsOneWidget);
    expect(find.textContaining('我们将在收到您的反馈后'), findsNothing);

    await tester.scrollUntilVisible(
      find.textContaining('我们将在收到您的反馈后'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('我们将在收到您的反馈后'), findsWidgets);
  });

  testWidgets('未登录状态也可访问用户协议与隐私政策', (tester) async {
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3.0;
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    // 模拟 main() 中的登录态恢复；未登录时 redirect 会停在登录页。
    await AuthStore.instance.restore();
    await tester.pumpWidget(const PrototypeApp());
    await tester.pumpAndSettle();
    expect(find.text('注册新账号'), findsOneWidget);

    appRouter.go(RoutePaths.profileUserAgreement);
    await tester.pumpAndSettle();
    expect(find.text('Think Origin 手作工坊用户协议'), findsOneWidget);

    appRouter.go(RoutePaths.profilePrivacyPolicy);
    await tester.pumpAndSettle();
    expect(find.text('Think Origin 手作工坊隐私政策'), findsOneWidget);
  });
}
