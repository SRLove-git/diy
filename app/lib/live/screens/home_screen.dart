import 'dart:async';

import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/chat_services.dart';
import '../../api/models.dart';
import '../../api/services.dart';
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
    // 预约成功 / 核销 / 下钟结束后自动刷新订单，无需手动下拉
    HomeOrdersRefresh.instance.addListener(_onOrdersChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从后台回到前台时刷新订单，感知店员后台核销
    if (state == AppLifecycleState.resumed && ( _orders.isNotEmpty || _pendingOrders.isNotEmpty)) {
      _loadOrders();
    }
  }

  void _onOrdersChanged() {
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
    HomeOrdersRefresh.instance.removeListener(_onOrdersChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: ErrorView(
                    message: snap.error is ApiException
                        ? (snap.error as ApiException).message
                        : '加载失败',
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
              .where((a) =>
                  a.status == 'checked_in' || a.status == 'in_service')
              .toList();
          // 未来可核销订单：待核销且未过期，按时间升序
          final upcoming = mergedOrders
              .where((a) => a.status == 'booked')
              .where((a) => !a.isExpired(now))
              .toList()
            ..sort((x, y) => (x.endDateTime ?? DateTime.now())
                .compareTo(y.endDateTime ?? DateTime.now()));
          // 已失效订单（超过预约结束时间）不在首页展示，
          // 仅保留在“我的预约”中；到点后由 _scheduleExpiryRefresh 触发消失。
          final showOrders = active.isNotEmpty || upcoming.isNotEmpty;
          return RefreshIndicator(
            onRefresh: () async => _retry(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                const _TopBar(),
                // 「拼豆」板块：入口卡（预约 / 到店 / 会员套餐）
                _SectionHeader(
                  title: '拼豆',
                  badge: '人气手作',
                  more: '查看全部 ›',
                  onMore: () => LiveRoutes.push(context, RoutePaths.activityList),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _EntryCardsRow(
                    onTap: (key) {
                      switch (key) {
                        case 'appoint':
                          LiveRoutes.push(context, RoutePaths.storeList);
                        case 'checkin':
                          LiveRoutes.push(context, RoutePaths.storeCheckin);
                        case 'member':
                          LiveRoutes.push(context, RoutePaths.memberCenter);
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
                              onTap: () => LiveRoutes.push(
                                context,
                                RoutePaths.appointmentServiceEnd,
                                extra: o,
                              ),
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
                _SectionHeader(title: '敬请期待'),
                Padding(
                  // 与拼豆模块卡片同宽
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    width: double.infinity,
                    // 高度与拼豆模块（124）一致
                    height: 124,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LiveColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LiveColors.divider),
                    ),
                    child: const Text(
                      '更多活动敬请期待',
                      style: TextStyle(
                        fontSize: 13,
                        color: LiveColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                // 「活动推荐」板块
                _SectionHeader(
                  title: '活动推荐',
                  more: '查看全部 ›',
                  onMore: () => LiveRoutes.push(context, RoutePaths.activityList),
                ),
                if (data.activities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _ActivityGrid(activities: data.activities),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: EmptyView(text: '暂无活动，敬请期待'),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 顶部：手作星球 + 搜索 + 通知铃铛（角标）
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 2),
      child: Row(
        children: [
          const Text(
            '手作星球',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: LiveColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          // ── 社区搜索前期暂不开放，入口先隐藏 ──
          // IconButton(
          //   icon: const Icon(Icons.search, color: LiveColors.textPrimary, size: 24),
          //   onPressed: () => LiveRoutes.push(context, RoutePaths.search),
          // ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: LiveColors.textPrimary, size: 24),
            onPressed: () => LiveRoutes.push(context, RoutePaths.appointmentMy),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: LiveColors.textPrimary, size: 24),
                ValueListenableBuilder<int>(
                  valueListenable: NotificationService.instance.unread,
                  builder: (context, unread, _) {
                    if (unread <= 0) return const SizedBox.shrink();
                    return Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                        decoration: const BoxDecoration(
                          color: LiveColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 8),
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

/// 区块标题：标题 + 可选徽标 + 可选「查看全部 ›」/ 右侧灰字
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.badge,
    this.more,
    this.trailing,
    this.onMore,
  });

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
                color: LiveColors.textPrimary,
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
                style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
              ),
            )
          else if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(fontSize: 11.6, color: LiveColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

/// 三入口卡（预约 / 到店 / 会员套餐），使用设计稿资源图 + 三等分点击区。
class _EntryCardsRow extends StatelessWidget {
  const _EntryCardsRow({required this.onTap});

  final void Function(String key) onTap;

  static const _keys = ['appoint', 'checkin', 'member'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/divrowgap30.png', fit: BoxFit.fill),
          Row(
            children: [
              for (final key in _keys)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(key),
                  ),
                ),
            ],
          ),
        ],
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
    final a = appointment;
    final expired = a.status == 'booked' && a.isExpired();
    final date = DateTime.tryParse(a.date);
    final week = date == null
        ? ''
        : '周${'一二三四五六日'[date.weekday - 1]}';
    final table = a.tableName.isNotEmpty ? ' · ${a.tableName}' : '';
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
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      expired ? '订单已失效' : '待核销',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: expired
                            ? LiveColors.textSecondary
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
              '${_durationLabel(a)} · ${a.peopleCount} 人',
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
                    '预约码 ${a.code}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: LiveColors.textTertiary,
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
                    child: const Text(
                      '订单已失效',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LiveColors.textSecondary,
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
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '到店核销',
                      style: TextStyle(
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
class _HomeServiceCard extends StatelessWidget {
  const _HomeServiceCard({required this.appointment, required this.onTap});

  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LiveColors.divider),
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
                    '服务中',
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
            '${a.date} ${a.startTime} 上钟${_durationLabel(a)}',
            style: const TextStyle(
              fontSize: 13,
              color: LiveColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          TimerCard(appointment: a, onAction: onTap),
        ],
      ),
    );
  }
}

/// 预约时长描述（与预约卡片一致）。
String _durationLabel(Appointment a) {
  if (a.type == 'activity') return '';
  if (a.bookingType == 'all_day') return ' · 全天不限时';
  if (a.bookingType == 'package' && a.packageName.isNotEmpty) {
    return ' · ${a.packageName}';
  }
  if (a.durationHours != null && a.durationHours! > 0) {
    return ' · ${a.durationHours} 小时';
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
          color: LiveColors.brandLight,
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
                  style: const TextStyle(fontSize: 10.6, color: LiveColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              activity.title.startsWith('#') ? activity.title : '# ${activity.title}',
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
              activity.price > 0 ? '¥${activity.price.toStringAsFixed(0)} 起' : '免费',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: LiveColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
