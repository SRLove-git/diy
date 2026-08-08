import 'dart:math' as math;

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
                const LiveAppBar(title: '附近门店'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '附近门店'), Expanded(child: LoadingView())],
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
                title: '附近门店',
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
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 150, width: double.infinity, child: NetImage(url: store.cover)),
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
                      const Icon(Icons.place_outlined, size: 13, color: LiveColors.textTertiary),
                      const SizedBox(width: 2),
                      Text(
                        _distanceKm(store.lat, store.lng),
                        style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary),
                      ),
                      const Spacer(),
                      Text(
                        '¥${store.price.toStringAsFixed(0)}/人',
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

/// 门店距离（基于上海静安中心点粗略估算；无经纬度显示 --）
String _distanceKm(double? lat, double? lng) {
  if (lat == null || lng == null) return '--';
  const baseLat = 31.2304;
  const baseLng = 121.4737;
  const r = 6371.0;
  double rad(double d) => d * 3.141592653589793 / 180;
  final dLat = rad(lat - baseLat);
  final dLng = rad(lng - baseLng);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(baseLat)) *
          math.cos(rad(lat)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final km = r * 2 * math.asin(math.sqrt(a));
  return km < 1 ? '距您 ${(km * 1000).round()}m' : '距您 ${km.toStringAsFixed(1)}km';
}

class StoreSearchScreen extends StatefulWidget {
  const StoreSearchScreen({super.key});

  @override
  State<StoreSearchScreen> createState() => _StoreSearchScreenState();
}

class _StoreSearchScreenState extends State<StoreSearchScreen> {
  List<Store> _all = [];
  final _query = TextEditingController();
  String _sort = 'default'; // default / nearest
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
    if (_sort == 'nearest') {
      list.sort((a, b) {
        final da = _distanceValue(a.lat, a.lng);
        final db = _distanceValue(b.lat, b.lng);
        return da.compareTo(db);
      });
    }
    return list;
  }

  double _distanceValue(double? lat, double? lng) {
    if (lat == null || lng == null) return double.infinity;
    const baseLat = 31.2304;
    const baseLng = 121.4737;
    return (lat - baseLat) * (lat - baseLat) + (lng - baseLng) * (lng - baseLng);
  }

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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
            child: Row(
              children: [
                for (final t in [
                  ('default', '全部'),
                  ('nearest', '距离最近'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => setState(() => _sort = t.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _sort == t.$1 ? LiveColors.textPrimary : LiveColors.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          t.$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _sort == t.$1 ? Colors.white : LiveColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                InkWell(
                  onTap: () => LiveRoutes.replace(
                    context,
                    RoutePaths.storeList,
                  ),
                  child: const Text(
                    '地图模式 ›',
                    style: TextStyle(fontSize: 13, color: LiveColors.brand),
                  ),
                ),
              ],
            ),
          ),
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
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
  TimeSlot? _slot;

  @override
  void initState() {
    super.initState();
    _future = StoreService.instance.detail(widget.storeId);
  }

  void _retry() => setState(() {
        _future = StoreService.instance.detail(widget.storeId);
        _slot = null;
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
                    SizedBox(height: 180, width: double.infinity, child: NetImage(url: store.cover, radius: 16)),
                    const SizedBox(height: 14),
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
                      '门市 ¥${store.price.toStringAsFixed(2)}'
                      '${store.memberPrice != null && store.memberPrice! > 0 ? '　会员 ¥${store.memberPrice!.toStringAsFixed(2)}' : store.memberPrice == 0 ? '　会员免费' : ''}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    const _StepTitle('1', '选择日期'),
                    _datesRow(store),
                    const SizedBox(height: 18),
                    const _StepTitle('2', '选择时段'),
                    if (store.slots.isEmpty)
                      const EmptyView(text: '暂无可约时段')
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: store.slots.map((s) {
                          final sel = _slot?.id == s.id;
                          return _ChoiceChip(
                            label: s.label,
                            selected: sel,
                            onTap: () => setState(() => _slot = s),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 26),
                    PrimaryButton(
                      label: '下一步 · 选择桌位',
                      color: Colors.black,
                      textColor: Colors.white,
                      onTap: _date == null || _slot == null
                          ? null
                          : () {
                              LiveRoutes.push(
                                context,
                                RoutePaths.storeTableSelect,
                                extra: {
                                  'store': store,
                                  'date': _date!,
                                  'slot': _slot!,
                                },
                              );
                            },
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

  Widget _datesRow(Store store) {
    final dates = _nextDates();
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
    required this.slot,
  });

  final Store store;
  final String date;
  final TimeSlot slot;

  @override
  State<TableSelectScreen> createState() => _TableSelectScreenState();
}

class _TableSelectScreenState extends State<TableSelectScreen> {
  List<StoreTable> _tables = [];
  StoreTable? _table;
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
      final tables = await AppointmentService.instance.availability(
        storeId: widget.store.id,
        date: widget.date,
        slotId: widget.slot.id,
      );
      if (mounted) setState(() => _tables = tables);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _unitPrice =>
      widget.store.memberPrice != null && widget.store.memberPrice! > 0
          ? widget.store.memberPrice!
          : widget.store.price;

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
                                  '${store.name} · ${widget.date} ${widget.slot.label}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: LiveColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  '同店同桌同时段不重复预约',
                                  style: TextStyle(fontSize: 11.6, color: LiveColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text('选择桌位', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          if (_tables.isEmpty)
                            const EmptyView(text: '该时段暂无可用桌位')
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.95,
                              ),
                              itemCount: _tables.length,
                              itemBuilder: (_, i) {
                                final t = _tables[i];
                                final sel = _table?.id == t.id;
                                return InkWell(
                                  onTap: t.available ? () => setState(() => _table = t) : null,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? LiveColors.textPrimary
                                          : t.available
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
                                                : t.available
                                                    ? LiveColors.textPrimary
                                                    : LiveColors.textTertiary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          t.available ? '${t.capacity}人' : '满',
                                          style: TextStyle(
                                            fontSize: 10.6,
                                            color: sel
                                                ? Colors.white70
                                                : t.available
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
                          const SizedBox(height: 18),
                          const Text('到店人数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _RoundBtn(
                                icon: Icons.remove,
                                onTap: _people > 1
                                    ? () => setState(() => _people--)
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
                                    ? () => setState(() => _people++)
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              const Text('会员价 ¥', style: TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                              Text(
                                _unitPrice.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
                              ),
                              Text(' / 人 × $_people', style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                              const Spacer(),
                              Text(
                                '¥${(_unitPrice * _people).toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: LiveColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            label: '确认预约',
                            color: Colors.black,
                            textColor: Colors.white,
                            onTap: _table == null
                                ? null
                                : () => LiveRoutes.push(
                                    context,
                                    RoutePaths.appointmentConfirm,
                                    extra: {
                                      'type': 'store',
                                      'store': store,
                                      'date': widget.date,
                                      'slot': widget.slot,
                                      'table': _table!,
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

String _msg(Object? e) =>
    e is ApiException ? e.message : '加载失败，请确认后端服务已启动';
