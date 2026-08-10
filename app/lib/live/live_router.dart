import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/auth_store.dart';
import '../api/models.dart';
import '../api/services.dart';
import 'live_routes.dart';
import 'live_theme.dart';
import 'live_widgets.dart';
import 'screens/activity_screens.dart';
import 'screens/appointment_screens.dart';
import 'screens/auth_screens.dart';
import 'screens/chat_screens.dart';
// import 'screens/community_screens.dart'; // 社区前期暂不开放（分支已注释）
import 'screens/home_screen.dart';
import 'screens/member_screens.dart';
import 'screens/notifications_screen.dart';
import 'screens/post_screens.dart';
import 'screens/profile_screens.dart';
import 'screens/store_screens.dart';
import 'screens/video_screens.dart';

/// 底部 Tab 快速连续切换的防抖时间戳。
DateTime? _lastTabTap;

/// Think Origin 路由表。
/// - 底部 5 Tab 使用 StatefulShellRoute.indexedStack，切换时保留各分支状态（Tab 保活）；
/// - 其余页面为顶层路由，覆盖在 Tab 壳之上；
/// - redirect 负责登录态跳转：启动先进 Splash，等待 AuthStore 恢复完成
///   （AuthStore 为 ChangeNotifier，登录态变化会触发 redirect 重算）。
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  refreshListenable: AuthStore.instance,
  redirect: (context, state) {
    final auth = AuthStore.instance;
    final loc = state.matchedLocation;
    // 登录态尚未恢复：统一停留在 Splash
    if (!auth.loaded) {
      return loc == RoutePaths.splash ? null : RoutePaths.splash;
    }
    final loggedIn = auth.isLoggedIn;
    final onLogin = loc.startsWith(RoutePaths.login);
    // 恢复完成：Splash 收敛到对应首页
    if (loc == RoutePaths.splash) {
      return loggedIn ? RoutePaths.home : RoutePaths.login;
    }
    if (!loggedIn && !onLogin) return RoutePaths.login;
    if (loggedIn && onLogin) return RoutePaths.home;
    return null;
  },
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (_, _) => const LiveHost(
        child: Center(
          child: CircularProgressIndicator(color: LiveColors.brand),
        ),
      ),
    ),
    // ===== 登录 / 注册 =====
    GoRoute(
      path: RoutePaths.login,
      builder: (_, _) =>
          LiveHost(resizeToAvoidBottomInset: false, child: const LoginScreen()),
    ),
    GoRoute(
      path: RoutePaths.loginRegister,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.loginForgot,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.loginVerify,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const VerifyCodeScreen(),
      ),
    ),
    // ===== 底部 5 Tab（保活） =====
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => LiveHost(
        child: Stack(
          children: [
            Positioned.fill(child: navigationShell),
            // 悬浮 Tab 覆盖在内容之上：内容可滚动到 Tab 背后，不留白色条
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LiveTabBar(
                current: navigationShell.currentIndex,
                onTap: (i) {
                  // 重复点击当前 Tab 不导航；快速连续切换也做防抖，
                  // 避免过渡期重复导航触发 '!keyReservation.contains(key)' 断言。
                  if (i == navigationShell.currentIndex) return;
                  final now = DateTime.now();
                  if (_lastTabTap != null &&
                      now.difference(_lastTabTap!).inMilliseconds < 250) {
                    return;
                  }
                  _lastTabTap = now;
                  // 不能在 build 阶段同步 goBranch：正常点击立即切换，
                  // 仅在 build 帧内时延迟到帧末，避免与页面过渡叠加触发重复 page key 断言。
                  LiveRoutes.afterBuildFrame(() {
                    if (!context.mounted) return;
                    navigationShell.goBranch(i, initialLocation: false);
                    // 切回首页时刷新订单，感知店员后台核销（事件驱动，非轮询）
                    if (i == 0) {
                      HomeOrdersRefresh.instance.refresh();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (_, _) => const HomeScreen(),
            ),
          ],
        ),
        // ── 社区 / Reels / 聊天前期暂不开放，分支先隐藏（恢复时取消注释） ──
        // StatefulShellBranch(
        //   routes: [
        //     GoRoute(
        //       path: RoutePaths.community,
        //       builder: (_, __) => const CommunityHomeScreen(),
        //     ),
        //   ],
        // ),
        // StatefulShellBranch(
        //   routes: [
        //     GoRoute(
        //       path: RoutePaths.reels,
        //       builder: (_, __) => const ReelsScreen(),
        //     ),
        //   ],
        // ),
        // StatefulShellBranch(
        //   routes: [
        //     GoRoute(
        //       path: RoutePaths.chat,
        //       builder: (_, __) => const ConversationListScreen(),
        //     ),
        //   ],
        // ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.profile,
              builder: (_, _) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // ===== 通用 =====
    GoRoute(
      path: RoutePaths.search,
      // 搜索页有输入框：键盘弹出时页面不压缩，键盘覆盖下半部分。
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const SearchScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.notifications,
      builder: (_, _) => LiveHost(child: const NotificationsScreen()),
    ),
    GoRoute(
      path: RoutePaths.viewer,
      builder: (_, s) => LiveHost(child: ImageViewerPage(url: s.extra as String)),
    ),
    // ===== 用户 =====
    GoRoute(
      path: RoutePaths.userFollows,
      builder: (_, s) {
        final m = s.extra as Map;
        return LiveHost(
          child: FollowScreen(
            targetId: m['targetId'] as int,
            initialTab: m['initialTab'] as String,
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.userDetail,
      builder: (_, s) => LiveHost(
        child: UserProfileScreen(userId: _id(s, 'id')),
      ),
    ),
    // ===== 帖子 =====
    GoRoute(
      path: RoutePaths.postPublish,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const PostPublishScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.postPublishSuccess,
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: PostPublishSuccessScreen(post: s.extra as Post),
      ),
    ),
    GoRoute(
      path: RoutePaths.postDetail,
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: PostDetailScreen(postId: _id(s, 'id')),
      ),
    ),
    // ===== 视频 =====
    GoRoute(
      path: RoutePaths.videoSearch,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const VideoSearchScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.videoCapture,
      builder: (_, _) => LiveHost(child: const CaptureScreen()),
    ),
    GoRoute(
      path: RoutePaths.videoPublish,
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: VideoPublishScreen(initialCover: s.extra as String),
      ),
    ),
    GoRoute(
      path: RoutePaths.videoMusic,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const MusicPickerScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.videoPlayer,
      builder: (_, s) => LiveHost(child: VideoPlayerPage(video: s.extra as Video)),
    ),
    GoRoute(
      path: RoutePaths.videoLandscape,
      builder: (_, s) =>
          LiveHost(child: VideoLandscapePage(video: s.extra as Video)),
    ),
    GoRoute(
      path: RoutePaths.videoDetail,
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: VideoDetailScreen(videoId: _id(s, 'id')),
      ),
    ),
    // ===== 聊天 =====
    GoRoute(
      path: RoutePaths.chatDetail,
      builder: (_, s) {
        final m = (s.extra as Map).cast<String, Object?>();
        return LiveHost(
          resizeToAvoidBottomInset: false,
          child: ChatScreen(
            conversationId: m['conversationId'] as int?,
            groupId: m['groupId'] as int?,
            peerId: (m['peerId'] as int?) ?? 0,
            peerName: (m['peerName'] as String?) ?? '',
            peerAvatar: (m['peerAvatar'] as String?) ?? '',
            groupName: (m['groupName'] as String?) ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.chatInfo,
      builder: (_, s) {
        final m = s.extra as Map;
        return LiveHost(
          child: ChatInfoScreen(
            peerId: m['peerId'] as int,
            peerName: m['peerName'] as String,
            peerAvatar: m['peerAvatar'] as String,
            conversationId: m['conversationId'] as int,
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.chatGroupSettings,
      // 群设置页会弹「修改群名称」输入框：键盘弹出时页面不压缩，
      // 键盘覆盖下半部分（与登录页一致），避免页面缩小出现上下分层。
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: GroupSettingsScreen(groupId: _id(s, 'id')),
      ),
    ),
    GoRoute(
      path: RoutePaths.chatGroupManage,
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: GroupMemberManageScreen(groupId: _id(s, 'id')),
      ),
    ),
    GoRoute(
      path: RoutePaths.chatBlocks,
      builder: (_, _) => LiveHost(child: const BlocksScreen()),
    ),
    GoRoute(
      path: RoutePaths.chatAddFriend,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const AddFriendScreen(),
      ),
    ),
    // ===== 活动 =====
    GoRoute(
      path: RoutePaths.activityList,
      builder: (_, _) => LiveHost(child: const ActivityListScreen()),
    ),
    GoRoute(
      path: RoutePaths.activityDetail,
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: ActivityDetailScreen(activityId: _id(s, 'id')),
      ),
    ),
    // ===== 门店 / 预约 =====
    GoRoute(
      path: RoutePaths.storeList,
      builder: (_, _) => LiveHost(child: const StoreListScreen()),
    ),
    GoRoute(
      path: RoutePaths.storeSearch,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const StoreSearchScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.storeCheckin,
      builder: (_, _) => LiveHost(child: const CheckinFlowScreen()),
    ),
    GoRoute(
      path: RoutePaths.storeTableSelect,
      builder: (_, s) {
        final m = s.extra as Map;
        return LiveHost(
          child: TableSelectScreen(
            store: m['store'] as Store,
            date: m['date'] as String,
            bookingType: m['bookingType'] as String,
            startTime: m['startTime'] as String,
            endTime: m['endTime'] as String,
            durationHours: m['durationHours'] as int,
            package: m['package'] as StorePackage?,
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.storeDetail,
      builder: (_, s) =>
          LiveHost(child: StoreDetailScreen(storeId: _id(s, 'id'))),
    ),
    GoRoute(
      path: RoutePaths.appointmentConfirm,
      builder: (_, s) {
        final m = s.extra as Map;
        return LiveHost(
          child: AppointmentConfirmScreen(
            type: m['type'] as String,
        store: m['store'] as Store?,
        activity: m['activity'] as Activity?,
        date: m['date'] as String,
        peopleCount: m['peopleCount'] as int,
        bookingType: (m['bookingType'] as String?) ?? 'hourly',
        startTime: (m['startTime'] as String?) ?? '',
        endTime: (m['endTime'] as String?) ?? '',
        durationHours: (m['durationHours'] as int?) ?? 0,
        packageName: (m['packageName'] as String?) ?? '',
        packageId: (m['packageId'] as int?),
        packagePrice: (m['packagePrice'] as num?)?.toDouble(),
        session: m['session'] as ActivitySession?,
        tableIds: ((m['tableIds'] as List?) ?? const <int>[]).cast<int>(),
        tableLabel: (m['tableLabel'] as String?) ?? '',
        note: (m['note'] as String?) ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.appointmentSuccess,
      builder: (_, s) => LiveHost(
        child: AppointmentSuccessScreen(appointment: s.extra as Appointment),
      ),
    ),
    GoRoute(
      path: RoutePaths.appointmentCheckinQr,
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: CheckinQrScreen(appointment: s.extra as Appointment),
      ),
    ),
    GoRoute(
      path: RoutePaths.appointmentServiceEnd,
      builder: (_, s) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: ServiceEndScreen(appointment: s.extra as Appointment),
      ),
    ),
    GoRoute(
      path: RoutePaths.appointmentMy,
      builder: (_, _) => LiveHost(child: const MyAppointmentsScreen()),
    ),
    GoRoute(
      path: RoutePaths.appointmentDetail,
      builder: (_, s) => LiveHost(
        child: AppointmentDetailScreen(appointmentId: _id(s, 'id')),
      ),
    ),
    // ===== 会员 =====
    GoRoute(
      path: RoutePaths.memberCenter,
      builder: (_, _) => LiveHost(child: const MemberCenterScreen()),
    ),
    GoRoute(
      path: RoutePaths.memberCoupons,
      builder: (_, _) => LiveHost(child: const CouponsScreen()),
    ),
    GoRoute(
      path: RoutePaths.memberCouponCenter,
      builder: (_, _) => LiveHost(child: const CouponCenterScreen()),
    ),
    GoRoute(
      path: RoutePaths.memberPurchase,
      builder: (_, s) => LiveHost(
        child: MemberPurchaseScreen(plan: s.extra as MemberPlan),
      ),
    ),
    // ===== 个人 =====
    GoRoute(
      path: RoutePaths.profileEdit,
      builder: (_, _) => LiveHost(
        resizeToAvoidBottomInset: false,
        child: const EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.profileSettings,
      builder: (_, _) => LiveHost(child: const SettingsScreen()),
    ),
    GoRoute(
      path: RoutePaths.profileLiked,
      builder: (_, _) => LiveHost(child: const LikedFavoritesScreen()),
    ),
    GoRoute(
      path: RoutePaths.profileHistory,
      builder: (_, _) => LiveHost(child: const WatchHistoryScreen()),
    ),
  ],
);

int _id(GoRouterState s, String name) => int.parse(s.pathParameters[name]!);
