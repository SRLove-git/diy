import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

/// 34-取消预约确认弹窗（对齐 Pixso 34-居中确认）：
/// 遮罩 + 312 宽圆角白卡 + 标题 + 说明 + 再想想 / 确认取消。
Future<bool?> showCancelAppointmentDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x6B141414),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 39),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 312),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x38141414),
                blurRadius: 64,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '取消预约',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141414),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '取消后该时段名额将释放，确定取消吗？',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                  height: 1.6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 22, 0, 22),
                child: Row(
                  children: [
                    Expanded(
                      child: _DialogActionBtn(
                        label: '再想想',
                        backgroundColor: const Color(0xFFF7F7F8),
                        foregroundColor: const Color(0xFF141414),
                        onTap: () => Navigator.pop(dialogContext, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogActionBtn(
                        label: '确认取消',
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        onTap: () => Navigator.pop(dialogContext, true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 下钟确认弹窗（对齐取消预约弹窗样式）：
/// 遮罩 + 312 宽圆角白卡 + 标题 + 说明 + 再想想 / 确认下钟。
Future<bool?> showClockOutConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x6B141414),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 39),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 312),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x38141414),
                blurRadius: 64,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '结束体验',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141414),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '下钟后将停止计时并生成完成记录，确认结束本次体验吗？',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                  height: 1.6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 22, 0, 22),
                child: Row(
                  children: [
                    Expanded(
                      child: _DialogActionBtn(
                        label: '再想想',
                        backgroundColor: const Color(0xFFF7F7F8),
                        foregroundColor: const Color(0xFF141414),
                        onTap: () => Navigator.pop(dialogContext, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogActionBtn(
                        label: '确认下钟',
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        onTap: () => Navigator.pop(dialogContext, true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 弹窗按钮：高 46、圆角 15、字号 15 加粗（对齐设计稿）。
class _DialogActionBtn extends StatelessWidget {
  const _DialogActionBtn({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 46,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentConfirmScreen extends StatefulWidget {
  const AppointmentConfirmScreen({
    super.key,
    required this.type,
    this.store,
    this.activity,
    required this.date,
    required this.peopleCount,
    this.bookingType = 'hourly',
    this.startTime = '',
    this.endTime = '',
    this.durationHours = 0,
    this.packageName = '',
    this.packageId,
    this.packagePrice,
    this.packageMemberPrice,
    this.packageGroupPrice,
    this.session,
    this.tableIds = const <int>[],
    this.tableLabel = '',
    this.note = '',
  });

  final String type; // store / activity
  final Store? store;
  final Activity? activity;
  final String date;
  final int peopleCount;
  final String bookingType;
  final String startTime;
  final String endTime;
  final int durationHours;
  final String packageName;
  final int? packageId;
  final double? packagePrice;
  final double? packageMemberPrice;
  final double? packageGroupPrice;
  final ActivitySession? session;
  final List<int> tableIds;
  final String tableLabel;
  final String note;

  @override
  State<AppointmentConfirmScreen> createState() => _AppointmentConfirmScreenState();
}

class _AppointmentConfirmScreenState extends State<AppointmentConfirmScreen> {
  // ── 线上支付（暂不接入）：优惠券 / 支付方式选择，先注释 ──
  // List<Coupon> _coupons = [];
  // Coupon? _selected;
  // String _payMethod = 'wechat';
  bool _loading = false;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    // 获取预订人会员状态，用于计价预览（会员价 / 多人同行价）
    MemberService.instance.myMembership().then((m) {
      if (mounted && m.isActive) setState(() => _isMember = true);
    }).catchError((_) {
      // 会员状态获取失败时按非会员预览，最终金额以服务端结算为准
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   MemberService.instance.wallet().then((list) {
  //     if (mounted) {
  //       setState(() {
  //         _coupons = list.where((c) => c.usable).toList();
  //         if (_coupons.isNotEmpty) _selected = _coupons.first;
  //       });
  //     }
  //   }).catchError((_) {});
  // }

  /// 门市单价（原价基准，$/人，含时长）
  double get _normalPrice {
    if (widget.type == 'activity') return widget.activity?.price ?? 0;
    final store = widget.store;
    if (store == null) return 0;
    if (widget.bookingType == 'package') {
      return widget.packagePrice ?? store.price * widget.durationHours;
    }
    if (widget.bookingType == 'all_day') {
      return store.allDayPrice ?? store.price * widget.durationHours;
    }
    return store.price * widget.durationHours;
  }

  /// 会员单价（$/人）
  double get _memberUnit {
    final store = widget.store;
    if (store == null || widget.type == 'activity') return _normalPrice;
    if (widget.bookingType == 'package') {
      return widget.packageMemberPrice ?? _normalPrice;
    }
    if (widget.bookingType == 'all_day') {
      return store.allDayMemberPrice ?? _normalPrice;
    }
    return (store.memberPrice ?? store.price) * widget.durationHours;
  }

  /// 多人同行单价（$/人）
  double get _groupUnit {
    final store = widget.store;
    if (store == null || widget.type == 'activity') return _normalPrice;
    if (widget.bookingType == 'package') {
      return widget.packageGroupPrice ?? _normalPrice;
    }
    if (widget.bookingType == 'all_day') {
      return store.allDayGroupPrice ?? _normalPrice;
    }
    return (store.groupPrice ?? store.price) * widget.durationHours;
  }

  /// 实际单人单价：同行 ≥2 人按多人价，单人按会员价（会员）或门市价
  double get _unitPrice {
    if (widget.type == 'activity') return _normalPrice;
    if (widget.peopleCount >= 2) return _groupUnit;
    return _isMember ? _memberUnit : _normalPrice;
  }

  /// 优惠前小计（不含周末加价）：会员预订人按会员价 1 人，其余同行按多人价
  double get _subtotalBase {
    final n = widget.peopleCount;
    if (widget.type == 'activity') return _normalPrice * n;
    if (n >= 2 && _isMember) return _memberUnit + _groupUnit * (n - 1);
    return _unitPrice * n;
  }

  /// 周末/节假日是否加价（与服务端一致：周六/周日按配置百分比上浮）
  bool get _weekendSurcharge {
    final pct = widget.store?.weekendSurchargePercent ?? 0;
    if (pct <= 0) return false;
    final wd = DateTime.tryParse(widget.date)?.weekday ?? 1;
    return wd == 6 || wd == 7;
  }

  double get _surchargeRate =>
      _weekendSurcharge
          ? (100 + (widget.store?.weekendSurchargePercent ?? 0)) / 100
          : 1;

  /// 原价（门市价 × 人数，不含周末加价）
  double get _originalBase => _normalPrice * widget.peopleCount;
  /// 会员/同行优惠（门市小计 − 实际小计）
  double get _discountBase => _originalBase - _subtotalBase;
  /// 周末加价金额（实际小计 × 加价比例）
  double get _surchargeAmount => _subtotalBase * (_surchargeRate - 1);
  // ── 线上支付（暂不接入）：优惠券抵扣固定为 0 ──
  double get _discount => 0;
  double get _total =>
      (_subtotalBase + _surchargeAmount - _discount)
          .clamp(0, double.infinity);

  String get _discountLabel {
    if (widget.type == 'activity') return '会员优惠';
    if (widget.peopleCount >= 2) return _isMember ? '会员/同行优惠' : '同行优惠';
    return '会员优惠';
  }

  String get _title {
    if (widget.type == 'activity') return widget.activity?.title ?? '活动预约';
    return widget.store?.name ?? '门店预约';
  }

  String get _timeText {
    if (widget.type == 'activity' && widget.session != null) {
      return '${widget.session!.date} ${widget.session!.startTime}-${widget.session!.endTime}';
    }
    final window = widget.startTime.isNotEmpty && widget.endTime.isNotEmpty
        ? ' ${widget.startTime}-${widget.endTime}'
        : '';
    return '${widget.date}$window';
  }

  String get _bookingLabel {
    if (widget.type == 'activity') return '活动场次';
    return switch (widget.bookingType) {
      'package' => '${widget.packageName.isEmpty ? '套餐' : widget.packageName} · ${widget.durationHours} 小时',
      'all_day' => '全天不限时',
      _ => '${widget.durationHours} 小时',
    };
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final body = <String, dynamic>{
        'type': widget.type,
        'peopleCount': widget.peopleCount,
        if (widget.note.isNotEmpty) 'note': widget.note,
      };
      if (widget.type == 'activity') {
        body['activityId'] = widget.activity!.id;
        body['activitySessionId'] = widget.session!.id;
      } else {
        body['storeId'] = widget.store!.id;
        body['tableIds'] = widget.tableIds;
        body['bookingType'] = widget.bookingType;
        body['date'] = widget.date;
        if (widget.bookingType != 'all_day') {
          body['startTime'] = widget.startTime;
        }
        if (widget.bookingType == 'package') {
          body['packageId'] = widget.packageId;
        } else if (widget.bookingType == 'hourly') {
          body['durationHours'] = widget.durationHours;
        }
      }
      final appointment = await AppointmentService.instance.create(body);
      if (!mounted) return;
      // 通知首页自动刷新，新订单立即展示
      HomeOrdersRefresh.instance.refresh(appointment);
      LiveRoutes.push(
        context,
        RoutePaths.appointmentSuccess,
        extra: appointment,
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
                  ...[
                    _InfoRow(label: '预约方式', value: _bookingLabel),
                    _InfoRow(
                      label: '桌位',
                      value:
                          '${widget.tableLabel.isEmpty ? '-' : widget.tableLabel}（${widget.peopleCount} 人）',
                    ),
                    _InfoRow(label: '付款方式', value: '到店核销后付款'),
                  ]
                else
                  _InfoRow(label: '人数', value: '${widget.peopleCount} 人'),
                const Divider(height: 32, color: LiveColors.divider),
                // ── 线上支付（暂不接入）：优惠券 / 支付方式选择，先注释 ──
                // Text('优惠券', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                // const SizedBox(height: 8),
                // if (_coupons.isEmpty)
                //   const Text('暂无可用优惠券', style: TextStyle(fontSize: 13, color: LiveColors.textTertiary))
                // else
                //   ..._coupons.map((c) => _CouponTile(
                //         coupon: c,
                //         selected: _selected?.userCouponId == c.userCouponId,
                //         onTap: () => setState(() => _selected = _selected?.userCouponId == c.userCouponId ? null : c),
                //       )),
                // const Divider(height: 32, color: LiveColors.divider),
                // const Text('支付方式', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                // const SizedBox(height: 8),
                // _PayTile(
                //   label: '微信支付',
                //   icon: Icons.wechat,
                //   selected: _payMethod == 'wechat',
                //   onTap: () => setState(() => _payMethod = 'wechat'),
                // ),
                // _PayTile(
                //   label: '支付宝',
                //   icon: Icons.account_balance_wallet_outlined,
                //   selected: _payMethod == 'alipay',
                //   onTap: () => setState(() => _payMethod = 'alipay'),
                // ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: LiveColors.brandLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.storefront_outlined, size: 18, color: LiveColors.brand),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '无需线上支付，预约成功后到店出示核销码，核销后线下付款',
                          style: TextStyle(fontSize: 12.5, color: LiveColors.textSecondary, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32, color: LiveColors.divider),
                _PriceRow(label: '原价', value: '\$${_originalBase.toStringAsFixed(2)}'),
                if (_discountBase > 0)
                  _PriceRow(
                    label: _discountLabel,
                    value: '-\$${_discountBase.toStringAsFixed(2)}',
                    valueColor: LiveColors.success,
                  ),
                if (_discount > 0)
                  _PriceRow(
                    label: '优惠券',
                    value: '-\$${_discount.toStringAsFixed(2)}',
                    valueColor: LiveColors.success,
                  ),
                if (_weekendSurcharge)
                  _PriceRow(
                    label:
                        '周末/节假日加价 ${widget.store?.weekendSurchargePercent ?? 0}%',
                    value: '+\$${_surchargeAmount.toStringAsFixed(2)}',
                  ),
                const Divider(height: 22, color: LiveColors.divider),
                _PriceRow(
                  label: '应付金额',
                  value: '\$${_total.toStringAsFixed(2)}',
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

// ── 线上支付（暂不接入）：优惠券 / 支付方式组件，先注释 ──
// class _CouponTile extends StatelessWidget {
//   const _CouponTile({required this.coupon, required this.selected, required this.onTap});
//
//   final Coupon coupon;
//   final bool selected;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: selected ? LiveColors.brandLight : LiveColors.card,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: selected ? LiveColors.brand : LiveColors.divider, width: selected ? 1.2 : 1),
//         ),
//         child: Row(
//           children: [
//             Text(
//               '\$${coupon.amount.toStringAsFixed(0)}',
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: LiveColors.brand),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(coupon.title,
//                       style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LiveColors.textPrimary)),
//                   Text('${coupon.threshold} · 有效期至 ${fmtTime(coupon.expireAt, withYear: true)}',
//                       style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary)),
//                 ],
//               ),
//             ),
//             Icon(
//               selected ? Icons.check_circle : Icons.radio_button_unchecked,
//               size: 20,
//               color: selected ? LiveColors.brand : LiveColors.textTertiary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _PayTile extends StatelessWidget {
//   const _PayTile({required this.label, required this.icon, required this.selected, required this.onTap});
//
//   final String label;
//   final IconData icon;
//   final bool selected;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: Row(
//           children: [
//             Icon(icon, size: 20, color: LiveColors.brand),
//             const SizedBox(width: 10),
//             Text(label, style: const TextStyle(fontSize: 14, color: LiveColors.textPrimary)),
//             const Spacer(),
//             Icon(
//               selected ? Icons.check_circle : Icons.radio_button_unchecked,
//               size: 20,
//               color: selected ? LiveColors.brand : LiveColors.textTertiary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
                    '到店出示此码即可核销体验，核销后线下付款',
                    style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: '查看预约',
              color: Colors.black,
              textColor: Colors.white,
              onTap: () => LiveRoutes.pushId(
                context,
                RoutePaths.appointmentDetail,
                appointment.id,
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
  /// 已取消订单：取消后立即从列表消失（不等网络刷新）。
  final Set<int> _removedIds = {};
  /// 最近一次拉取的订单快照（供乐观失效刷新使用，避免依赖网络）。
  List<Appointment>? _lastList;
  /// 预约到点后本地立即把卡片置灰，无需网络刷新。
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    // 预约取消 / 核销 / 下钟后自动刷新列表，无需退出再进入
    HomeOrdersRefresh.instance.addListener(_onOrdersChanged);
    // 首次加载即建立乐观失效刷新（到点自动置灰，不等网络）
    _retry();
  }

  void _onOrdersChanged() {
    final p = HomeOrdersRefresh.instance.pending;
    if (p != null && p.status == 'cancelled') {
      setState(() => _removedIds.add(p.id));
    }
    _retry();
  }

  Future<void> _retry() async {
    final future = AppointmentService.instance.myList();
    setState(() => _future = future);
    try {
      final list = await future;
      if (!mounted) return;
      _lastList = list;
      _scheduleExpiryRefresh();
    } catch (_) {
      // 拉取失败静默，下次事件触发时重试
    }
  }

  /// 乐观失效刷新：算出最近一个待核销订单的结束时间，
  /// 到点后本地 setState 置灰（“订单已失效”），不发起网络请求。
  void _scheduleExpiryRefresh() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
    final list = _lastList;
    if (list == null) return;
    final now = DateTime.now();
    DateTime? earliest;
    for (final a in list) {
      if (a.status != 'booked' || a.isExpired(now)) continue;
      final end = a.endDateTime;
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

  @override
  void dispose() {
    _expiryTimer?.cancel();
    HomeOrdersRefresh.instance.removeListener(_onOrdersChanged);
    super.dispose();
  }

  Future<void> _cancelAppointment(Appointment a) async {
    final ok = await showCancelAppointmentDialog(context);
    if (ok != true || !mounted) return;
    // 乐观更新：确认后先让订单立即从列表消失，不等接口返回
    setState(() => _removedIds.add(a.id));
    try {
      final updated = await AppointmentService.instance.cancel(a.id);
      HomeOrdersRefresh.instance.refresh(updated);
      if (!mounted) return;
      showLiveSnack(context, '预约已取消');
    } on ApiException catch (e) {
      // 失败回滚：恢复显示
      if (mounted) {
        setState(() => _removedIds.remove(a.id));
        showLiveSnack(context, e.message);
      }
    }
  }

  static const _tabs = [
    ('all', '全部'),
    ('booked', '待核销'),
    ('in_service', '服务中'),
    ('completed', '已完成'),
  ];

  List<Appointment> _filter(List<Appointment> list) {
    // 已取消的订单不再展示（取消后直接消失）
    final visible = list
        .where((a) => a.status != 'cancelled' && !_removedIds.contains(a.id))
        .toList();
    if (_tab == 'all') return visible;
    if (_tab == 'in_service') {
      return visible
          .where((a) => a.status == 'checked_in' || a.status == 'in_service')
          .toList();
    }
    return visible.where((a) => a.status == _tab).toList();
  }

  void _again(Appointment a) {
    if (a.type == 'activity' && a.activityId != null) {
      LiveRoutes.pushId(context, RoutePaths.activityDetail, a.activityId!);
    } else if (a.storeId != null) {
      LiveRoutes.pushId(context, RoutePaths.storeDetail, a.storeId!);
    } else {
      LiveRoutes.push(context, RoutePaths.storeList);
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
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final a = list[i];
                            return _AppointmentCard(
                              appointment: a,
                              onCancel: a.status == 'booked'
                                  ? () => _cancelAppointment(a)
                                  : null,
                              onTap: () => LiveRoutes.pushId(
                                context,
                                RoutePaths.appointmentDetail,
                                a.id,
                              ),
                              onAction: switch (a.status) {
                                'booked' => a.isExpired()
                                    ? () {}
                                    : () => LiveRoutes.push(
                                          context,
                                          RoutePaths.appointmentCheckinQr,
                                          extra: a,
                                        ),
                                'checked_in' => () => LiveRoutes.push(
                                      context,
                                      RoutePaths.appointmentCheckinQr,
                                      extra: a,
                                    ),
                                'in_service' => () async {
                                      final ok =
                                          await showClockOutConfirmDialog(
                                        context,
                                      );
                                      if (ok == true && context.mounted) {
                                        LiveRoutes.push(
                                          context,
                                          RoutePaths.appointmentServiceEnd,
                                          extra: a,
                                        );
                                      }
                                    },
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

/// 07-我的预约卡片（对齐 Pixso）：白卡 + 状态标签，按状态展示预约码 / 计时 / 支付信息。
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
    required this.onAction,
    this.onCancel,
  });

  final Appointment appointment;
  final VoidCallback onTap;
  final VoidCallback onAction;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final expired = a.status == 'booked' && a.isExpired();
    // 状态标签配色（对齐设计稿 tag.red / tag.green / tag.blue / tag.gray）
    final (tagBg, tagFg) = expired
        ? (const Color(0xFFECECEF), LiveColors.textSecondary)
        : switch (a.status) {
            'booked' => (const Color(0xFFFFEBEE), const Color(0xFFE53935)),
            'checked_in' => (const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
            'in_service' => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
            'completed' => (const Color(0xFFF7F7F8), const Color(0xFF8E8E93)),
            _ => (const Color(0xFFF7F7F8), const Color(0xFF8E8E93)),
          };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                _StatusTag(
                  label: expired ? '订单已失效' : a.statusLabel,
                  bg: tagBg,
                  fg: tagFg,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _infoLine(a),
              style: TextStyle(
                fontSize: 13,
                color: expired
                    ? LiveColors.textTertiary
                    : LiveColors.textSecondary,
              ),
            ),
            if (a.status == 'booked' || a.status == 'checked_in') ...[
              const SizedBox(height: 2),
              Text(
                '预约码 ${a.code}',
                style: const TextStyle(
                  fontSize: 11,
                  color: LiveColors.textTertiary,
                ),
              ),
            ],
            if (a.status == 'booked' && expired) ...[
              const SizedBox(height: 12),
              // 失效卡：置灰提示，不可再核销
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4E4E8), width: 1),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '订单已失效',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: LiveColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '已超过预约时间，无法再核销',
                      style: TextStyle(
                        fontSize: 11,
                        color: LiveColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (a.status == 'booked' && !expired) ...[
              const SizedBox(height: 12),
              // 到店核销卡：大号预约码 + 到店核销标签（点击进入核销）
              InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFDDDDE3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.code.split('').join(' '),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3,
                                color: LiveColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            height: 22,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF333333), Color(0xFF141414)],
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(
                                '到店核销',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '出示预约码，店员扫码或输入验证码开始体验',
                        style: TextStyle(
                          fontSize: 11,
                          color: LiveColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (a.status == 'booked') ...[
              if (onCancel != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onCancel,
                    child: const Text(
                      '取消预约',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: LiveColors.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ],
            if (a.status == 'in_service') ...[
              const SizedBox(height: 12),
              // 计时卡：实时计时（每秒刷新）+ 进度 + 下钟结束
              TimerCard(appointment: a, onAction: onAction),
            ],
            if (a.status == 'completed' || a.status == 'cancelled') ...[
              const SizedBox(height: 2),
              Text(
                _payLine(a),
                style: const TextStyle(
                  fontSize: 11,
                  color: LiveColors.textTertiary,
                ),
              ),
            ],
            if (a.status != 'booked' && a.status != 'in_service') ...[
              const Divider(height: 24, color: LiveColors.divider),
              Align(
                alignment: Alignment.centerRight,
                child: _ActionButton(
                  label: _actionLabel(a),
                  onTap: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _actionLabel(Appointment a) => switch (a.status) {
        'checked_in' => '查看二维码',
        'completed' => '再次预约',
        'cancelled' => '再次预约',
        _ => '查看详情',
      };

  String _payLine(Appointment a) {
    final paid = a.amount > 0
        ? '到店支付 \$${a.amount.toStringAsFixed(0)}'
        : '到店支付 \$0（会员免费）';
    return '${a.statusLabel} · $paid';
  }

  String _infoLine(Appointment a) {
    final date = DateTime.tryParse(a.date);
    final week = date == null
        ? ''
        : '周${'一二三四五六日'[date.weekday - 1]}';
    final table = a.tableLabel.isNotEmpty ? ' · ${a.tableLabel}' : '';
    return '${a.date} $week ${a.startTime}-${a.endTime}$table'
        '${_durationLabel(a)} · ${a.peopleCount} 人';
  }
}

/// 预约时长描述：套餐名 / 小时数 / 全天不限时。
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

/// 状态标签（对齐设计稿 tag：高 22、圆角 11、字号 11 加粗）。
class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// 卡片底部操作按钮（黑色胶囊）。
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: LiveColors.textPrimary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12.6,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 服务中计时卡：每秒刷新已用时长，实时计时（首页 / 我的预约共用）。
class TimerCard extends StatefulWidget {
  const TimerCard({super.key, required this.appointment, required this.onAction});

  final Appointment appointment;
  final VoidCallback onAction;

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _elapsed() {
    final start = widget.appointment.serviceStartTime;
    if (start == null) return '00:00:00';
    var sec = DateTime.now().difference(start).inSeconds;
    if (sec < 0) sec = 0;
    final h = (sec ~/ 3600).toString().padLeft(2, '0');
    final m = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// 剩余时间 = 预约结束时间 - 当前（结束时间固定，不因迟到顺延）。
  /// 兼容旧数据：无结束时间时退回显示已用时长。
  String _remaining() {
    final end = widget.appointment.serviceEndTime;
    if (end == null) return _elapsed();
    var sec = end.difference(DateTime.now()).inSeconds;
    if (sec < 0) sec = 0;
    final h = (sec ~/ 3600).toString().padLeft(2, '0');
    final m = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  double _progress() {
    final start = widget.appointment.serviceStartTime;
    final end = widget.appointment.serviceEndTime;
    if (start == null || end == null) return 0;
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0;
    final elapsed = DateTime.now().difference(start).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '剩余时间（扫码即开始计时，不顺延）',
                style: TextStyle(
                  fontSize: 12,
                  color: LiveColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _remaining(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progress(),
              minHeight: 4,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation(
                LiveColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: Material(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: widget.onAction,
                borderRadius: BorderRadius.circular(15),
                child: const Center(
                  child: Text(
                    '下钟结束',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    final ok = await showCancelAppointmentDialog(context);
    if (ok != true) return;
    setState(() => _acting = true);
    try {
      final updated =
          await AppointmentService.instance.cancel(widget.appointmentId);
      HomeOrdersRefresh.instance.refresh(updated);
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
          final expired = a.status == 'booked' && a.isExpired();
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
                          Text(expired ? '订单已失效' : a.statusLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: expired
                                    ? LiveColors.textSecondary
                                    : LiveColors.brand,
                              )),
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
                    if (a.tableLabel.isNotEmpty) _DetailRow('桌位', a.tableLabel),
                    // ── 线上支付（暂不接入）：支付方式 / 支付状态 / 优惠券，先注释 ──
                    // _DetailRow('支付方式', a.payMethod == 'wechat' ? '微信支付' : a.payMethod == 'alipay' ? '支付宝' : a.payMethod),
                    // _DetailRow('支付状态', a.payStatus == 'paid' ? '已支付' : '未支付'),
                    _DetailRow('付款方式', '到店核销后付款'),
                    _DetailRow('金额', '\$${a.amount.toStringAsFixed(2)}'),
                    // if (a.couponDiscount > 0) _DetailRow('优惠券', '${a.couponTitle} -\$${a.couponDiscount.toStringAsFixed(2)}'),
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
                              onTap: expired
                                  ? null
                                  : () => LiveRoutes.push(
                                        context,
                                        RoutePaths.appointmentCheckinQr,
                                        extra: a,
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

/// 72-体验结束：下钟后展示上/下钟时间、使用时长与评价（对齐 Pixso 72）。
class ServiceEndScreen extends StatefulWidget {
  const ServiceEndScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  State<ServiceEndScreen> createState() => _ServiceEndScreenState();
}

class _ServiceEndScreenState extends State<ServiceEndScreen> {
  Appointment? _result;
  String? _error;
  int _stars = 5;

  @override
  void initState() {
    super.initState();
    _clockOut();
  }

  Future<void> _clockOut() async {
    try {
      final updated =
          await AppointmentService.instance.clockOut(widget.appointment.id);
      // 通知首页自动刷新：服务中订单移除、计时停止
      HomeOrdersRefresh.instance.refresh(updated);
      if (mounted) setState(() => _result = updated);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  String _fmtTime(DateTime? t) {
    if (t == null) return '--';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _duration() {
    final a = _result ?? widget.appointment;
    final start = a.serviceStartTime;
    if (start == null) return '--';
    final end = a.serviceEndTime ?? DateTime.now();
    var sec = end.difference(start).inSeconds;
    if (sec < 0) sec = 0;
    return '${sec ~/ 60} 分钟 ${sec % 60} 秒';
  }

  void _again() {
    final a = widget.appointment;
    if (a.type == 'activity' && a.activityId != null) {
      LiveRoutes.pushId(context, RoutePaths.activityDetail, a.activityId!);
    } else if (a.storeId != null) {
      LiveRoutes.pushId(context, RoutePaths.storeDetail, a.storeId!);
    } else {
      LiveRoutes.push(context, RoutePaths.storeList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _result ?? widget.appointment;
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '体验结束'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 92,
                  height: 92,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF141414),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '体验结束',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: LiveColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '已为您记录本次体验时长，欢迎再次光临',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: LiveColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                // 时长统计卡
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LiveColors.divider),
                  ),
                  child: Column(
                    children: [
                      _DetailRow('门店', a.title),
                      _DetailRow(
                        '桌位 / 人数',
                        '${a.tableLabel.isEmpty ? '--' : a.tableLabel} · ${a.peopleCount} 人',
                      ),
                      _DetailRow('上钟时间', _fmtTime(a.serviceStartTime)),
                      _DetailRow('下钟时间', _fmtTime(a.serviceEndTime)),
                      const Divider(height: 20, color: LiveColors.divider),
                      Row(
                        children: [
                          const Text(
                            '使用时长',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: LiveColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _duration(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: LiveColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // 评价卡
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LiveColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '本次体验如何？',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: LiveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (var i = 1; i <= 5; i++)
                            GestureDetector(
                              onTap: () => setState(() => _stars = i),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  i <= _stars
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 30,
                                  color: i <= _stars
                                      ? const Color(0xFFFFB300)
                                      : LiveColors.textTertiary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: Material(
                    color: const Color(0xFFF7F7F8),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          showLiveSnack(context, '评价已提交，感谢您的反馈'),
                      child: const Center(
                        child: Text(
                          '提交评价',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: LiveColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Material(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _again,
                            child: const Center(
                              child: Text(
                                '再次预约',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Material(
                          color: const Color(0xFFF7F7F8),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => LiveRoutes.switchTab(context, 0),
                            child: const Center(
                              child: Text(
                                '返回首页',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: LiveColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: LiveColors.danger,
                      ),
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
              .where((a) =>
                  (a.status == 'booked' && !a.isExpired()) ||
                  a.status == 'checked_in' ||
                  a.status == 'in_service')
              .toList();
          return Column(
            children: [
              LiveAppBar(
                title: '到店核销',
                // 输入核销码入口暂不开放，先隐藏
                // actions: [
                //   TextButton(
                //     onPressed: () => LiveRoutes.push(context, RoutePaths.loginVerify),
                //     child: const Text(
                //       '输入核销码',
                //       style: TextStyle(fontSize: 13, color: LiveColors.textPrimary),
                //     ),
                //   ),
                //   const SizedBox(width: 8),
                // ],
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
                            RoutePaths.appointmentCheckinQr,
                            extra: a,
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
    final table = appointment.tableLabel.isNotEmpty
        ? ' · ${appointment.tableLabel}'
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
      // 通知首页自动刷新：待核销 → 服务中（实时计时）立即更新
      HomeOrdersRefresh.instance.refresh(a);
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
      LiveRoutes.push(context, RoutePaths.appointmentCheckinQr, extra: a);
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
                        color: Colors.black,
                        textColor: Colors.white,
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
