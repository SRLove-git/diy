import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';
import 'activity_screens.dart';
import 'store_screens.dart';

class AppointmentConfirmScreen extends StatefulWidget {
  const AppointmentConfirmScreen({
    super.key,
    required this.type,
    this.store,
    this.activity,
    required this.date,
    required this.peopleCount,
    this.slot,
    this.session,
    this.table,
    this.note = '',
  });

  final String type; // store / activity
  final Store? store;
  final Activity? activity;
  final String date;
  final int peopleCount;
  final TimeSlot? slot;
  final ActivitySession? session;
  final StoreTable? table;
  final String note;

  @override
  State<AppointmentConfirmScreen> createState() => _AppointmentConfirmScreenState();
}

class _AppointmentConfirmScreenState extends State<AppointmentConfirmScreen> {
  List<Coupon> _coupons = [];
  Coupon? _selected;
  String _payMethod = 'wechat';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    MemberService.instance.wallet().then((list) {
      if (mounted) {
        setState(() {
          _coupons = list.where((c) => c.usable).toList();
          if (_coupons.isNotEmpty) _selected = _coupons.first;
        });
      }
    }).catchError((_) {});
  }

  double get _basePrice {
    if (widget.type == 'activity') {
      return widget.activity?.price ?? 0;
    }
    return widget.store?.price ?? 0;
  }

  double get _unitPrice {
    if (widget.type == 'activity') return widget.activity?.price ?? 0;
    final member = widget.store?.memberPrice;
    if (member != null && member >= 0 && member < (widget.store?.price ?? 0)) {
      return member;
    }
    return widget.store?.price ?? 0;
  }

  double get _originalSubtotal => _basePrice * widget.peopleCount;
  double get _subtotal => _unitPrice * widget.peopleCount;
  double get _memberDiscount => _originalSubtotal - _subtotal;
  double get _discount => _selected?.amount ?? 0;
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  String get _title {
    if (widget.type == 'activity') return widget.activity?.title ?? '活动预约';
    return widget.store?.name ?? '门店预约';
  }

  String get _timeText {
    if (widget.type == 'activity' && widget.session != null) {
      return '${widget.session!.date} ${widget.session!.startTime}-${widget.session!.endTime}';
    }
    if (widget.slot != null) {
      return '${widget.date} ${widget.slot!.label}';
    }
    return widget.date;
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final body = <String, dynamic>{
        'type': widget.type,
        'peopleCount': widget.peopleCount,
        'payMethod': _payMethod,
        if (_selected != null) 'userCouponId': _selected!.userCouponId,
        if (widget.note.isNotEmpty) 'note': widget.note,
      };
      if (widget.type == 'activity') {
        body['activityId'] = widget.activity!.id;
        body['activitySessionId'] = widget.session!.id;
      } else {
        body['storeId'] = widget.store!.id;
        body['tableId'] = widget.table!.id;
        body['slotId'] = widget.slot!.id;
        body['date'] = widget.date;
      }
      final appointment = await AppointmentService.instance.create(body);
      if (!mounted) return;
      LiveRoutes.push(
        context,
        AppointmentSuccessScreen(appointment: appointment),
      );
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '预约确认'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _InfoRow(label: '预约项目', value: _title),
                _InfoRow(label: '预约时间', value: _timeText),
                if (widget.type == 'store')
                  _InfoRow(label: '桌位', value: '${widget.table?.name ?? '-'}（${widget.peopleCount} 人）')
                else
                  _InfoRow(label: '人数', value: '${widget.peopleCount} 人'),
                const Divider(height: 32, color: LiveColors.divider),
                Text('优惠券', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (_coupons.isEmpty)
                  const Text('暂无可用优惠券', style: TextStyle(fontSize: 13, color: LiveColors.textTertiary))
                else
                  ..._coupons.map((c) => _CouponTile(
                        coupon: c,
                        selected: _selected?.userCouponId == c.userCouponId,
                        onTap: () => setState(() => _selected = _selected?.userCouponId == c.userCouponId ? null : c),
                      )),
                const Divider(height: 32, color: LiveColors.divider),
                const Text('支付方式', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _PayTile(
                  label: '微信支付',
                  icon: Icons.wechat,
                  selected: _payMethod == 'wechat',
                  onTap: () => setState(() => _payMethod = 'wechat'),
                ),
                _PayTile(
                  label: '支付宝',
                  icon: Icons.account_balance_wallet_outlined,
                  selected: _payMethod == 'alipay',
                  onTap: () => setState(() => _payMethod = 'alipay'),
                ),
                const Divider(height: 32, color: LiveColors.divider),
                _PriceRow(label: '原价', value: '¥${_originalSubtotal.toStringAsFixed(2)}'),
                if (_memberDiscount > 0)
                  _PriceRow(
                    label: '会员优惠',
                    value: '-¥${_memberDiscount.toStringAsFixed(2)}',
                    valueColor: LiveColors.success,
                  ),
                if (_discount > 0)
                  _PriceRow(
                    label: '优惠券',
                    value: '-¥${_discount.toStringAsFixed(2)}',
                    valueColor: LiveColors.success,
                  ),
                const Divider(height: 22, color: LiveColors.divider),
                _PriceRow(
                  label: '应付金额',
                  value: '¥${_total.toStringAsFixed(2)}',
                  bold: true,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: '提交预约',
                  loading: _loading,
                  onTap: _loading ? null : _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: LiveColors.textSecondary)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor = LiveColors.textPrimary,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: bold ? LiveColors.textPrimary : LiveColors.textSecondary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 18 : 13,
              color: valueColor,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({required this.coupon, required this.selected, required this.onTap});

  final Coupon coupon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? LiveColors.brandLight : LiveColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? LiveColors.brand : LiveColors.divider, width: selected ? 1.2 : 1),
        ),
        child: Row(
          children: [
            Text(
              '¥${coupon.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: LiveColors.brand),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coupon.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LiveColors.textPrimary)),
                  Text('${coupon.threshold} · 有效期至 ${fmtTime(coupon.expireAt, withYear: true)}',
                      style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? LiveColors.brand : LiveColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayTile extends StatelessWidget {
  const _PayTile({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: LiveColors.brand),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 14, color: LiveColors.textPrimary)),
            const Spacer(),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? LiveColors.brand : LiveColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentSuccessScreen extends StatelessWidget {
  const AppointmentSuccessScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.check_circle, size: 84, color: LiveColors.success),
            const SizedBox(height: 16),
            const Text(
              '预约成功',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LiveColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '${appointment.title} · ${appointment.date} ${appointment.startTime}',
              style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LiveColors.brandLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('核销码', style: TextStyle(fontSize: 12, color: LiveColors.brand)),
                  const SizedBox(height: 6),
                  SelectableText(
                    appointment.code,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: LiveColors.textPrimary, letterSpacing: 6),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '到店出示此码即可核销体验',
                    style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: '查看预约',
              onTap: () => LiveRoutes.push(
                context,
                AppointmentDetailScreen(appointmentId: appointment.id),
              ),
            ),
            const SizedBox(height: 12),
            OutlineButton(
              label: '返回首页',
              onTap: () => LiveRoutes.goHome(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late Future<List<Appointment>> _future;
  String _tab = 'all';

  @override
  void initState() {
    super.initState();
    _future = AppointmentService.instance.myList();
  }

  void _retry() => setState(() => _future = AppointmentService.instance.myList());

  static const _tabs = [
    ('all', '全部'),
    ('booked', '待核销'),
    ('checked_in', '服务中'),
    ('completed', '已完成'),
    ('cancelled', '已取消'),
  ];

  List<Appointment> _filter(List<Appointment> list) {
    if (_tab == 'all') return list;
    if (_tab == 'checked_in') {
      return list
          .where((a) => a.status == 'checked_in' || a.status == 'in_service')
          .toList();
    }
    return list.where((a) => a.status == _tab).toList();
  }

  void _again(Appointment a) {
    if (a.type == 'activity' && a.activityId != null) {
      LiveRoutes.push(context, ActivityDetailScreen(activityId: a.activityId!));
    } else if (a.storeId != null) {
      LiveRoutes.push(context, StoreDetailScreen(storeId: a.storeId!));
    } else {
      LiveRoutes.push(context, const StoreListScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder<List<Appointment>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '我的预约'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '我的预约'), Expanded(child: LoadingView())],
            );
          }
          final list = _filter(snap.data!);
          return Column(
            children: [
              const LiveAppBar(title: '我的预约'),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                child: _PillTabs(
                  tabs: _tabs.map((t) => t.$2).toList(),
                  current: _tabs.indexWhere((t) => t.$1 == _tab),
                  onChanged: (i) => setState(() => _tab = _tabs[i].$1),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyView(text: '暂无预约，去预约一个体验吧')
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final a = list[i];
                            return _AppointmentCard(
                              appointment: a,
                              onTap: () => LiveRoutes.push(
                                context,
                                AppointmentDetailScreen(appointmentId: a.id),
                              ),
                              onAction: switch (a.status) {
                                'booked' => () => LiveRoutes.push(
                                      context,
                                      CheckinQrScreen(appointment: a),
                                    ),
                                'checked_in' => () => LiveRoutes.push(
                                      context,
                                      CheckinQrScreen(appointment: a),
                                    ),
                                'in_service' => () => LiveRoutes.push(
                                      context,
                                      CheckinQrScreen(appointment: a),
                                    ),
                                _ => () => _again(a),
                              },
                            );
                          },
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

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
    required this.onAction,
  });

  final Appointment appointment;
  final VoidCallback onTap;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = switch (appointment.status) {
      'booked' => '扫码核销',
      'checked_in' => '查看二维码',
      'in_service' => '查看二维码',
      'completed' => '再次预约',
      _ => '查看详情',
    };
    final progress = switch (appointment.status) {
      'booked' => 0.25,
      'checked_in' => 0.5,
      'in_service' => 0.75,
      'completed' => 1.0,
      _ => 0.1,
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.6,
                      fontWeight: FontWeight.w700,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.statusLabel,
                  style: const TextStyle(fontSize: 11.6, color: LiveColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.code,
              style: const TextStyle(
                fontSize: 21.6,
                fontWeight: FontWeight.w800,
                color: LiveColors.textPrimary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _infoLine(appointment),
              style: const TextStyle(fontSize: 11.6, color: LiveColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: const AlwaysStoppedAnimation(LiveColors.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: LiveColors.textPrimary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 12.6,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _infoLine(Appointment a) {
    final date = DateTime.tryParse(a.date);
    final week = date == null
        ? ''
        : '周${'一二三四五六日'[date.weekday - 1]}';
    final table = a.tableName.isNotEmpty ? ' · ${a.tableName}' : '';
    return '${a.date} $week ${a.startTime}-${a.endTime}$table · ${a.peopleCount} 人';
  }
}

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  final int appointmentId;

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Future<Appointment> _future;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _future = AppointmentService.instance.detail(widget.appointmentId);
  }

  void _reload() => setState(() {
        _future = AppointmentService.instance.detail(widget.appointmentId);
      });

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('取消预约'),
        content: const Text('确定要取消该预约吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('再想想')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('确定取消')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _acting = true);
    try {
      await AppointmentService.instance.cancel(widget.appointmentId);
      if (mounted) {
        showLiveSnack(context, '预约已取消');
        _reload();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder<Appointment>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '预约详情'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _reload)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '预约详情'), Expanded(child: LoadingView())],
            );
          }
          final a = snap.data!;
          return Column(
            children: [
              const LiveAppBar(title: '预约详情'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LiveColors.brandLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Text('核销码', style: TextStyle(fontSize: 12, color: LiveColors.brand)),
                          const SizedBox(height: 4),
                          SelectableText(
                            a.code,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 6,
                              color: LiveColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(a.statusLabel,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LiveColors.brand)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '预约进度',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    _ProgressStepper(status: a.status),
                    const SizedBox(height: 22),
                    const Text(
                      '订单信息',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    _DetailRow('预约项目', a.title),
                    _DetailRow('预约时间', '${a.date} ${a.startTime}-${a.endTime}'),
                    _DetailRow('人数', '${a.peopleCount} 人'),
                    if (a.tableName.isNotEmpty) _DetailRow('桌位', a.tableName),
                    _DetailRow('支付方式', a.payMethod == 'wechat' ? '微信支付' : a.payMethod == 'alipay' ? '支付宝' : a.payMethod),
                    _DetailRow('支付状态', a.payStatus == 'paid' ? '已支付' : '未支付'),
                    _DetailRow('金额', '¥${a.amount.toStringAsFixed(2)}'),
                    if (a.couponDiscount > 0) _DetailRow('优惠券', '${a.couponTitle} -¥${a.couponDiscount.toStringAsFixed(2)}'),
                    if (a.note.isNotEmpty) _DetailRow('备注', a.note),
                    if (a.status != 'completed' && a.status != 'cancelled') ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlineButton(
                              label: '复制',
                              height: 42,
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: a.code));
                                showLiveSnack(context, '预约码已复制');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              label: '扫码核销',
                              height: 42,
                              onTap: () => LiveRoutes.push(
                                context,
                                CheckinQrScreen(appointment: a),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _QrCard(appointment: a),
                    const SizedBox(height: 16),
                    if (a.status == 'booked')
                      PrimaryButton(
                        label: '取消预约',
                        textColor: LiveColors.danger,
                        loading: _acting,
                        onTap: _acting ? null : _cancel,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 预约进度：待核销 → 已核销 → 已完成。
class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.status});

  final String status;

  static const _labels = ['待核销', '已核销', '已完成'];

  int get _current => switch (status) {
        'checked_in' => 1,
        'in_service' => 1,
        'completed' => 2,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: i <= _current
                    ? LiveColors.textPrimary
                    : LiveColors.cardBorder,
              ),
            ),
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: i <= _current
                      ? LiveColors.textPrimary
                      : LiveColors.bg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i <= _current
                        ? LiveColors.textPrimary
                        : LiveColors.cardBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: i < _current
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: i <= _current
                              ? Colors.white
                              : LiveColors.textTertiary,
                        ),
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                _labels[i],
                style: TextStyle(
                  fontSize: 10.6,
                  color: i <= _current
                      ? LiveColors.textPrimary
                      : LiveColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: LiveColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LiveColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LiveColors.divider),
      ),
      child: Column(
        children: [
          const Text('到店出示二维码核销', style: TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
          const SizedBox(height: 12),
          QrImageView(
            data: appointment.code,
            version: QrVersions.auto,
            size: 180,
            backgroundColor: LiveColors.bg,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: LiveColors.textPrimary),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: LiveColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            '核销码 ${appointment.code}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// 分段胶囊选择器。
class _PillTabs extends StatelessWidget {
  const _PillTabs({
    required this.tabs,
    required this.current,
    required this.onChanged,
  });

  final List<String> tabs;
  final int current;
  final ValueChanged<int> onChanged;

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
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: current == i ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: current == i
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
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(17),
                  child: Center(
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: current == i
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: current == i
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

/// 71-核销二维码出示：调亮屏幕 + 二维码 + 30 秒刷新提示。
class CheckinQrScreen extends StatelessWidget {
  const CheckinQrScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          LiveAppBar(
            title: '到店核销',
            actions: [
              TextButton(
                onPressed: () => showLiveSnack(context, '已调亮屏幕（模拟）'),
                child: const Text(
                  '调亮屏幕',
                  style: TextStyle(fontSize: 13, color: LiveColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    '出示给店员扫码核销',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Center(
                  child: Avatar(
                    url: '',
                    name: appointment.title,
                    size: 58,
                  ),
                ),
                const SizedBox(height: 22),
                const Center(
                  child: Text(
                    '预约码',
                    style: TextStyle(fontSize: 12, color: LiveColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    appointment.code,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: LiveColors.textPrimary,
                      letterSpacing: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: LiveColors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: LiveColors.cardBorder),
                    ),
                    child: QrImageView(
                      data: appointment.code,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: LiveColors.bg,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: LiveColors.textPrimary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: LiveColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '二维码每 30 秒自动刷新',
                    style: TextStyle(fontSize: 11.6, color: LiveColors.textTertiary),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '有效期至 ${appointment.endTime}',
                    style: const TextStyle(fontSize: 11.6, color: LiveColors.textTertiary),
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

/// 首页「到店」入口：当前预约的到店体验页（对齐 08-到店核销-体验）。
class CheckinFlowScreen extends StatefulWidget {
  const CheckinFlowScreen({super.key});

  @override
  State<CheckinFlowScreen> createState() => _CheckinFlowScreenState();
}

class _CheckinFlowScreenState extends State<CheckinFlowScreen> {
  late Future<List<Appointment>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppointmentService.instance.myList();
  }

  void _retry() => setState(() => _future = AppointmentService.instance.myList());

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder<List<Appointment>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '到店核销'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '到店核销'), Expanded(child: LoadingView())],
            );
          }
          final list = snap.data!;
          final active = list
              .where((a) => a.status == 'booked' || a.status == 'checked_in' || a.status == 'in_service')
              .toList();
          return Column(
            children: [
              LiveAppBar(
                title: '到店核销',
                actions: [
                  TextButton(
                    onPressed: () => LiveRoutes.push(context, const VerifyCodeScreen()),
                    child: const Text(
                      '输入核销码',
                      style: TextStyle(fontSize: 13, color: LiveColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    if (active.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: EmptyView(text: '暂无待核销预约', icon: Icons.qr_code_scanner_outlined),
                      )
                    else
                      ...active.map(
                        (a) => _ExperienceCard(
                          appointment: a,
                          onScan: () => LiveRoutes.push(
                            context,
                            CheckinQrScreen(appointment: a),
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
    );
  }
}

/// 到店体验卡（门店 + 预约码 + 扫码核销）。
class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.appointment,
    required this.onScan,
  });

  final Appointment appointment;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(appointment.date);
    final week = date == null
        ? ''
        : '周${'一二三四五六日'[date.weekday - 1]}';
    final table = appointment.tableName.isNotEmpty
        ? ' · ${appointment.tableName}'
        : '';
    final info =
        '${appointment.date} $week ${appointment.startTime}-${appointment.endTime}$table · ${appointment.peopleCount} 人';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: LiveColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                appointment.statusLabel,
                style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              appointment.code,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: LiveColors.textPrimary,
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              info,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: appointment.status == 'booked' ? '扫码核销' : '查看二维码',
            height: 46,
            onTap: onScan,
          ),
        ],
      ),
    );
  }
}

/// 45-输入核销码（6 位分格输入）→ 查询 → 确认核销。
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();
  Appointment? _found;
  bool _searching = false;
  bool _checking = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _query() async {
    if (_codeCtrl.text.trim().length != 6) {
      showLiveSnack(context, '请输入 6 位核销码');
      return;
    }
    setState(() {
      _searching = true;
      _found = null;
    });
    try {
      final a = await AppointmentService.instance.findByCode(_codeCtrl.text.trim());
      if (mounted) setState(() => _found = a);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _checkIn() async {
    setState(() => _checking = true);
    try {
      final a = await AppointmentService.instance.checkIn(_codeCtrl.text.trim());
      if (!mounted) return;
      showLiveSnack(context, '核销成功，开始体验');
      setState(() => _found = a);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _scanQr() {
    final a = _found;
    if (a != null) {
      LiveRoutes.push(context, CheckinQrScreen(appointment: a));
    } else {
      showLiveSnack(context, '请先查询预约');
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _codeCtrl.text;
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '输入核销码'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text(
                    '输入预约码',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: LiveColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '输入店员提供的 6 位预约码进行核销',
                    style: TextStyle(fontSize: 12.6, color: LiveColors.textSecondary),
                  ),
                  const SizedBox(height: 30),
                  // 6 位分格输入
                  GestureDetector(
                    onTap: () => FocusScope.of(context).requestFocus(_codeFocus),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            final filled = i < code.length;
                            return Container(
                              width: 48,
                              height: 58,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: filled ? LiveColors.bg : LiveColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: filled ? LiveColors.textPrimary : LiveColors.cardBorder,
                                ),
                              ),
                              child: Text(
                                i < code.length ? code[i] : '',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: LiveColors.textPrimary,
                                ),
                              ),
                            );
                          }),
                        ),
                        TextField(
                          controller: _codeCtrl,
                          focusNode: _codeFocus,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          showCursor: false,
                          style: const TextStyle(color: Colors.transparent, fontSize: 20),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _query(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    label: '查询预约',
                    loading: _searching,
                    onTap: _searching ? null : _query,
                  ),
                  const SizedBox(height: 20),
                  if (_found != null) ...[
                    _FoundCard(
                      appointment: _found!,
                    ),
                    if (_found!.status == 'booked') ...[
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: '确认核销',
                        loading: _checking,
                        onTap: _checking ? null : _checkIn,
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          '当前状态：${_found!.statusLabel}',
                          style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
                        ),
                      ),
                  ],
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '也可以',
                        style: TextStyle(fontSize: 12.6, color: LiveColors.textTertiary),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _scanQr,
                        child: const Text(
                          '扫码核销',
                          style: TextStyle(
                            fontSize: 12.6,
                            fontWeight: FontWeight.w700,
                            color: LiveColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundCard extends StatelessWidget {
  const _FoundCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appointment.title,
            style: const TextStyle(fontSize: 14.6, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            '${appointment.date} ${appointment.startTime}-${appointment.endTime} · ${appointment.peopleCount} 人',
            style: const TextStyle(fontSize: 11.6, color: LiveColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            '预约码 ${appointment.code} · ${appointment.statusLabel}',
            style: const TextStyle(fontSize: 12.6, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

String _msg(Object? e) =>
    e is ApiException ? e.message : '加载失败，请确认后端服务已启动';
