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
  Timer? _tickTimer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.loadActiveAppointments) return;
    _loadActiveAppointments();
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
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
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
                SliverToBoxAdapter(child: HomeHeader(isAdmin: isAdmin)),
                SliverToBoxAdapter(
                  child: FeatureEntryRow(
                    isAdmin: isAdmin,
                    onBooking: _openBooking,
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
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                const SliverToBoxAdapter(child: ShortcutBar()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PromoBanner(onTap: _openBooking),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 26)),
                const SliverToBoxAdapter(child: HotRecommendSection()),
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
  const HomeHeader({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
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
          _NotificationButton(count: isAdmin ? 12 : 6),
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
              child: Image.asset(
                'assets/images/home/avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFFFFDCE5),
                  child: Icon(Icons.person, color: HomePalette.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 44,
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
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: HomePalette.badgeRed,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
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
    );
  }
}

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
    final entries = [
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
  const ShortcutBar({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _ShortcutData(
        icon: Icons.auto_awesome_rounded,
        label: '新品推荐',
        colors: [Color(0xFFFF8199), Color(0xFFFF506F)],
      ),
      _ShortcutData(
        icon: Icons.redeem_rounded,
        label: '领券中心',
        colors: [Color(0xFFFFC05B), Color(0xFFFF9D29)],
      ),
      _ShortcutData(
        icon: Icons.workspace_premium_rounded,
        label: '会员专享',
        colors: [Color(0xFFA37AFF), Color(0xFF774CE8)],
      ),
      _ShortcutData(
        icon: Icons.local_fire_department_rounded,
        label: '热门排行',
        colors: [Color(0xFF83CCFF), Color(0xFF5799EC)],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: items
            .map(
              (item) => Expanded(
                child: Semantics(
                  button: true,
                  label: item.label,
                  child: InkResponse(
                    radius: 34,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.label}即将上线'),
                        duration: const Duration(seconds: 1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _GradientIcon(
                          icon: item.icon,
                          colors: item.colors,
                          size: 46,
                          iconSize: 23,
                          radius: 23,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.label,
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
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ShortcutData {
  const _ShortcutData({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
}

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

class HotRecommendSection extends StatelessWidget {
  const HotRecommendSection({super.key});

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
                onTap: () {},
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
            itemCount: _mockProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                ProductCard(product: _mockProducts[index], index: index),
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
