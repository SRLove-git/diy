import 'package:flutter/material.dart';

import 'api/auth_store.dart';
import 'interactive/prototype_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 恢复登录态；未完成前由路由 redirect 停留在 Splash。
  AuthStore.instance.restore();
  runApp(const PrototypeApp());
}
