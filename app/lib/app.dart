import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'core/auth_service.dart';
import 'core/chat_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

/// IDOL BEADS · 手作星球 客户端入口
///
/// 新版 UI App（由 Pixso 82 屏设计稿生成）接入后端 server 后的真实客户端壳：
/// 登录态门卫 + 底部五 Tab 主框架，核心页面全部走 [ApiClient]/[ChatService] 真实数据。
class DiyApp extends StatelessWidget {
  const DiyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '手作星球',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.light.accent,
          brightness: Brightness.light,
        ),
        fontFamily: 'PingFang SC',
        extensions: const [AppColors.light],
      ),
      home: const AuthGate(),
    );
  }
}

/// 登录态门卫：未登录 → 登录页；已登录 → 五 Tab 主框架
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // 已恢复登录态时立即连接聊天实时通道
    if (AuthService.instance.isLoggedIn) {
      ChatService.instance.ensureConnected();
      ChatService.instance.refreshConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        if (!AuthService.instance.isLoggedIn) {
          return const LoginScreen();
        }
        return const MainShell();
      },
    );
  }
}
