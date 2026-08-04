import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/appointment_api.dart';
import '../core/auth_service.dart';
import '../features/home/presentation/palette.dart';
import '../features/member/presentation/member_plan_page.dart';
import 'booking/booking_flow_page.dart';
import 'checkin/my_checkin_qr_page.dart';
import 'checkin/scan_checkin_page.dart';
import 'checkin/service_timer_page.dart';

// ════════════════════════════════════════════════
// 点击缩放动画包装器
// ════════════════════════════════════════════════

class _TapScaleBounce extends StatefulWidget {
  const _TapScaleBounce({required this.child, this.onTap, this.scale = 0.96});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<_TapScaleBounce> createState() => _TapScaleBounceState();
}

class _TapScaleBounceState extends State<_TapScaleBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _anim = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => Transform.scale(scale: _anim.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ════════════════════════════════════════════════
// Mock 商品数据模型
// ════════════════════════════════════════════════

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

// ════════════════════════════════════════════════
// HomePage
// ════════════════════════════════════════════════

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final isAdmin = AuthService.instance.isAdmin;

    return Scaffold(
      backgroundColor: HomePalette.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) => CustomScrollView(
            slivers: [
              // 顶部 Header
              SliverToBoxAdapter(child: HomeHeader(isAdmin: isAdmin)),
              // 功能入口卡片
              SliverToBoxAdapter(
                child: FeatureEntryRow(
                  onBooking: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const BookingFlowPage()),
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
                        builder: (_) => const MemberPlanPage()),
                  ),
                  isAdmin: isAdmin,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // 快捷功能
              const SliverToBoxAdapter(child: ShortcutBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PromoBanner(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const BookingFlowPage()),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // 热门推荐
              const SliverToBoxAdapter(child: HotRecommendSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // 进行中的服务
              if (_activeAppts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '进行中的服务',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: HomePalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._activeAppts.map(
                          (appt) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ActiveServiceCard(
                              appt: appt,
                              inService: appt.status == 'in_service',
                              elapsed: appt.serviceStartTime != null
                                  ? DateTime.now().difference(
                                      DateTime.parse(appt.serviceStartTime!))
                                  : Duration.zero,
                              onTap: () => _openActiveService(appt),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// 1. 顶部 Header（品牌标语 + 通知 + 头像）
// ════════════════════════════════════════════════

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧品牌区
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '拾染爱恋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: HomePalette.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '拼出美好 · 豆住快乐',
                  style: TextStyle(
                    fontSize: 11,
                    color: HomePalette.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // 右侧：通知 + 头像
          _buildNotificationBadge(),
          const SizedBox(width: 14),
          _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: HomePalette.textSecondary,
            size: 18,
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: const BoxDecoration(
              color: HomePalette.badgeRed,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: const Text(
              '12',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        'assets/images/home/avatar.png',
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: HomePalette.primary.withAlpha(30),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.person, color: HomePalette.primary, size: 18),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// 2. 功能入口区域（三张白色卡片）
// ════════════════════════════════════════════════

class FeatureEntryRow extends StatelessWidget {
  const FeatureEntryRow({
    super.key,
    required this.onBooking,
    required this.onCheckIn,
    required this.onMembership,
    required this.isAdmin,
  });

  final VoidCallback onBooking;
  final VoidCallback onCheckIn;
  final VoidCallback onMembership;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _FeatureCard(
              icon: Icons.calendar_month_rounded,
              iconBgColor: HomePalette.iconPinkBg,
              iconColor: HomePalette.primary,
              title: '到店预约',
              subtitle: '预约手作时间',
              onTap: onBooking,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeatureCard(
              icon: isAdmin
                  ? Icons.qr_code_scanner_rounded
                  : Icons.qr_code_rounded,
              iconBgColor: HomePalette.iconPurpleBg,
              iconColor: const Color(0xFF8B7CF6),
              title: isAdmin ? '扫码核销' : '到店核销',
              subtitle: '快速开始制作',
              onTap: onCheckIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeatureCard(
              icon: Icons.card_membership_rounded,
              iconBgColor: HomePalette.iconYellowBg,
              iconColor: const Color(0xFFF0A040),
              title: '会员套餐',
              subtitle: '查看会员权益',
              onTap: onMembership,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TapScaleBounce(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: HomePalette.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 彩色圆形图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: HomePalette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: HomePalette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// 3. 快捷功能区域
// ════════════════════════════════════════════════

class ShortcutBar extends StatelessWidget {
  const ShortcutBar({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        icon: Icons.auto_awesome_rounded,
        label: '新品推荐',
        bgColor: HomePalette.iconPinkBg,
        fgColor: HomePalette.primary,
      ),
      (
        icon: Icons.card_giftcard_rounded,
        label: '领取中心',
        bgColor: HomePalette.iconPurpleBg,
        fgColor: Color(0xFF8B7CF6),
      ),
      (
        icon: Icons.star_rounded,
        label: '会员专享',
        bgColor: HomePalette.iconYellowBg,
        fgColor: Color(0xFFF0A040),
      ),
      (
        icon: Icons.local_fire_department_rounded,
        label: '热门排行',
        bgColor: HomePalette.iconTealBg,
        fgColor: Color(0xFF4DC0B5),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Icon(item.icon, color: item.fgColor, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HomePalette.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// 4. Banner 区域
// ════════════════════════════════════════════════

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 32;

    return _TapScaleBounce(
      onTap: onTap,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: HomePalette.bannerBg,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            // 右侧拼豆作品图 — 占40%
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: screenWidth * 0.40,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(28)),
                child: Hero(
                  tag: 'banner_art',
                  child: Image.asset(
                    'assets/images/home/banner_art.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            // 左侧文字区 — 占60%
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 8),
              child: SizedBox(
                width: screenWidth * 0.56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '创意拼豆手作工坊',
                      style: TextStyle(
                        color: HomePalette.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '拼出你的独特创意',
                      style: TextStyle(
                        color: HomePalette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '¥39.9 / 次起',
                      style: TextStyle(
                        color: HomePalette.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: HomePalette.primary.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        '立即预约',
                        style: TextStyle(
                          color: HomePalette.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// 5. 热门推荐区域
// ════════════════════════════════════════════════

class HotRecommendSection extends StatelessWidget {
  const HotRecommendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '热门推荐',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HomePalette.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Text(
                      '查看更多',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.textSecondary,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: HomePalette.textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 横向商品列表
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mockProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => ProductCard(
              product: _mockProducts[i],
              index: i,
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.index});
  final MockProduct product;
  final int index;

  @override
  Widget build(BuildContext context) {
    return _TapScaleBounce(
      child: Container(
        width: 124,
        decoration: BoxDecoration(
          color: HomePalette.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Hero(
                tag: 'product_$index',
                child: Image.asset(
                  product.asset,
                  width: 124,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 124,
                    height: 100,
                    color: const Color(0xFFF5F5F5),
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          color: Color(0xFFCCCCCC), size: 32),
                    ),
                  ),
                ),
              ),
            ),
            // 信息
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HomePalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '¥${product.price.toStringAsFixed(1)} 起',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: HomePalette.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_border_rounded,
                          size: 10, color: HomePalette.textSecondary),
                      const SizedBox(width: 1),
                      Text(
                        _fmtCount(product.collections),
                        style: const TextStyle(
                            fontSize: 9, color: HomePalette.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.favorite_border_rounded,
                          size: 10, color: HomePalette.textSecondary),
                      const SizedBox(width: 1),
                      Text(
                        _fmtCount(product.likes),
                        style: const TextStyle(
                            fontSize: 9, color: HomePalette.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// Mock 商品数据
// ════════════════════════════════════════════════

const _mockProducts = [
  MockProduct(
    name: '库洛米系列',
    asset: 'assets/images/home/product_kuromi.png',
    price: 39.9,
    likes: 2840,
    collections: 1520,
  ),
  MockProduct(
    name: '星之卡比系列',
    asset: 'assets/images/home/product_kirby.png',
    price: 39.9,
    likes: 1960,
    collections: 1100,
  ),
  MockProduct(
    name: '花花系列',
    asset: 'assets/images/home/product_flower.png',
    price: 39.9,
    likes: 3270,
    collections: 1890,
  ),
  MockProduct(
    name: '可爱萌宠系列',
    asset: 'assets/images/home/product_pet.png',
    price: 39.9,
    likes: 4210,
    collections: 2340,
  ),
];

// ════════════════════════════════════════════════
// 6. 进行中的服务卡片
// ════════════════════════════════════════════════

class ActiveServiceCard extends StatelessWidget {
  const ActiveServiceCard({
    super.key,
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
    return _TapScaleBounce(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: HomePalette.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: inService
                          ? const Color(0xFF26DE81).withAlpha(25)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      inService ? Icons.timer_outlined : Icons.login_rounded,
                      color: inService
                          ? const Color(0xFF20B868)
                          : HomePalette.textPrimary,
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
                            color: HomePalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${appt.date} ${appt.startTime}-${appt.endTime} · 桌位 ${appt.tableName}',
                          style: const TextStyle(
                            color: HomePalette.textSecondary,
                            fontSize: 13,
                          ),
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
                          _fmtDuration(elapsed),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20B868),
                            letterSpacing: 1,
                          ),
                        ),
                        const Text(
                          '服务中',
                          style: TextStyle(
                            color: HomePalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          '已核销',
                          style: TextStyle(
                            color: HomePalette.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '待上钟',
                          style: TextStyle(
                            color: HomePalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: HomePalette.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _fmtDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

String _fmtCount(int n) {
  if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}w';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}
