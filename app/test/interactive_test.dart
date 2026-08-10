import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diy_ui_app/api/auth_store.dart';
import 'package:diy_ui_app/interactive/prototype_app.dart';
import 'package:diy_ui_app/live/live_router.dart';
import 'package:diy_ui_app/live/live_routes.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3.0;
    // 固定中文环境，保证页面文案断言稳定
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    // 模拟 main() 中的登录态恢复；未调用时 redirect 会一直停留在 Splash。
    await AuthStore.instance.restore();
    await tester.pumpWidget(const PrototypeApp());
    // appRouter 是全局单例，显式回到 Splash 重置路由位置，避免上个用例残留。
    appRouter.go(RoutePaths.splash);
    await tester.pumpAndSettle();
    // LiveRoutes 防抖使用真实时钟，等待其静态状态过期，避免上个用例的
    // 导航时间戳让本次点击被 `_allowNavigation` 直接丢弃。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
  }

  testWidgets('启动进入登录页（用户名密码登录）', (tester) async {
    await pumpApp(tester);
    expect(find.text('Think Origin'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('用户名 / 邮箱'), findsOneWidget);
    expect(find.text('注册新账号'), findsOneWidget);
  });

  testWidgets('账号为空时点击登录提示校验', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('登录'));
    // 第一帧处理点击；第二帧执行 showLiveSnack 的 postFrameCallback 并构建 toast
    await tester.pump();
    await tester.pump();
    expect(find.text('请输入用户名或邮箱'), findsOneWidget);
    // 等待顶部 Toast 的 2.2s 自动消失定时器结束，避免测试 teardown 断言挂起。
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('进入注册页', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('注册新账号'));
    await tester.pumpAndSettle();
    expect(find.text('用用户名和密码注册，绑定邮箱用于找回密码'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
  });

  testWidgets('进入忘记密码页', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('忘记密码？'));
    await tester.pumpAndSettle();
    expect(find.text('通过绑定邮箱验证后设置新密码'), findsOneWidget);
    expect(find.text('重置密码'), findsOneWidget);
  });
}
