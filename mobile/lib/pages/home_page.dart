import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/api_client.dart';
import '../core/appointment_api.dart';
import '../core/auth_service.dart';
import '../core/chat_api.dart';
import '../core/chat_service.dart';
import '../core/notification_api.dart';
import '../core/post_api.dart';
import '../core/service_events.dart';
import '../features/home/presentation/palette.dart';
import '../features/member/presentation/member_plan_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'admin/admin_members_page.dart';
import 'admin/admin_notifications_page.dart';
import 'admin/admin_orders_page.dart';
import 'admin/admin_posts_page.dart';
import 'admin/admin_stores_page.dart';
import 'admin/admin_users_page.dart';
import 'booking/booking_flow_page.dart';
import 'checkin/my_checkin_qr_page.dart';
import 'checkin/scan_checkin_page.dart';
import 'checkin/service_timer_page.dart';
import 'community/post_detail_page.dart';
import 'home/activity_zone_page.dart';
import 'home/coupon_center_page.dart';
import 'home/works_list_page.dart';
import 'notifications/notification_list_page.dart';
import 'profile/order_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.loadActiveAppointments = true});

  final bool loadActiveAppointments;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<Appointment> _activeAppointments = [];
  int _unreadCount = 0;
  int _sectionIndex = 0;
  Timer? _tickTimer;
  Timer? _pollTimer;
  Timer? _unreadTimer;
  StreamSubscription<ChatEvent>? _chatSub;
  StreamSubscription<int>? _serviceSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 收到平台通知实时事件：立即刷新未读角标，不等 30s 轮询
    _chatSub = ChatService.instance.events.listen((event) {
      if (event is NotificationEvent) _loadUnreadCount();
    });
    // 下钟成功后立即移除「服务中」卡片（乐观更新），不等 3s 轮询
    _serviceSub = ServiceEvents.ended.listen(_onServiceEnded);
    if (!widget.loadActiveAppointments) return;
    _loadActiveAppointments();
    _loadUnreadCount();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      final expiredIds = _activeAppointments
          .where((appointment) => _slotEnded(appointment, now))
          .map((appointment) => appointment.id)
          .toSet();
      if (expiredIds.isNotEmpty) {
        // 预约时段到点：乐观移除「服务中」卡片，与服务端自动下钟规则一致
        setState(() {
          _activeAppointments.removeWhere(
            (appointment) => expiredIds.contains(appointment.id),
          );
        });
      } else if (_activeAppointments.any(
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
    WidgetsBinding.instance.removeObserver(this);
    _chatSub?.cancel();
    _tickTimer?.cancel();
    _pollTimer?.cancel();
    _unreadTimer?.cancel();
    _serviceSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从后台回到前台：刷新未读角标（后台推送期间不触发轮询）
    if (state == AppLifecycleState.resumed) _loadUnreadCount();
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

  void _onServiceEnded(int appointmentId) {
    if (!mounted) return;
    setState(() {
      _activeAppointments.removeWhere((a) => a.id == appointmentId);
    });
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
      final now = DateTime.now();
      final appointments = (response.data as List)
          .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
          .where((appointment) {
            // 预约时段已结束：乐观视为已下钟（服务端稍后自动置为已完成），
            // 避免被下一次轮询结果重新加回首页。
            if (_slotEnded(appointment, now)) return false;
            return appointment.status == 'in_service' ||
                appointment.status == 'checked_in';
          })
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

  /// 预约时段结束时刻（date + endTime，按设备本地时区），与服务端自动下钟规则一致
  DateTime? _scheduledEnd(Appointment appointment) =>
      DateTime.tryParse('${appointment.date}T${appointment.endTime}:00');

  /// 预约时段是否已到点（in_service 且当前时间 >= endTime）
  bool _slotEnded(Appointment appointment, DateTime now) {
    if (appointment.status != 'in_service') return false;
    final end = _scheduledEnd(appointment);
    return end != null && !now.isBefore(end);
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
                  child: HomeSectionSwitcher(
                    index: _sectionIndex,
                    onChanged: (index) =>
                        setState(() => _sectionIndex = index),
                  ),
                ),
                if (_sectionIndex == 0) ...[
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
                        MaterialPageRoute(
                          builder: (_) => const MemberPlanPage(),
                        ),
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
                  if (_activeAppointments.isNotEmpty) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                    SliverToBoxAdapter(
                      child: ActiveServiceSection(
                        appointments: _activeAppointments,
                        onTap: _openActiveService,
                      ),
                    ),
                  ],
                ] else ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverToBoxAdapter(child: ComingSoonSection()),
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

/// 首页顶部板块切换（拼豆 / 敬请期待）
class HomeSectionSwitcher extends StatelessWidget {
  const HomeSectionSwitcher({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _tabs = ['拼豆', '敬请期待'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: _SectionTab(
                  label: _tabs[i],
                  selected: index == i,
                  onTap: () => onChanged(i),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTab extends StatelessWidget {
  const _SectionTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? HomePalette.textPrimary
                  : HomePalette.textSecondary,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// 「敬请期待」占位板块：浅色卡片 + 一句话，不引导、不给按钮
class ComingSoonSection extends StatelessWidget {
  const ComingSoonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3F4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: Color(0xFFD9A2B2),
            ),
            SizedBox(height: 16),
            Text(
              '敬请期待',
              style: TextStyle(
                color: Color(0xFF6F686B),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '更多精彩 DIY 手作板块正在筹备中',
              style: TextStyle(
                color: Color(0xFFA8A2A5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instagram 风格渐变字标（橙 → 粉 → 紫 → 蓝）
                ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFFEDA75),
                      Color(0xFFFA7E1E),
                      Color(0xFFD62976),
                      Color(0xFF962FBF),
                      Color(0xFF4F5BD5),
                    ],
                  ).createShader(rect),
                  child: const Text(
                    'IDOL BEADS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
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
              color: Palette.accentLight,
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
      color: Palette.accentLight,
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
          colors: const [Color(0xFF4F5BD5), Color(0xFF0095F6)],
          title: '门店管理',
          subtitle: '维护门店信息',
          onTap: onStores,
        )
      else
        _FeatureEntry(
          icon: Icons.event_available_rounded,
          colors: const [Color(0xFFFA7E1E), Color(0xFFD62976)],
          title: '到店预约',
          subtitle: '预约手作时间',
          onTap: onBooking,
        ),
      _FeatureEntry(
        icon: isAdmin ? Icons.qr_code_scanner_rounded : Icons.qr_code_2_rounded,
        colors: const [Color(0xFFD62976), Color(0xFF962FBF)],
        title: isAdmin ? '扫码核销' : '到店核销',
        subtitle: '快速开始制作',
        onTap: onCheckIn,
      ),
      if (isAdmin)
        _FeatureEntry(
          icon: Icons.receipt_long_rounded,
          colors: const [Color(0xFF0095F6), Color(0xFF4F5BD5)],
          title: '订单管理',
          subtitle: '处理门店订单',
          onTap: onOrders,
        )
      else
        _FeatureEntry(
          icon: Icons.card_membership_rounded,
          colors: const [Color(0xFF962FBF), Color(0xFF4F5BD5)],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Palette.primary, width: 1),
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
        icon: Icons.receipt_long_rounded,
        label: '我的订单',
        colors: const [Color(0xFFD62976), Color(0xFF962FBF)],
        onTap: () => _push(context, const OrderListPage()),
      ),
      _ShortcutData(
        icon: Icons.redeem_rounded,
        label: '领券中心',
        colors: const [Color(0xFFFEDA75), Color(0xFFFA7E1E)],
        onTap: () => _push(context, const CouponCenterPage()),
      ),
      _ShortcutData(
        icon: Icons.celebration_rounded,
        label: '活动专区',
        colors: const [Color(0xFF962FBF), Color(0xFF4F5BD5)],
        onTap: () => _push(context, const ActivityZonePage()),
      ),
      _ShortcutData(
        icon: Icons.local_fire_department_rounded,
        label: '热门排行',
        colors: const [Color(0xFF4F5BD5), Color(0xFF0095F6)],
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
    label: '社区管理',
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
      // 接口不可用时保持空态，不再展示本地假数据
    }
  }

  void _openMore() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorksListPage(mode: WorksListMode.hot)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        if (_works.isEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspaces_outline,
                    size: 30,
                    color: Color(0xFFC9C1C3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '暂无热门作品，去社区逛逛吧',
                    style: TextStyle(
                      color: Color(0xFFA8A2A5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 214,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _works.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  WorkCard(work: _works[index]),
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
    var mediaList = post.medias
        .where((m) => m.url.trim().isNotEmpty)
        .toList();
    if (mediaList.isEmpty) {
      mediaList = post.images
          .where((url) => url.trim().isNotEmpty)
          .map(
            (url) => PostMedia(type: 'image', url: url, aspectRatio: 4 / 5),
          )
          .toList();
    }
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
            if (work.cover.isNotEmpty)
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
              )
            else
              Container(
                width: cardWidth,
                height: 126,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Palette.iconBgOrange, Palette.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 14,
                          color: Palette.accent,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '纯文字',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Palette.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      work.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF3D3836),
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                    appointment.type == 'activity'
                        ? '${appointment.date} ${appointment.startTime}-${appointment.endTime} · 活动'
                        : '${appointment.date} ${appointment.startTime}-${appointment.endTime} · ${appointment.tableName}',
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
