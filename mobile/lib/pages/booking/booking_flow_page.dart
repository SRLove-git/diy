import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/app_colors.dart';
import '../../core/appointment_api.dart';
import '../../core/geo_utils.dart';
import '../profile/order_list_page.dart';
import 'store_map_view.dart';

/// 预约流程：选店 → 日期/时段 → 人数/桌位 → 确认 → 生成预约单
/// 对齐 D4 排期「可完成预约下单」检查点
class BookingFlowPage extends StatefulWidget {
  const BookingFlowPage({
    super.key,
    this.storesLoader,
    this.locate,
    this.detailLoader,
    this.mapBuilder,
  });

  /// 测试注入：门店列表加载
  final Future<List<Store>> Function()? storesLoader;

  /// 测试注入：定位（返回 null 表示未授权/定位失败）
  final Future<GeoPoint?> Function()? locate;

  /// 测试注入：门店详情（时段）
  final Future<
      ({Store store, List<StoreTable> tables, List<TimeSlot> slots})
      > Function(int storeId)? detailLoader;

  /// 测试注入：地图渲染
  final StoreMapBuilder? mapBuilder;

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  int _step = 0; // 0 选店 1 日期时段 2 人数桌位 3 确认 4 成功

  // 步骤 0 数据
  List<Store> _stores = [];
  bool _storesLoading = true;
  String? _storesError;
  GeoPoint? _userLocation;
  final Map<int, GlobalKey> _storeKeys = {};
  bool _userPicked = false;

  // 已选
  Store? _store;
  List<TimeSlot> _slots = [];

  // 步骤 1 数据
  DateTime _date = DateTime.now();
  TimeSlot? _slot;

  // 步骤 2 数据
  int _people = 1;
  List<TableAvailability> _availability = [];
  bool _availabilityLoading = false;
  TableAvailability? _table;

  // 步骤 3 提交
  bool _submitting = false;
  Appointment? _appointment;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _storesLoading = true;
      _storesError = null;
      _userPicked = false;
    });
    try {
      // 门店列表与定位并行请求：列表先展示，定位到位后再按距离重排
      final storesF = (widget.storesLoader ?? AppointmentApi.fetchStores)();
      final locF = (widget.locate ?? _locate)();
      final stores = await storesF;
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _storesLoading = false;
        if (!_userPicked && _step == 0 && stores.isNotEmpty) {
          _selectStoreSilently(stores.first);
        }
      });
      final location = await locF;
      if (!mounted || location == null) return;
      setState(() {
        _userLocation = location;
        _stores = _sortedByDistance(stores, location);
        if (!_userPicked && _step == 0 && _stores.isNotEmpty) {
          _selectStoreSilently(_stores.first);
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _storesError = AppointmentApi.messageOf(e);
        _storesLoading = false;
      });
    }
  }

  /// 按用户定位重排门店（近 → 远）
  List<Store> _sortedByDistance(List<Store> stores, GeoPoint location) {
    final sorted = List.of(stores);
    sorted.sort((a, b) {
      final da = haversineKm(location, GeoPoint(lat: a.lat, lng: a.lng));
      final db = haversineKm(location, GeoPoint(lat: b.lat, lng: b.lng));
      return da.compareTo(db);
    });
    return sorted;
  }

  /// 默认定位实现：请求定位权限后取当前坐标，失败返回 null
  Future<GeoPoint?> _locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return GeoPoint(lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// 选中门店（仅标记，不跳转步骤），并预取时段
  void _selectStoreSilently(Store store) {
    _store = store;
    _slot = null;
    _table = null;
    _availability = [];
    _date = DateTime.now();
    _prefetchDetail(store);
  }

  Future<void> _prefetchDetail(Store store) async {
    try {
      final detail = await (widget.detailLoader ?? AppointmentApi.fetchStoreDetail)(
        store.id,
      );
      if (!mounted || _store?.id != store.id) return;
      setState(() {
        _slots = detail.slots;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppointmentApi.messageOf(e))));
    }
  }

  /// 点击地图标记：选中该门店并滚动列表到对应卡片
  void _selectFromMap(Store store) {
    setState(() {
      _userPicked = true;
      _selectStoreSilently(store);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _keyFor(store).currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  GlobalKey _keyFor(Store store) =>
      _storeKeys.putIfAbsent(store.id, () => GlobalKey());

  void _goToSlots() {
    if (_store == null) return;
    setState(() => _step = 1);
  }

  void _selectSlot(TimeSlot slot) {
    setState(() {
      _slot = slot;
      _table = null;
    });
  }

  Future<void> _loadAvailability() async {
    if (_store == null || _slot == null) return;
    setState(() => _availabilityLoading = true);
    try {
      final list = await AppointmentApi.fetchAvailability(
        _store!.id,
        _dateStr(),
        _slot!.id,
      );
      if (!mounted || _slot == null) return;
      setState(() {
        _availability = list;
        _availabilityLoading = false;
        // 人数变化后校验桌位是否仍可选
        if (_table != null) {
          final still = _availableTables.any((t) => t.id == _table!.id);
          if (!still) _table = null;
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _availabilityLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppointmentApi.messageOf(e))));
    }
  }

  List<TableAvailability> get _availableTables =>
      _availability.where((t) => t.available && t.capacity >= _people).toList();

  String _dateStr() {
    final m = _date.month.toString().padLeft(2, '0');
    final d = _date.day.toString().padLeft(2, '0');
    return '${_date.year}-$m-$d';
  }

  /// 未来 7 天可选日期
  List<DateTime> get _dates {
    final today = DateTime.now();
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  bool get _canNext {
    switch (_step) {
      case 0:
        return _store != null;
      case 1:
        return _slot != null;
      case 2:
        return _table != null;
      case 3:
        return !_submitting;
      default:
        return false;
    }
  }

  Future<void> _submit() async {
    if (_store == null || _slot == null || _table == null) return;
    setState(() => _submitting = true);
    try {
      final appt = await AppointmentApi.create(
        storeId: _store!.id,
        tableId: _table!.id,
        slotId: _slot!.id,
        date: _dateStr(),
        peopleCount: _people,
      );
      if (!mounted) return;
      setState(() {
        _appointment = appt;
        _step = 4;
        _submitting = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppointmentApi.messageOf(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 4 ? '预约成功' : '预约（${_step + 1}/4）'),
        leading: _step == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _step == 4 ? null : _goBack,
              ),
      ),
      body: switch (_step) {
        0 => _buildStoreStep(context),
        1 => _buildSlotStep(context),
        2 => _buildTableStep(context),
        3 => _buildConfirmStep(context),
        _ => _buildSuccessStep(context),
      },
      bottomNavigationBar: _step <= 3
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_step == 0)
                      Expanded(
                        child: FilledButton(
                          onPressed: _canNext ? _goToSlots : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.textPrimary,
                            foregroundColor: colors.surface,
                          ),
                          child: const Text('下一步'),
                        ),
                      )
                    else ...[
                      if (_step > 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _goBack,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.textPrimary,
                              side: BorderSide(color: colors.textPrimary),
                            ),
                            child: const Text('上一步'),
                          ),
                        ),
                      if (_step > 1) const SizedBox(width: 12),
                      Expanded(
                        flex: _step > 1 ? 1 : 2,
                        child: FilledButton(
                          onPressed: _canNext
                              ? (_step == 3 ? _submit : _onNext)
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.textPrimary,
                            foregroundColor: colors.surface,
                          ),
                          child: Text(
                            _step == 3
                                ? (_submitting ? '提交中…' : '确认预约')
                                : '下一步',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _onNext() {
    if (_step == 1) {
      setState(() => _step = 2);
      _loadAvailability();
    } else if (_step == 2) {
      setState(() => _step = 3);
    }
  }

  void _goBack() {
    if (_step == 0) return;
    setState(() => _step--);
  }

  // ===== 步骤 0：选店 =====

  Widget _buildStoreStep(BuildContext context) {
    final colors = AppColors.of(context);
    if (_storesLoading) return const Center(child: CircularProgressIndicator());
    if (_storesError != null) {
      return _ErrorRetry(message: _storesError!, onRetry: _loadStores);
    }
    if (_stores.isEmpty) {
      return Center(
        child: Text(
          '暂无可预约门店',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Text('选择门店', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (_userLocation != null)
                Text(
                  '已按距离从近到远排序',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StoreMapView(
            data: StoreMapViewData(
              stores: _stores,
              userLocation: _userLocation,
              selectedStoreId: _store?.id,
              onSelectStore: _selectFromMap,
            ),
            builder: widget.mapBuilder,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _stores.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _buildStoreCard(context, _stores[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(BuildContext context, Store s, int index) {
    final colors = AppColors.of(context);
    final selected = _store?.id == s.id;
    final isNearest = _userLocation != null && index == 0;
    final location = _userLocation;
    final distance = location == null
        ? null
        : haversineKm(location, GeoPoint(lat: s.lat, lng: s.lng));
    return KeyedSubtree(
      key: _keyFor(s),
      child: _Card(
        key: Key('store-card-${s.id}'),
        selected: selected,
        onTap: () => setState(() {
          _userPicked = true;
          _selectStoreSilently(s);
        }),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isNearest) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4DA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '最近',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (selected)
                  Icon(Icons.check_circle, color: colors.textPrimary),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Color(0xFFFFB300)),
                const SizedBox(width: 2),
                Text(
                  '${s.rating}',
                  style: TextStyle(color: colors.textSecondary),
                ),
                if (distance != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    formatDistanceKm(distance),
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ],
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  s.businessHours,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== 步骤 1：日期 + 时段 =====

  Widget _buildSlotStep(BuildContext context) {
    final colors = AppColors.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('选择日期', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final d = _dates[i];
              final selected = _dateStr() == _dateStrFrom(d);
              final isToday = i == 0;
              return InkWell(
                onTap: () => setState(() => _date = d),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  decoration: BoxDecoration(
                    color: selected ? colors.textPrimary : colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? colors.textPrimary : colors.divider,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekday(d),
                        style: TextStyle(
                          color: selected ? colors.surface : colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          color: selected ? colors.surface : colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isToday)
                        Text(
                          '今天',
                          style: TextStyle(
                            color: selected ? colors.surface : colors.textPrimary,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text('选择时段', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_slots.isEmpty)
          Text(
            '该门店暂未配置可约时段',
            style: TextStyle(color: colors.textSecondary),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _slots.map((slot) {
              final selected = _slot?.id == slot.id;
              return ChoiceChip(
                label: Text(slot.label),
                selected: selected,
                selectedColor: const Color(0xFFFFE4DA),
                labelStyle: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => _selectSlot(slot),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ===== 步骤 2：人数 + 桌位 =====

  Widget _buildTableStep(BuildContext context) {
    final colors = AppColors.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('选择人数', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            _StepperBtn(
              icon: Icons.remove,
              onTap: _people > 1 ? () => _onPeopleChanged(_people - 1) : null,
            ),
            const SizedBox(width: 16),
            Text('$_people 人', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 16),
            _StepperBtn(
              icon: Icons.add,
              onTap: () => _onPeopleChanged(_people + 1),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('选择桌位', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_availabilityLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_availability.isEmpty)
          Text(
            '该时段暂无桌位',
            style: TextStyle(color: colors.textSecondary),
          )
        else
          Column(
            children: _availability.map((t) {
              final selectable = t.available && t.capacity >= _people;
              final selected = _table?.id == t.id && selectable;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _Card(
                  selected: selected,
                  enabled: selectable,
                  onTap: () => setState(() => _table = t),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '桌位 ${t.name}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (!selectable) ...[
                              const SizedBox(height: 2),
                              Text(
                                !t.available
                                    ? '已被预约或使用中'
                                    : '最多容纳 ${t.capacity} 人',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '可容纳 ${t.capacity} 人',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      if (selected)
                        Icon(
                          Icons.check_circle,
                          color: colors.textPrimary,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ===== 步骤 3：确认 =====

  Widget _buildConfirmStep(BuildContext context) {
    final colors = AppColors.of(context);
    final store = _store!;
    final slot = _slot!;
    final table = _table!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(label: '门店', value: store.name),
        _InfoRow(label: '日期', value: _dateStr()),
        _InfoRow(label: '时段', value: slot.label),
        _InfoRow(label: '人数', value: '$_people 人'),
        _InfoRow(
          label: '桌位',
          value: '桌位 ${table.name}（可容纳 ${table.capacity} 人）',
        ),
        const SizedBox(height: 8),
        Text(
          '提交后将生成预约码，到店出示即可核销。',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  // ===== 步骤 4：成功 =====

  Widget _buildSuccessStep(BuildContext context) {
    final colors = AppColors.of(context);
    final appt = _appointment!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 72, color: Color(0xFF4CAF50)),
          const SizedBox(height: 16),
          Text('预约成功', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '到店出示预约码即可核销',
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4DA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              appt.code,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${appt.storeName} · ${appt.date} ${appt.startTime}-${appt.endTime}',
            style: TextStyle(color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '桌位 ${appt.tableName} · ${appt.peopleCount} 人',
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: colors.textPrimary,
                foregroundColor: colors.surface,
              ),
              child: const Text('完成'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrderListPage()),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.textPrimary),
              ),
              child: const Text('查看我的订单'),
            ),
          ),
        ],
      ),
    );
  }

  void _onPeopleChanged(int v) {
    setState(() {
      _people = v;
      if (_table != null && !_availableTables.any((t) => t.id == _table!.id)) {
        _table = null;
      }
    });
  }

  String _dateStrFrom(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _weekday(DateTime d) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${names[d.weekday - 1]}';
  }
}

class _Card extends StatelessWidget {
  const _Card({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.enabled = true,
  });

  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? colors.surface : const Color(0xFFF0EEEA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.textPrimary : colors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: child,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFF0F0F0)
              : const Color(0xFFFFE4DA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null
              ? const Color(0xFFBDBDBD)
              : colors.textPrimary,
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: TextStyle(color: colors.textSecondary)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.textPrimary),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
