import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/appointment_api.dart';
import '../core/auth_service.dart';
import 'admin/admin_dashboard_page.dart';
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

// ────────────────────────────────────────────
// 页面专属配色（简洁年轻风）
// ────────────────────────────────────────────
const _accent = Color(0xFFFF6B6B);
const _bgLight = Color(0xFFF8F9FC);
const _textDark = Color(0xFF1A1A2E);
const _textHint = Color(0xFFA0A0B0);
const _cardWhite = Colors.white;

/// 快捷功能的多彩配色
const _shortcutColors = [
  Color(0xFFFF6B6B),
  Color(0xFF4ECDC4),
  Color(0xFFFFB347),
  Color(0xFF7C6FF7),
  Color(0xFF45B7D1),
  Color(0xFFF7DC6F),
  Color(0xFF26DE81),
  Color(0xFFFC5C65),
];

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  List<Appointment> _activeAppts = [];
  Timer? _tickTimer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadActive();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted &&
          _activeAppts.any(
            (a) => a.status == 'in_service' && a.serviceStartTime != null,
          )) {
        setState(() {});
      }
    });
    _pollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _loadActive());
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActive() async {
    try {
      final resp = await ApiClient.instance.get('/appointments');
      if (!mounted) return;
      final active = (resp.data as List)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .where((a) => a.status == 'in_service' || a.status == 'checked_in')
          .toList();
      setState(() => _activeAppts = active);
    } on DioException {
      // 忽略
    }
  }

  Future<void> _openActiveService(Appointment appt) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceTimerPage(appointmentId: appt.id),
      ),
    );
    _loadActive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) {
            final isAdmin = AuthService.instance.isAdmin;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 1. 顶部 Banner
                  _TopBanner(
                    tabIndex: _tabIndex,
                    onTabChanged: (i) => setState(() => _tabIndex = i),
                    onBooking: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BookingFlowPage(),
                      ),
                    ),
                    onCheckIn: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => isAdmin
                            ? const ScanCheckInPage()
                            : const MyCheckInQrPage(),
                      ),
                    ),
                    isAdmin: isAdmin,
                    checkInLabel: isAdmin ? '扫码核销' : '到店核销',
                  ),

                  const SizedBox(height: 20),

                  // 2. 快捷功能区域
                  const _ShortcutBar(),

                  const SizedBox(height: 20),

                  // 3. 商品广告 Banner
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _ProductAdBanner(),
                  ),

                  const SizedBox(height: 24),

                  // 4. 管理员入口
                  if (isAdmin) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('管理后台'),
                          const SizedBox(height: 12),
                          _AdminEntryGrid(
                            onTap: (page) => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => page),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 5. 进行中的服务
                  if (_activeAppts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('进行中的服务'),
                          const SizedBox(height: 12),
                          for (final appt in _activeAppts) ...[
                            _ActiveServiceCard(
                              appt: appt,
                              inService: appt.status == 'in_service',
                              elapsed: appt.serviceStartTime != null
                                  ? DateTime.now().difference(
                                      DateTime.parse(appt.serviceStartTime!),
                                    )
                                  : Duration.zero,
                              onTap: () => _openActiveService(appt),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 区块小标题
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: _textDark,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ════════════════════════════════════════════
// 1. 顶部 Banner
// ════════════════════════════════════════════

class _TopBanner extends StatelessWidget {
  const _TopBanner({
    required this.tabIndex,
    required this.onTabChanged,
    required this.onBooking,
    required this.onCheckIn,
    required this.isAdmin,
    required this.checkInLabel,
  });

  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onBooking;
  final VoidCallback onCheckIn;
  final bool isAdmin;
  final String checkInLabel;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth > 600 ? 320.0 : 280.0;

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        children: [
          // 柔和渐变背景 + 装饰圆
          const _SoftGradientBg(),
          // 顶部切换按钮
          Positioned(
            top: 14,
            left: 16,
            child: _BannerToggle(
              tabIndex: tabIndex,
              onChanged: onTabChanged,
            ),
          ),
          // 底部入口卡片
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _BannerEntry(
                      icon: Icons.calendar_month_rounded,
                      label: '到店预约',
                      onTap: onBooking,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BannerEntry(
                      icon: isAdmin
                          ? Icons.qr_code_scanner_rounded
                          : Icons.store_rounded,
                      label: checkInLabel,
                      onTap: onCheckIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _BannerEntry(
                      icon: Icons.card_membership_rounded,
                      label: '会员套餐',
                      onTap: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 柔和渐变背景
class _SoftGradientBg extends StatelessWidget {
  const _SoftGradientBg();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return ClipRect(
          child: Stack(
            children: [
              // 柔和渐变
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8DDF5),
                      Color(0xFFF0E6F6),
                      Color(0xFFFDE8EC),
                      Color(0xFFFFF0E8),
                    ],
                  ),
                ),
              ),
              // 装饰性大圆
              Positioned(
                right: -40,
                top: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                left: -60,
                bottom: 20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7C6FF7).withValues(alpha: 0.06),
                  ),
                ),
              ),
              // 小装饰点
              ...List.generate(8, (i) {
                final rng = math.Random(i * 13);
                return Positioned(
                  left: rng.nextDouble() * w * 0.8,
                  top: rng.nextDouble() * h * 0.5,
                  child: Container(
                    width: 4 + rng.nextDouble() * 4,
                    height: 4 + rng.nextDouble() * 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// 切换按钮
class _BannerToggle extends StatelessWidget {
  const _BannerToggle({required this.tabIndex, required this.onChanged});

  final int tabIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: '拼豆',
            active: tabIndex == 0,
            onTap: () => onChanged(0),
          ),
          _ToggleChip(
            label: '敬请期待',
            active: tabIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: active
            ? BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? _textDark : Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

/// 入口卡片
class _BannerEntry extends StatelessWidget {
  const _BannerEntry({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: _textDark),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// 2. 快捷功能
// ════════════════════════════════════════════

class _ShortcutBar extends StatefulWidget {
  const _ShortcutBar();

  @override
  State<_ShortcutBar> createState() => _ShortcutBarState();
}

class _ShortcutBarState extends State<_ShortcutBar> {
  int _pageIndex = 0;

  static const _pages = [
    [
      (icon: Icons.auto_awesome_rounded, label: '新品推荐'),
      (icon: Icons.card_giftcard_rounded, label: '领券中心'),
      (icon: Icons.star_rounded, label: '会员专享'),
      (icon: Icons.local_fire_department_rounded, label: '热销排行'),
    ],
    [
      (icon: Icons.palette_rounded, label: '创意素材'),
      (icon: Icons.menu_book_rounded, label: '教程指南'),
      (icon: Icons.emoji_events_rounded, label: '作品大赛'),
      (icon: Icons.grid_view_rounded, label: '全部项目'),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(
              _pages[_pageIndex].length,
              (i) {
                final item = _pages[_pageIndex][i];
                return Expanded(
                  child: _ShortcutItem(
                    icon: item.icon,
                    label: item.label,
                    color: _shortcutColors[i % _shortcutColors.length],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) {
            final active = i == _pageIndex;
            return GestureDetector(
              onTap: () => setState(() => _pageIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 5,
                decoration: BoxDecoration(
                  color: active ? _accent : const Color(0xFFDDDDE0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// 3. 商品广告 Banner
// ════════════════════════════════════════════

class _ProductAdBanner extends StatelessWidget {
  const _ProductAdBanner();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = cardWidth * 0.72 > 500 ? 500.0 : cardWidth * 0.72;
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        return Container(
          width: cardWidth,
          height: isLandscape ? 280 : cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D2D44), Color(0xFF43436A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D2D44).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 装饰圆
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withValues(alpha: 0.1),
                  ),
                ),
              ),
              // 右侧产品图片
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: cardWidth * 0.48,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    'https://picsum.photos/seed/beads/400/500',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF3A3A55),
                      child: const Center(
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 56,
                          color: Color(0xFFFFB347),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 左侧渐变遮罩
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: cardWidth * 0.58,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2D2D44),
                        const Color(0xFF2D2D44).withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // 左侧文字
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '热门',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '创意拼豆\n手作工坊',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape ? 18 : 24,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '¥39.9 / 次起',
                      style: TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        '立即预约',
                        style: TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════
// 原有：管理后台宫格
// ════════════════════════════════════════════

class _AdminEntryGrid extends StatelessWidget {
  const _AdminEntryGrid({required this.onTap});

  final ValueChanged<Widget> onTap;

  static const _entries = [
    (icon: Icons.dashboard_outlined, label: '数据看板', page: AdminDashboardPage()),
    (icon: Icons.store_outlined, label: '门店管理', page: AdminStoresPage()),
    (icon: Icons.receipt_long_outlined, label: '订单管理', page: AdminOrdersPage()),
    (icon: Icons.article_outlined, label: '作品审核', page: AdminPostsPage()),
    (icon: Icons.people_outline, label: '用户管理', page: AdminUsersPage()),
    (icon: Icons.report_outlined, label: '举报处理', page: AdminReportsPage()),
    (icon: Icons.notifications_outlined, label: '通知管理', page: AdminNotificationsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, i) {
        final e = _entries[i];
        return Material(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => onTap(e.page),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(e.icon, size: 26, color: _textDark),
                const SizedBox(height: 8),
                Text(
                  e.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════
// 原有：进行中的服务卡片
// ════════════════════════════════════════════

class _ActiveServiceCard extends StatelessWidget {
  const _ActiveServiceCard({
    required this.appt,
    required this.inService,
    required this.elapsed,
    required this.onTap,
  });

  final Appointment appt;
  final bool inService;
  final Duration elapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: inService
                        ? const Color(0xFF26DE81).withValues(alpha: 0.12)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    inService ? Icons.timer_outlined : Icons.login_rounded,
                    color: inService ? const Color(0xFF20B868) : _textDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.storeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${appt.date} ${appt.startTime}-${appt.endTime} · 桌位 ${appt.tableName}',
                        style: const TextStyle(color: _textHint, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (inService) ...[
                      Text(
                        _formatDuration(elapsed),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20B868),
                          letterSpacing: 1,
                        ),
                      ),
                      const Text(
                        '服务中',
                        style: TextStyle(color: _textHint, fontSize: 12),
                      ),
                    ] else ...[
                      const Text(
                        '已核销',
                        style: TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        '待上钟',
                        style: TextStyle(color: _textHint, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: _textHint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
