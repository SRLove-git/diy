import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api/auth_store.dart';
import 'api/realtime.dart';
import 'interactive/prototype_app.dart';
import 'l10n/locale_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 强制竖屏锁定（Android/iOS 生效；与原生配置双保险）
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // 恢复登录态；未完成前由路由 redirect 停留在 Splash。
  AuthStore.instance.restore().then((_) {
    RealtimeService.instance.start();
  });
  await LocaleStore.instance.restore();
  // 登录后建立实时推送；退出登录时断开。
  AuthStore.instance.addListener(() {
    if (AuthStore.instance.isLoggedIn) {
      RealtimeService.instance.start();
    } else {
      RealtimeService.instance.stop();
    }
  });
  runApp(const PrototypeApp());
}
