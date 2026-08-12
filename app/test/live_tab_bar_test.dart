import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thinkorigin/api/auth_store.dart';
import 'package:thinkorigin/interactive/prototype_app.dart';
import 'package:thinkorigin/live/live_router.dart';
import 'package:thinkorigin/live/live_routes.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 预置登录态：启动后 redirect 直接进入底部 Tab 壳（首页）。
    SharedPreferences.setMockInitialValues(const {
      'auth_access_token': 'test-token',
      'auth_refresh_token': 'test-refresh',
      'auth_user_id': 1,
    });
  });

  testWidgets('首页底部 Tab：液态玻璃纯图标，可切换首页/我的', (tester) async {
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3.0;
    // 固定中文环境，保证页面文案断言稳定
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    await AuthStore.instance.restore();
    await tester.pumpWidget(const PrototypeApp());
    // appRouter 是全局单例，显式回到 Splash 让 redirect 重新收敛到首页。
    appRouter.go(RoutePaths.splash);
    // 首页 Logo 有循环流光动画，pumpAndSettle 不会收敛，用定长帧推进。
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 液态玻璃 Tab Bar 已挂载；ins 风纯图标：选中实心 home，未选中描边 person。
    expect(find.byType(GlassTabBar), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    // 纯图标样式：不渲染文字标签
    expect(find.text('首页'), findsNothing);
    expect(find.text('我的'), findsNothing);

    // 切到「我的」：选中态图标翻转
    await tester.tap(find.byIcon(Icons.person_outline));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });
}
