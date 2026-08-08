import 'package:flutter/material.dart';

import '../live/live_router.dart';
import '../live/live_theme.dart';

/// 手作星球 App 入口：go_router 声明式路由，启动时由 redirect 处理登录态。
class PrototypeApp extends StatelessWidget {
  const PrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '手作星球',
      debugShowCheckedModeBanner: false,
      theme: LiveTheme.data,
      routerConfig: appRouter,
    );
  }
}
