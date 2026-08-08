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

  static Future<T?> push<T>(
    BuildContext context,
    Widget child, {
    bool resizeToAvoidBottomInset = true,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (_) => LiveHost(
          child: child,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ),
      ),
    );
  }

  static void replace(
    BuildContext context,
    Widget child, {
    bool resizeToAvoidBottomInset = true,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LiveHost(
          child: child,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ),
      ),
    );
  }

  /// 清空栈后切换到指定页面（登录成功 / Tab 切换 / 退出登录）。
  static void reset(
    BuildContext context,
    Widget child, {
    bool resizeToAvoidBottomInset = true,
  }) {
    // 用一步式 pushAndRemoveUntil 替换「popUntil + pushReplacement」，
    // 避免同一帧内连续移除/添加 route 导致 Overlay 中 InheritedElement
    // 在 deactivate 时仍被依赖（framework 断言 _dependents.isEmpty）。
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LiveHost(
          child: child,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ),
      ),
      (route) => false,
    );
  }

  /// 先关掉当前页（如抽屉菜单），再打开目标页。
  /// 使用捕获的 NavigatorState，避免在已卸载的 context 上再取 Navigator。
  static void pushAfterPop(
    BuildContext context,
    Widget child, {
    bool resizeToAvoidBottomInset = true,
  }) {
    final nav = Navigator.of(context);
    nav.pop();
    // 等 pop 的 route 离开树后再 push，避免同步 pop+push 触发
    // InheritedElement 依赖残留断言。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (nav.mounted) {
        nav.push(
          MaterialPageRoute(
            builder: (_) => LiveHost(
              child: child,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            ),
          ),
        );
      }
    });
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
      reset(context, const LoginScreen(), resizeToAvoidBottomInset: false);

  static Future<void> logout(BuildContext context) async {
    await AuthStore.instance.clear();
    if (context.mounted) goLogin(context);
  }
}

/// 手机外框宿主。
class LiveHost extends StatefulWidget {
  const LiveHost({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  /// 键盘弹出时是否压缩 440x956 画幅。登录页设为 false，
  /// 键盘直接覆盖在页面下半部分，页面不缩小。
  final bool resizeToAvoidBottomInset;

  @override
  State<LiveHost> createState() => _LiveHostState();
}

class _LiveHostState extends State<LiveHost> {
  /// 键盘弹出前（无键盘遮挡时）的窗口高度。
  /// 键盘弹出后画布仍按该高度渲染，避免 440x956 画幅被压缩。
  double? _noKeyboardHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.viewInsets.bottom == 0) {
      _noKeyboardHeight = mediaQuery.size.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final canvas = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 956),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 440,
            height: 956,
            child: ColoredBox(color: LiveColors.bg, child: widget.child),
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: widget.resizeToAvoidBottomInset
          // 聊天等页面：跟随 Scaffold 收缩，键盘弹出时输入框被顶起。
          ? canvas
          // 登录等页面：画布固定在键盘弹出前的高度，键盘覆盖下半部分。
          : Center(
              child: OverflowBox(
                // 画布顶部与窗口顶部对齐，底部溢出部分正好落入键盘区域，
                // 使输入栏的 viewInsets 补偿恰好把输入框顶到键盘上沿。
                alignment: Alignment.topCenter,
                minWidth: mediaQuery.size.width,
                maxWidth: mediaQuery.size.width,
                minHeight: _noKeyboardHeight ?? mediaQuery.size.height,
                maxHeight: _noKeyboardHeight ?? mediaQuery.size.height,
                child: canvas,
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
      resizeToAvoidBottomInset: !AuthStore.instance.isLoggedIn,
      child: AuthStore.instance.isLoggedIn
          ? const HomeScreen(root: true)
          : const LoginScreen(),
    );
  }
}
