// import 'dart:math' as math; // 地图相关：距离计算用，先注释

import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  late Future<List<Store>> _future;
  String _filter = 'all'; // all / bookable / member

  @override
  void initState() {
    super.initState();
    _future = StoreService.instance.list();
  }

  void _retry() => setState(() => _future = StoreService.instance.list());

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder<List<Store>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '门店列表'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '门店列表'), Expanded(child: LoadingView())],
            );
          }
          final stores = snap.data!;
          final filtered = stores.where((s) {
            return switch (_filter) {
              'bookable' => s.slots.isNotEmpty,
              'member' => s.memberPrice != null,
              _ => true,
            };
          }).toList();
          return Column(
            children: [
              LiveAppBar(
                title: '门店列表',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: LiveColors.textPrimary),
                    onPressed: () => LiveRoutes.push(context, RoutePaths.storeSearch),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                child: _StoreFilterChips(
                  current: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyView(text: '暂无门店，请先到管理后台添加')
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _StoreCard(
                            store: filtered[i],
                            onTap: () => LiveRoutes.pushId(
                              context,
                              RoutePaths.storeDetail,
                              filtered[i].id,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 门店封面：有图显示图片；无图不渲染封面区，避免出现大块占位
/// （原地图/封面占位视觉）。
class _StoreCover extends StatelessWidget {
  const _StoreCover({
    required this.store,
    this.height = 150,
    this.radius = 0,
  });

  final Store store;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (store.cover.isNotEmpty) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: NetImage(url: store.cover, radius: radius),
      );
    }
    // 无门店图时渲染空组件，不显示任何占位块
    return const SizedBox.shrink();
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.onTap});

  final Store store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: LiveColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LiveColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StoreCover(store: store, height: 150),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
                        ),
                      ),
                      const Icon(Icons.star, size: 14, color: LiveColors.warning),
                      const SizedBox(width: 2),
                      Text(store.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    store.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: LiveColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(store.businessHours,
                          style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
                      const SizedBox(width: 8),
                      // ── 地图相关：距离展示，先注释，页面保持纯门店列表 ──
                      // const Icon(Icons.place_outlined, size: 13, color: LiveColors.textTertiary),
                      // const SizedBox(width: 2),
                      // Text(
                      //   _distanceKm(store.lat, store.lng),
                      //   style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary),
                      // ),
                      const Spacer(),
                      Text(
                        '¥${store.price.toStringAsFixed(0)}/时·人',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: LiveColors.brand,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: '立即预约',
                          height: 40,
                          borderRadius: 12,
                          color: Colors.black,
                          textColor: Colors.white,
                          onTap: onTap,
                        ),
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

/// 门店筛选：全部 / 可预约 / 会员价
class _StoreFilterChips extends StatelessWidget {
  const _StoreFilterChips({required this.current, required this.onChanged});

  final String current;
  final ValueChanged<String> onChanged;

  static const _tabs = [
    ('all', '全部'),
    ('bookable', '可预约'),
    ('member', '会员价'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LiveColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final t in _tabs)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: current == t.$1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: current == t.$1
                      ? const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: InkWell(
                  onTap: () => onChanged(t.$1),
                  borderRadius: BorderRadius.circular(17),
                  child: Center(
                    child: Text(
                      t.$2,
                      style: TextStyle(
                        fontSize: 12.6,
                        fontWeight: current == t.$1 ? FontWeight.w700 : FontWeight.w400,
                        color: current == t.$1
                            ? LiveColors.textPrimary
                            : LiveColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 地图相关：门店距离估算（基于经纬度），先注释 ──
// String _distanceKm(double? lat, double? lng) {
//   if (lat == null || lng == null) return '--';
//   const baseLat = 31.2304;
//   const baseLng = 121.4737;
//   const r = 6371.0;
//   double rad(double d) => d * 3.141592653589793 / 180;
//   final dLat = rad(lat - baseLat);
//   final dLng = rad(lng - baseLng);
//   final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//       math.cos(rad(baseLat)) *
//           math.cos(rad(lat)) *
//           math.sin(dLng / 2) *
//           math.sin(dLng / 2);
//   final km = r * 2 * math.asin(math.sqrt(a));
//   return km < 1 ? '距您 ${(km * 1000).round()}m' : '距您 ${km.toStringAsFixed(1)}km';
// }

class StoreSearchScreen extends StatefulWidget {
  const StoreSearchScreen({super.key});

  @override
  State<StoreSearchScreen> createState() => _StoreSearchScreenState();
}

class _StoreSearchScreenState extends State<StoreSearchScreen> {
  List<Store> _all = [];
  final _query = TextEditingController();
  // String _sort = 'default'; // default / nearest（地图相关：距离排序，先注释）
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await StoreService.instance.list();
      if (mounted) setState(() => _all = list);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Store> get _filtered {
    final q = _query.text.trim();
    var list = _all
        .where((s) => s.name.contains(q) || s.address.contains(q))
        .toList();
    // ── 地图相关：按距离排序，先注释 ──
    // if (_sort == 'nearest') {
    //   list.sort((a, b) {
    //     final da = _distanceValue(a.lat, a.lng);
    //     final db = _distanceValue(b.lat, b.lng);
    //     return da.compareTo(db);
    //   });
    // }
    return list;
  }

  // ── 地图相关：距离排序辅助函数，先注释 ──
  // double _distanceValue(double? lat, double? lng) {
  //   if (lat == null || lng == null) return double.infinity;
  //   const baseLat = 31.2304;
  //   const baseLng = 121.4737;
  //   return (lat - baseLat) * (lat - baseLat) + (lng - baseLng) * (lng - baseLng);
  // }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: TextField(
              controller: _query,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '搜索门店名称 / 地址',
                prefixIcon: const Icon(Icons.search, color: LiveColors.textTertiary),
                suffixIcon: _query.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: LiveColors.textTertiary),
                        onPressed: () => setState(() => _query.clear()),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // ── 地图相关：距离最近排序 + 地图模式入口，先注释，保留纯门店列表 ──
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
          //   child: Row(
          //     children: [
          //       for (final t in [
          //         ('default', '全部'),
          //         ('nearest', '距离最近'),
          //       ])
          //         Padding(
          //           padding: const EdgeInsets.only(right: 10),
          //           child: InkWell(
          //             onTap: () => setState(() => _sort = t.$1),
          //             child: Container(
          //               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          //               decoration: BoxDecoration(
          //                 color: _sort == t.$1 ? LiveColors.textPrimary : LiveColors.card,
          //                 borderRadius: BorderRadius.circular(16),
          //               ),
          //               child: Text(
          //                 t.$2,
          //                 style: TextStyle(
          //                   fontSize: 12,
          //                   fontWeight: FontWeight.w600,
          //                   color: _sort == t.$1 ? Colors.white : LiveColors.textSecondary,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       const Spacer(),
          //       InkWell(
          //         onTap: () => LiveRoutes.replace(
          //           context,
          //           RoutePaths.storeList,
          //         ),
          //         child: const Text(
          //           '地图模式 ›',
          //           style: TextStyle(fontSize: 13, color: LiveColors.brand),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _filtered.isEmpty
                        ? const EmptyView(text: '未找到相关门店')
                        : ListView.separated(
                            padding: const EdgeInsets.all(18),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => _StoreCard(
                              store: _filtered[i],
                              onTap: () => LiveRoutes.pushId(
                                context,
                                RoutePaths.storeDetail,
                                _filtered[i].id,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/// 门店详情：日期 / 时段 / 桌位 / 人数 → 预约确认
class StoreDetailScreen extends StatefulWidget {
  const StoreDetailScreen({super.key, required this.storeId});

  final int storeId;

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  late Future<Store> _future;
  String? _date;
  String _bookingType = 'hourly'; // hourly / package / all_day
  int _hours = 1;
  StorePackage? _package;
  String? _startTime;

  @override
  void initState() {
    super.initState();
    _future = StoreService.instance.detail(widget.storeId);
  }

  void _retry() => setState(() {
        _future = StoreService.instance.detail(widget.storeId);
        _startTime = null;
        _package = null;
      });

  List<String> _nextDates() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.add(Duration(days: i));
      final mm = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      return '${d.year}-$mm-$dd';
    });
  }

  String _todayStr() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder<Store>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '门店详情'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '门店详情'), Expanded(child: LoadingView())],
            );
          }
          final store = snap.data!;
          return Column(
            children: [
              const LiveAppBar(title: '门店详情'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    if (store.cover.isNotEmpty) ...[
                      _StoreCover(store: store, height: 180, radius: 16),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      store.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: LiveColors.warning),
                        Text(store.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                        const SizedBox(width: 10),
                        const Icon(Icons.schedule, size: 13, color: LiveColors.textTertiary),
                        Text(store.businessHours,
                            style: const TextStyle(fontSize: 13, color: LiveColors.textTertiary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 15, color: LiveColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(store.address,
                              style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '按小时 ¥${store.price.toStringAsFixed(2)}/人/小时'
                      '${store.memberPrice != null && store.memberPrice! > 0 ? '　会员 ¥${store.memberPrice!.toStringAsFixed(2)}' : store.memberPrice == 0 ? '　会员免费' : ''}'
                      '${store.groupPrice != null ? '　同行 ¥${store.groupPrice!.toStringAsFixed(2)}' : ''}'
                      '${store.allDayPrice != null ? '　全天 ¥${store.allDayPrice!.toStringAsFixed(2)}/人' : ''}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    const _StepTitle('1', '选择日期'),
                    _datesRow(store),
                    const SizedBox(height: 18),
                    const _StepTitle('2', '选择预约方式'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final t in [
                          ('hourly', '按小时'),
                          ('package', '时长套餐'),
                          ('all_day', '全天不限时'),
                        ])
                          _ChoiceChip(
                            label: t.$2,
                            selected: _bookingType == t.$1,
                            onTap: () => setState(() {
                              _bookingType = t.$1;
                              _package = null;
                              _startTime = null;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_bookingType == 'hourly') ...[
                      _hoursSelector(store),
                      const SizedBox(height: 16),
                      Text(
                        '开始时间（营业 ${store.businessHours}）',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: LiveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _startTimeChips(store, _hours),
                    ] else if (_bookingType == 'package') ...[
                      if (store.packages.isEmpty)
                        const EmptyView(text: '门店暂未配置时长套餐')
                      else ...[
                        Text(
                          '选择套餐',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: LiveColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: store.packages.map((p) {
                            return _ChoiceChip(
                              label: '${p.name} · ¥${p.price.toStringAsFixed(0)}/人',
                              selected: _package?.id == p.id,
                              onTap: () => setState(() {
                                _package = p;
                                final opts = _startOptions(store, p.hours);
                                _startTime = opts.isEmpty ? null : opts.first;
                              }),
                            );
                          }).toList(),
                        ),
                        if (_package != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            '开始时间（营业 ${store.businessHours}）',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: LiveColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _startTimeChips(store, _package!.hours),
                        ],
                      ],
                    ] else ...[
                      const Text(
                        '全天不限时',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: LiveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '营业时间（${store.businessHours}）内不限时长，到店扫码即开始计时',
                        style: const TextStyle(
                          fontSize: 12,
                          color: LiveColors.textSecondary,
                        ),
                      ),
                    ],
                    if (_windowOf(store) != null) ...[
                      const SizedBox(height: 14),
                      _bookingSummary(store),
                    ],
                    const SizedBox(height: 26),
                    PrimaryButton(
                      label: '下一步 · 选择桌位',
                      color: Colors.black,
                      textColor: Colors.white,
                      onTap: _canNext(store)
                          ? () {
                              final w = _windowOf(store)!;
                              LiveRoutes.push(
                                context,
                                RoutePaths.storeTableSelect,
                                extra: {
                                  'store': store,
                                  'date': _date!,
                                  'bookingType': _bookingType,
                                  'startTime': w.$1,
                                  'endTime': w.$2,
                                  'durationHours': _selectedHours(store),
                                  'package': _package,
                                },
                              );
                            }
                          : null,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _hoursSelector(Store store) {
    final range = _businessHoursRange(store);
    final maxHours = ((_minutes(range.$2) - _minutes(range.$1)) / 60).floor();
    final maxHoursSafe = maxHours < 1 ? 1 : maxHours;
    return Row(
      children: [
        const Text(
          '时长',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: LiveColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        _RoundBtn(
          icon: Icons.remove,
          onTap: _hours > 1
              ? () => setState(() {
                    _hours--;
                    final opts = _startOptions(store, _hours);
                    _startTime = opts.isEmpty ? null : opts.first;
                  })
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '$_hours 小时',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LiveColors.textPrimary,
            ),
          ),
        ),
        _RoundBtn(
          icon: Icons.add,
          onTap: _hours < maxHoursSafe
              ? () => setState(() {
                    _hours++;
                    final opts = _startOptions(store, _hours);
                    _startTime = opts.isEmpty ? null : opts.first;
                  })
              : null,
        ),
        const Spacer(),
        Text(
          '1 小时起',
          style: const TextStyle(
            fontSize: 11,
            color: LiveColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _startTimeChips(Store store, int hours) {
    final opts = _startOptions(store, hours);
    if (opts.isEmpty) return const EmptyView(text: '该时段已无可约开始时间');
    if (_startTime != null && !opts.contains(_startTime)) {
      // 时长/套餐变化后同步重置为第一个可选开始时间
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _startTime = opts.first);
      });
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: opts.map((t) {
        final sel = _startTime == t;
        return _ChoiceChip(
          label: t,
          selected: sel,
          onTap: () => setState(() => _startTime = t),
        );
      }).toList(),
    );
  }

  List<String> _startOptions(Store store, int hours) {
    final range = _businessHoursRange(store);
    final open = _minutes(range.$1);
    final close = _minutes(range.$2);
    final maxStart = close - hours * 60;
    final list = <String>[];
    // 今天已过去的开始时间不可预约
    final isToday = _date == _todayStr();
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    for (var m = open; m <= maxStart; m += 60) {
      if (isToday && m <= nowMin) continue;
      list.add(_fmtMin(m));
    }
    return list;
  }

  int _selectedHours(Store store) {
    if (_bookingType == 'package') return _package?.hours ?? 0;
    if (_bookingType == 'all_day') {
      final range = _businessHoursRange(store);
      return ((_minutes(range.$2) - _minutes(range.$1)) / 60).round();
    }
    return _hours;
  }

  /// 当前选择的时段窗口；未选完返回 null
  (String, String)? _windowOf(Store store) {
    if (_date == null) return null;
    if (_bookingType == 'all_day') return _businessHoursRange(store);
    final start = _startTime;
    if (start == null) return null;
    final hours = _selectedHours(store);
    if (hours <= 0) return null;
    return (start, _addHours(start, hours));
  }

  bool _canNext(Store store) => _windowOf(store) != null;

  Widget _bookingSummary(Store store) {
    final w = _windowOf(store)!;
    final hours = _selectedHours(store);
    final unit = _previewUnitPrice(store, hours);
    final label = switch (_bookingType) {
      'package' => '${_package?.name ?? '套餐'} · $hours 小时',
      'all_day' => '全天不限时',
      _ => '$hours 小时',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LiveColors.brandLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label · ${w.$1}-${w.$2}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LiveColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '到店扫码即开始计时，结束时间固定不顺延',
                  style: TextStyle(
                    fontSize: 11,
                    color: LiveColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '¥${unit.toStringAsFixed(0)}/人',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: LiveColors.brand,
            ),
          ),
        ],
      ),
    );
  }

  double _previewUnitPrice(Store store, int hours) {
    if (_bookingType == 'package') return _package?.price ?? 0;
    if (_bookingType == 'all_day') {
      return store.allDayPrice ??
          (store.price * ((_selectedHours(store) == 0 ? 1 : _selectedHours(store))));
    }
    final rate = store.memberPrice != null && store.memberPrice! >= 0
        ? store.memberPrice!
        : store.price;
    return rate * hours;
  }

  Widget _datesRow(Store store) {
    final dates = _nextDates();
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = dates[i];
          final date = DateTime.parse(d);
          final sel = _date == d;
          return InkWell(
            onTap: () {
              setState(() {
                _date = d;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              decoration: BoxDecoration(
                color: sel ? LiveColors.textPrimary : LiveColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? LiveColors.textPrimary : LiveColors.cardBorder,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    i == 0 ? '今天' : i == 1 ? '明天' : '周${'一二三四五六日'[date.weekday - 1]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: sel ? Colors.white : LiveColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : LiveColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${date.month}月',
                    style: TextStyle(
                      fontSize: 10,
                      color: sel ? Colors.white70 : LiveColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 05-门店详情-选择桌位：桌位网格 + 人数 + 价格小计。
class TableSelectScreen extends StatefulWidget {
  const TableSelectScreen({
    super.key,
    required this.store,
    required this.date,
    required this.bookingType,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    this.package,
  });

  final Store store;
  final String date;
  final String bookingType; // hourly / package / all_day
  final String startTime;
  final String endTime;
  final int durationHours;
  final StorePackage? package;

  @override
  State<TableSelectScreen> createState() => _TableSelectScreenState();
}

class _TableSelectScreenState extends State<TableSelectScreen> {
  List<StoreTable> _tables = [];
  Map<int, TableAvailability> _avail = {};
  final Set<int> _selected = {};
  int _people = 2;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final avail = await AppointmentService.instance.availability(
        storeId: widget.store.id,
        date: widget.date,
      );
      if (mounted) {
        setState(() {
          _avail = {for (final a in avail) a.id: a};
          _tables = avail
              .map((a) =>
                  StoreTable(id: a.id, name: a.name, capacity: a.capacity))
              .toList();
        });
        _autoSelect();
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isAvailable(StoreTable t) {
    final w = _avail[t.id];
    if (w == null) return false;
    if (widget.bookingType == 'all_day') {
      return w.bookedWindows.isEmpty;
    }
    return w.isFree(widget.startTime, widget.endTime);
  }

  /// 单人价格（含时长；实际以服务端结算为准，此处为预览）。
  /// 同行 ≥2 人按多人同行价；单人按会员价（有配置时）或门市价。
  double get _unitPrice {
    final store = widget.store;
    final group = _people >= 2;
    if (widget.bookingType == 'package') {
      final p = widget.package;
      if (p == null) return 0;
      if (group && p.groupPrice != null) return p.groupPrice!;
      if (p.memberPrice != null) return p.memberPrice!;
      return p.price;
    }
    if (widget.bookingType == 'all_day') {
      if (group && store.allDayGroupPrice != null) {
        return store.allDayGroupPrice!;
      }
      if (store.allDayMemberPrice != null) return store.allDayMemberPrice!;
      return store.allDayPrice ?? store.price * widget.durationHours;
    }
    if (group && store.groupPrice != null) {
      return store.groupPrice! * widget.durationHours;
    }
    final rate = store.memberPrice != null && store.memberPrice! >= 0
        ? store.memberPrice!
        : store.price;
    return rate * widget.durationHours;
  }

  /// 周末/节假日是否加价（预览，与服务端一致：周六/周日按配置百分比上浮）
  bool get _weekendSurcharge {
    final pct = widget.store.weekendSurchargePercent;
    if (pct <= 0) return false;
    final wd = DateTime.tryParse(widget.date)?.weekday ?? 1;
    return wd == 6 || wd == 7;
  }

  /// 预估总额 = 单价 × 人数（周末加价时上浮）
  double get _totalPrice {
    final base = _unitPrice * _people;
    if (_weekendSurcharge) {
      return base * (100 + widget.store.weekendSurchargePercent) / 100;
    }
    return base;
  }

  String get _bookingLabel {
    return switch (widget.bookingType) {
      'package' => '${widget.package?.name ?? '套餐'} · ${widget.durationHours} 小时',
      'all_day' => '全天不限时',
      _ => '${widget.durationHours} 小时',
    };
  }

  List<StoreTable> get _selectedTables =>
      _tables.where((t) => _selected.contains(t.id)).toList();

  int get _selectedCapacity =>
      _selectedTables.fold(0, (s, t) => s + t.capacity);

  bool get _capacityOk => _selectedCapacity >= _people;

  /// 自动推荐最优桌位组合（锁定推荐，不可手动多加桌）：
  /// 先选「不大于剩余人数」的最大桌，剩余人数用「最小可容纳的桌」补齐。
  /// 例：5 人 → 4人桌+单人桌；无单人桌 → 4人桌+2人桌；无 2 人桌 → 4人桌+4人桌。
  void _autoSelect() {
    final available = _tables.where((t) => _isAvailable(t)).toList();
    if (available.isEmpty) {
      setState(_selected.clear);
      return;
    }
    final rest = [...available];
    final picked = <StoreTable>[];
    var remaining = _people;
    while (remaining > 0 && picked.length < 3) {
      // 先选「不大于剩余人数」的最大桌
      final smaller = rest
          .where((t) => t.capacity <= remaining)
          .toList()
        ..sort((a, b) => b.capacity - a.capacity);
      if (smaller.isNotEmpty) {
        final t = smaller.first;
        picked.add(t);
        rest.remove(t);
        remaining -= t.capacity;
        continue;
      }
      // 没有更小的桌了：用「最小可容纳剩余人数」的桌补齐（如无单人桌用双人桌，无双人桌用 4 人桌）
      final cover = rest
          .where((t) => t.capacity >= remaining)
          .toList()
        ..sort((a, b) => a.capacity - b.capacity);
      if (cover.isEmpty) break;
      final t = cover.first;
      picked.add(t);
      rest.remove(t);
      remaining = 0;
    }
    setState(() {
      _selected.clear();
      if (remaining <= 0) {
        _selected.addAll(picked.map((t) => t.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '选择桌位'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F8),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${store.name} · ${widget.date} '
                                  '${widget.startTime}-${widget.endTime}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: LiveColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$_bookingLabel · 扫码即开始计时，结束时间固定不顺延',
                                  style: const TextStyle(fontSize: 11.6, color: LiveColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Text('选择桌位', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              const Text(
                                '自动推荐最优组合',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: LiveColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_tables.isEmpty)
                            const EmptyView(text: '该门店暂无可用桌位')
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: _tables.length,
                              itemBuilder: (_, i) {
                                final t = _tables[i];
                                final sel = _selected.contains(t.id);
                                final free = _isAvailable(t);
                                return InkWell(
                                  // 系统按人数自动推荐；可点选切换同规格桌位（如 4人桌1 ↔ 4人桌2），
                                  // 但不能换成其他规格组合（避免多选/少选）。
                                  onTap: free
                                      ? () {
                                          if (sel) {
                                            showLiveSnack(
                                              context,
                                              '该桌已在推荐组合中',
                                            );
                                            return;
                                          }
                                          final same = _selectedTables
                                              .where(
                                                (s) =>
                                                    s.capacity == t.capacity,
                                              )
                                              .toList();
                                          if (same.isEmpty) {
                                            showLiveSnack(
                                              context,
                                              '请保持推荐规格（可切换同规格桌位编号）',
                                            );
                                            return;
                                          }
                                          setState(() {
                                            _selected.remove(same.first.id);
                                            _selected.add(t.id);
                                          });
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? LiveColors.textPrimary
                                          : free
                                              ? LiveColors.card
                                              : const Color(0xFFEFEFEF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          t.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: sel
                                                ? Colors.white
                                                : free
                                                    ? LiveColors.textPrimary
                                                    : LiveColors.textTertiary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          free ? '${t.capacity}人' : '满',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: sel
                                                ? Colors.white70
                                                : free
                                                    ? LiveColors.textTertiary
                                                    : LiveColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (_selected.isEmpty && _tables.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            const Text(
                              '当前时段没有合适的桌位组合，请调整时段或联系门店',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: LiveColors.textTertiary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          const Text('到店人数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _RoundBtn(
                                icon: Icons.remove,
                                onTap: _people > 1
                                    ? () {
                                        setState(() => _people--);
                                        _autoSelect();
                                      }
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28),
                                child: Text(
                                  '$_people',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: LiveColors.textPrimary,
                                  ),
                                ),
                              ),
                              _RoundBtn(
                                icon: Icons.add,
                                onTap: _people < 8
                                    ? () {
                                        setState(() => _people++);
                                        _autoSelect();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          if (_selected.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _capacityOk
                                    ? LiveColors.brandLight
                                    : const Color(0xFFFFF3F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '推荐桌位：${_selectedTables.map((t) => t.name).join(' + ')} · 可容纳 $_selectedCapacity 人',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: LiveColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  if (!_capacityOk)
                                    const Text(
                                      '容量不足，请再选桌位',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: LiveColors.danger,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Text(
                                _people >= 2 ? '同行价 ¥' : '单价 ¥',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: LiveColors.textSecondary,
                                ),
                              ),
                              Text(
                                _unitPrice.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
                              ),
                              Text(' / 人 × $_people', style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                              const Spacer(),
                              Text(
                                '¥${_totalPrice.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: LiveColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (_weekendSurcharge) ...[
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '含周末/节假日加价 ${widget.store.weekendSurchargePercent}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: LiveColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          PrimaryButton(
                            label: '确认预约',
                            color: Colors.black,
                            textColor: Colors.white,
                            onTap: _selected.isEmpty || !_capacityOk
                                ? null
                                : () => LiveRoutes.push(
                                    context,
                                    RoutePaths.appointmentConfirm,
                                    extra: {
                                      'type': 'store',
                                      'store': store,
                                      'date': widget.date,
                                      'bookingType': widget.bookingType,
                                      'startTime': widget.startTime,
                                      'endTime': widget.endTime,
                                      'durationHours': widget.durationHours,
                                      'packageName': widget.package?.name ?? '',
                                      'packageId': widget.package?.id,
                                      'packagePrice': widget.package?.price,
                                      'tableIds': _selected.toList(),
                                      'tableLabel': _selectedTables
                                          .map((t) => t.name)
                                          .join(' + '),
                                      'peopleCount': _people,
                                    },
                                  ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFEFEFEF) : LiveColors.textPrimary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: onTap == null ? LiveColors.textTertiary : Colors.white, size: 20),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.no, this.title);

  final String no;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: LiveColors.brand, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(no,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: LiveColors.textPrimary)),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? LiveColors.textPrimary : LiveColors.card;
    final fg = selected ? Colors.white : LiveColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
      ),
    );
  }
}

/// 解析营业时间 "09:00-21:00"，解析失败回退 09:00-22:00。
(String, String) _businessHoursRange(Store store) {
  final m = RegExp(
    r'((?:[01]\d|2[0-3]):[0-5]\d)\s*-\s*((?:[01]\d|2[0-3]):[0-5]\d)',
  ).firstMatch(store.businessHours);
  return m != null ? (m.group(1)!, m.group(2)!) : ('09:00', '22:00');
}

int _minutes(String time) {
  final parts = time.split(':');
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

String _fmtMin(int mins) {
  final h = (mins ~/ 60).toString().padLeft(2, '0');
  final m = (mins % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

String _addHours(String start, int hours) {
  return _fmtMin(_minutes(start) + hours * 60);
}

String _msg(Object? e) =>
    e is ApiException ? e.message : '加载失败，请确认后端服务已启动';
