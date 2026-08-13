import 'dart:async';

import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/auth_store.dart';
import '../../api/chat_services.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_ext.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';
import 'appointment_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.root = false});

  final bool root;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Future<({List<Activity> activities, int unread})> _future;

  /// 当前账号是否为管理员（null 表示角色尚未拉取完成）。
  bool? _isAdmin;

  /// 已拉取的订单列表（独立状态，支持后台轮询实时更新）。
  List<Appointment> _orders = [];

  /// 乐观更新的订单（预约成功 / 下钟结束后立即合入展示，不等网络刷新）。
  final Map<int, Appointment> _pendingOrders = {};
  bool _loadingOrders = false;

  /// 预约到点后自动刷新，让已失效订单从首页消失（保留在“我的预约”中）。
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _loadBase();
    _loadOrders();
    _maybeRefreshRole();
    AuthStore.instance.addListener(_onAuthChanged);
    // 预约成功 / 核销 / 下钟结束后自动刷新订单，无需手动下拉
    HomeOrdersRefresh.instance.addListener(_onOrdersChanged);
  }

  /// 最近一次已刷新角色的账号（避免 applyMe 的通知触发重复拉取）。
  int? _roleCheckedUserId;

  void _onAuthChanged() {
    final isAdmin = AuthStore.instance.isAdmin;
    if (_isAdmin != isAdmin) setState(() => _isAdmin = isAdmin);
    // 切换账号 / 重新登录后拉取新账号角色；同一账号的通知（applyMe）不再重复拉取
    _maybeRefreshRole();
  }

  /// 账号变化或角色尚未拉取成功时（重新）拉取 /auth/me 的角色信息。
  void _maybeRefreshRole() {
    final uid = AuthStore.instance.userId;
    if (uid == null) return;
    if (uid != _roleCheckedUserId || _isAdmin == null) {
      _refreshRole();
    }
  }

  /// 拉取 /auth/me 的角色信息：管理员显示管理模块，普通用户显示预约/到店/会员。
  Future<void> _refreshRole() async {
    final uid = AuthStore.instance.userId;
    if (uid == null) return;
    _roleCheckedUserId = uid;
    try {
      final u = await AuthService.instance.me();
      unawaited(AuthStore.instance.applyMe(u));
      if (!mounted || uid != AuthStore.instance.userId) return;
      final isAdmin = AuthStore.instance.isAdmin;
      if (_isAdmin != isAdmin) setState(() => _isAdmin = isAdmin);
    } catch (_) {
      // 角色拉取失败保持现状；同一账号的角色后续由 applyMe 的通知带到首页
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从后台回到前台：重新拉取订单、未读数与角色，
    // 感知后台期间的核销/上钟/新通知，以及管理员角色未拉取成功时的自愈
    if (state == AppLifecycleState.resumed) {
      _loadOrders();
      _maybeRefreshRole();
      unawaited(
        NotificationService.instance.unreadCount().catchError((_) => 0),
      );
    }
  }

  void _onOrdersChanged() {
    // 切回首页 Tab 时顺带自愈角色状态（首次拉取失败后自动重试）
    _maybeRefreshRole();
    final p = HomeOrdersRefresh.instance.pending;
    if (p != null) {
      setState(() => _pendingOrders[p.id] = p);
    }
    _loadOrders();
  }

  Future<({List<Activity> activities, int unread})> _loadBase() async {
    final results = await Future.wait([
      ActivityService.instance.list(),
      NotificationService.instance.unreadCount().catchError((_) => 0),
    ]);
    return (
      activities: results[0] as List<Activity>,
      unread: results[1] as int,
    );
  }

  Future<void> _loadOrders() async {
    if (_loadingOrders) return;
    _loadingOrders = true;
    try {
      final orders = await AppointmentService.instance.myList();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        // 校准：拉取结果已包含乐观更新的订单后移除本地缓存
        final fetched = orders.map((o) => o.id).toSet();
        _pendingOrders.removeWhere((id, _) => fetched.contains(id));
      });
      _scheduleExpiryRefresh();
    } catch (_) {
      // 刷新失败静默，下次事件触发时重试
    } finally {
      _loadingOrders = false;
    }
  }

  /// 预约到点后自动刷新一次，让已失效订单实时从首页消失。
  void _scheduleExpiryRefresh() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
    final now = DateTime.now();
    DateTime? earliest;
    for (final o in [..._orders, ..._pendingOrders.values]) {
      if (o.status != 'booked' || o.isExpired(now)) continue;
      final end = o.endDateTime;
      if (end != null && (earliest == null || end.isBefore(earliest))) {
        earliest = end;
      }
    }
    if (earliest == null) return;
    final delta = earliest.difference(now);
    _expiryTimer = Timer(
      delta.isNegative
          ? const Duration(seconds: 1)
          : delta + const Duration(seconds: 1),
      () {
        if (!mounted) return;
        setState(() {});
        _scheduleExpiryRefresh();
      },
    );
  }

  Future<void> _retry() async {
    final base = _loadBase();
    setState(() => _future = base);
    await base;
    await _loadOrders();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    AuthStore.instance.removeListener(_onAuthChanged);
    HomeOrdersRefresh.instance.removeListener(_onOrdersChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 页面级极光背景：深蓝 / 深紫透明光晕固定在顶部渐隐，内容在其上滚动
    return LivePage(
      fullBleed: true,
      statusBarLight: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _AuroraBackground(),
          SafeArea(
            bottom: false,
            child: FutureBuilder(
              future: _future,
              builder: (context, snap) {
                final l10n = context.l10n;
                if (snap.hasError) {
                  return Column(
                    children: [
                      const _TopBar(),
                      Expanded(
                        child: ErrorView(
                          message: snap.error is ApiException
                              ? (snap.error as ApiException).message
                              : l10n.commonLoadFailed,
                          onRetry: _retry,
                        ),
                      ),
                    ],
                  );
                }
                if (!snap.hasData) {
                  return Column(
                    children: [
                      const _TopBar(),
                      const Expanded(child: LoadingView()),
                    ],
                  );
                }
                final data = snap.data!;
                final now = DateTime.now();
                // 合并轮询数据与乐观更新的订单（乐观更新优先，即时展示）
                final mergedOrders = <Appointment>[..._orders];
                for (final p in _pendingOrders.values) {
                  mergedOrders.removeWhere((o) => o.id == p.id);
                  mergedOrders.add(p);
                }
                // 服务中订单（实时计时）
                final active = mergedOrders
                    .where(
                      (a) =>
                          a.status == 'checked_in' || a.status == 'in_service',
                    )
                    .toList();
                // 未来订单：待确认/待核销且未过期，按时间升序
                final upcoming =
                    mergedOrders
                        .where(
                          (a) => a.status == 'pending' || a.status == 'booked',
                        )
                        .where((a) => !a.isExpired(now))
                        .toList()
                      ..sort(
                        (x, y) => (x.endDateTime ?? DateTime.now()).compareTo(
                          y.endDateTime ?? DateTime.now(),
                        ),
                      );
                // 已失效订单（超过预约结束时间）不在首页展示，
                // 仅保留在“我的预约”中；到点后由 _scheduleExpiryRefresh 触发消失。
                final showOrders = active.isNotEmpty || upcoming.isNotEmpty;
                return RefreshIndicator(
                  onRefresh: () async => _retry(),
                  color: const Color(0xFF5B21B6),
                  backgroundColor: Colors.white,
                  child: ListView(
                    // 底部悬浮 Tab 覆盖在内容之上，预留滚动空间避免最后内容被遮挡
                    padding: const EdgeInsets.only(bottom: 96),
                    children: [
                      const _TopBar(),
                      // 门店板块：普通用户三入口（预约 / 到店 / 会员套餐），
                      // 管理员替换为管理端三入口（扫码核销 / 订单管理 / 会员运营）
                      _SectionHeader(
                        title: _isAdmin == true
                            ? l10n.adminStoreSection
                            : l10n.homeStoreSection,
                        badge: _isAdmin == true
                            ? l10n.adminStoreBadge
                            : l10n.homeStoreSectionBadge,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _EntryCardsRow(
                          admin: _isAdmin == true,
                          onTap: (key) {
                            switch (key) {
                              case 'appoint':
                                LiveRoutes.push(context, RoutePaths.storeList);
                              case 'checkin':
                                LiveRoutes.push(
                                  context,
                                  RoutePaths.storeCheckin,
                                );
                              case 'member':
                                LiveRoutes.push(
                                  context,
                                  RoutePaths.memberCenter,
                                );
                              case 'redeem':
                                LiveRoutes.push(
                                  context,
                                  RoutePaths.adminRedeem,
                                );
                              case 'orders':
                                LiveRoutes.push(
                                  context,
                                  RoutePaths.adminOrders,
                                );
                              case 'members':
                                LiveRoutes.push(
                                  context,
                                  RoutePaths.adminMembers,
                                );
                            }
                          },
                        ),
                      ),
                      // 「我的订单」：服务中实时计时 + 未来可核销的待核销订单
                      if (showOrders) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                          child: Column(
                            children: [
                              for (final o in active)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _HomeServiceCard(
                                    appointment: o,
                                    onTap: () async {
                                      final ok =
                                          await showClockOutConfirmDialog(
                                            context,
                                          );
                                      if (ok == true && context.mounted) {
                                        LiveRoutes.push(
                                          context,
                                          RoutePaths.appointmentServiceEnd,
                                          extra: o,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              for (final o in upcoming)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _HomeOrderCard(
                                    appointment: o,
                                    onTap: () => LiveRoutes.push(
                                      context,
                                      RoutePaths.appointmentCheckinQr,
                                      extra: o,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      // 「敬请期待」模块：标题在左上角（同拼豆模块），下方为占位框
                      _SectionHeader(title: l10n.homeComingSoon),
                      Padding(
                        // 与拼豆模块卡片同宽
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Container(
                          width: double.infinity,
                          // 高度与拼豆模块（124）一致
                          height: 124,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LiveGradients.brandSoft,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE4DEF9)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: Color(0xFFB7AEF2),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.homeComingSoonMore,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9B93C9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 「活动推荐」板块
                      _SectionHeader(
                        title: l10n.homeActivitySection,
                        more: l10n.homeViewAll,
                        onMore: () =>
                            LiveRoutes.push(context, RoutePaths.activityList),
                      ),
                      if (data.activities.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _ActivityGrid(activities: data.activities),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: EmptyView(text: l10n.homeNoActivities),
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 页面级极光背景：深蓝 / 深紫光晕在顶部渐隐，营造 ins 风氛围。
class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        // 蓝紫渐变底纱：从顶部向下渐隐，奠定清晰可见的 ins 蓝紫基调
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFDCD9F7), Color(0x00DCD9F7)],
                stops: [0.0, 0.55],
              ),
            ),
          ),
        ),
        // 深蓝极光（左上）
        Positioned(
          top: -110,
          left: -70,
          child: _GlowCircle(
            diameter: 360,
            color: Color(0xFF2E3AB8),
            opacity: 0.5,
          ),
        ),
        // 深紫极光（右上）
        Positioned(
          top: -80,
          right: -90,
          child: _GlowCircle(
            diameter: 360,
            color: Color(0xFF5B21B6),
            opacity: 0.45,
          ),
        ),
        // 靛蓝过渡（中上部，衔接两团光晕）
        Positioned(
          top: 90,
          left: 60,
          child: _GlowCircle(
            diameter: 240,
            color: Color(0xFF4F46E5),
            opacity: 0.28,
          ),
        ),
      ],
    );
  }
}

/// 极光光晕：径向渐隐的柔光圆。
class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.diameter,
    required this.color,
    required this.opacity,
  });

  final double diameter;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// 顶部：Think Origin 渐变流光 Logo 字 + 通知铃铛（角标）。
class _TopBar extends StatefulWidget {
  const _TopBar();

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> with SingleTickerProviderStateMixin {
  /// Logo 字流光时钟：4.2s 循环，前 45% 扫过一次，其余时间静止。
  late final AnimationController _shine;
  late final CurvedAnimation _shineCurve;

  /// Logo 字样式（ShaderMask 下颜色仅作遮罩，用白色）。
  static const _titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
    _shineCurve = CurvedAnimation(
      parent: _shine,
      curve: const Interval(0, 0.45, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shineCurve.dispose();
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 2),
      child: Row(
        children: [
          // 渐变 Logo 字：深蓝 → 深紫底 + 周期性高光扫过
          Stack(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF2E3AB8), Color(0xFF5B21B6)],
                ).createShader(bounds),
                child: const Text('Think Origin', style: _titleStyle),
              ),
              AnimatedBuilder(
                animation: _shineCurve,
                builder: (context, _) {
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.75),
                        Colors.transparent,
                      ],
                      stops: const [0.42, 0.5, 0.58],
                      transform: _TitleShineTransform(_shineCurve.value),
                    ).createShader(bounds),
                    child: const Text('Think Origin', style: _titleStyle),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          // ── 社区搜索前期暂不开放，入口先隐藏 ──
          // IconButton(
          //   icon: const Icon(Icons.search, color: LiveColors.textPrimary, size: 24),
          //   onPressed: () => LiveRoutes.push(context, RoutePaths.search),
          // ),
          IconButton(
            icon: const Icon(
              Icons.receipt_long_outlined,
              color: LiveColors.textPrimary,
              size: 24,
            ),
            onPressed: () => LiveRoutes.push(context, RoutePaths.appointmentMy),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: LiveColors.textPrimary,
                  size: 24,
                ),
                ValueListenableBuilder<int>(
                  valueListenable: NotificationService.instance.unread,
                  builder: (context, unread, _) {
                    if (unread <= 0) return const SizedBox.shrink();
                    return Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        decoration: const BoxDecoration(
                          color: LiveColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onPressed: () => LiveRoutes.push(context, RoutePaths.notifications),
          ),
        ],
      ),
    );
  }
}

/// Logo 字流光：光带随动画从文字左侧外滑到右侧外。
class _TitleShineTransform extends GradientTransform {
  const _TitleShineTransform(this.percent);

  /// 0 → 1，光带中心从文字左缘外移到右缘外。
  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * 2 * (percent - 0.5), 0, 0);
  }
}

/// 区块标题：标题 + 可选徽标 + 可选「查看全部 ›」/ 右侧灰字。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.badge,
    this.more,
    this.onMore,
  }) : trailing = null;

  final String title;
  final String? badge;
  final String? more;
  final String? trailing;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21.6,
              fontWeight: FontWeight.w800,
              color: LiveColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                gradient: LiveGradients.brand,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 10.6,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (more != null)
            InkWell(
              onTap: onMore,
              child: Text(
                more!,
                style: const TextStyle(
                  fontSize: 13,
                  color: LiveColors.textSecondary,
                ),
              ),
            )
          else if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(
                fontSize: 11.6,
                color: LiveColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// 三入口卡（普通用户：预约 / 到店 / 会员套餐；管理员：扫码核销 / 订单管理 / 会员运营）。
class _EntryCardsRow extends StatelessWidget {
  const _EntryCardsRow({required this.onTap, this.admin = false});

  final void Function(String key) onTap;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = admin
        ? [
            (
              key: 'redeem',
              icon: Icons.qr_code_scanner,
              title: l10n.adminRedeem,
              desc: l10n.adminRedeemDesc,
            ),
            (
              key: 'orders',
              icon: Icons.receipt_long_outlined,
              title: l10n.adminOrders,
              desc: l10n.adminOrdersDesc,
            ),
            (
              key: 'members',
              icon: Icons.groups_outlined,
              title: l10n.adminMembers,
              desc: l10n.adminMembersDesc,
            ),
          ]
        : [
            (
              key: 'appoint',
              icon: Icons.pin_drop_outlined,
              title: l10n.homeBookNow,
              desc: l10n.homeBookNowDesc,
            ),
            (
              key: 'checkin',
              icon: Icons.qr_code_scanner,
              title: l10n.homeCheckIn,
              desc: l10n.homeCheckInDesc,
            ),
            (
              key: 'member',
              icon: Icons.card_membership,
              title: l10n.homeMember,
              desc: l10n.homeMemberDesc,
            ),
          ];
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _EntryCard(
              entry: entries[i],
              onTap: () => onTap(entries[i].key),
            ),
          ),
        ],
      ],
    );
  }
}

/// 单张入口卡：白卡 + 深蓝紫渐变图标盒 + 标题/描述，带柔和投影。
class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.onTap});

  final ({String key, IconData icon, String title, String desc}) entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 124,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C3674).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LiveGradients.brand,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(entry.icon, size: 19, color: Colors.white),
            ),
            const Spacer(),
            Text(
              entry.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: LiveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              entry.desc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: LiveColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 首页“我的订单”卡：待核销预约（门店 + 时间 + 预约码 + 到店核销）；
/// 超过预约结束时间的订单置灰并标注“订单已失效”。
class _HomeOrderCard extends StatelessWidget {
  const _HomeOrderCard({required this.appointment, this.onTap});

  final Appointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = appointment;
    final expired = a.status == 'booked' && a.isExpired();
    final pending = a.status == 'pending';
    final date = DateTime.tryParse(a.date);
    final week = date == null
        ? ''
        : switch (date.weekday) {
            1 => l10n.weekdayMon,
            2 => l10n.weekdayTue,
            3 => l10n.weekdayWed,
            4 => l10n.weekdayThu,
            5 => l10n.weekdayFri,
            6 => l10n.weekdaySat,
            _ => l10n.weekdaySun,
          };
    final table = a.tableLabel.isNotEmpty ? ' · ${a.tableLabel}' : '';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: expired ? LiveColors.card : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: expired ? const Color(0xFFE4E4E8) : LiveColors.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: expired
                          ? LiveColors.textTertiary
                          : LiveColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: expired
                        ? const Color(0xFFECECEF)
                        : pending
                        ? const Color(0xFFF3E8FF)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      expired
                          ? l10n.homeOrderExpired
                          : pending
                          ? l10n.homeWaitingConfirm
                          : l10n.appointmentStatusBooked,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: expired
                            ? LiveColors.textSecondary
                            : pending
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFE53935),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${a.date} $week ${a.startTime}-${a.endTime}$table'
              '${_durationLabel(a, l10n)} · ${l10n.appointmentPeople(a.peopleCount)}',
              style: TextStyle(
                fontSize: 13,
                color: expired
                    ? LiveColors.textTertiary
                    : LiveColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    pending
                        ? l10n.homeWaitingStoreConfirm
                        : l10n.homeCode(a.code),
                    style: TextStyle(
                      fontSize: 11,
                      color: pending
                          ? const Color(0xFF6D28D9)
                          : LiveColors.textTertiary,
                    ),
                  ),
                ),
                if (expired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E4E8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l10n.homeOrderExpired,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LiveColors.textSecondary,
                      ),
                    ),
                  )
                else if (pending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDC8FF)),
                    ),
                    child: Text(
                      l10n.homeWaitingChip,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LiveGradients.brand,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l10n.homeToCheckIn,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

/// 首页“服务中”卡：门店 + 服务中标签 + 实时计时卡（下钟进入体验页）。
/// 外层包一圈 ins 蓝紫渐变描边，突出「进行中」状态。
class _HomeServiceCard extends StatelessWidget {
  const _HomeServiceCard({required this.appointment, required this.onTap});

  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = appointment;
    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        gradient: LiveGradients.brand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      l10n.appointmentStatusInService,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeStartedAt(a.date, a.startTime, _durationLabel(a, l10n)),
              style: const TextStyle(
                fontSize: 13,
                color: LiveColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            TimerCard(appointment: a, onAction: onTap),
          ],
        ),
      ),
    );
  }
}

/// 预约时长描述（与预约卡片一致）。
String _durationLabel(Appointment a, AppLocalizations l10n) {
  if (a.type == 'activity') return '';
  if (a.bookingType == 'all_day') return l10n.homeAllDaySuffix;
  if (a.bookingType == 'package' && a.packageName.isNotEmpty) {
    return ' · ${a.packageName}';
  }
  if (a.durationHours != null && a.durationHours! > 0) {
    return l10n.homeHourSuffix(a.durationHours!);
  }
  return '';
}

/// 活动推荐：两列 221×135 活动卡（实时数据）。
class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < activities.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _ActivityCard(
                    activity: activities[i],
                    onTap: () => LiveRoutes.pushId(
                      context,
                      RoutePaths.activityDetail,
                      activities[i].id,
                    ),
                  ),
                ),
                if (i + 1 < activities.length) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActivityCard(
                      activity: activities[i + 1],
                      onTap: () => LiveRoutes.pushId(
                        context,
                        RoutePaths.activityDetail,
                        activities[i + 1].id,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onTap});

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 135,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LiveGradients.brandSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (activity.tag.isNotEmpty)
                  TagChip(label: activity.tag, color: LiveColors.blue),
                const Spacer(),
                Text(
                  activity.date,
                  style: const TextStyle(
                    fontSize: 10.6,
                    color: LiveColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              activity.title.startsWith('#')
                  ? activity.title
                  : '# ${activity.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: LiveColors.textPrimary,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Text(
              activity.price > 0
                  ? context.l10n.homePriceFrom('\$${fmtPrice(activity.price)}')
                  : context.l10n.commonFree,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5B21B6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
