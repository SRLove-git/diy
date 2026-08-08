import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

class MemberCenterScreen extends StatefulWidget {
  const MemberCenterScreen({super.key});

  @override
  State<MemberCenterScreen> createState() => _MemberCenterScreenState();
}

class _MemberCenterScreenState extends State<MemberCenterScreen> {
  late Future<({Membership membership, List<MemberPlan> plans, List<Coupon> coupons})> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({Membership membership, List<MemberPlan> plans, List<Coupon> coupons})> _load() async {
    final results = await Future.wait([
      MemberService.instance.myMembership(),
      MemberService.instance.plans(),
      MemberService.instance.wallet(),
    ]);
    return (
      membership: results[0] as Membership,
      plans: results[1] as List<MemberPlan>,
      coupons: results[2] as List<Coupon>,
    );
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '会员中心'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '会员中心'), Expanded(child: LoadingView())],
            );
          }
          final data = snap.data!;
          return Column(
            children: [
              const LiveAppBar(title: '会员中心'),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _retry(),
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      _MembershipCard(membership: data.membership),
                      const SizedBox(height: 14),
                      _QuickEntry(
                        icon: Icons.confirmation_number_outlined,
                        label: '卡包 · 优惠券',
                        value: '${data.coupons.where((c) => c.usable).length} 张可用',
                        onTap: () => LiveRoutes.push(context, const CouponsScreen()),
                      ),
                      const SizedBox(height: 8),
                      _QuickEntry(
                        icon: Icons.redeem_outlined,
                        label: '领券中心',
                        value: '',
                        onTap: () => LiveRoutes.push(context, const CouponCenterScreen()),
                      ),
                      const SizedBox(height: 20),
                      const SectionHeader(title: '会员套餐'),
                      ...data.plans.map(
                        (p) => _PlanCard(
                          plan: p,
                          onTap: () => LiveRoutes.push(
                            context,
                            MemberPurchaseScreen(plan: p),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final active = membership.isActive;
    final remaining = active && membership.expireAt != null
        ? membership.expireAt!.difference(DateTime.now()).inDays
        : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? const [Color(0xFF1A1A1A), Color(0xFF0F0F0F)]
              : const [Color(0xFFBDBDBD), Color(0xFF757575)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(
                membership.levelName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  active ? '已开通' : membership.status == 'expired' ? '已过期' : '未开通',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            active && membership.expireAt != null
                ? '有效期至 ${fmtTime(membership.expireAt, withYear: true)}'
                : '开通会员享专属价格与福利',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          if (active) ...[
            const SizedBox(height: 4),
            Text(
              '剩余 ${remaining > 0 ? remaining : 0} 天',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            membership.memberNo.isNotEmpty ? '会员编号 ${membership.memberNo}' : '会员编号 --',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _QuickEntry extends StatelessWidget {
  const _QuickEntry({required this.icon, required this.label, required this.value, required this.onTap});

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
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LiveColors.textPrimary)),
            const Spacer(),
            if (value.isNotEmpty)
              Text(value, style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
            const Icon(Icons.chevron_right, size: 18, color: LiveColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onTap});

  final MemberPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: plan.recommended ? LiveColors.brandLight : LiveColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: plan.recommended ? LiveColors.brand : LiveColors.divider,
            width: plan.recommended ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary)),
                      if (plan.badge.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        TagChip(label: plan.badge, color: LiveColors.brand),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.benefits.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${plan.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: LiveColors.brand),
                ),
                Text(
                  plan.originalPrice > plan.price ? '原价 ¥${plan.originalPrice.toStringAsFixed(0)}' : '',
                  style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary, decoration: TextDecoration.lineThrough),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: LiveColors.textTertiary),
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
  String _payMethod = 'wechat';

  Future<void> _purchase() async {
    setState(() => _loading = true);
    try {
      final membership = await MemberService.instance.purchase(widget.plan.id);
      if (!mounted) return;
      showLiveSnack(context, '开通成功，会员有效期至 ${fmtTime(membership.expireAt, withYear: true)}');
      Navigator.of(context).pop(true);
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
          const LiveAppBar(title: '开通会员'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                  Text(widget.plan.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: LiveColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text('${widget.plan.durationDays} 天有效期',
                      style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
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
                  const Text('支付明细', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _PurchaseRow(
                    label: '套餐原价',
                    value: '¥${widget.plan.originalPrice.toStringAsFixed(2)}',
                    strikethrough: widget.plan.originalPrice > widget.plan.price,
                  ),
                  if (widget.plan.originalPrice > widget.plan.price)
                    _PurchaseRow(
                      label: '限时优惠',
                      value: '-¥${(widget.plan.originalPrice - widget.plan.price).toStringAsFixed(2)}',
                      valueColor: LiveColors.success,
                    ),
                  const Divider(height: 20, color: LiveColors.divider),
                  _PurchaseRow(
                    label: '实付金额',
                    value: '¥${widget.plan.price.toStringAsFixed(2)}',
                    bold: true,
                  ),
                  const SizedBox(height: 18),
                  const Text('支付方式', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _payMethod = 'wechat'),
                          child: Row(
                            children: [
                              Icon(
                                _payMethod == 'wechat'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: _payMethod == 'wechat'
                                    ? LiveColors.brand
                                    : LiveColors.textTertiary,
                              ),
                              const SizedBox(width: 8),
                              const Text('微信支付',
                                  style: TextStyle(fontSize: 14, color: LiveColors.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _payMethod = 'alipay'),
                          child: Row(
                            children: [
                              Icon(
                                _payMethod == 'alipay'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: _payMethod == 'alipay'
                                    ? LiveColors.brand
                                    : LiveColors.textTertiary,
                              ),
                              const SizedBox(width: 8),
                              const Text('支付宝',
                                  style: TextStyle(fontSize: 14, color: LiveColors.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: '确认开通',
                    loading: _loading,
                    onTap: _loading ? null : _purchase,
                  ),
                  const SizedBox(height: 12),
                  OutlineButton(
                    label: '再想想',
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '支付即代表同意《会员服务协议》，开通后立即生效',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: LiveColors.textTertiary),
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
    return LivePage(
      child: FutureBuilder<List<Coupon>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '卡包 · 优惠券'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '卡包 · 优惠券'), Expanded(child: LoadingView())],
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
                title: '卡包 · 优惠券',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: LiveColors.brand),
                    onPressed: () => LiveRoutes.push(context, const CouponCenterScreen()),
                  ),
                ],
              ),
              _CouponTabs(
                current: _tab,
                onChanged: (t) => setState(() => _tab = t),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyView(text: '暂无优惠券，去领券中心看看')
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _CouponCard(coupon: list[i]),
                        ),
                      ),
              ),
              const Divider(height: 1, color: LiveColors.divider),
              _QuickEntry(
                icon: Icons.workspace_premium_outlined,
                label: '会员专属体验',
                value: '每月 1 次 ›',
                onTap: () => LiveRoutes.push(context, const MemberCenterScreen()),
              ),
              _QuickEntry(
                icon: Icons.redeem_outlined,
                label: '领取更多优惠券',
                value: '',
                onTap: () => LiveRoutes.push(context, const CouponCenterScreen()),
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
    const tabs = [('unused', '可用'), ('used', '已使用'), ('expired', '已过期')];
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
              '¥${coupon.amount.toStringAsFixed(0)}',
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
        showLiveSnack(context, '领取成功');
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
    return LivePage(
      child: FutureBuilder<List<Coupon>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '领券中心'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '领券中心'), Expanded(child: LoadingView())],
            );
          }
          final list = snap.data!;
          return Column(
            children: [
              const LiveAppBar(title: '领券中心'),
              Expanded(
                child: list.isEmpty
                    ? const EmptyView(text: '暂无可领取的优惠券')
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                          label: '一键领取全部',
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
