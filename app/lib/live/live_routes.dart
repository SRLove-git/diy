import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/auth_store.dart';
import 'live_theme.dart';

/// 路由路径常量（go_router 声明式路由表，定义见 live_router.dart）。
class RoutePaths {
  RoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const loginPassword = '/login/password';
  static const loginSetPassword = '/login/set-password';
  static const loginVerify = '/login/verify';

  // 底部 5 Tab（StatefulShellRoute 分支）
  static const home = '/home';
  static const community = '/community';
  static const reels = '/reels';
  static const chat = '/chat';
  static const profile = '/profile';

  // 详情页（顶层路由，覆盖 Tab 壳）
  static const search = '/search';
  static const notifications = '/notifications';
  static const userDetail = '/user/:id';
  static const userFollows = '/user/follows';
  static const postDetail = '/post/:id';
  static const postPublish = '/post/publish';
  static const postPublishSuccess = '/post/publish/success';
  static const videoDetail = '/video/:id';
  static const videoSearch = '/video/search';
  static const videoCapture = '/video/capture';
  static const videoPublish = '/video/publish';
  static const videoMusic = '/video/music';
  static const videoPlayer = '/video/player';
  static const videoLandscape = '/video/landscape';
  static const viewer = '/viewer';
  static const chatDetail = '/chat/detail';
  static const chatInfo = '/chat/info';
  static const chatGroupSettings = '/chat/group-settings/:id';
  static const chatBlocks = '/chat/blocks';
  static const chatAddFriend = '/chat/add-friend';
  static const activityList = '/activity/list';
  static const activityDetail = '/activity/:id';
  static const storeList = '/store/list';
  static const storeDetail = '/store/:id';
  static const storeSearch = '/store/search';
  static const storeCheckin = '/store/checkin';
  static const storeTableSelect = '/store/table-select';
  static const appointmentConfirm = '/appointment/confirm';
  static const appointmentDetail = '/appointment/:id';
  static const appointmentSuccess = '/appointment/success';
  static const appointmentCheckinQr = '/appointment/checkin-qr';
  static const appointmentMy = '/appointment/my';
  static const memberCenter = '/member/center';
  static const memberCoupons = '/member/coupons';
  static const memberCouponCenter = '/member/coupon-center';
  static const memberPurchase = '/member/purchase';
  static const profileEdit = '/profile/edit';
  static const profileSettings = '/profile/settings';
  static const profileLiked = '/profile/liked';
  static const profileHistory = '/profile/history';
}

/// 实时页面导航（go_router 封装）。
/// 声明式路由表见 live_router.dart（RoutePaths / appRouter）。
class LiveRoutes {
  LiveRoutes._();

  static void switchTab(BuildContext context, int index) =>
      context.go(switch (index) {
        0 => RoutePaths.home,
        1 => RoutePaths.community,
        2 => RoutePaths.reels,
        3 => RoutePaths.chat,
        _ => RoutePaths.profile,
      });

  static void goHome(BuildContext context) => context.go(RoutePaths.home);

  static void goLogin(BuildContext context) => context.go(RoutePaths.login);

  /// 打开目标页（顶层路由，覆盖 Tab 壳）。
  /// 泛型 T 用于接收 pop 返回值（如选音乐）。
  static Future<T?> push<T>(BuildContext context, String path,
          {Object? extra}) =>
      context.push<T>(path, extra: extra);

  /// 替换当前页（登录流程用）。
  static void replace(BuildContext context, String path, {Object? extra}) =>
      context.pushReplacement(path, extra: extra);

  /// 带 int 路径参数（:id）的跳转。
  static Future<void> pushId(BuildContext context, String path, int id) =>
      context.push(path.replaceFirst(':id', '$id'));

  static Future<void> logout(BuildContext context) async {
    await AuthStore.instance.clear();
    if (context.mounted) goLogin(context);
  }

  /// 先关掉当前页（如抽屉菜单），再打开目标页。
  /// 使用捕获的 NavigatorState，避免在已卸载的 context 上再取 Navigator。
  static void pushAfterPop(
    BuildContext context,
    String path, {
    Object? extra,
  }) {
    final nav = Navigator.of(context);
    nav.pop();
    // 等 pop 的 route 离开树后再 push，避免同步 pop+push 触发
    // InheritedElement 依赖残留断言。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (nav.mounted) {
        nav.context.push(path, extra: extra);
      }
    });
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
