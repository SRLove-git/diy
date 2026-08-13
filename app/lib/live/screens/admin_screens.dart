import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_ext.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

/// ===== 管理端模块（仅管理员账号在首页可见入口） =====
///
/// - 扫码核销：扫/输用户出示的 6 位核销码，核销预约（上钟）或优惠券；
/// - 订单管理：预约订单（确认/核销/取消/下钟）+ 会员开通申请（确认/取消）；
/// - 会员运营：会员列表、套餐上架状态、优惠券启停。

/// 扫码核销：扫码或输码 → 查询 → 确认核销。
class AdminRedeemScreen extends StatefulWidget {
  const AdminRedeemScreen({super.key});

  @override
  State<AdminRedeemScreen> createState() => _AdminRedeemScreenState();
}

class _AdminRedeemScreenState extends State<AdminRedeemScreen> {
  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();
  Appointment? _appointment;
  Coupon? _coupon;
  bool _searching = false;
  bool _redeeming = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _query([String? raw]) async {
    final code = (raw ?? _codeCtrl.text).trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(code)) {
      showLiveSnack(context, context.l10n.adminRedeemCodeInvalid);
      return;
    }
    _codeCtrl.text = code;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _appointment = null;
      _coupon = null;
      _error = null;
    });

    Appointment? appt;
    try {
      appt = await AdminAppointmentService.instance.findByCode(code);
    } on ApiException {
      appt = null;
    }

    Coupon? coupon;
    String? error;
    if (appt == null) {
      try {
        coupon = await AdminMemberService.instance.findCouponByCode(code);
      } on ApiException catch (e) {
        error = e.message;
      }
    }
    if (!mounted) return;
    setState(() {
      _appointment = appt;
      _coupon = coupon;
      _error = error;
      _searching = false;
    });
  }

  Future<void> _redeemAppointment() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    setState(() => _redeeming = true);
    try {
      final a = await AdminAppointmentService.instance.checkInByCode(code);
      if (!mounted) return;
      HomeOrdersRefresh.instance.refresh(a);
      showLiveSnack(context, context.l10n.adminAppointmentCheckedIn);
      setState(() => _appointment = a);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  Future<void> _redeemCoupon() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    setState(() => _redeeming = true);
    try {
      final c = await AdminMemberService.instance.redeemCouponByCode(code);
      if (!mounted) return;
      showLiveSnack(context, context.l10n.adminCouponRedeemed);
      setState(() => _coupon = c);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  Future<void> _openScanner() async {
    final code = await LiveRoutes.push<String>(context, RoutePaths.adminScan);
    if (code == null || !mounted || code.isEmpty) return;
    _codeCtrl.text = code;
    await _query(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LivePage(
      // 键盘覆盖页面而不是压缩页面，保持布局稳定
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          LiveAppBar(title: l10n.adminRedeem),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // 扫码入口
                InkWell(
                  onTap: _searching ? null : _openScanner,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LiveGradients.brand,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF3C3674,
                          ).withValues(alpha: 0.22),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 46,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.adminScanPrompt,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.adminScanHint,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xCCFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.adminRedeemOrEnter,
                        style: const TextStyle(
                          fontSize: 12.6,
                          color: LiveColors.textTertiary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeCtrl,
                        focusNode: _codeFocus,
                        maxLength: 6,
                        textCapitalization: TextCapitalization.characters,
                        // 键盘覆盖页面时，聚焦输入框自动上滚到键盘上方（滚动余量 260）
                        scrollPadding: const EdgeInsets.only(bottom: 260),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                          color: LiveColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: l10n.adminRedeemCodeHint,
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            letterSpacing: 0,
                            color: LiveColors.textTertiary,
                          ),
                          filled: true,
                          fillColor: LiveColors.card,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp('[A-Za-z0-9]'),
                          ),
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) => newValue.copyWith(
                              text: newValue.text.toUpperCase(),
                              selection: TextSelection.collapsed(
                                offset: newValue.text.length,
                              ),
                            ),
                          ),
                        ],
                        onSubmitted: (_) => _query(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 76,
                      height: 52,
                      child: PrimaryButton(
                        label: l10n.adminQuery,
                        height: 52,
                        loading: _searching,
                        onTap: _searching ? null : _query,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_searching)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: LoadingView(text: l10n.adminQuerying),
                  )
                else ...[
                  if (_appointment != null)
                    _RedeemAppointmentCard(
                      appointment: _appointment!,
                      redeeming: _redeeming,
                      onRedeem: _redeemAppointment,
                    ),
                  if (_coupon != null)
                    _RedeemCouponCard(
                      coupon: _coupon!,
                      redeeming: _redeeming,
                      onRedeem: _redeemCoupon,
                    ),
                  if (_error != null && _appointment == null && _coupon == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LiveColors.danger.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: LiveColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: LiveColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RedeemAppointmentCard extends StatelessWidget {
  const _RedeemAppointmentCard({
    required this.appointment,
    required this.redeeming,
    required this.onRedeem,
  });

  final Appointment appointment;
  final bool redeeming;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final l10n = context.l10n;
    final table = a.tableLabel.isEmpty ? '' : ' · ${a.tableLabel}';
    return _ResultCard(
      icon: Icons.event_available_outlined,
      title: a.title,
      lines: [
        '${a.date} ${a.startTime}-${a.endTime} · ${l10n.activityPeople(a.peopleCount)}$table',
        '${l10n.homeCode(a.code)} · ${_appointmentStatusLabel(l10n, a.status)}',
        if (a.amount > 0) '${l10n.appointmentAmount} \$${fmtPrice(a.amount)}',
        if (a.couponTitle.isNotEmpty)
          l10n.adminCouponDiscount(a.couponTitle, '-\$${fmtPrice(a.couponDiscount)}'),
      ],
      action: switch (a.status) {
        'booked' => _CardAction(
          label: l10n.adminConfirmRedeem,
          loading: redeeming,
          color: LiveColors.brand,
          onTap: onRedeem,
        ),
        'pending' => null,
        _ => null,
      },
      hint: switch (a.status) {
        'pending' => l10n.adminApptHintPending,
        'checked_in' || 'in_service' => l10n.adminApptHintCheckedIn,
        'completed' => l10n.adminApptHintCompleted,
        'cancelled' => l10n.adminApptHintCancelled,
        _ => null,
      },
    );
  }
}

class _RedeemCouponCard extends StatelessWidget {
  const _RedeemCouponCard({
    required this.coupon,
    required this.redeeming,
    required this.onRedeem,
  });

  final Coupon coupon;
  final bool redeeming;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final c = coupon;
    final l10n = context.l10n;
    final expire =
        c.expireAt == null ? '' : '${l10n.memberValidUntil} ${_fmtDate(c.expireAt!)}';
    return _ResultCard(
      icon: Icons.confirmation_number_outlined,
      title: c.title,
      lines: [
        if (c.userNickname.isNotEmpty) l10n.adminCouponUser(c.userNickname),
        if (c.userEmail != null && c.userEmail!.isNotEmpty)
          l10n.adminCouponEmail(c.userEmail!),
        l10n.adminCouponAmountLine(
          '\$${fmtPrice(c.amount)}',
          _couponThresholdLabel(l10n, c.threshold),
        ),
        l10n.adminCouponCodeStatus(
          c.code,
          _couponStatusLabel(l10n, c.status),
        ),
        if (expire.isNotEmpty) expire,
      ],
      action: c.status == 'unused'
          ? _CardAction(
              label: l10n.adminConfirmRedeem,
              loading: redeeming,
              color: LiveColors.brand,
              onTap: onRedeem,
            )
          : null,
      hint: c.status == 'used'
          ? l10n.adminCouponHintUsed
          : c.status == 'expired'
          ? l10n.adminCouponHintExpired
          : null,
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.title,
    required this.lines,
    this.action,
    this.hint,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final _CardAction? action;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LiveColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C3674).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: LiveColors.brandLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: LiveColors.brand),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: LiveColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: const TextStyle(
                  fontSize: 12.6,
                  color: LiveColors.textSecondary,
                ),
              ),
            ),
          if (action != null) ...[const SizedBox(height: 12), action!],
          if (hint != null) ...[
            const SizedBox(height: 10),
            Text(
              hint!,
              style: const TextStyle(
                fontSize: 12,
                color: LiveColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 全屏扫码页：识别到二维码后自动关闭并把内容（核销码）带回上一页。
class AdminScanScreen extends StatefulWidget {
  const AdminScanScreen({super.key});

  @override
  State<AdminScanScreen> createState() => _AdminScanScreenState();
}

class _AdminScanScreenState extends State<AdminScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;
    _handled = true;
    unawaited(_controller.stop());
    Navigator.of(context).pop(raw.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LivePage(
      fullBleed: true,
      statusBarLight: true,
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      l10n.adminRedeem,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () {
                        unawaited(
                          _controller.toggleTorch().catchError((_) => false),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.cameraswitch_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        unawaited(
                          _controller.switchCamera().catchError((_) {}),
                        );
                      },
                    ),
                  ],
                ),
                const Spacer(),
                // 取景框
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    size: 120,
                    color: Color(0x66FFFFFF),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.adminScanAutoHint,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 订单管理：预约订单 + 会员开通申请。
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LivePage(
      // 键盘覆盖页面而不是压缩页面，保持布局稳定
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          LiveAppBar(title: l10n.adminOrders),
          _AdminTabBar(
            tabs: [l10n.adminOrdersTab, l10n.adminMemberOrdersTab],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [_AppointmentOrdersTab(), _MemberOrdersTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentOrdersTab extends StatefulWidget {
  const _AppointmentOrdersTab();

  @override
  State<_AppointmentOrdersTab> createState() => _AppointmentOrdersTabState();
}

class _AppointmentOrdersTabState extends State<_AppointmentOrdersTab> {
  final _searchCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Appointment> _items = [];
  List<Store> _stores = [];
  String _status = '';
  int? _storeId;
  String? _date;
  int _page = 1;
  int _gen = 0;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  DateTime _now = DateTime.now();
  Timer? _refreshTimer;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load(reset: true);
    unawaited(_loadStores());
    // 服务中订单的时长每秒走动
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_items.any((a) => a.status == 'in_service')) {
        setState(() => _now = DateTime.now());
      }
    });
    // 每 30 秒静默刷新，状态与时间自动更新（对齐网页管理端）
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _load(reset: true, silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tickTimer?.cancel();
    _searchCtrl.dispose();
    _codeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    try {
      final stores = await StoreService.instance.list();
      if (mounted) setState(() => _stores = stores);
    } catch (_) {
      // 门店筛选加载失败时仅不显示门店选项
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _load();
    }
  }

  Future<void> _load({bool reset = false, bool silent = false}) async {
    if (reset) {
      _gen += 1;
      _page = 1;
      _hasMore = true;
    } else if (_loading || !_hasMore) {
      return;
    }
    final gen = _gen;
    final page = _page;
    if (!silent) {
      setState(() {
        _loading = true;
        if (reset) _error = null;
      });
    }
    try {
      final keyword = _searchCtrl.text.trim();
      final code = _codeCtrl.text.trim();
      final r = await AdminAppointmentService.instance.list(
        status: _status.isEmpty ? null : _status,
        keyword: keyword.isEmpty ? null : keyword,
        code: code.isEmpty ? null : code,
        storeId: _storeId,
        date: _date,
        page: page,
      );
      if (!mounted || gen != _gen) return;
      setState(() {
        _items = reset ? r.items : [..._items, ...r.items];
        _hasMore = _items.length < r.total;
        if (r.items.isNotEmpty) _page = page + 1;
      });
    } on ApiException catch (e) {
      if (!mounted || gen != _gen) return;
      if (!silent) {
        setState(() {
          _error = e.message;
          if (reset) _items = [];
        });
      }
    } finally {
      if (mounted && gen == _gen && !silent) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _runAction(
    Appointment a,
    Future<Appointment> Function(int id) action,
    String success,
  ) async {
    try {
      final r = await action(a.id);
      if (!mounted) return;
      if (r.status == 'in_service') {
        HomeOrdersRefresh.instance.refresh(r);
      }
      showLiveSnack(context, success);
      await _load(reset: true);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _confirmCancel(Appointment a) async {
    final l10n = context.l10n;
    final ok = await _confirmDialog(
      context,
      title: l10n.appointmentCancel,
      desc: l10n.adminCancelAppointmentDesc(a.title),
    );
    if (ok == true && mounted) {
      await _runAction(
        a,
        AdminAppointmentService.instance.cancel,
        context.l10n.appointmentCancelled,
      );
    }
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_date ?? '');
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
    _load(reset: true);
  }

  void _resetFilters() {
    _searchCtrl.clear();
    _codeCtrl.clear();
    setState(() {
      _status = '';
      _storeId = null;
      _date = null;
    });
    _load(reset: true);
  }

  void _showOrderDetail(Appointment a) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OrderDetailSheet(appointment: a, now: _now),
    );
  }

  Widget _buildFilters() {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LiveColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: _storeId,
                    isExpanded: true,
                    hint: Text(
                      l10n.adminAllStores,
                      style: const TextStyle(
                        fontSize: 13,
                        color: LiveColors.textSecondary,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: LiveColors.textPrimary,
                    ),
                    items: [
                      for (final s in _stores)
                        DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _stores.isEmpty
                        ? null
                        : (v) {
                            setState(() => _storeId = v);
                            _load(reset: true);
                          },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: LiveColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: LiveColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _date ?? l10n.adminDate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: LiveColors.textPrimary,
                        ),
                      ),
                      if (_date != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() => _date = null);
                            _load(reset: true);
                          },
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: LiveColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    color: LiveColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: l10n.adminRedeemCodeHint,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: LiveColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) => newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                        selection: TextSelection.collapsed(
                          offset: newValue.text.length,
                        ),
                      ),
                    ),
                  ],
                  onSubmitted: (_) => _load(reset: true),
                ),
              ),
              const SizedBox(width: 8),
              _ActionChip(label: l10n.adminQuery, onTap: () => _load(reset: true)),
              const SizedBox(width: 6),
              _ActionChip(
                label: l10n.adminReset,
                color: LiveColors.textSecondary,
                onTap: _resetFilters,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statuses = [
      ('', l10n.commonAll),
      ('pending', l10n.appointmentStatusPending),
      ('booked', l10n.appointmentStatusBooked),
      ('checked_in', l10n.appointmentStatusCheckedIn),
      ('in_service', l10n.appointmentStatusInService),
      ('completed', l10n.appointmentStatusCompleted),
      ('cancelled', l10n.appointmentStatusCancelled),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.adminSearchUserHint,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: LiveColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: LiveColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: LiveColors.card,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _load(reset: true),
                ),
              ),
              const SizedBox(width: 8),
              _ActionChip(
                label: l10n.adminRedeemAction,
                color: LiveColors.success,
                onTap: () => LiveRoutes.push(context, RoutePaths.adminRedeem),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            children: [
              for (final (value, label) in statuses)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: label,
                    selected: _status == value,
                    onTap: () {
                      if (_status == value) return;
                      setState(() => _status = value);
                      _load(reset: true);
                    },
                  ),
                ),
            ],
          ),
        ),
        _buildFilters(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _load(reset: true),
            color: LiveColors.brand,
            child: _items.isEmpty && _loading && _error == null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 120), LoadingView()],
                  )
                : ListView(
                    controller: _scrollCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ErrorView(
                            message: _error!,
                            onRetry: () => _load(reset: true),
                          ),
                        ),
                      if (_items.isEmpty && _error == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: EmptyView(
                            text: l10n.adminNoOrders,
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),
                      for (final a in _items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AppointmentOrderCard(
                            appointment: a,
                            now: _now,
                            onTap: () => _showOrderDetail(a),
                            onConfirm: () => _runAction(
                              a,
                              AdminAppointmentService.instance.confirm,
                              l10n.adminAppointmentConfirmed,
                            ),
                            onCheckIn: () => _runAction(
                              a,
                              AdminAppointmentService.instance.checkIn,
                              l10n.adminAppointmentCheckedIn,
                            ),
                            onClockIn: () => _runAction(
                              a,
                              AdminAppointmentService.instance.clockIn,
                              l10n.adminClockInSuccess,
                            ),
                            onClockOut: () => _runAction(
                              a,
                              AdminAppointmentService.instance.clockOut,
                              l10n.adminClockOutSuccess,
                            ),
                            onCancel: () => _confirmCancel(a),
                          ),
                        ),
                      if (_hasMore && _items.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: LiveColors.brand,
                              ),
                            ),
                          ),
                        ),
                      if (!_hasMore && _items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              l10n.adminNoMore,
                              style: const TextStyle(
                                fontSize: 12,
                                color: LiveColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentOrderCard extends StatelessWidget {
  const _AppointmentOrderCard({
    required this.appointment,
    required this.now,
    required this.onTap,
    required this.onConfirm,
    required this.onCheckIn,
    required this.onClockIn,
    required this.onClockOut,
    required this.onCancel,
  });

  final Appointment appointment;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onConfirm;
  final VoidCallback onCheckIn;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final l10n = context.l10n;
    final user =
        a.userNickname.isNotEmpty ? a.userNickname : l10n.commonUserId(a.userId);
    final table = a.tableLabel.isEmpty ? '' : ' · ${a.tableLabel}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LiveColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                ),
                TagChip(
                  label: _appointmentStatusLabel(l10n, a.status),
                  color: _appointmentStatusColor(a.status),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              a.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: LiveColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${a.date} ${a.startTime}-${a.endTime} · ${l10n.activityPeople(a.peopleCount)}$table',
              style: const TextStyle(
                fontSize: 12,
                color: LiveColors.textTertiary,
              ),
            ),
            if (a.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.appointmentNote} ${a.note}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.6,
                  color: LiveColors.textTertiary,
                ),
              ),
            ],
            if (a.serviceStartTime != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.adminServiceDuration(_serviceDuration(a, now)),
                style: const TextStyle(
                  fontSize: 11.6,
                  color: LiveColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${fmtPrice(a.amount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: LiveColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.adminCodeShort(a.code),
                  style: const TextStyle(
                    fontSize: 11.6,
                    color: LiveColors.textTertiary,
                  ),
                ),
                const Spacer(),
                if (a.status == 'pending') ...[
                  _ActionChip(label: l10n.commonConfirm, onTap: onConfirm),
                  const SizedBox(width: 8),
                  _ActionChip(
                    label: l10n.commonCancel,
                    color: LiveColors.danger,
                    onTap: onCancel,
                  ),
                ] else if (a.status == 'booked') ...[
                  _ActionChip(label: l10n.adminRedeemAction, onTap: onCheckIn),
                  const SizedBox(width: 8),
                  _ActionChip(
                    label: l10n.commonCancel,
                    color: LiveColors.danger,
                    onTap: onCancel,
                  ),
                ] else if (a.status == 'checked_in') ...[
                  _ActionChip(label: l10n.adminClockIn, onTap: onClockIn),
                ] else if (a.status == 'in_service') ...[
                  _ActionChip(label: l10n.adminClockOut, onTap: onClockOut),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 订单详情底部弹层：补齐网页端的时间列（核销 / 上钟 / 下钟 / 时长）与备注。
class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({required this.appointment, required this.now});

  final Appointment appointment;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final l10n = context.l10n;
    final user =
        a.userNickname.isNotEmpty ? a.userNickname : l10n.commonUserId(a.userId);
    final table = a.tableLabel.isEmpty ? '—' : a.tableLabel;
    final booking = a.type == 'activity'
        ? l10n.activityTitle
        : a.bookingType == 'all_day'
        ? l10n.storeAllDay
        : a.bookingType == 'package' && a.packageName.isNotEmpty
        ? context.memberName(a.packageName)
        : a.durationHours != null
        ? l10n.adminDurationHours(a.durationHours!)
        : l10n.storeBookingTypeHourly;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LiveColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                ),
                TagChip(
                  label: _appointmentStatusLabel(l10n, a.status),
                  color: _appointmentStatusColor(a.status),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _detailRow(l10n.appointmentCodeLabel, a.code),
            _detailRow(l10n.adminUser, user),
            if (a.userEmail != null && a.userEmail!.isNotEmpty)
              _detailRow(l10n.adminEmail, a.userEmail!),
            _detailRow(l10n.appointmentStore, a.storeName),
            _detailRow(
              l10n.adminTypeTable,
              a.type == 'activity' ? l10n.activityTitle : table,
            ),
            _detailRow(
              l10n.adminTimeSlot,
              '$booking · ${a.date} ${a.startTime}-${a.endTime}',
            ),
            _detailRow(
              l10n.appointmentPeopleCountLabel,
              l10n.appointmentPeople(a.peopleCount),
            ),
            _detailRow(l10n.appointmentAmount, '\$${fmtPrice(a.amount)}'),
            if (a.couponTitle.isNotEmpty)
              _detailRow(
                l10n.appointmentCoupon,
                l10n.adminCouponDiscount(
                  a.couponTitle,
                  '-\$${fmtPrice(a.couponDiscount)}',
                ),
              ),
            _detailRow(l10n.appointmentNote, a.note.isEmpty ? '—' : a.note),
            _detailRow(
              l10n.adminStatus,
              _appointmentStatusLabel(l10n, a.status),
            ),
            _detailRow(l10n.adminCheckInTime, _fmtTime(a.checkInTime)),
            _detailRow(l10n.appointmentStartTime, _fmtTime(a.serviceStartTime)),
            _detailRow(l10n.appointmentEndTime, _fmtTime(a.serviceEndTime)),
            _detailRow(
              l10n.adminServiceDurationLabel,
              a.serviceStartTime == null ? '—' : _serviceDuration(a, now),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberOrdersTab extends StatefulWidget {
  const _MemberOrdersTab();

  @override
  State<_MemberOrdersTab> createState() => _MemberOrdersTabState();
}

class _MemberOrdersTabState extends State<_MemberOrdersTab> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<MemberOrder> _items = [];
  String _status = '';
  int _page = 1;
  int _gen = 0;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load(reset: true);
    // 每 30 秒静默刷新，状态自动更新（对齐网页管理端）
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _load(reset: true, silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _load();
    }
  }

  Future<void> _load({bool reset = false, bool silent = false}) async {
    if (reset) {
      _gen += 1;
      _page = 1;
      _hasMore = true;
    } else if (_loading || !_hasMore) {
      return;
    }
    final gen = _gen;
    final page = _page;
    if (!silent) {
      setState(() {
        _loading = true;
        if (reset) _error = null;
      });
    }
    try {
      final keyword = _searchCtrl.text.trim();
      final r = await AdminMemberService.instance.orders(
        keyword: keyword.isEmpty ? null : keyword,
        status: _status.isEmpty ? null : _status,
        page: page,
      );
      if (!mounted || gen != _gen) return;
      setState(() {
        _items = reset ? r.items : [..._items, ...r.items];
        _hasMore = _items.length < r.total;
        if (r.items.isNotEmpty) _page = page + 1;
      });
    } on ApiException catch (e) {
      if (!mounted || gen != _gen) return;
      if (!silent) {
        setState(() {
          _error = e.message;
          if (reset) _items = [];
        });
      }
    } finally {
      if (mounted && gen == _gen && !silent) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _runAction(
    MemberOrder o,
    Future<void> Function(int id) action,
    String success,
  ) async {
    try {
      await action(o.id);
      if (!mounted) return;
      showLiveSnack(context, success);
      await _load(reset: true);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _confirmCancel(MemberOrder o) async {
    final l10n = context.l10n;
    final ok = await _confirmDialog(
      context,
      title: l10n.adminCancelMemberOrderTitle,
      desc: l10n.adminCancelMemberOrderDesc(o.planName),
    );
    if (ok == true && mounted) {
      await _runAction(
        o,
        AdminMemberService.instance.cancelOrder,
        context.l10n.adminMemberOrderCancelled,
      );
    }
  }

  Future<void> _confirmOrder(MemberOrder o) async {
    final l10n = context.l10n;
    final user =
        o.userNickname.isNotEmpty ? o.userNickname : l10n.adminMemberOrderId(o.id);
    final ok = await _confirmDialog(
      context,
      title: l10n.adminConfirmMemberTitle,
      desc: l10n.adminConfirmMemberDesc(
        user,
        o.planName,
        o.durationDays,
        '\$${fmtPrice(o.amount)}',
      ),
    );
    if (ok == true && mounted) {
      await _runAction(
        o,
        AdminMemberService.instance.confirmOrder,
        context.l10n.adminMemberConfirmed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statuses = [
      ('', l10n.commonAll),
      ('pending', l10n.appointmentStatusPending),
      ('confirmed', l10n.adminMemberStatusConfirmed),
      ('cancelled', l10n.appointmentStatusCancelled),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
          child: TextField(
            controller: _searchCtrl,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: l10n.adminSearchUserHint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: LiveColors.textTertiary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: LiveColors.textTertiary,
              ),
              filled: true,
              fillColor: LiveColors.card,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _load(reset: true),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            children: [
              for (final (value, label) in statuses)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: label,
                    selected: _status == value,
                    onTap: () {
                      if (_status == value) return;
                      setState(() => _status = value);
                      _load(reset: true);
                    },
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _load(reset: true),
            color: LiveColors.brand,
            child: _items.isEmpty && _loading && _error == null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 120), LoadingView()],
                  )
                : ListView(
                    controller: _scrollCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ErrorView(
                            message: _error!,
                            onRetry: () => _load(reset: true),
                          ),
                        ),
                      if (_items.isEmpty && _error == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: EmptyView(
                            text: l10n.adminMemberOrdersNo,
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),
                      for (final o in _items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MemberOrderCard(
                            order: o,
                            onConfirm: () => _confirmOrder(o),
                            onCancel: () => _confirmCancel(o),
                          ),
                        ),
                      if (_hasMore && _items.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: LiveColors.brand,
                              ),
                            ),
                          ),
                        ),
                      if (!_hasMore && _items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              l10n.adminNoMore,
                              style: const TextStyle(
                                fontSize: 12,
                                color: LiveColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _MemberOrderCard extends StatelessWidget {
  const _MemberOrderCard({
    required this.order,
    required this.onConfirm,
    required this.onCancel,
  });

  final MemberOrder order;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final l10n = context.l10n;
    final user =
        o.userNickname.isNotEmpty ? o.userNickname : l10n.adminMemberOrderId(o.id);
    final createdAt = o.createdAt == null ? '' : _fmtDateTime(o.createdAt!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LiveColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LiveColors.textPrimary,
                  ),
                ),
              ),
              TagChip(
                label: _memberOrderStatusLabel(l10n, o.status),
                color: _memberOrderStatusColor(o.status),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adminPlanDays(context.memberName(o.planName), o.durationDays),
            style: const TextStyle(
              fontSize: 13,
              color: LiveColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            createdAt,
            style: const TextStyle(
              fontSize: 11.6,
              color: LiveColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '\$${fmtPrice(o.amount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LiveColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (o.status == 'pending') ...[
                _ActionChip(label: l10n.adminConfirmMemberAction, onTap: onConfirm),
                const SizedBox(width: 8),
                _ActionChip(
                  label: l10n.commonCancel,
                  color: LiveColors.danger,
                  onTap: onCancel,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 会员运营：会员列表 / 套餐 / 优惠券。
class AdminMembersScreen extends StatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  State<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends State<AdminMembersScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LivePage(
      // 键盘覆盖页面而不是压缩页面，保持布局稳定
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          LiveAppBar(title: l10n.adminMembers),
          _AdminTabBar(
            tabs: [
              l10n.adminMembersTab,
              l10n.adminPlansTab,
              l10n.adminCouponsTab,
            ],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [_MembersTab(), _PlansTab(), _CouponsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersTab extends StatefulWidget {
  const _MembersTab();

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<AdminMembership> _items = [];
  int _page = 1;
  int _gen = 0;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _gen += 1;
      _page = 1;
      _hasMore = true;
    } else if (_loading || !_hasMore) {
      return;
    }
    final gen = _gen;
    final page = _page;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final keyword = _searchCtrl.text.trim();
      final r = await AdminMemberService.instance.memberships(
        keyword: keyword.isEmpty ? null : keyword,
        page: page,
      );
      if (!mounted || gen != _gen) return;
      setState(() {
        _items = reset ? r.items : [..._items, ...r.items];
        _hasMore = _items.length < r.total;
        if (r.items.isNotEmpty) _page = page + 1;
      });
    } on ApiException catch (e) {
      if (!mounted || gen != _gen) return;
      setState(() {
        _error = e.message;
        if (reset) _items = [];
      });
    } finally {
      if (mounted && gen == _gen) setState(() => _loading = false);
    }
  }

  Future<void> _openCreate() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MembershipFormSheet(
        defaultLevel: context.l10n.adminLevelDefault,
      ),
    );
    if (created == true && mounted) {
      showLiveSnack(context, context.l10n.adminMemberCreated);
      await _load(reset: true);
    }
  }

  Future<void> _openEdit(AdminMembership m) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MembershipFormSheet(membership: m),
    );
    if (saved == true && mounted) {
      showLiveSnack(context, context.l10n.adminMemberSaved);
      await _load(reset: true);
    }
  }

  Future<void> _confirmDelete(AdminMembership m) async {
    final l10n = context.l10n;
    final ok = await _confirmDialog(
      context,
      title: l10n.adminDeleteMemberTitle,
      desc: l10n.adminDeleteMemberDesc(m.memberNo, m.userName),
    );
    if (ok != true || !mounted) return;
    try {
      await AdminMemberService.instance.deleteMembership(m.id);
      if (!mounted) return;
      showLiveSnack(context, context.l10n.adminMemberDeleted);
      await _load(reset: true);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.adminSearchMemberHint,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: LiveColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: LiveColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: LiveColors.card,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _load(reset: true),
                ),
              ),
              const SizedBox(width: 8),
              _ActionChip(label: l10n.adminOpenMember, onTap: _openCreate),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _load(reset: true),
            color: LiveColors.brand,
            child: _items.isEmpty && _loading && _error == null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 120), LoadingView()],
                  )
                : ListView(
                    controller: _scrollCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ErrorView(
                            message: _error!,
                            onRetry: () => _load(reset: true),
                          ),
                        ),
                      if (_items.isEmpty && _error == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: EmptyView(
                            text: l10n.adminNoMembers,
                            icon: Icons.workspace_premium_outlined,
                          ),
                        ),
                      for (final m in _items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MembershipCard(
                            membership: m,
                            onEdit: () => _openEdit(m),
                            onDelete: () => _confirmDelete(m),
                          ),
                        ),
                      if (_hasMore && _items.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: LiveColors.brand,
                              ),
                            ),
                          ),
                        ),
                      if (!_hasMore && _items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              l10n.adminNoMore,
                              style: const TextStyle(
                                fontSize: 12,
                                color: LiveColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.membership,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminMembership membership;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final m = membership;
    final l10n = context.l10n;
    final expire = m.expireAt == null ? '—' : _fmtDate(m.expireAt!);
    final updated = m.updatedAt == null ? '' : _fmtDateTime(m.updatedAt!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LiveColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LiveGradients.brand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: LiveColors.textPrimary,
                        ),
                      ),
                    ),
                    TagChip(
                      label: _membershipStatusLabel(l10n, m.status),
                      color: m.status == 'active'
                          ? LiveColors.success
                          : LiveColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${m.memberNo} · ${context.memberName(m.levelName)}',
                  style: const TextStyle(
                    fontSize: 12.6,
                    color: LiveColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.memberValidUntil} $expire',
                  style: const TextStyle(
                    fontSize: 11.6,
                    color: LiveColors.textTertiary,
                  ),
                ),
                if (updated.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      l10n.adminLastUpdated(updated),
                      style: const TextStyle(
                        fontSize: 11.6,
                        color: LiveColors.textTertiary,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ActionChip(label: l10n.commonEdit, onTap: onEdit),
                    const SizedBox(width: 8),
                    _ActionChip(
                      label: l10n.commonDelete,
                      color: LiveColors.danger,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 开通 / 编辑会员底部表单（对齐网页管理端：用户 ID + 等级 + 有效期，可按套餐快捷填充）。
class _MembershipFormSheet extends StatefulWidget {
  const _MembershipFormSheet({this.membership, this.defaultLevel});

  final AdminMembership? membership;
  final String? defaultLevel;

  @override
  State<_MembershipFormSheet> createState() => _MembershipFormSheetState();
}

class _MembershipFormSheetState extends State<_MembershipFormSheet> {
  final _userIdCtrl = TextEditingController();
  final _levelCtrl = TextEditingController();
  DateTime? _expireAt;
  int? _planId;
  List<MemberPlan> _plans = [];
  bool _saving = false;

  bool get _editing => widget.membership != null;

  @override
  void initState() {
    super.initState();
    final m = widget.membership;
    _levelCtrl.text = m?.levelName ?? widget.defaultLevel ?? '手作会员';
    _expireAt = m?.expireAt ?? DateTime.now().add(const Duration(days: 30));
    unawaited(_loadPlans());
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _levelCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await AdminMemberService.instance.plans();
      if (mounted) setState(() => _plans = plans);
    } catch (_) {
      // 套餐拉取失败不影响手动选择有效期
    }
  }

  Future<void> _pickExpireAt() async {
    final base = _expireAt ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    setState(() {
      _expireAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _fillExpireFromPlan(int? planId) {
    setState(() => _planId = planId);
    for (final p in _plans) {
      if (p.id == planId) {
        setState(() {
          _expireAt = DateTime.now().add(Duration(days: p.durationDays));
        });
        return;
      }
    }
  }

  Future<void> _save() async {
    final expire = _expireAt;
    if (expire == null) {
      showLiveSnack(context, context.l10n.adminNeedExpire);
      return;
    }
    int? userId;
    if (!_editing) {
      userId = int.tryParse(_userIdCtrl.text.trim());
      if (userId == null || userId <= 0) {
        showLiveSnack(context, context.l10n.adminNeedUserId);
        return;
      }
    }
    setState(() => _saving = true);
    try {
      final levelName = _levelCtrl.text.trim();
      if (_editing) {
        await AdminMemberService.instance.updateMembership(
          widget.membership!.id,
          levelName: levelName,
          expireAt: expire,
        );
      } else {
        await AdminMemberService.instance.createMembership(
          userId: userId!,
          levelName: levelName,
          expireAt: expire,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LiveColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _editing ? l10n.adminEditMember : l10n.adminOpenMember,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (!_editing) ...[
                _FormField(
                  label: l10n.adminUserIdLabel,
                  hint: l10n.adminUserIdHint,
                  controller: _userIdCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],
              _FormField(
                label: l10n.adminMemberLevel,
                hint: l10n.adminLevelDefault,
                controller: _levelCtrl,
              ),
              const SizedBox(height: 12),
              _FormField(
                label: l10n.memberValidUntil,
                hint: _expireAt == null ? l10n.adminSelectTime : _fmtDateTime(_expireAt!),
                readOnly: true,
                onTap: _pickExpireAt,
                trailing: const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: LiveColors.textSecondary,
                ),
              ),
              if (!_editing && _plans.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FormField(
                  label: l10n.adminFillByPlan,
                  hint: l10n.adminNoPlanHint,
                  planDropdown: _planId,
                  plans: _plans,
                  onPlanChanged: _fillExpireFromPlan,
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: l10n.commonCancel,
                      height: 44,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.commonSave,
                      height: 44,
                      loading: _saving,
                      onTap: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlansTab extends StatefulWidget {
  const _PlansTab();

  @override
  State<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<_PlansTab> {
  late Future<List<MemberPlan>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminMemberService.instance.plans();
  }

  void _retry() => setState(() {
    _future = AdminMemberService.instance.plans();
  });

  Future<void> _toggle(MemberPlan plan, bool enabled) async {
    try {
      await AdminMemberService.instance.togglePlan(plan.id, enabled);
      if (!mounted) return;
      showLiveSnack(
        context,
        enabled ? context.l10n.adminPlanEnabled : context.l10n.adminPlanDisabled,
      );
      _retry();
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
      _retry();
    }
  }

  Future<void> _openCreate() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PlanFormSheet(),
    );
    if (saved == true && mounted) {
      showLiveSnack(context, context.l10n.adminPlanSaved);
      _retry();
    }
  }

  Future<void> _openEdit(MemberPlan plan) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanFormSheet(plan: plan),
    );
    if (saved == true && mounted) {
      showLiveSnack(context, context.l10n.adminPlanSaved);
      _retry();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 2),
          child: Row(
            children: [
              Text(
                l10n.adminPlansManage,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const Spacer(),
              _ActionChip(label: l10n.adminAddPlan, onTap: _openCreate),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MemberPlan>>(
            future: _future,
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(
                  child: ErrorView(
                    message: snap.error is ApiException
                        ? (snap.error as ApiException).message
                        : l10n.commonLoadFailed,
                    onRetry: _retry,
                  ),
                );
              }
              if (!snap.hasData) {
                return const LoadingView();
              }
              final plans = snap.data!;
              if (plans.isEmpty) {
                return EmptyView(
                  text: l10n.adminNoPlans,
                  icon: Icons.card_membership_outlined,
                );
              }
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  for (final p in plans)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PlanCard(
                        plan: p,
                        onEdit: () => _openEdit(p),
                        onToggle: (v) => _toggle(p, v),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.onEdit,
    required this.onToggle,
  });

  final MemberPlan plan;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final p = plan;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LiveColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LiveColors.textPrimary,
                  ),
                ),
              ),
              if (p.badge.isNotEmpty)
                TagChip(
                  label: context.memberName(p.badge),
                  color: LiveColors.blue,
                ),
              if (p.recommended) ...[
                const SizedBox(width: 6),
                TagChip(label: l10n.memberRecommended, color: LiveColors.success),
              ],
              const SizedBox(width: 6),
              Switch(
                value: p.enabled,
                onChanged: onToggle,
                activeTrackColor: LiveColors.success,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.adminPlanDurationPrice(p.durationDays, '\$${fmtPrice(p.price)}')}'
            '${p.originalPrice > 0 ? l10n.adminPlanOriginalPrice('\$${fmtPrice(p.originalPrice)}') : ''}',
            style: const TextStyle(
              fontSize: 13,
              color: LiveColors.textSecondary,
            ),
          ),
          if (p.benefits.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              p.benefits
                  .map((b) => context.memberBenefit(b))
                  .join(' · '),
              style: const TextStyle(
                fontSize: 11.6,
                color: LiveColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_ActionChip(label: l10n.commonEdit, onTap: onEdit)],
          ),
        ],
      ),
    );
  }
}

/// 新增 / 编辑套餐底部表单（对齐网页管理端字段）。
class _PlanFormSheet extends StatefulWidget {
  const _PlanFormSheet({this.plan});

  final MemberPlan? plan;

  @override
  State<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<_PlanFormSheet> {
  final _nameCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _originalCtrl = TextEditingController();
  final _badgeCtrl = TextEditingController();
  final _benefitsCtrl = TextEditingController();
  bool _recommended = false;
  bool _enabled = true;
  bool _saving = false;

  bool get _editing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    if (p != null) {
      _nameCtrl.text = p.name;
      _daysCtrl.text = '${p.durationDays}';
      _priceCtrl.text = fmtPrice(p.price);
      _originalCtrl.text = fmtPrice(p.originalPrice);
      _badgeCtrl.text = p.badge;
      _benefitsCtrl.text = p.benefits.join('\n');
      _recommended = p.recommended;
      _enabled = p.enabled;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _daysCtrl.dispose();
    _priceCtrl.dispose();
    _originalCtrl.dispose();
    _badgeCtrl.dispose();
    _benefitsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final days = int.tryParse(_daysCtrl.text.trim());
    final price = double.tryParse(_priceCtrl.text.trim());
    final original = double.tryParse(_originalCtrl.text.trim());
    if (name.isEmpty) {
      showLiveSnack(context, context.l10n.adminNeedPlanName);
      return;
    }
    if (days == null || days <= 0) {
      showLiveSnack(context, context.l10n.adminNeedPlanDays);
      return;
    }
    if (price == null || price < 0 || original == null || original < 0) {
      showLiveSnack(context, context.l10n.adminNeedPlanPrice);
      return;
    }
    final body = <String, dynamic>{
      'name': name,
      'durationDays': days,
      'price': price,
      'originalPrice': original,
      'benefits': _benefitsCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'badge': _badgeCtrl.text.trim(),
      'recommended': _recommended,
      'enabled': _enabled,
    };
    setState(() => _saving = true);
    try {
      if (_editing) {
        await AdminMemberService.instance.updatePlan(widget.plan!.id, body);
      } else {
        await AdminMemberService.instance.createPlan(body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LiveColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _editing ? l10n.adminEditPlan : l10n.adminAddPlan,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _FormField(
                label: l10n.adminPlanName,
                hint: l10n.adminPlanNameHint,
                controller: _nameCtrl,
              ),
              const SizedBox(height: 12),
              _FormField(
                label: l10n.adminDurationDays,
                hint: '30',
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: l10n.adminPrice,
                      hint: '199',
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FormField(
                      label: l10n.appointmentOriginalPrice,
                      hint: '299',
                      controller: _originalCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FormField(
                label: l10n.adminBadge,
                hint: l10n.adminBadgeHint,
                controller: _badgeCtrl,
              ),
              const SizedBox(height: 12),
              _FormField(
                label: l10n.adminBenefitsLabel,
                hint: l10n.adminBenefitsHint,
                controller: _benefitsCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SwitchRow(
                      label: l10n.adminRecommendedPlan,
                      value: _recommended,
                      onChanged: (v) => setState(() => _recommended = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SwitchRow(
                      label: l10n.adminPublishNow,
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: l10n.commonCancel,
                      height: 44,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.commonSave,
                      height: 44,
                      loading: _saving,
                      onTap: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CouponsTab extends StatefulWidget {
  const _CouponsTab();

  @override
  State<_CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends State<_CouponsTab> {
  late Future<List<Coupon>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminMemberService.instance.coupons();
  }

  void _retry() => setState(() {
    _future = AdminMemberService.instance.coupons();
  });

  Future<void> _toggle(Coupon coupon, bool enabled) async {
    try {
      await AdminMemberService.instance.toggleCoupon(coupon.id, enabled);
      if (!mounted) return;
      showLiveSnack(
        context,
        enabled ? context.l10n.adminCouponEnabled : context.l10n.adminCouponDisabled,
      );
      _retry();
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
      _retry();
    }
  }

  Future<void> _openCreate() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CouponFormSheet(),
    );
    if (saved == true && mounted) {
      showLiveSnack(context, context.l10n.adminCouponSaved);
      _retry();
    }
  }

  Future<void> _openEdit(Coupon coupon) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CouponFormSheet(coupon: coupon),
    );
    if (saved == true && mounted) {
      showLiveSnack(context, context.l10n.adminCouponSaved);
      _retry();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.adminCouponsManage,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const Spacer(),
              _ActionChip(
                label: l10n.adminRedeemAction,
                color: LiveColors.success,
                onTap: () => LiveRoutes.push(context, RoutePaths.adminRedeem),
              ),
              const SizedBox(width: 6),
              _ActionChip(label: l10n.adminAddCoupon, onTap: _openCreate),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: FutureBuilder<List<Coupon>>(
              future: _future,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                  child: ErrorView(
                    message: snap.error is ApiException
                        ? (snap.error as ApiException).message
                        : l10n.commonLoadFailed,
                    onRetry: _retry,
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const LoadingView();
                }
                final coupons = snap.data!;
                if (coupons.isEmpty) {
                  return EmptyView(
                    text: l10n.adminNoCoupons,
                    icon: Icons.confirmation_number_outlined,
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    for (final c in coupons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CouponCard(
                          coupon: c,
                          onEdit: () => _openEdit(c),
                          onToggle: (v) => _toggle(c, v),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.onEdit,
    required this.onToggle,
  });

  final Coupon coupon;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final c = coupon;
    final l10n = context.l10n;
    final expire = c.expireAt == null ? '—' : _fmtDate(c.expireAt!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LiveColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LiveColors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: c.enabled,
                onChanged: onToggle,
                activeTrackColor: LiveColors.success,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adminCouponStockLine(
              '\$${fmtPrice(c.amount)}',
              _couponThresholdLabel(l10n, c.threshold),
              c.stock,
            ),
            style: const TextStyle(
              fontSize: 13,
              color: LiveColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${l10n.memberValidUntil} $expire · '
            '${c.membersOnly ? l10n.adminMembersOnly : l10n.adminAllCanClaim}',
            style: const TextStyle(
              fontSize: 11.6,
              color: LiveColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_ActionChip(label: l10n.commonEdit, onTap: onEdit)],
          ),
        ],
      ),
    );
  }
}

/// 新增 / 编辑优惠券底部表单（对齐网页管理端字段）。
class _CouponFormSheet extends StatefulWidget {
  const _CouponFormSheet({this.coupon});

  final Coupon? coupon;

  @override
  State<_CouponFormSheet> createState() => _CouponFormSheetState();
}

class _CouponFormSheetState extends State<_CouponFormSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  DateTime? _expireAt;
  bool _membersOnly = true;
  bool _enabled = true;
  bool _saving = false;

  bool get _editing => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    if (c != null) {
      _titleCtrl.text = c.title;
      _amountCtrl.text = c.amountRaw.isNotEmpty
          ? c.amountRaw
          : fmtPrice(c.amount);
      _thresholdCtrl.text = _thresholdPrefill(c.threshold);
      _stockCtrl.text = '${c.stock}';
      _expireAt = c.expireAt;
      _membersOnly = c.membersOnly;
      _enabled = c.enabled;
    } else {
      _thresholdCtrl.text = '0';
      _expireAt = DateTime.now().add(const Duration(days: 30));
    }
  }

  /// 旧数据门槛换算为数字：无门槛 → 0；`满 $100 可用` → 100。
  String _thresholdPrefill(String raw) {
    if (raw == '无门槛') return '0';
    final m = RegExp(r'\d+(?:\.\d+)?').firstMatch(raw);
    return m?.group(0) ?? '0';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _thresholdCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpireAt() async {
    final base = _expireAt ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    setState(() {
      _expireAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final amount = _amountCtrl.text.trim();
    final threshold = _thresholdCtrl.text.trim();
    final stock = int.tryParse(_stockCtrl.text.trim());
    final expire = _expireAt;
    if (title.isEmpty || amount.isEmpty || threshold.isEmpty) {
      showLiveSnack(context, context.l10n.adminNeedCouponFields);
      return;
    }
    final thresholdValue = double.tryParse(threshold);
    if (thresholdValue == null || thresholdValue < 0) {
      showLiveSnack(context, context.l10n.adminNeedThresholdNumber);
      return;
    }
    if (stock == null || stock < 0) {
      showLiveSnack(context, context.l10n.adminNeedStock);
      return;
    }
    if (expire == null) {
      showLiveSnack(context, context.l10n.adminNeedExpireTime);
      return;
    }
    final body = <String, dynamic>{
      'title': title,
      'amount': amount,
      'threshold': threshold,
      'expireAt': expire.toIso8601String(),
      'stock': stock,
      'membersOnly': _membersOnly,
      'enabled': _enabled,
    };
    setState(() => _saving = true);
    try {
      if (_editing) {
        await AdminMemberService.instance.updateCoupon(widget.coupon!.id, body);
      } else {
        await AdminMemberService.instance.createCoupon(body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LiveColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _editing ? l10n.adminEditCoupon : l10n.adminAddCoupon,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _FormField(
                label: l10n.adminCouponName,
                hint: l10n.adminCouponNameHint,
                controller: _titleCtrl,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: l10n.adminAmountText,
                      hint: l10n.adminAmountHint,
                      controller: _amountCtrl,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FormField(
                      label: l10n.adminThreshold,
                      hint: l10n.adminThresholdHint,
                      controller: _thresholdCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FormField(
                label: l10n.adminStock,
                hint: '0',
                controller: _stockCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _FormField(
                label: l10n.adminExpireTime,
                hint: _expireAt == null ? l10n.adminSelectTime : _fmtDateTime(_expireAt!),
                readOnly: true,
                onTap: _pickExpireAt,
                trailing: const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: LiveColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SwitchRow(
                      label: l10n.adminMembersOnlyClaim,
                      value: _membersOnly,
                      onChanged: (v) => setState(() => _membersOnly = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SwitchRow(
                      label: l10n.adminPublishNow,
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: l10n.commonCancel,
                      height: 44,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.commonSave,
                      height: 44,
                      loading: _saving,
                      onTap: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 底部表单通用字段：文本输入 / 只读展示（点击选择）/ 套餐下拉。
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.trailing,
    this.planDropdown,
    this.plans = const [],
    this.onPlanChanged,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? trailing;
  final int? planDropdown;
  final List<MemberPlan> plans;
  final ValueChanged<int?>? onPlanChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.6,
            color: LiveColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (plans.isNotEmpty && onPlanChanged != null)
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: LiveColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: planDropdown,
                isExpanded: true,
                hint: Text(
                  hint ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: LiveColors.textTertiary,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 13.6,
                  color: LiveColors.textPrimary,
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      hint ?? context.l10n.adminNoPlanShort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  for (final p in plans)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        context.l10n.adminPlanOption(
                          context.memberName(p.name),
                          p.durationDays,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onPlanChanged,
              ),
            ),
          )
        else if (readOnly)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: LiveColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hint ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.6,
                        color: LiveColors.textPrimary,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          )
        else
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: LiveColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: LiveColors.textTertiary,
              ),
              filled: true,
              fillColor: LiveColors.card,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: LiveColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: LiveColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: LiveColors.success,
          ),
        ],
      ),
    );
  }
}

/// 顶部 Tab 切换（白底 + 选中黑字下划线）。
class _AdminTabBar extends StatelessWidget {
  const _AdminTabBar({
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 6),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LiveColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: index == i
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF3C3674,
                              ).withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: index == i
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: index == i
                          ? LiveColors.textPrimary
                          : LiveColors.textSecondary,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? LiveColors.brand : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? LiveColors.brand : LiveColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            height: 1.0,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : LiveColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.onTap,
    this.color = LiveColors.brand,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.6,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

Future<bool> _confirmDialog(
  BuildContext context, {
  required String title,
  required String desc,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: LiveColors.textPrimary,
        ),
      ),
      content: Text(
        desc,
        style: const TextStyle(
          fontSize: 13.6,
          color: LiveColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            context.l10n.commonCancel,
            style: const TextStyle(
              fontSize: 14,
              color: LiveColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            context.l10n.commonConfirm,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: LiveColors.danger,
            ),
          ),
        ),
      ],
    ),
  );
  return ok == true;
}

/// 预约状态展示名（跟随语言）。
String _appointmentStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'pending' => l10n.appointmentStatusPending,
      'booked' => l10n.appointmentStatusBooked,
      'checked_in' => l10n.appointmentStatusCheckedIn,
      'in_service' => l10n.appointmentStatusInService,
      'completed' => l10n.appointmentStatusCompleted,
      'cancelled' => l10n.appointmentStatusCancelled,
      _ => status,
    };

String _memberOrderStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'pending' => l10n.appointmentStatusPending,
      'confirmed' => l10n.adminMemberStatusConfirmed,
      'cancelled' => l10n.appointmentStatusCancelled,
      _ => status,
    };

String _membershipStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'active' => l10n.adminMemberStatusConfirmed,
      'expired' => l10n.memberExpired,
      _ => status,
    };

String _couponStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'unused' => l10n.adminCouponStatusUnused,
      'used' => l10n.adminCouponStatusUsed,
      'expired' => l10n.memberExpired,
      _ => status,
    };

/// 服务端优惠券门槛（无门槛 / 满 $X 可用）转成跟随语言的展示文本。
String _couponThresholdLabel(AppLocalizations l10n, String raw) {
  if (raw == '无门槛') return l10n.adminThresholdNone;
  final m = RegExp(r'^满 \$(\d+(?:\.\d+)?) 可用$').firstMatch(raw);
  if (m != null) return l10n.adminThresholdMin('\$${m.group(1)}');
  return raw;
}

Color _appointmentStatusColor(String status) => switch (status) {
  'pending' => LiveColors.warning,
  'booked' => LiveColors.blue,
  'checked_in' => LiveColors.success,
  'in_service' => LiveColors.success,
  'completed' => LiveColors.textTertiary,
  'cancelled' => LiveColors.danger,
  _ => LiveColors.textTertiary,
};

Color _memberOrderStatusColor(String status) => switch (status) {
  'pending' => LiveColors.warning,
  'confirmed' => LiveColors.success,
  'cancelled' => LiveColors.danger,
  _ => LiveColors.textTertiary,
};

String _fmtDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

String _fmtDateTime(DateTime dt) =>
    '${_fmtDate(dt)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _fmtTime(DateTime? dt) {
  if (dt == null) return '—';
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  final s = dt.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

/// 服务时长：服务中取当前时间，已完成取下钟时间；异常数据按 0 处理。
String _serviceDuration(Appointment a, DateTime now) {
  final start = a.serviceStartTime;
  if (start == null) return '—';
  final end = a.status == 'in_service' ? now : a.serviceEndTime;
  if (end == null) return '—';
  final seconds = end.difference(start).inSeconds;
  final safe = seconds < 0 ? 0 : seconds;
  final h = (safe ~/ 3600).toString().padLeft(2, '0');
  final m = ((safe % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (safe % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.6,
              color: LiveColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: LiveColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
