import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../widgets/state_widgets.dart';
import '../data/mock_member_repository.dart';
import '../domain/member_models.dart';
import '../domain/member_repository.dart';

/// 会员套餐页面
///
/// 展示：会员开通/续费/到期状态、会员编号、有效期、
/// 不同期限套餐及价格、会员专属体验价、优惠券与专属活动。
class MemberPlanPage extends StatefulWidget {
  const MemberPlanPage({super.key});

  @override
  State<MemberPlanPage> createState() => _MemberPlanPageState();
}

class _MemberPlanPageState extends State<MemberPlanPage> {
  final MemberRepository _repo = MockMemberRepository();

  MyMembership? _membership;
  List<MemberPlan> _plans = [];
  List<MemberExperience> _experiences = [];
  List<MemberCoupon> _coupons = [];
  List<MemberActivity> _activities = [];

  String? _selectedPlanId;
  bool _loading = true;
  String? _error;
  bool _purchasing = false;

  MemberPlan? get _selectedPlan {
    for (final p in _plans) {
      if (p.id == _selectedPlanId) return p;
    }
    return _plans.isEmpty ? null : _plans.first;
  }

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
      final results = await Future.wait([
        _repo.fetchMyMembership(),
        _repo.fetchPlans(),
        _repo.fetchExperiences(),
        _repo.fetchCoupons(),
        _repo.fetchActivities(),
      ]);
      if (!mounted) return;
      setState(() {
        _membership = results[0] as MyMembership;
        _plans = results[1] as List<MemberPlan>;
        _experiences = results[2] as List<MemberExperience>;
        _coupons = results[3] as List<MemberCoupon>;
        _activities = results[4] as List<MemberActivity>;
        // 默认选中「推荐」套餐
        _selectedPlanId ??= _plans
                .where((p) => p.recommended)
                .firstOrNull
                ?.id ??
            _plans.firstOrNull?.id;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '加载失败，请重试';
      });
    }
  }

  /// 模拟开通 / 续费：确认弹层 → 更新会员状态
  Future<void> _purchase() async {
    final plan = _selectedPlan;
    if (plan == null || _purchasing) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final colors = AppColors.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '确认开通',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '${plan.name} · ${plan.durationLabel} · 有效期 ${plan.durationDays} 天',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('模拟支付 ¥${_formatPrice(plan.price)}'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    '暂不购买',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _purchasing = true);
    try {
      final updated = await _repo.purchase(plan.id);
      if (!mounted) return;
      setState(() => _membership = updated);
      _toast('开通成功，有效期至 ${_formatDate(updated.expireAt!)}');
    } catch (_) {
      if (!mounted) return;
      _toast('开通失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  /// 领取优惠券（Mock：本地置为已领取）
  Future<void> _receiveCoupon(MemberCoupon coupon) async {
    if (coupon.received) return;
    setState(() {
      _coupons = [
        for (final c in _coupons)
          c.id == coupon.id ? c.copyWith(received: true) : c,
      ];
    });
    _toast('${coupon.title} 已领取，可在到店核销时使用');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── 格式化工具 ───

  static String _formatPrice(double value) =>
      value == value.roundToDouble() ? '¥${value.toInt()}' : '¥$value';

  static String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  // ─── 构建 ───

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final canShowBar = !_loading && _error == null && _plans.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('会员套餐')),
      body: _buildBody(),
      bottomNavigationBar: canShowBar
          ? _buildPurchaseBar(colors)
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingWidget(message: '加载会员信息…');
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          _buildPlanSection(),
          _buildExperienceSection(),
          _buildCouponSection(),
          _buildActivitySection(),
        ],
      ),
    );
  }

  // ─── 1. 会员状态卡片（编号 / 有效期 / 开通续费到期状态） ───

  Widget _buildStatusCard() {
    final m = _membership!;
    final gradient = switch (m.status) {
      MemberStatus.active => const [
          Color(0xFF7C6FF7),
          Color(0xFFFF6B6B),
        ],
      MemberStatus.expired => const [
          Color(0xFF9A9AA4),
          Color(0xFF6E6E7A),
        ],
      MemberStatus.none => const [
          Color(0xFFFFB347),
          Color(0xFFFF6B6B),
        ],
    };
    final (chipText, chipColor) = switch (m.status) {
      MemberStatus.active => ('生效中', const Color(0xFF2E9E5B)),
      MemberStatus.expired => ('已到期', const Color(0xFFD9453E)),
      MemberStatus.none => ('未开通', const Color(0xFFFFB347)),
    };

    final subtitle = switch (m.status) {
      MemberStatus.active =>
        '有效期至 ${_formatDate(m.expireAt!)} · 剩余 ${m.remainingDays} 天',
      MemberStatus.expired => '有效期至 ${_formatDate(m.expireAt!)} · 续费恢复全部权益',
      MemberStatus.none => '开通会员，解锁专属体验价与优惠券',
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                m.levelName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chipText,
                  style: TextStyle(
                    color: chipColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '会员编号  $memberNo',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String get memberNo =>
      _membership?.memberNo.isEmpty == true ? '开通后生成' : _membership!.memberNo;

  // ─── 2. 会员套餐（不同期限 + 价格） ───

  Widget _buildPlanSection() {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('会员套餐', '选择时长，随时可续费'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < _plans.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _buildPlanCard(_plans[i], colors)),
              ],
            ],
          ),
        ),
        // 选中套餐权益
        if (_selectedPlan != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildPlanBenefits(_selectedPlan!, colors),
          ),
      ],
    );
  }

  Widget _buildPlanCard(MemberPlan plan, AppColors colors) {
    final selected = plan.id == _selectedPlanId;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.primary : colors.divider,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              child: plan.badge != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          plan.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              plan.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 1),
                Text(
                  _formatPrice(plan.price).replaceFirst('¥', ''),
                  style: TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '原价 ${_formatPrice(plan.originalPrice)}',
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanBenefits(MemberPlan plan, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${plan.name}权益',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (final benefit in plan.benefits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 15, color: colors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textPrimary,
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

  // ─── 3. 会员专属预约 / 到店体验价格 ───

  Widget _buildExperienceSection() {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('会员专属体验价', '预约到店，享专属价'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _experiences.length; i++) ...[
                if (i > 0) Divider(height: 1, color: colors.divider),
                _buildExperienceRow(_experiences[i], colors),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceRow(MemberExperience exp, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  exp.desc,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  '会员每月 ${exp.quota} 次',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '会员 ',
                    style: TextStyle(
                        fontSize: 11, color: colors.textSecondary),
                  ),
                  Text(
                    _formatPrice(exp.memberPrice),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '门市价 ${_formatPrice(exp.normalPrice)}',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 4. 会员优惠券 ───

  Widget _buildCouponSection() {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('会员优惠券', '到店核销时使用'),
        SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _coupons.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _buildCouponCard(_coupons[i], colors),
          ),
        ),
      ],
    );
  }

  Widget _buildCouponCard(MemberCoupon coupon, AppColors colors) {
    return Container(
      width: 264,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // 券额区
          Container(
            width: 84,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  coupon.amount,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coupon.threshold,
                  style: TextStyle(fontSize: 10, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          // 券信息区
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '有效期至 ${_formatDate(coupon.expireAt)}',
                    style: TextStyle(
                        fontSize: 11, color: colors.textSecondary),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: coupon.received
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.placeholder,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '已领取',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () => _receiveCoupon(coupon),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '领取',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 5. 会员专属活动 ───

  Widget _buildActivitySection() {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('会员专属活动', '优先报名 · 双倍积分'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final activity in _activities) ...[
                _buildActivityCard(activity, colors),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(MemberActivity activity, AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity.tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                activity.date,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            activity.desc,
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── 通用区块标题 ───

  Widget _buildSectionHeader(String title, String subtitle) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 底部开通 / 续费栏 ───

  Widget _buildPurchaseBar(AppColors colors) {
    final plan = _selectedPlan;
    if (plan == null) return const SizedBox.shrink();
    final isMember = _membership?.status == MemberStatus.active;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${plan.name} · ${plan.durationLabel}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _formatPrice(plan.price),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' 原价 ${_formatPrice(plan.originalPrice)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: _purchasing ? null : _purchase,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(132, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: Text(
                  _purchasing
                      ? '开通中…'
                      : isMember
                          ? '立即续费'
                          : '立即开通',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
