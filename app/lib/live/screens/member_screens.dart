import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_ext.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

/// 会员权益列表（对齐 Pixso 09-会员中心）。
List<(IconData, String, String)> _benefitsOf(AppLocalizations l10n) => [
      (Icons.account_balance_wallet_outlined, l10n.memberBenefitPrice, l10n.memberBenefitPriceDesc),
      (Icons.card_giftcard_outlined, l10n.memberBenefitActivity, l10n.memberBenefitActivityDesc),
      (Icons.confirmation_number_outlined, l10n.memberBenefitCoupon, l10n.memberBenefitCouponDesc),
      (Icons.local_fire_department_outlined, l10n.memberBenefitBirthday, l10n.memberBenefitBirthdayDesc),
    ];

class MemberCenterScreen extends StatefulWidget {
  const MemberCenterScreen({super.key});

  @override
  State<MemberCenterScreen> createState() => _MemberCenterScreenState();
}

class _MemberCenterScreenState extends State<MemberCenterScreen> {
  late Future<
      ({
        Membership membership,
        List<MemberPlan> plans,
        List<Coupon> coupons,
        List<MemberOrder> orders,
      })> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<
      ({
        Membership membership,
        List<MemberPlan> plans,
        List<Coupon> coupons,
        List<MemberOrder> orders,
      })> _load() async {
    final results = await Future.wait([
      MemberService.instance.myMembership(),
      MemberService.instance.plans(),
      MemberService.instance.wallet(),
      MemberService.instance.memberOrders(),
    ]);
    return (
      membership: results[0] as Membership,
      plans: results[1] as List<MemberPlan>,
      coupons: results[2] as List<Coupon>,
      orders: results[3] as List<MemberOrder>,
    );
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          final l10n = context.l10n;
          if (snap.hasError) {
            return Column(
              children: [
                LiveAppBar(title: l10n.memberCenterTitle),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return Column(
              children: [
                LiveAppBar(title: l10n.memberCenterTitle),
                const Expanded(child: LoadingView()),
              ],
            );
          }
          final data = snap.data!;
          final pendingOrders =
              data.orders.where((o) => o.status == 'pending').toList();
          final benefits = _benefitsOf(l10n);
          return Column(
            children: [
                LiveAppBar(title: l10n.memberCenterTitle),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _retry(),
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      _MembershipCard(membership: data.membership),
                      if (pendingOrders.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        // 待确认开通申请提示
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFDDC8FF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 20,
                                color: Color(0xFF7C3AED),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '有 ${pendingOrders.length} 笔会员开通申请待门店确认，到店支付费用后将为你开通',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: Color(0xFF6D28D9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // 会员权益（对齐 Pixso 09-会员中心）
                      _SectionTitle(title: l10n.memberBenefits),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: LiveColors.divider),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < benefits.length; i++) ...[
                              if (i > 0)
                                const Divider(
                                  height: 1,
                                  color: LiveColors.divider,
                                ),
                              _BenefitRow(
                                icon: benefits[i].$1,
                                title: benefits[i].$2,
                                desc: benefits[i].$3,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // 开通 / 续费（对齐 Pixso 09-会员中心）
                      _SectionTitle(
                        title: l10n.memberOpenRenew,
                        more: data.membership.isActive
                            ? l10n.memberCurrent(data.membership.levelName)
                            : null,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < data.plans.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            Expanded(
                              child: _PlanCard(
                                plan: data.plans[i],
                                renewing: data.membership.isActive &&
                                    data.membership.levelName ==
                                        data.plans[i].name,
                                onTap: () => LiveRoutes.push(
                                  context,
                                  RoutePaths.memberPurchase,
                                  extra: data.plans[i],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          l10n.memberAgreementHint,
                          style: const TextStyle(
                            fontSize: 11,
                            color: LiveColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
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

// ===== 会员中心（对齐 Pixso 09-会员中心）=====

/// 会员卡：金碧辉煌的尊贵金卡，左侧等级 + 编号，右侧有效期，底部状态标签。
class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.membership});

  final Membership membership;

  // 金色卡片配色：深棕文字 + 香槟金渐变 + 金色光晕
  static const _goldText = Color(0xFF4A3200);
  static const _goldAccent = Color(0xFF6B4E00);
  static const _activeGradient = [
    Color(0xFFF9ECB8),
    Color(0xFFE7C878),
    Color(0xFFC79A3B),
    Color(0xFFA97A1E),
  ];
  static const _inactiveGradient = [
    Color(0xFFEFE8D4),
    Color(0xFFD8CDA8),
    Color(0xFFB8AA82),
  ];

  String _date(DateTime? d) {
    if (d == null) return '--';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = membership.isActive;
    final remaining = active && membership.expireAt != null
        ? membership.expireAt!.difference(DateTime.now()).inDays
        : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              active ? _activeGradient : _inactiveGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x55D4AF37),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // 左上角金色高光，营造珠宝质感
          Positioned(
            top: -34,
            right: -26,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.38),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // 右下角暗角，增强立体感
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0x33552F00),
                    const Color(0x00552F00),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              size: 15,
                              color: _goldAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.memberLevel(membership.levelName),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _goldText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          membership.memberNo.isNotEmpty
                              ? membership.memberNo
                              : '--',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _goldText,
                            letterSpacing: 1.2,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.memberValidUntil,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _goldText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        active ? _date(membership.expireAt) : '--',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _goldText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _CardTag(
                    label: active
                        ? l10n.memberStatusActive
                        : membership.status == 'expired'
                            ? l10n.memberExpired
                            : l10n.memberNotOpened,
                    active: active,
                  ),
                  if (active) ...[
                    const SizedBox(width: 8),
                    _CardTag(label: l10n.memberRemainingDays(remaining), active: true),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 会员卡上的金卡标签（半透明白底 + 深棕文字）。
class _CardTag extends StatelessWidget {
  const _CardTag({required this.label, this.active = true});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: active
            ? const Color(0x4DFFFFFF)
            : const Color(0x33808080),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _MembershipCard._goldText,
          ),
        ),
      ),
    );
  }
}

/// 通用快捷入口行（我的卡包页等使用）。
class _QuickEntry extends StatelessWidget {
  const _QuickEntry({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: LiveColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LiveColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: LiveColors.brand),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: LiveColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  color: LiveColors.textTertiary,
                ),
              ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: LiveColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 区块标题：左对齐 17 号加粗 + 右侧说明（对齐设计稿 section-title）。
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.more});

  final String title;
  final String? more;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: LiveColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          if (more != null)
            Text(
              more!,
              style: const TextStyle(
                fontSize: 12,
                color: LiveColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// 会员权益行：浅色图标块 + 标题 + 描述 + 右箭头。
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: LiveColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: LiveColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: LiveColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: LiveColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

/// 套餐卡（月/季/年）：名称 + 推荐标签 + 价格/划线价 + 天数 + 开通/续费按钮。
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.renewing,
    required this.onTap,
  });

  final MemberPlan plan;
  final bool renewing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recommended = plan.recommended;
    final dark = recommended || renewing;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: recommended ? const Color(0xFFF4F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: recommended
              ? null
              : Border.all(color: LiveColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: LiveColors.textSecondary,
                    ),
                  ),
                ),
                if (recommended)
                  Container(
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF333333), Color(0xFF141414)],
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Text(
                        plan.badge.isNotEmpty ? plan.badge : '推荐',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: '\$${fmtPrice(plan.price)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LiveColors.textPrimary,
                ),
                children: [
                  if (plan.originalPrice > plan.price)
                    TextSpan(
                      text: '  \$${fmtPrice(plan.originalPrice)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: LiveColors.textTertiary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${plan.durationDays} 天',
              style: const TextStyle(
                fontSize: 11,
                color: LiveColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF141414) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: dark
                    ? null
                    : Border.all(color: LiveColors.divider),
              ),
              child: Text(
                renewing ? '续费' : '开通',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : LiveColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberPurchaseScreen extends StatefulWidget {
  const MemberPurchaseScreen({super.key, required this.plan});

  final MemberPlan plan;

  @override
  State<MemberPurchaseScreen> createState() => _MemberPurchaseScreenState();
}

class _MemberPurchaseScreenState extends State<MemberPurchaseScreen> {
  bool _loading = false;
  bool _submitted = false;

  Future<void> _purchase() async {
    setState(() => _loading = true);
    try {
      await MemberService.instance.purchase(widget.plan.id);
      if (!mounted) return;
      setState(() => _submitted = true);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_submitted) {
      return MemberOrderSubmittedView(
        planName: widget.plan.name,
        durationDays: widget.plan.durationDays,
        onDone: () => Navigator.of(context).pop(true),
      );
    }
    return LivePage(
      child: Column(
        children: [
          LiveAppBar(title: l10n.memberPurchaseTitle),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                  Text(widget.plan.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: LiveColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(
                    l10n.memberPurchaseDays(widget.plan.durationDays),
                    style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: LiveColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        for (final b in widget.plan.benefits)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: LiveColors.brand),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(b,
                                      style: const TextStyle(fontSize: 13, color: LiveColors.textPrimary)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.memberPayDetails,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _PurchaseRow(
                    label: l10n.memberOriginalPrice,
                    value: '\$${widget.plan.originalPrice.toStringAsFixed(2)}',
                    strikethrough: widget.plan.originalPrice > widget.plan.price,
                  ),
                  if (widget.plan.originalPrice > widget.plan.price)
                    _PurchaseRow(
                      label: l10n.memberDiscount,
                      value: '-\$${(widget.plan.originalPrice - widget.plan.price).toStringAsFixed(2)}',
                      valueColor: LiveColors.success,
                    ),
                  const Divider(height: 20, color: LiveColors.divider),
                  _PurchaseRow(
                    label: l10n.memberPayAmount,
                    value: '\$${widget.plan.price.toStringAsFixed(2)}',
                    bold: true,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: LiveColors.brandLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined,
                            size: 18, color: LiveColors.brand),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.memberOfflinePayHint,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: LiveColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: l10n.memberSubmitOrder,
                    color: Colors.black,
                    textColor: Colors.white,
                    loading: _loading,
                    onTap: _loading ? null : _purchase,
                  ),
                  const SizedBox(height: 12),
                  OutlineButton(
                    label: l10n.memberThinkAgain,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.memberAgreeTerms,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary),
                  ),
                  const SizedBox(height: 16),
                ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 下单成功：会员开通申请已提交，等待门店确认（到店支付后由门店开通）。
class MemberOrderSubmittedView extends StatelessWidget {
  const MemberOrderSubmittedView({
    super.key,
    required this.planName,
    required this.durationDays,
    required this.onDone,
  });

  final String planName;
  final int durationDays;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LivePage(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.check_circle, size: 84, color: LiveColors.success),
            const SizedBox(height: 16),
            Text(
              l10n.memberOrderSubmitted,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: LiveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$planName · ${l10n.memberPurchaseDays(durationDays)}',
              style: const TextStyle(
                fontSize: 13,
                color: LiveColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.schedule, size: 32, color: Color(0xFF7C3AED)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.memberWaitingConfirm,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6D28D9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.memberOrderSubmittedDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: l10n.commonDone,
              color: Colors.black,
              textColor: Colors.white,
              onTap: onDone,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({
    required this.label,
    required this.value,
    this.valueColor = LiveColors.textPrimary,
    this.bold = false,
    this.strikethrough = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;
  final bool strikethrough;

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
              color: LiveColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 18 : 13,
              color: valueColor,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              decoration: strikethrough ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  late Future<List<Coupon>> _future;
  String _tab = 'unused';

  @override
  void initState() {
    super.initState();
    _future = MemberService.instance.wallet();
  }

  void _retry() => setState(() => _future = MemberService.instance.wallet());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LivePage(
      child: FutureBuilder<List<Coupon>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                LiveAppBar(title: l10n.memberWalletTitle),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return Column(
              children: [
                LiveAppBar(title: l10n.memberWalletTitle),
                const Expanded(child: LoadingView()),
              ],
            );
          }
          final all = snap.data!;
          final list = switch (_tab) {
            'unused' => all.where((c) => c.usable).toList(),
            'used' => all.where((c) => c.status == 'used').toList(),
            'expired' => all
                .where((c) =>
                    c.status == 'expired' ||
                    (c.status == 'unused' && !c.usable))
                .toList(),
            _ => all,
          };
          return Column(
            children: [
              LiveAppBar(
                title: l10n.memberWalletTitle,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: LiveColors.brand),
                    onPressed: () => LiveRoutes.push(context, RoutePaths.memberCouponCenter),
                  ),
                ],
              ),
              _CouponTabs(
                current: _tab,
                onChanged: (t) => setState(() => _tab = t),
              ),
              Expanded(
                child: list.isEmpty
                    ? EmptyView(text: l10n.memberNoCoupons)
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _CouponCard(coupon: list[i]),
                        ),
                      ),
              ),
              const Divider(height: 1, color: LiveColors.divider),
              _QuickEntry(
                icon: Icons.workspace_premium_outlined,
                label: l10n.memberExclusiveExperience,
                value: l10n.memberMonthlyOnce,
                onTap: () => LiveRoutes.push(context, RoutePaths.memberCenter),
              ),
              _QuickEntry(
                icon: Icons.redeem_outlined,
                label: l10n.memberMoreCoupons,
                value: '',
                onTap: () => LiveRoutes.push(context, RoutePaths.memberCouponCenter),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CouponTabs extends StatelessWidget {
  const _CouponTabs({required this.current, required this.onChanged});

  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      ('unused', l10n.memberTabUnused),
      ('used', l10n.memberTabUsed),
      ('expired', l10n.memberTabExpired),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Row(
        children: tabs.map((t) {
          final sel = current == t.$1;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(t.$1),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? LiveColors.brand : LiveColors.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  t.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : LiveColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final usable = coupon.usable;
    return Opacity(
      opacity: usable ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LiveColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LiveColors.divider),
        ),
        child: Row(
          children: [
            Text(
              '\$${fmtPrice(coupon.amount)}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: LiveColors.brand),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coupon.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LiveColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${coupon.threshold} · 有效期至 ${fmtTime(coupon.expireAt, withYear: true)}',
                    style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary),
                  ),
                  Text(
                    coupon.status == 'used' ? '已使用' : coupon.status == 'expired' ? '已过期' : '可使用',
                    style: TextStyle(fontSize: 11, color: usable ? LiveColors.success : LiveColors.textTertiary),
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

class CouponCenterScreen extends StatefulWidget {
  const CouponCenterScreen({super.key});

  @override
  State<CouponCenterScreen> createState() => _CouponCenterScreenState();
}

class _CouponCenterScreenState extends State<CouponCenterScreen> {
  late Future<List<Coupon>> _future;
  final Set<int> _receiving = {};

  @override
  void initState() {
    super.initState();
    _future = MemberService.instance.couponCenter();
  }

  void _retry() => setState(() => _future = MemberService.instance.couponCenter());

  Future<void> _receive(Coupon c) async {
    setState(() => _receiving.add(c.id));
    try {
      await MemberService.instance.receive(c.id);
      if (mounted) {
        showLiveSnack(context, context.l10n.memberClaimed);
        _retry();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _receiving.remove(c.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LivePage(
      child: FutureBuilder<List<Coupon>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                LiveAppBar(title: l10n.memberCouponCenter),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return Column(
              children: [
                LiveAppBar(title: l10n.memberCouponCenter),
                const Expanded(child: LoadingView()),
              ],
            );
          }
          final list = snap.data!;
          return Column(
            children: [
              LiveAppBar(title: l10n.memberCouponCenter),
              Expanded(
                child: list.isEmpty
                    ? EmptyView(text: l10n.memberNoCouponsAvailable)
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final c = list[i];
                            return _CouponCard(coupon: c);
                          },
                        ),
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.memberClaimAll,
                          onTap: () async {
                            for (final c in list.where((x) => !x.received)) {
                              await _receive(c);
                            }
                          },
                        ),
                      ),
                    ],
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

String _msg(Object? e) =>
    e is ApiException ? e.message : '加载失败，请确认后端服务已启动';
