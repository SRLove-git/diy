import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/auth_store.dart';
import '../api/models.dart';
import 'live_routes.dart';
import 'live_theme.dart';
import 'live_widgets.dart';
import 'screens/activity_screens.dart';
import 'screens/appointment_screens.dart';
import 'screens/auth_screens.dart';
import 'screens/chat_screens.dart';
import 'screens/community_screens.dart';
import 'screens/home_screen.dart';
import 'screens/member_screens.dart';
import 'screens/notifications_screen.dart';
import 'screens/post_screens.dart';
import 'screens/profile_screens.dart';
import 'screens/store_screens.dart';
import 'screens/video_screens.dart';

/// 底部 Tab 快速连续切换的防抖时间戳。
DateTime? _lastTabTap;

/// 手作星球路由表。
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
      builder: (_, __) => const LiveHost(
        child: Center(
          child: CircularProgressIndicator(color: LiveColors.brand),
        ),
      ),
    ),
    // ===== 登录 / 注册 =====
    GoRoute(
      path: RoutePaths.login,
      builder: (_, __) =>
          LiveHost(child: const LoginScreen(), resizeToAvoidBottomInset: false),
    ),
    GoRoute(
      path: RoutePaths.loginPassword,
      builder: (_, __) => LiveHost(
        child: const PasswordLoginScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.loginSetPassword,
      builder: (_, __) => LiveHost(
        child: const SetPasswordScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.loginVerify,
      builder: (_, __) => LiveHost(
        child: const VerifyCodeScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    // ===== 底部 5 Tab（保活） =====
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => LiveHost(
        child: Column(
          children: [
            Expanded(child: navigationShell),
            LiveTabBar(
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
                navigationShell.goBranch(i, initialLocation: false);
              },
            ),
          ],
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (_, __) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.community,
              builder: (_, __) => const CommunityHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.reels,
              builder: (_, __) => const ReelsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.chat,
              builder: (_, __) => const ConversationListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.profile,
              builder: (_, __) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // ===== 通用 =====
    GoRoute(
      path: RoutePaths.search,
      // 搜索页有输入框：键盘弹出时页面不压缩，键盘覆盖下半部分。
      builder: (_, __) => LiveHost(
        child: const SearchScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.notifications,
      builder: (_, __) => LiveHost(child: const NotificationsScreen()),
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
      builder: (_, __) => LiveHost(
        child: const PostPublishScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.postPublishSuccess,
      builder: (_, s) => LiveHost(
        child: PostPublishSuccessScreen(post: s.extra as Post),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.postDetail,
      builder: (_, s) => LiveHost(
        child: PostDetailScreen(postId: _id(s, 'id')),
        resizeToAvoidBottomInset: false,
      ),
    ),
    // ===== 视频 =====
    GoRoute(
      path: RoutePaths.videoSearch,
      builder: (_, __) => LiveHost(
        child: const VideoSearchScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.videoCapture,
      builder: (_, __) => LiveHost(child: const CaptureScreen()),
    ),
    GoRoute(
      path: RoutePaths.videoPublish,
      builder: (_, s) => LiveHost(
        child: VideoPublishScreen(initialCover: s.extra as String),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.videoMusic,
      builder: (_, __) => LiveHost(
        child: const MusicPickerScreen(),
        resizeToAvoidBottomInset: false,
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
        child: VideoDetailScreen(videoId: _id(s, 'id')),
        resizeToAvoidBottomInset: false,
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
        child: GroupSettingsScreen(groupId: _id(s, 'id')),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.chatGroupManage,
      builder: (_, s) => LiveHost(
        child: GroupMemberManageScreen(groupId: _id(s, 'id')),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.chatBlocks,
      builder: (_, __) => LiveHost(child: const BlocksScreen()),
    ),
    GoRoute(
      path: RoutePaths.chatAddFriend,
      builder: (_, __) => LiveHost(
        child: const AddFriendScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    // ===== 活动 =====
    GoRoute(
      path: RoutePaths.activityList,
      builder: (_, __) => LiveHost(child: const ActivityListScreen()),
    ),
    GoRoute(
      path: RoutePaths.activityDetail,
      builder: (_, s) => LiveHost(
        child: ActivityDetailScreen(activityId: _id(s, 'id')),
        resizeToAvoidBottomInset: false,
      ),
    ),
    // ===== 门店 / 预约 =====
    GoRoute(
      path: RoutePaths.storeList,
      builder: (_, __) => LiveHost(child: const StoreListScreen()),
    ),
    GoRoute(
      path: RoutePaths.storeSearch,
      builder: (_, __) => LiveHost(
        child: const StoreSearchScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.storeCheckin,
      builder: (_, __) => LiveHost(child: const CheckinFlowScreen()),
    ),
    GoRoute(
      path: RoutePaths.storeTableSelect,
      builder: (_, s) {
        final m = s.extra as Map;
        return LiveHost(
          child: TableSelectScreen(
            store: m['store'] as Store,
            date: m['date'] as String,
            slot: m['slot'] as TimeSlot,
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
            slot: m['slot'] as TimeSlot?,
            session: m['session'] as ActivitySession?,
            table: m['table'] as StoreTable?,
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
        child: CheckinQrScreen(appointment: s.extra as Appointment),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.appointmentMy,
      builder: (_, __) => LiveHost(child: const MyAppointmentsScreen()),
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
      builder: (_, __) => LiveHost(child: const MemberCenterScreen()),
    ),
    GoRoute(
      path: RoutePaths.memberCoupons,
      builder: (_, __) => LiveHost(child: const CouponsScreen()),
    ),
    GoRoute(
      path: RoutePaths.memberCouponCenter,
      builder: (_, __) => LiveHost(child: const CouponCenterScreen()),
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
      builder: (_, __) => LiveHost(
        child: const EditProfileScreen(),
        resizeToAvoidBottomInset: false,
      ),
    ),
    GoRoute(
      path: RoutePaths.profileSettings,
      builder: (_, __) => LiveHost(child: const SettingsScreen()),
    ),
    GoRoute(
      path: RoutePaths.profileLiked,
      builder: (_, __) => LiveHost(child: const LikedFavoritesScreen()),
    ),
    GoRoute(
      path: RoutePaths.profileHistory,
      builder: (_, __) => LiveHost(child: const WatchHistoryScreen()),
    ),
  ],
);

int _id(GoRouterState s, String name) => int.parse(s.pathParameters[name]!);
