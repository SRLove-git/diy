import 'package:flutter/material.dart';

import 'api/auth_store.dart';
import 'api/realtime.dart';
import 'interactive/prototype_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 恢复登录态；未完成前由路由 redirect 停留在 Splash。
  AuthStore.instance.restore().then((_) {
    RealtimeService.instance.start();
  });
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
