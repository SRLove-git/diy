import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/appointment_api.dart';
import '../core/auth_service.dart';
import '../core/chat_api.dart';
import '../core/notification_api.dart';
import '../core/post_api.dart';
import '../features/home/presentation/palette.dart';
import '../features/member/presentation/member_plan_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'admin/admin_members_page.dart';
import 'admin/admin_notifications_page.dart';
import 'admin/admin_orders_page.dart';
import 'admin/admin_posts_page.dart';
import 'admin/admin_reports_page.dart';
import 'admin/admin_stores_page.dart';
import 'admin/admin_users_page.dart';
import 'booking/booking_flow_page.dart';
import 'checkin/my_checkin_qr_page.dart';
import 'checkin/scan_checkin_page.dart';
import 'checkin/service_timer_page.dart';
import 'community/post_detail_page.dart';
import 'home/coupon_center_page.dart';
import 'home/works_list_page.dart';
import 'notifications/notification_list_page.dart';

class MockProduct {
  const MockProduct({
    required this.name,
    required this.asset,
    required this.price,
    required this.likes,
    required this.collections,
  });

  final String name;
  final String asset;
  final double price;
  final int likes;
  final int collections;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.loadActiveAppointments = true});

  final bool loadActiveAppointments;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Appointment> _activeAppointments = [];
  int _unreadCount = 0;
  Timer? _tickTimer;
  Timer? _pollTimer;
  Timer? _unreadTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.loadActiveAppointments) return;
    _loadActiveAppointments();
    _loadUnreadCount();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted &&
          _activeAppointments.any(
            (appointment) =>
                appointment.status == 'in_service' &&
                appointment.serviceStartTime != null,
          )) {
        setState(() {});
      }
    });
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _loadActiveAppointments(),
    );
    _unreadTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadUnreadCount(),
    );
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _pollTimer?.cancel();
    _unreadTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationApi.fetchUnreadCount();
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (_) {
      // 未读数获取失败时保持上次角标，不阻塞首页
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationListPage()),
    );
    _loadUnreadCount();
  }

  Future<void> _loadActiveAppointments() async {
    try {
      final response = await ApiClient.instance.get('/appointments');
      if (!mounted) return;
      final appointments = (response.data as List)
          .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
          .where(
            (appointment) =>
                appointment.status == 'in_service' ||
                appointment.status == 'checked_in',
          )
          .toList();
      setState(() => _activeAppointments = appointments);
    } on DioException {
      // The home content remains available while the active service request fails.
    }
  }

  Future<void> _openActiveService(Appointment appointment) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceTimerPage(appointmentId: appointment.id),
      ),
    );
    _loadActiveAppointments();
  }

  void _openBooking() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BookingFlowPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.background,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) {
            final isAdmin = AuthService.instance.isAdmin;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    unreadCount: _unreadCount,
                    onNotifications: _openNotifications,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FeatureEntryRow(
                    isAdmin: isAdmin,
                    onBooking: _openBooking,
                    onStores: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminStoresPage(),
                      ),
                    ),
                    onCheckIn: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => isAdmin
                            ? const ScanCheckInPage()
                            : const MyCheckInQrPage(),
                      ),
                    ),
                    onMembership: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MemberPlanPage()),
                    ),
                    onOrders: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminOrdersPage(),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(child: ShortcutBar(isAdmin: isAdmin)),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PromoBanner(onTap: _openBooking),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 26)),
                SliverToBoxAdapter(
                  child: HotRecommendSection(
                    enabled: widget.loadActiveAppointments,
                  ),
                ),
                if (_activeAppointments.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: ActiveServiceSection(
                      appointments: _activeAppointments,
                      onTap: _openActiveService,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.unreadCount,
    required this.onNotifications,
  });

  final int unreadCount;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;
    final avatar = user?.avatar;
    final hasNetworkAvatar =
        avatar != null &&
        avatar.isNotEmpty &&
        (avatar.startsWith('http://') ||
            avatar.startsWith('https://') ||
            avatar.startsWith('/uploads/'));
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 15, 18, 19),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '拾染爱恋',
                  style: TextStyle(
                    color: HomePalette.primary,
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Color(0x33FF718D), offset: Offset(1, 1)),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '拼出美好 · 豆住快乐',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _NotificationButton(
            count: unreadCount,
            onTap: onNotifications,
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE9EF),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: hasNetworkAvatar
                  ? Image.network(
                      ChatApi.resolveUrl(avatar),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _AvatarFallback(),
                    )
                  : const Image(
                      image: AssetImage('assets/images/home/avatar.png'),
                      fit: BoxFit.cover,
                      errorBuilder: _AvatarFallback.errorBuilder,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  static Widget errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) =>
      const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFFFDCE5),
      child: Icon(Icons.person, color: HomePalette.primary),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 44,
      child: InkResponse(
        radius: 22,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Align(
              alignment: Alignment.bottomLeft,
              child: Icon(
                Icons.notifications_none_rounded,
                color: HomePalette.textPrimary,
                size: 28,
              ),
            ),
            if (count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: HomePalette.badgeRed,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FeatureEntryRow extends StatelessWidget {
  const FeatureEntryRow({
    super.key,
    required this.onBooking,
    required this.onStores,
    required this.onCheckIn,
    required this.onMembership,
    required this.onOrders,
    required this.isAdmin,
  });

  final VoidCallback onBooking;
  final VoidCallback onStores;
  final VoidCallback onCheckIn;
  final VoidCallback onMembership;
  final VoidCallback onOrders;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final entries = [
      if (isAdmin)
        _FeatureEntry(
          icon: Icons.storefront_rounded,
          colors: const [Color(0xFF6FC3FF), Color(0xFF3A97E8)],
          title: '门店管理',
          subtitle: '维护门店信息',
          onTap: onStores,
        )
      else
        _FeatureEntry(
          icon: Icons.event_available_rounded,
          colors: const [Color(0xFFFF9BB0), Color(0xFFFF6687)],
          title: '到店预约',
          subtitle: '预约手作时间',
          onTap: onBooking,
        ),
      _FeatureEntry(
        icon: isAdmin ? Icons.qr_code_scanner_rounded : Icons.qr_code_2_rounded,
        colors: const [Color(0xFFA895FF), Color(0xFF7563EC)],
        title: isAdmin ? '扫码核销' : '到店核销',
        subtitle: '快速开始制作',
        onTap: onCheckIn,
      ),
      if (isAdmin)
        _FeatureEntry(
          icon: Icons.receipt_long_rounded,
          colors: const [Color(0xFF5ED1B2), Color(0xFF2FA58A)],
          title: '订单管理',
          subtitle: '处理门店订单',
          onTap: onOrders,
        )
      else
        _FeatureEntry(
          icon: Icons.card_membership_rounded,
          colors: const [Color(0xFFFFCA68), Color(0xFFFFA62E)],
          title: '会员套餐',
          subtitle: '查看会员权益',
          onTap: onMembership,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = constraints.maxWidth < 350 ? 8.0 : 10.0;
          return Row(
            children: [
              for (var index = 0; index < entries.length; index++) ...[
                Expanded(child: _FeatureCard(entry: entries[index])),
                if (index != entries.length - 1) SizedBox(width: spacing),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FeatureEntry {
  const _FeatureEntry({
    required this.icon,
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.entry});

  final _FeatureEntry entry;

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: entry.onTap,
      child: Container(
        height: 152,
        padding: const EdgeInsets.fromLTRB(8, 22, 8, 15),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(245),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D7A4754),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            _GradientIcon(
              icon: entry.icon,
              colors: entry.colors,
              size: 48,
              iconSize: 25,
              radius: 11,
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                entry.title,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                entry.subtitle,
                maxLines: 1,
                style: const TextStyle(
                  color: HomePalette.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShortcutBar extends StatelessWidget {
  const ShortcutBar({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      final itemWidth =
          (MediaQuery.sizeOf(context).width - 24) / 3; // 与左右 padding 对齐，每行 3 个
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Wrap(
          runSpacing: 16,
          children: [
            for (final item in _adminShortcutData)
              SizedBox(
                width: itemWidth,
                child: _ShortcutItem(
                  entry: _ShortcutData(
                    icon: item.icon,
                    label: item.label,
                    colors: item.colors,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => item.page),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final items = [
      _ShortcutData(
        icon: Icons.auto_awesome_rounded,
        label: '新品推荐',
        colors: const [Color(0xFFFF8199), Color(0xFFFF506F)],
        onTap: () =>
            _push(context, const WorksListPage(mode: WorksListMode.latest)),
      ),
      _ShortcutData(
        icon: Icons.redeem_rounded,
        label: '领券中心',
        colors: const [Color(0xFFFFC05B), Color(0xFFFF9D29)],
        onTap: () => _push(context, const CouponCenterPage()),
      ),
      _ShortcutData(
        icon: Icons.workspace_premium_rounded,
        label: '会员专享',
        colors: const [Color(0xFFA37AFF), Color(0xFF774CE8)],
        onTap: () => _push(context, const MemberPlanPage()),
      ),
      _ShortcutData(
        icon: Icons.local_fire_department_rounded,
        label: '热门排行',
        colors: const [Color(0xFF83CCFF), Color(0xFF5799EC)],
        onTap: () => _push(context, const WorksListPage(mode: WorksListMode.hot)),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: items
            .map(
              (item) => Expanded(child: _ShortcutItem(entry: item)),
            )
            .toList(),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({
    required this.entry,
  });

  final _ShortcutData entry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: entry.label,
      child: InkResponse(
        radius: 34,
        onTap: entry.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GradientIcon(
              icon: entry.icon,
              colors: entry.colors,
              size: 46,
              iconSize: 23,
              radius: 23,
            ),
            const SizedBox(height: 10),
            Text(
              entry.label,
              maxLines: 1,
              style: const TextStyle(
                color: HomePalette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutData {
  const _ShortcutData({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;
}

class _AdminShortcutData {
  const _AdminShortcutData({
    required this.icon,
    required this.label,
    required this.colors,
    required this.page,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final Widget page;
}

const _adminShortcutData = [
  _AdminShortcutData(
    icon: Icons.dashboard_rounded,
    label: '数据看板',
    colors: [Color(0xFF6EC6FF), Color(0xFF3E9BE0)],
    page: AdminDashboardPage(),
  ),
  _AdminShortcutData(
    icon: Icons.article_rounded,
    label: '作品审核',
    colors: [Color(0xFFFF9BB0), Color(0xFFFF6687)],
    page: AdminPostsPage(),
  ),
  _AdminShortcutData(
    icon: Icons.people_rounded,
    label: '用户管理',
    colors: [Color(0xFFA895FF), Color(0xFF7563EC)],
    page: AdminUsersPage(),
  ),
  _AdminShortcutData(
    icon: Icons.report_rounded,
    label: '举报处理',
    colors: [Color(0xFFFF8A80), Color(0xFFFF5C4D)],
    page: AdminReportsPage(),
  ),
  _AdminShortcutData(
    icon: Icons.notifications_rounded,
    label: '通知管理',
    colors: [Color(0xFF83CCFF), Color(0xFF5799EC)],
    page: AdminNotificationsPage(),
  ),
  _AdminShortcutData(
    icon: Icons.card_membership_rounded,
    label: '会员运营',
    colors: [Color(0xFFA37AFF), Color(0xFF774CE8)],
    page: AdminMembersPage(),
  ),
];

class _GradientIcon extends StatelessWidget {
  const _GradientIcon({
    required this.icon,
    required this.colors,
    required this.size,
    required this.iconSize,
    required this.radius,
  });

  final IconData icon;
  final List<Color> colors;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors.last.withAlpha(45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: SizedBox(
        height: (MediaQuery.sizeOf(context).width * 0.42).clamp(158.0, 170.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFDEE6), Color(0xFFFFF4F2)],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      width: constraints.maxWidth * 0.48,
                      child: Image.asset(
                        'assets/images/home/banner_art.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFDEE6),
                              const Color(0xFFFFDEE6).withAlpha(210),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.48, 0.72],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        constraints.maxWidth < 350 ? 18 : 22,
                        14,
                        constraints.maxWidth * 0.39,
                        12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '创意拼豆手作工坊',
                              maxLines: 1,
                              style: TextStyle(
                                color: Color(0xFF292529),
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            '拼出你的独特创意',
                            style: TextStyle(
                              color: Color(0xFF6F686B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '¥39.9 / 次起',
                            style: TextStyle(
                              color: HomePalette.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Container(
                            height: 31,
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: HomePalette.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              '立即预约',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HotRecommendSection extends StatefulWidget {
  const HotRecommendSection({super.key, this.enabled = true});

  /// 是否加载远程数据（关闭时仅展示内置示例，供测试/离线使用）
  final bool enabled;

  @override
  State<HotRecommendSection> createState() => _HotRecommendSectionState();
}

class _HotRecommendSectionState extends State<HotRecommendSection> {
  List<HomeWorkItem> _works = [];

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _load();
  }

  Future<void> _load() async {
    try {
      final result = await PostApi.fetchHot(page: 1);
      if (!mounted) return;
      setState(() {
        _works = result.items
            .take(6)
            .map(HomeWorkItem.fromPost)
            .where((item) => item.cover.isNotEmpty)
            .toList();
      });
    } catch (_) {
      // 接口不可用时回退到内置示例
    }
  }

  void _openMore() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorksListPage(mode: WorksListMode.hot)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useMock = _works.isEmpty;
    final count = useMock ? _mockProducts.length : _works.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '热门推荐',
                  style: TextStyle(
                    color: Color(0xFF252525),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openMore,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  child: Row(
                    children: [
                      Text(
                        '查看更多',
                        style: TextStyle(
                          color: HomePalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: HomePalette.textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 214,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: count,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => useMock
                ? ProductCard(product: _mockProducts[index], index: index)
                : WorkCard(work: _works[index]),
          ),
        ),
      ],
    );
  }
}

/// 首页热门推荐卡片数据（由社区作品映射而来）
class HomeWorkItem {
  const HomeWorkItem({
    required this.id,
    required this.title,
    required this.cover,
    required this.authorName,
    required this.likes,
    required this.collections,
  });

  final int id;
  final String title;
  final String cover;
  final String authorName;
  final int likes;
  final int collections;

  factory HomeWorkItem.fromPost(Post post) {
    final mediaList = post.medias.isNotEmpty
        ? post.medias
        : post.images
            .map(
              (url) => PostMedia(type: 'image', url: url, aspectRatio: 4 / 5),
            )
            .toList();
    final cover = mediaList.isEmpty ? '' : ChatApi.resolveUrl(mediaList.first.url);
    return HomeWorkItem(
      id: post.id,
      title: post.content.isEmpty ? post.title : post.content,
      cover: cover,
      authorName: post.author?.nickname ?? '用户 #${post.userId}',
      likes: post.likeCount,
      collections: post.collectCount,
    );
  }
}

class WorkCard extends StatelessWidget {
  const WorkCard({super.key, required this.work});

  final HomeWorkItem work;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width * 0.30).clamp(
      112.0,
      132.0,
    );
    return _TapScale(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostDetailPage(postId: work.id),
          ),
        );
      },
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                work.cover,
                width: cardWidth,
                height: 126,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: cardWidth,
                  height: 126,
                  color: const Color(0xFFF6F1F2),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFC9C1C3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              work.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF343034),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              work.authorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6F6A6D),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 14,
                  color: Color(0xFFA8A2A5),
                ),
                const SizedBox(width: 2),
                Text(
                  _formatCount(work.collections),
                  style: const TextStyle(
                    color: Color(0xFFA8A2A5),
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 14,
                  color: Color(0xFFE49AA9),
                ),
                const SizedBox(width: 2),
                Text(
                  _formatCount(work.likes),
                  style: const TextStyle(
                    color: Color(0xFFA8A2A5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.index});

  final MockProduct product;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width * 0.30).clamp(
      112.0,
      132.0,
    );
    return _TapScale(
      onTap: () {},
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                product.asset,
                width: cardWidth,
                height: 126,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: cardWidth,
                  height: 126,
                  color: const Color(0xFFF6F1F2),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFC9C1C3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF343034),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '¥${product.price.toStringAsFixed(1)} 起',
              style: const TextStyle(
                color: Color(0xFF6F6A6D),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 14,
                  color: Color(0xFFA8A2A5),
                ),
                const SizedBox(width: 2),
                Text(
                  _formatCount(product.collections),
                  style: const TextStyle(
                    color: Color(0xFFA8A2A5),
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 14,
                  color: Color(0xFFE49AA9),
                ),
                const SizedBox(width: 2),
                Text(
                  _formatCount(product.likes),
                  style: const TextStyle(
                    color: Color(0xFFA8A2A5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const _mockProducts = [
  MockProduct(
    name: '库洛米系列',
    asset: 'assets/images/home/product_kuromi.png',
    price: 39.9,
    likes: 128,
    collections: 128,
  ),
  MockProduct(
    name: '星之卡比系列',
    asset: 'assets/images/home/product_kirby.png',
    price: 39.9,
    likes: 96,
    collections: 96,
  ),
  MockProduct(
    name: '花花系列',
    asset: 'assets/images/home/product_flower.png',
    price: 39.9,
    likes: 76,
    collections: 36,
  ),
  MockProduct(
    name: '可爱萌宠系列',
    asset: 'assets/images/home/product_pet.png',
    price: 39.9,
    likes: 86,
    collections: 58,
  ),
];

class ActiveServiceSection extends StatelessWidget {
  const ActiveServiceSection({
    super.key,
    required this.appointments,
    required this.onTap,
  });

  final List<Appointment> appointments;
  final ValueChanged<Appointment> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '进行中的服务',
            style: TextStyle(
              color: Color(0xFF252525),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final appointment in appointments)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ActiveServiceCard(
                appointment: appointment,
                elapsed: appointment.serviceStartTime == null
                    ? Duration.zero
                    : DateTime.now().difference(
                        DateTime.parse(appointment.serviceStartTime!),
                      ),
                onTap: () => onTap(appointment),
              ),
            ),
        ],
      ),
    );
  }
}

class ActiveServiceCard extends StatelessWidget {
  const ActiveServiceCard({
    super.key,
    required this.appointment,
    required this.elapsed,
    required this.onTap,
  });

  final Appointment appointment;
  final Duration elapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inService = appointment.status == 'in_service';
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F7A4754),
              blurRadius: 16,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: inService
                    ? const Color(0xFFEAF9F1)
                    : const Color(0xFFFFEFF3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                inService ? Icons.timer_outlined : Icons.login_rounded,
                color: inService
                    ? const Color(0xFF22A866)
                    : HomePalette.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: HomePalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${appointment.date} ${appointment.startTime}-${appointment.endTime} · ${appointment.tableName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: HomePalette.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              inService ? _formatDuration(elapsed) : '待上钟',
              style: TextStyle(
                color: inService
                    ? const Color(0xFF22A866)
                    : HomePalette.primary,
                fontSize: inService ? 14 : 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: HomePalette.textSecondary,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class _TapScale extends StatefulWidget {
  const _TapScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String _formatCount(int count) {
  if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}w';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return '$count';
}
