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
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        // 固定设计稿字号：整体界面已按屏幕缩放，
        // 禁止系统字体缩放改变布局导致文字溢出、按钮变形。
        minScaleFactor: 1.0,
        maxScaleFactor: 1.0,
        child: child!,
      ),
    );
  }
}
