import 'package:flutter/material.dart';

import '../api/auth_store.dart';
import 'live_theme.dart';
import 'screens/chat_screens.dart';
import 'screens/community_screens.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/profile_screens.dart';
import 'screens/video_screens.dart';

/// 实时页面路由：统一套 440×956 手机外框，与原型预览保持一致。
class LiveRoutes {
  LiveRoutes._();

  static const tabHome = '03-首页';
  static const tabCommunity = '12-社区';
  static const tabReels = '16-Reels';
  static const tabChat = '21-会话列表';
  static const tabProfile = '26-我的主页';

  static Future<T?> push<T>(BuildContext context, Widget child) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => LiveHost(child: child)),
    );
  }

  static void replace(BuildContext context, Widget child) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LiveHost(child: child)),
    );
  }

  /// 清空栈后切换到指定页面（登录成功 / Tab 切换 / 退出登录）。
  static void reset(BuildContext context, Widget child) {
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    nav.pushReplacement(
      MaterialPageRoute(builder: (_) => LiveHost(child: child)),
    );
  }

  /// 先关掉当前页（如抽屉菜单），再打开目标页。
  /// 使用捕获的 NavigatorState，避免在已卸载的 context 上再取 Navigator。
  static void pushAfterPop(BuildContext context, Widget child) {
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(MaterialPageRoute(builder: (_) => LiveHost(child: child)));
  }

  static void switchTab(BuildContext context, int index) {
    final target = switch (index) {
      0 => const HomeScreen(root: true),
      1 => const CommunityHomeScreen(root: true),
      2 => const ReelsScreen(root: true),
      3 => const ConversationListScreen(root: true),
      4 => const ProfileScreen(root: true),
      _ => const HomeScreen(root: true),
    };
    reset(context, target);
  }

  static void goHome(BuildContext context) =>
      reset(context, const HomeScreen(root: true));

  static void goLogin(BuildContext context) =>
      reset(context, const LoginScreen());

  static Future<void> logout(BuildContext context) async {
    await AuthStore.instance.clear();
    if (context.mounted) goLogin(context);
  }
}

/// 手机外框宿主。
class LiveHost extends StatelessWidget {
  const LiveHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 956),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 440,
              height: 956,
              child: ColoredBox(color: LiveColors.bg, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// 启动入口：恢复登录态后进入登录页或首页。
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    AuthStore.instance.restore().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.instance.loaded) {
      return const LiveHost(
        child: Center(
          child: CircularProgressIndicator(color: LiveColors.brand),
        ),
      );
    }
    return LiveHost(
      child: AuthStore.instance.isLoggedIn
          ? const HomeScreen(root: true)
          : const LoginScreen(),
    );
  }
}
