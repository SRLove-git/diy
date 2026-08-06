import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/app_colors.dart';
import '../../core/appointment_api.dart';
import '../../core/geo_utils.dart';
import '../../core/store_navigation.dart';
import '../../features/member/domain/member_models.dart';
import '../profile/order_list_page.dart';
import 'store_map_view.dart';

/// 预约流程：选「门店/活动」→ 日期/时段（门店）或场次（活动）→ 人数/桌位
/// → 确认（含金额与支付方式）→ 支付并生成预约单
class BookingFlowPage extends StatefulWidget {
  const BookingFlowPage({
    super.key,
    this.initialType = 'store',
    this.initialActivityId,
    this.storesLoader,
    this.locate,
    this.detailLoader,
    this.mapBuilder,
    this.navigationLauncher,
    this.activitiesLoader,
    this.sessionsLoader,
    this.memberLoader,
    this.couponsLoader,
  });

  /// 初始预约类型：store / activity（活动专区进入时直接停在活动 Tab）
  final String initialType;

  /// 活动专区进入时指定的活动：加载后自动选中并直接进入「选场次」步骤
  final int? initialActivityId;

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

  /// 测试注入：外部地图启动（默认 url_launcher）
  final StoreNavigationLauncher? navigationLauncher;

  /// 测试注入：可预约活动列表
  final Future<List<Activity>> Function()? activitiesLoader;

  /// 测试注入：活动场次（含剩余名额）
  final Future<List<ActivitySession>> Function(int activityId)?
      sessionsLoader;

  /// 测试注入：是否有效会员（用于会员价）
  final Future<bool> Function()? memberLoader;

  /// 测试注入：卡包中未使用的优惠券（确认支付页选券用）
  final Future<List<MemberWalletCoupon>> Function()? couponsLoader;

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  int _step = 0; // 0 选门店/活动 1 日期时段(门店)/场次(活动) 2 人数桌位(门店)/人数(活动) 3 确认 4 成功

  // 预约类型
  String _type = 'store';

  // 会员状态（预约计价用）
  bool _isMember = false;

  // 支付方式
  String _payMethod = 'wechat';

  // 卡包优惠券（确认支付页选券用）
  List<MemberWalletCoupon> _walletCoupons = [];
  MemberWalletCoupon? _selectedCoupon;

  // 步骤 0 数据（门店）
  List<Store> _stores = [];
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _storesLoading = true;
  String? _storesError;
  GeoPoint? _userLocation;
  final Map<int, GlobalKey> _storeKeys = {};
  bool _userPicked = false;

  // 步骤 0 数据（活动）
  List<Activity> _activities = [];
  bool _activitiesLoading = false;
  String? _activitiesError;
  bool _sessionsLoading = false;

  /// 是否从活动专区直接进入（锁定该活动，加载后自动跳到场次选择）
  bool _jumpFromZone = false;

  // 已选（门店）
  Store? _store;
  List<TimeSlot> _slots = [];

  // 已选（活动）
  Activity? _activity;
  List<ActivitySession> _sessions = [];
  ActivitySession? _session;

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
    _type = widget.initialType == 'activity' ? 'activity' : 'store';
    _jumpFromZone = widget.initialActivityId != null;
    if (_jumpFromZone) _step = 1;
    _loadStores();
    _loadMemberStatus();
    _loadCoupons();
    if (_type == 'activity') _loadActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberStatus() async {
    try {
      final member = await (widget.memberLoader ??
          AppointmentApi.fetchMemberActive)();
      if (!mounted) return;
      setState(() => _isMember = member);
    } catch (_) {
      // 会员状态获取失败时按非会员计价，不阻塞预约
    }
  }

  /// 加载卡包中未使用的优惠券（失败不阻塞预约，按无券处理）
  Future<void> _loadCoupons() async {
    try {
      final coupons = await (widget.couponsLoader ??
          AppointmentApi.fetchWalletCoupons)();
      if (!mounted) return;
      setState(() => _walletCoupons = coupons);
    } catch (_) {
      // 无优惠券或加载失败时保持空列表
    }
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
        if (!_userPicked && _step == 0 && _type == 'store' && stores.isNotEmpty) {
          _selectStoreSilently(stores.first);
        }
      });
      final location = await locF;
      if (!mounted || location == null) return;
      setState(() {
        _userLocation = location;
        _stores = _sortedByDistance(stores, location);
        if (!_userPicked && _step == 0 && _type == 'store' && _stores.isNotEmpty) {
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

  Future<void> _loadActivities() async {
    setState(() {
      _activitiesLoading = true;
      _activitiesError = null;
    });
    try {
      final activities = await (widget.activitiesLoader ??
          AppointmentApi.fetchActivities)();
      if (!mounted) return;
      final bookable = activities.where((a) => a.bookable).toList();
      final jumpActivity = _jumpFromZone
          ? bookable.where((a) => a.id == widget.initialActivityId).firstOrNull
          : null;
      setState(() {
        _activities = bookable;
        _activitiesLoading = false;
        if (_type == 'activity' &&
            _step == 0 &&
            _activity == null &&
            bookable.isNotEmpty) {
          _activity = bookable.first;
          _prefetchSessions(bookable.first);
        } else if (jumpActivity != null &&
            _type == 'activity' &&
            _activity == null) {
          _activity = jumpActivity;
          _prefetchSessions(jumpActivity);
        }
      });
      // 从活动专区进入：活动确认后自动进入场次选择页（2/4）
      if (jumpActivity != null) _goToSessions();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _activitiesLoading = false;
        _activitiesError = AppointmentApi.messageOf(e);
      });
    }
  }

  /// 按用户定位重排活动（近 → 远）
  List<Activity> _sortedActivities(List<Activity> activities) {
    final location = _userLocation;
    if (location == null) return activities;
    final sorted = List.of(activities);
    sorted.sort((a, b) {
      if (a.lat == null || a.lng == null) return 1;
      if (b.lat == null || b.lng == null) return -1;
      final da = haversineKm(
        location,
        GeoPoint(lat: a.lat!, lng: a.lng!),
      );
      final db = haversineKm(
        location,
        GeoPoint(lat: b.lat!, lng: b.lng!),
      );
      return da.compareTo(db);
    });
    return sorted;
  }

  /// 按用户定位重排门店（近 → 远）
  List<Store> _sortedByDistance(List<Store> stores, GeoPoint location) {
    final sorted = List.of(stores);
    sorted.sort((a, b) {
      // 未配置经纬度的门店排到最后，仍可列表选择
      final aLat = a.lat;
      final aLng = a.lng;
      final bLat = b.lat;
      final bLng = b.lng;
      if (aLat == null || aLng == null) return 1;
      if (bLat == null || bLng == null) return -1;
      final da = haversineKm(location, GeoPoint(lat: aLat, lng: aLng));
      final db = haversineKm(location, GeoPoint(lat: bLat, lng: bLng));
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

  /// 切换预约类型（门店 / 活动）：清空已选状态
  void _switchType(String type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      _step = 0;
      _store = null;
      _slot = null;
      _table = null;
      _activity = null;
      _session = null;
      _sessions = [];
      _people = 1;
      _query = '';
      _searchController.clear();
      if (type == 'activity' && !_activitiesLoading && _activities.isEmpty) {
        _loadActivities();
      }
    });
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

  /// 搜索过滤后的门店（名称/地址模糊匹配，同时作用于地图与列表）
  List<Store> get _visibleStores {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _stores;
    return _stores
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.address.toLowerCase().contains(q),
        )
        .toList();
  }

  /// 搜索过滤后的活动（标题/地址模糊匹配）
  List<Activity> get _visibleActivities {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _sortedActivities(_activities);
    return _sortedActivities(_activities)
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              a.address.toLowerCase().contains(q),
        )
        .toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _selectActivity(Activity activity) {
    setState(() {
      _activity = activity;
      _session = null;
      _sessions = [];
      _people = 1;
    });
    _prefetchSessions(activity);
  }

  Future<void> _prefetchSessions(Activity activity) async {
    setState(() => _sessionsLoading = true);
    try {
      final sessions = await (widget.sessionsLoader ??
          AppointmentApi.fetchActivitySessions)(activity.id);
      if (!mounted || _activity?.id != activity.id) return;
      setState(() {
        _sessions = sessions;
        _sessionsLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _sessionsLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppointmentApi.messageOf(e))));
    }
  }

  void _goToSessions() {
    if (_activity == null) return;
    setState(() => _step = 1);
  }

  void _selectSession(ActivitySession session) {
    setState(() {
      _session = session;
      _people = 1;
    });
  }

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

  // ===== 计价 =====

  /// 单价（元/人）：会员且配置会员价时用会员价，否则门市价
  double get _unitPrice {
    if (_type == 'activity') {
      final a = _activity;
      if (a == null) return 0;
      if (_isMember && a.memberPrice != null) return a.memberPrice!;
      return a.price;
    }
    final s = _store;
    if (s == null) return 0;
    if (_isMember && s.memberPrice != null) return s.memberPrice!;
    return s.price;
  }

  /// 原价单价（划线对比）
  double get _originalUnitPrice {
    if (_type == 'activity') return _activity?.price ?? 0;
    return _store?.price ?? 0;
  }

  /// 是否命中会员价（会员价与门市价不同或为 0 免费）
  bool get _memberPriceApplied {
    if (!_isMember) return false;
    if (_type == 'activity') return _activity?.memberPrice != null;
    return _store?.memberPrice != null;
  }

  double get _totalAmount => _unitPrice * _people;
  double get _originalTotal => _originalUnitPrice * _people;

  /// 当前金额下可用的卡包券（满足门槛且抵扣大于 0）
  List<MemberWalletCoupon> get _usableCoupons {
    final total = _totalAmount;
    return _walletCoupons.where((c) {
      return total >= _couponThresholdOf(c) &&
          _couponDiscountOf(c, total) > 0;
    }).toList();
  }

  /// 当前所选优惠券的抵扣金额
  double get _couponDiscount {
    final c = _effectiveCoupon;
    if (c == null) return 0;
    final d = _couponDiscountOf(c, _totalAmount);
    return d > 0 ? d : 0;
  }

  /// 已选且当前金额仍可用的券（改人数/桌位后可能失效，失效按未选处理）
  MemberWalletCoupon? get _effectiveCoupon {
    final c = _selectedCoupon;
    if (c == null) return null;
    return _usableCoupons.any((x) => x.userCouponId == c.userCouponId)
        ? c
        : null;
  }

  /// 优惠券抵扣后的实付金额
  double get _payAmount => _totalAmount - _couponDiscount;

  /// 解析券额：`¥20` → 现金 20；`8.8 折` → 88% 支付
  static (double value, bool isPercent) _parseCouponAmount(String raw) {
    final percent = RegExp(r'(\d+(?:\.\d+)?)\s*折').firstMatch(raw);
    if (percent != null) {
      return (double.parse(percent.group(1)!), true);
    }
    final cash = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(raw);
    return (cash != null ? double.parse(cash.group(1)!) : 0, false);
  }

  /// 解析使用门槛：`无门槛` → 0；`满 ¥100 可用` → 100
  static double _couponThresholdOf(MemberWalletCoupon coupon) {
    if (coupon.threshold.contains('无门槛')) return 0;
    final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(coupon.threshold);
    return m != null ? double.parse(m.group(1)!) : 0;
  }

  static double _couponDiscountOf(
    MemberWalletCoupon coupon,
    double amount,
  ) {
    final (value, isPercent) = _parseCouponAmount(coupon.amount);
    if (isPercent) return amount * (1 - value / 10);
    return value < amount ? value : amount;
  }

  static String _fmt(double value) {
    if (value == value.roundToDouble()) return '¥${value.toInt()}';
    return '¥${value.toStringAsFixed(2)}';
  }

  static String _payMethodLabel(String method) =>
      method == 'alipay' ? '支付宝' : '微信支付';

  bool get _canNext {
    switch (_step) {
      case 0:
        return _type == 'activity' ? _activity != null : _store != null;
      case 1:
        return _type == 'activity' ? _session != null : _slot != null;
      case 2:
        return _type == 'activity' ? _people >= 1 : _table != null;
      case 3:
        return !_submitting;
      default:
        return false;
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final appt = await AppointmentApi.create(
        type: _type,
        storeId: _type == 'store' ? _store!.id : null,
        tableId: _type == 'store' ? _table!.id : null,
        slotId: _type == 'store' ? _slot!.id : null,
        date: _type == 'store' ? _dateStr() : null,
        activityId: _type == 'activity' ? _activity!.id : null,
        activitySessionId:
            _type == 'activity' ? _session!.id : null,
        peopleCount: _people,
        payMethod: _payMethod,
        userCouponId: int.tryParse(_effectiveCoupon?.userCouponId ?? ''),
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
        0 => _buildSelectStep(context),
        1 => _type == 'activity'
            ? _buildSessionStep(context)
            : _buildSlotStep(context),
        2 => _type == 'activity'
            ? _buildActivityPeopleStep(context)
            : _buildTableStep(context),
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
                          onPressed: _canNext
                              ? (_type == 'activity' ? _goToSessions : _goToSlots)
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
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
                            backgroundColor: colors.primary,
                            foregroundColor: colors.surface,
                          ),
                          child: Text(
                            _step == 3
                                ? (_submitting
                                    ? '支付中…'
                                    : '确认支付 ${_fmt(_payAmount)}')
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
      if (_type == 'store') _loadAvailability();
    } else if (_step == 2) {
      setState(() => _step = 3);
    }
  }

  void _goBack() {
    if (_step == 0) return;
    setState(() => _step--);
  }

  // ===== 步骤 0：选门店 / 活动 =====

  Widget _buildSelectStep(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: _buildTypeToggle(context),
        ),
        Expanded(
          child: _type == 'activity'
              ? _buildActivityStep(context)
              : _buildStoreStep(context),
        ),
      ],
    );
  }

  Widget _buildTypeToggle(BuildContext context) {
    final colors = AppColors.of(context);
    const tabs = [
      (value: 'store', label: '门店预约'),
      (value: 'activity', label: '活动预约'),
    ];
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.placeholder,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _switchType(tabs[i].value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _type == tabs[i].value
                        ? colors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _type == tabs[i].value
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
                    tabs[i].label,
                    style: TextStyle(
                      color: _type == tabs[i].value
                          ? colors.textPrimary
                          : colors.textSecondary,
                      fontSize: 14,
                      fontWeight: _type == tabs[i].value
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            key: const Key('store-search-field'),
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '搜索门店名称 / 地址',
              hintStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('store-search-clear'),
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: _clearSearch,
                    ),
              isDense: true,
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.textPrimary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.textPrimary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.textPrimary),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              Text(
                _query.isEmpty ? '选择门店' : '找到 ${_visibleStores.length} 家门店',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_userLocation != null)
                Text(
                  _query.isEmpty ? '已按距离从近到远排序' : '地图已同步结果',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StoreMapView(
            data: StoreMapViewData(
              stores: _visibleStores,
              userLocation: _userLocation,
              selectedStoreId: _store?.id,
              onSelectStore: _selectFromMap,
            ),
            builder: widget.mapBuilder,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _visibleStores.isEmpty
              ? Center(
                  child: Text(
                    '未找到匹配的门店',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _visibleStores.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _buildStoreCard(context, _visibleStores[i], i),
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
    final hasCoords = s.lat != null && s.lng != null;
    final distance = location == null || !hasCoords
        ? null
        : haversineKm(location, GeoPoint(lat: s.lat!, lng: s.lng!));
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
                      color: Palette.primaryLight,
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
                if (hasCoords)
                  IconButton(
                    key: Key('store-nav-${s.id}'),
                    tooltip: '导航到这家门店',
                    icon: const Icon(Icons.navigation_outlined, size: 22),
                    color: colors.textPrimary,
                    onPressed: () => showStoreNavigationSheet(
                      context,
                      s,
                      launcher: widget.navigationLauncher,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Palette.warning),
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
                Icon(Icons.schedule, size: 16, color: colors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  s.businessHours,
                  style: TextStyle(color: colors.textSecondary),
                ),
                const Spacer(),
                if (s.memberPrice != null && s.memberPrice! < s.price)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.accentSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '会员 ${_fmt(s.memberPrice!)}/人',
                      style: TextStyle(
                        color: Palette.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  '${_fmt(s.price)}/人',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== 步骤 0：活动列表 =====

  Widget _buildActivityStep(BuildContext context) {
    final colors = AppColors.of(context);
    if (_activitiesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_activitiesError != null) {
      return _ErrorRetry(message: _activitiesError!, onRetry: _loadActivities);
    }
    if (_activities.isEmpty) {
      return Center(
        child: Text(
          '暂无可预约活动',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '搜索活动名称 / 地址',
              hintStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: _clearSearch,
                    ),
              isDense: true,
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.textPrimary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.textPrimary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.textPrimary),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              Text(
                _query.isEmpty ? '选择活动' : '找到 ${_visibleActivities.length} 个活动',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_userLocation != null)
                Text(
                  _query.isEmpty ? '已按距离从近到远排序' : '已同步搜索结果',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
            ],
          ),
        ),
        Expanded(
          child: _visibleActivities.isEmpty
              ? Center(
                  child: Text(
                    '未找到匹配的活动',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _visibleActivities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _buildActivityCard(
                    context,
                    _visibleActivities[i],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity a) {
    final colors = AppColors.of(context);
    final selected = _activity?.id == a.id;
    final location = _userLocation;
    final distance =
        location != null && a.lat != null && a.lng != null
            ? haversineKm(location, GeoPoint(lat: a.lat!, lng: a.lng!))
            : null;
    return _Card(
      selected: selected,
      onTap: () => setState(() {
        _selectActivity(a);
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (a.tag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a.tag,
                    style: TextStyle(
                      color: Palette.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              if (selected)
                Icon(Icons.check_circle, color: colors.textPrimary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            a.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule, size: 15, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text(
                a.date,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              if (distance != null) ...[
                const SizedBox(width: 10),
                Icon(Icons.near_me_outlined, size: 14, color: colors.textSecondary),
                const SizedBox(width: 3),
                Text(
                  formatDistanceKm(distance),
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ],
            ],
          ),
          if (a.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.place_outlined, size: 14, color: colors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    a.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          if (a.desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              a.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (a.memberPrice != null) ...[
                Text(
                  _fmt(a.memberPrice!),
                  style: TextStyle(
                    color: Palette.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ' 会员价 / ${_fmt(a.price)}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ] else ...[
                Text(
                  _fmt(a.price),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ' /人',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ===== 步骤 1（活动）：选场次 =====

  Widget _buildSessionStep(BuildContext context) {
    final colors = AppColors.of(context);
    final activity = _activity;
    if (activity == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('选择活动场次', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          activity.title,
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        if (_sessionsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_sessions.isEmpty)
          Text(
            '该活动暂无可预约场次',
            style: TextStyle(color: colors.textSecondary),
          )
        else
          Column(
            children: _sessions.map((session) {
              final selectable = session.remaining > 0;
              final selected = _session?.id == session.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _Card(
                  selected: selected,
                  enabled: selectable,
                  onTap: () => setState(() => _selectSession(session)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_displayDate(session.date)}  ${session.startTime}-${session.endTime}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectable
                                  ? '剩余 ${session.remaining} 个名额'
                                  : '本场次已约满',
                              style: TextStyle(
                                color: selectable
                                    ? colors.textSecondary
                                    : colors.danger,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_circle, color: colors.textPrimary),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ===== 步骤 2（活动）：人数 =====

  Widget _buildActivityPeopleStep(BuildContext context) {
    final colors = AppColors.of(context);
    final session = _session!;
    final maxPeople = session.remaining > 0 ? session.remaining : 1;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('选择人数', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '${_displayDate(session.date)} ${session.startTime}-${session.endTime} · 剩余 ${session.remaining} 个名额',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
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
              onTap: _people < maxPeople
                  ? () => _onPeopleChanged(_people + 1)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '每人 ${_fmt(_unitPrice)}，共 ${_fmt(_totalAmount)}',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  // ===== 步骤 1（门店）：日期 + 时段 =====

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
                    border: Border.all(color: colors.textPrimary),
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
                selectedColor: Palette.primaryLight,
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

  // ===== 步骤 2（门店）：人数 + 桌位 =====

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

  // ===== 步骤 3：确认 + 支付 =====

  Widget _buildConfirmStep(BuildContext context) {
    final colors = AppColors.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_type == 'activity') ...[
          _InfoRow(label: '活动', value: _activity!.title),
          _InfoRow(label: '场次', value: _session!.label),
          if (_activity!.address.isNotEmpty)
            _InfoRow(label: '地点', value: _activity!.address),
        ] else ...[
          _InfoRow(label: '门店', value: _store!.name),
          _InfoRow(label: '日期', value: _dateStr()),
          _InfoRow(label: '时段', value: _slot!.label),
          _InfoRow(
            label: '桌位',
            value: '桌位 ${_table!.name}（可容纳 ${_table!.capacity} 人）',
          ),
        ],
        _InfoRow(label: '人数', value: '$_people 人'),
        const SizedBox(height: 8),
        _buildPriceSection(context),
        const SizedBox(height: 16),
        _buildPayMethodSection(context),
        const SizedBox(height: 8),
        Text(
          '提交后将生成预约码，到店出示即可核销。当前为演示支付，不会真实扣款。',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.placeholder,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _memberPriceApplied ? '会员价' : '单价',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              if (_memberPriceApplied) ...[
                Text(
                  _fmt(_originalUnitPrice),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                '${_fmt(_unitPrice)} × $_people 人',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 优惠券选择
          InkWell(
            onTap: _usableCoupons.isEmpty ? null : _pickCoupon,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.redeem_rounded,
                    size: 18,
                    color: Palette.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _effectiveCoupon?.title ??
                          (_usableCoupons.isEmpty ? '暂无可用优惠券' : '选择优惠券'),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (_effectiveCoupon != null)
                    Text(
                      '-${_fmt(_couponDiscount)}',
                      style: const TextStyle(
                        color: Palette.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),
          if (_couponDiscount > 0) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '优惠券已抵扣 ${_fmt(_couponDiscount)}',
                style: const TextStyle(
                  color: Palette.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '应付金额',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_memberPriceApplied || _couponDiscount > 0) ...[
                Text(
                  _fmt(
                    _memberPriceApplied ? _originalTotal : _totalAmount,
                  ),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                _fmt(_payAmount),
                style: TextStyle(
                  color: Palette.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (_memberPriceApplied && _totalAmount < _originalTotal) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '会员已省 ${_fmt(_originalTotal - _totalAmount)}',
                style: TextStyle(
                  color: Palette.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 选择优惠券底部弹层；barrier 关闭不改变选择，点「不使用」清空
  Future<void> _pickCoupon() async {
    final result = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final colors = AppColors.of(ctx);
        final usable = _usableCoupons;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              const Center(
                child: Text(
                  '选择优惠券',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              if (usable.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '暂无可用优惠券',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                for (final (i, coupon) in usable.indexed) ...[
                  _buildCouponOption(ctx, colors, coupon),
                  if (i < usable.length - 1) const SizedBox(height: 8),
                ],
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, 'NO_COUPON'),
                  child: Text(
                    '不使用优惠券',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == null || !mounted) return;
    if (result == 'NO_COUPON') {
      setState(() => _selectedCoupon = null);
      return;
    }
    setState(() => _selectedCoupon = result as MemberWalletCoupon);
  }

  Widget _buildCouponOption(
    BuildContext ctx,
    AppColors colors,
    MemberWalletCoupon coupon,
  ) {
    final discount = _couponDiscountOf(coupon, _totalAmount);
    final selected = _effectiveCoupon?.userCouponId == coupon.userCouponId;
    return InkWell(
      onTap: () => Navigator.pop(ctx, coupon),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${coupon.threshold} · 有效期至 ${_shortDate(coupon.expireAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '-${_fmt(discount)}',
              style: const TextStyle(
                color: Palette.accent,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Widget _buildPayMethodSection(BuildContext context) {
    final colors = AppColors.of(context);
    const methods = [
      (value: 'wechat', label: '微信支付', icon: Icons.wechat),
      (value: 'alipay', label: '支付宝', icon: Icons.account_balance_wallet),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支付方式',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final m in methods) ...[
              Expanded(
                child: _Card(
                  selected: _payMethod == m.value,
                  onTap: () => setState(() => _payMethod = m.value),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        m.icon,
                        size: 18,
                        color: _payMethod == m.value
                            ? Palette.accent
                            : colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        m.label,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (m.value == 'wechat') const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }

  // ===== 步骤 4：成功 =====

  Widget _buildSuccessStep(BuildContext context) {
    final colors = AppColors.of(context);
    final appt = _appointment!;
    final paid = appt.payStatus == 'paid';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 72, color: Palette.success),
          const SizedBox(height: 16),
          Text('预约成功', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            paid ? '支付成功，到店出示预约码即可核销' : '到店出示预约码即可核销',
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: BoxDecoration(
              color: Palette.primaryLight,
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
            appt.type == 'activity'
                ? '${appt.peopleCount} 人'
                : '桌位 ${appt.tableName} · ${appt.peopleCount} 人',
            style: TextStyle(color: colors.textSecondary),
          ),
          if (paid) ...[
            const SizedBox(height: 4),
            Text(
              '已支付 ${_fmt(appt.amount)}（${_payMethodLabel(appt.payMethod)}）',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
          if (appt.couponDiscount > 0) ...[
            const SizedBox(height: 4),
            Text(
              '优惠券已抵扣 ${_fmt(appt.couponDiscount)}',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
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
      if (_type == 'store' &&
          _table != null &&
          !_availableTables.any((t) => t.id == _table!.id)) {
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

  /// 将 `YYYY-MM-DD` 展示为 `MM-DD 周X`
  String _displayDate(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    final y = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    if (y == 0 || m == 0 || d == 0) return date;
    return '$m-$d ${_weekday(DateTime(y, m, d))}';
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
          color: enabled ? colors.surface : Palette.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.textPrimary,
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
          color: onTap == null ? Palette.surfaceAlt : Palette.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? Palette.textTertiary : colors.textPrimary,
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
