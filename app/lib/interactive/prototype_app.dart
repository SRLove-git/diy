import 'package:flutter/material.dart';

import '../live/live_routes.dart';
import '../live/live_theme.dart';

/// 手作星球 App 入口：启动时恢复登录态，进入登录页或首页。
class PrototypeApp extends StatelessWidget {
  const PrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '手作星球',
      debugShowCheckedModeBanner: false,
      theme: LiveTheme.data,
      home: const AuthGate(),
    );
  }
}
