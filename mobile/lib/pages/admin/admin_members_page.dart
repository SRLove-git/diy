import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 会员运营：会员列表 / 套餐管理 / 优惠券管理（对齐网页管理端 MembersView）
class AdminMembersPage extends StatefulWidget {
  const AdminMembersPage({super.key});

  @override
  State<AdminMembersPage> createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends State<AdminMembersPage> {
  int _tab = 0; // 0 会员列表 / 1 套餐管理 / 2 优惠券管理

  // 会员列表
  List<AdminMembership> _members = [];
  int _total = 0;
  int _page = 1;
  bool _membersLoading = true;
  String? _membersError;
  final TextEditingController _keywordController = TextEditingController();

  // 套餐
  List<AdminMemberPlan> _plans = [];
  bool _plansLoading = true;
  String? _plansError;

  // 优惠券
  List<AdminCoupon> _coupons = [];
  bool _couponsLoading = true;
  String? _couponsError;

  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadPlans();
    _loadCoupons();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _membersLoading = true;
      _membersError = null;
    });
    try {
      final paged = await AdminApi.fetchMemberships(
        page: _page,
        keyword: _keywordController.text,
      );
      if (mounted) {
        setState(() {
          _members = paged.items;
          _total = paged.total;
        });
      }
    } on DioException catch (e) {
      if (mounted) setState(() => _membersError = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _membersLoading = false);
    }
  }

  void _searchMembers() {
    setState(() => _page = 1);
    _loadMembers();
  }

  Future<void> _openMemberForm([AdminMembership? member]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MemberSheet(member: member, plans: _plans),
    );
    if (saved == true && mounted) {
      _toast('保存成功');
      _loadMembers();
    }
  }

  Future<void> _deleteMember(AdminMembership member) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除会员记录'),
        content: Text(
          '确认删除会员编号 ${member.memberNo}（用户 #${member.userId}）？'
          '删除后该用户会员资格立即失效，操作不可恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(ctx).danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.deleteMembership(member.id);
      if (mounted) {
        _toast('已删除');
        _loadMembers();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _loadPlans() async {
    setState(() {
      _plansLoading = true;
      _plansError = null;
    });
    try {
      final list = await AdminApi.fetchMemberPlans();
      if (mounted) setState(() => _plans = list);
    } on DioException catch (e) {
      if (mounted) setState(() => _plansError = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _plansLoading = false);
    }
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _couponsLoading = true;
      _couponsError = null;
    });
    try {
      final list = await AdminApi.fetchCoupons();
      if (mounted) setState(() => _coupons = list);
    } on DioException catch (e) {
      if (mounted) setState(() => _couponsError = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _couponsLoading = false);
    }
  }

  int get _totalPages => (_total / _pageSize).ceil().clamp(1, 1 << 31);

  void _goPage(int p) {
    if (p < 1 || p > _totalPages) return;
    setState(() => _page = p);
    _loadMembers();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openPlanForm([AdminMemberPlan? plan]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PlanSheet(plan: plan),
    );
    if (saved == true && mounted) {
      _toast('保存成功');
      _loadPlans();
    }
  }

  Future<void> _openCouponForm([AdminCoupon? coupon]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CouponSheet(coupon: coupon),
    );
    if (saved == true && mounted) {
      _toast('保存成功');
      _loadCoupons();
    }
  }

  Future<void> _togglePlan(AdminMemberPlan plan, bool enabled) async {
    try {
      await AdminApi.toggleMemberPlan(plan.id, enabled);
      if (mounted) _loadPlans();
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _toggleCoupon(AdminCoupon coupon, bool enabled) async {
    try {
      await AdminApi.toggleCoupon(coupon.id, enabled);
      if (mounted) _loadCoupons();
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员运营'),
        actions: [
          if (_tab == 0)
            ...[
              TextButton.icon(
                onPressed: () => _openMemberForm(),
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: const Text('开通会员'),
              ),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMembers),
            ]
          else if (_tab == 1)
            TextButton.icon(
              onPressed: () => _openPlanForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建套餐'),
            )
          else
            TextButton.icon(
              onPressed: () => _openCouponForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建优惠券'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab 切换
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colors.placeholder,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                for (final (i, label) in const [
                  (0, '会员列表'),
                  (1, '套餐管理'),
                  (2, '优惠券管理'),
                ])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _tab == i
                              ? colors.textPrimary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _tab == i
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _tab == i
                                ? colors.surface
                                : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: switch (_tab) {
              0 => _buildMembers(),
              1 => _buildPlans(),
              _ => _buildCoupons(),
            },
          ),
        ],
      ),
    );
  }

  // ─── 会员列表 ───

  Widget _buildMemberCard(AdminMembership member, AppColors colors) {
    final active = DateTime.tryParse(member.expireAt)?.isAfter(DateTime.now()) ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Expanded(
                child: Text(
                  member.memberNo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: active
                      ? Palette.success.withValues(alpha: 0.1)
                      : colors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  active ? '有效' : '已过期',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: active ? Palette.success : colors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${member.levelName} · 用户 #${member.userId}',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '有效期至 ${_shortDate(member.expireAt)}',
                      style: TextStyle(fontSize: 12, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '更新于 ${_shortDate(member.updatedAt)}',
                      style: TextStyle(fontSize: 11, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _openMemberForm(member),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('编辑'),
              ),
              TextButton.icon(
                onPressed: () => _deleteMember(member),
                icon: const Icon(Icons.delete_outline, size: 17),
                label: const Text('删除'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembers() {
    if (_membersLoading) return const LoadingWidget();
    if (_membersError != null) {
      return AppErrorWidget(message: _membersError!, onRetry: _loadMembers);
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _loadMembers,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          // 搜索：用户ID / 会员编号
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _keywordController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchMembers(),
              decoration: InputDecoration(
                hintText: '搜索用户ID / 会员编号',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _searchMembers,
                ),
                isDense: true,
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_members.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: EmptyWidget(
                icon: Icons.card_membership_outlined,
                message: '暂无会员',
              ),
            )
          else ...[
            for (final member in _members)
              _buildMemberCard(member, colors),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PageButton(
                  label: '上一页',
                  enabled: _page > 1,
                  onTap: () => _goPage(_page - 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_page / $_totalPages',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                _PageButton(
                  label: '下一页',
                  enabled: _page < _totalPages,
                  onTap: () => _goPage(_page + 1),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── 套餐管理 ───

  Widget _buildPlans() {
    if (_plansLoading) return const LoadingWidget();
    if (_plansError != null) {
      return AppErrorWidget(message: _plansError!, onRetry: _loadPlans);
    }
    if (_plans.isEmpty) {
      return const EmptyWidget(
        icon: Icons.dashboard_customize_outlined,
        message: '暂无套餐，点击右上角新建',
      );
    }
    final colors = AppColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        for (final plan in _plans)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                    Expanded(
                      child: Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (plan.badge.isNotEmpty)
                      _Tag(
                        label: plan.badge,
                        background: colors.primary.withValues(alpha: 0.12),
                        foreground: colors.primary,
                      ),
                    if (plan.recommended) ...[
                      const SizedBox(width: 6),
                      const _Tag(
                        label: '推荐',
                        background: Palette.primaryLight,
                        foreground: Palette.accent,
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      plan.enabled ? '上架中' : '已下架',
                      style: TextStyle(
                        fontSize: 12,
                        color: plan.enabled
                            ? Palette.success
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '¥${_fmtNum(plan.price)}  ·  ${plan.durationDays} 天',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Palette.accent,
                  ),
                ),
                if (plan.originalPrice > plan.price) ...[
                  const SizedBox(height: 2),
                  Text(
                    '原价 ¥${_fmtNum(plan.originalPrice)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  plan.benefits.isEmpty ? '暂无权益' : plan.benefits.join(' · '),
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _openPlanForm(plan),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('编辑'),
                    ),
                    const Spacer(),
                    Switch(
                      value: plan.enabled,
                      onChanged: (v) => _togglePlan(plan, v),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── 优惠券管理 ───

  Widget _buildCoupons() {
    if (_couponsLoading) return const LoadingWidget();
    if (_couponsError != null) {
      return AppErrorWidget(message: _couponsError!, onRetry: _loadCoupons);
    }
    if (_coupons.isEmpty) {
      return const EmptyWidget(
        icon: Icons.confirmation_number_outlined,
        message: '暂无优惠券，点击右上角新建',
      );
    }
    final colors = AppColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        for (final coupon in _coupons)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                    Expanded(
                      child: Text(
                        coupon.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (coupon.membersOnly)
                      const _Tag(
                        label: '仅会员',
                        background: Palette.iconBgPurple,
                        foreground: Palette.purple,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      coupon.enabled ? '上架中' : '已下架',
                      style: TextStyle(
                        fontSize: 12,
                        color: coupon.enabled
                            ? Palette.success
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${coupon.amount}  ·  ${coupon.threshold}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Palette.accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '有效期至 ${_shortDate(coupon.expireAt.toIso8601String())}'
                  '  ·  剩余库存 ${coupon.stock}',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _openCouponForm(coupon),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('编辑'),
                    ),
                    const Spacer(),
                    Switch(
                      value: coupon.enabled,
                      onChanged: (v) => _toggleCoupon(coupon, v),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _shortDate(String value) {
    final dt = DateTime.tryParse(value);
    if (dt == null || value.isEmpty) return value;
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static String _fmtNum(double n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toString();
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(72, 36),
        padding: EdgeInsets.zero,
        foregroundColor: enabled ? colors.primary : colors.textSecondary,
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: foreground),
      ),
    );
  }
}

// ─── 套餐编辑弹层 ───

class _PlanSheet extends StatefulWidget {
  const _PlanSheet({this.plan});

  final AdminMemberPlan? plan;

  @override
  State<_PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<_PlanSheet> {
  late final TextEditingController _name;
  late final TextEditingController _duration;
  late final TextEditingController _price;
  late final TextEditingController _originalPrice;
  late final TextEditingController _benefits;
  late final TextEditingController _badge;
  late bool _recommended;
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _name = TextEditingController(text: plan?.name ?? '');
    _duration = TextEditingController(text: '${plan?.durationDays ?? 30}');
    _price = TextEditingController(text: plan == null ? '' : _fmt(plan.price));
    _originalPrice = TextEditingController(
      text: plan == null ? '' : _fmt(plan.originalPrice),
    );
    _benefits = TextEditingController(
      text: plan?.benefits.join('\n') ?? '',
    );
    _badge = TextEditingController(text: plan?.badge ?? '');
    _recommended = plan?.recommended ?? false;
    _enabled = plan?.enabled ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _duration.dispose();
    _price.dispose();
    _originalPrice.dispose();
    _benefits.dispose();
    _badge.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final durationDays = int.tryParse(_duration.text.trim());
    final price = double.tryParse(_price.text.trim());
    final originalPrice = double.tryParse(_originalPrice.text.trim());
    if (name.isEmpty || durationDays == null || price == null || originalPrice == null) {
      _toast('请填写完整（名称 / 时长 / 售价 / 原价）');
      return;
    }
    final benefits = _benefits.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final data = {
      'name': name,
      'durationDays': durationDays,
      'price': price,
      'originalPrice': originalPrice,
      'benefits': benefits,
      'badge': _badge.text.trim(),
      'recommended': _recommended,
      'enabled': _enabled,
    };
    setState(() => _saving = true);
    try {
      if (widget.plan == null) {
        await AdminApi.createMemberPlan(data);
      } else {
        await AdminApi.updateMemberPlan(widget.plan!.id, data);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.plan == null ? '新建套餐' : '编辑套餐',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: '套餐名称',
                hintText: '如：月卡 / 季卡 / 年卡',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _duration,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: '时长（天）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(labelText: '售价（元）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _originalPrice,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(labelText: '原价（元，划线价）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _badge,
              decoration: const InputDecoration(
                labelText: '角标',
                hintText: '如：推荐 / 最划算，可为空',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _benefits,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '套餐权益（每行一条）',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('推荐套餐'),
              value: _recommended,
              onChanged: (v) => setState(() => _recommended = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('上架'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? '保存中…' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toString();
}

// ─── 优惠券编辑弹层 ───

class _CouponSheet extends StatefulWidget {
  const _CouponSheet({this.coupon});

  final AdminCoupon? coupon;

  @override
  State<_CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<_CouponSheet> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _threshold;
  late final TextEditingController _stock;
  late DateTime _expireAt;
  late bool _membersOnly;
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final coupon = widget.coupon;
    _title = TextEditingController(text: coupon?.title ?? '');
    _amount = TextEditingController(text: coupon?.amount ?? '');
    _threshold = TextEditingController(text: coupon?.threshold ?? '无门槛');
    _stock = TextEditingController(text: '${coupon?.stock ?? 0}');
    _expireAt = coupon?.expireAt ?? DateTime.now().add(const Duration(days: 30));
    _membersOnly = coupon?.membersOnly ?? true;
    _enabled = coupon?.enabled ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _threshold.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickExpireAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expireAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expireAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _expireAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final amount = _amount.text.trim();
    final threshold = _threshold.text.trim();
    final stock = int.tryParse(_stock.text.trim());
    if (title.isEmpty || amount.isEmpty || threshold.isEmpty || stock == null) {
      _toast('请填写完整（标题 / 券额 / 门槛 / 库存）');
      return;
    }
    final data = {
      'title': title,
      'amount': amount,
      'threshold': threshold,
      'expireAt': _expireAt.toIso8601String(),
      'stock': stock,
      'membersOnly': _membersOnly,
      'enabled': _enabled,
    };
    setState(() => _saving = true);
    try {
      if (widget.coupon == null) {
        await AdminApi.createCoupon(data);
      } else {
        await AdminApi.updateCoupon(widget.coupon!.id, data);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String get _expireLabel {
    final d = _expireAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.coupon == null ? '新建优惠券' : '编辑优惠券',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: '券名称',
                hintText: '如：新客立减券',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              decoration: const InputDecoration(
                labelText: '券额文案',
                hintText: '如：¥20 / 8.8 折',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _threshold,
              decoration: const InputDecoration(
                labelText: '使用门槛',
                hintText: '如：满 100 可用 / 无门槛',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: '库存'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickExpireAt,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '有效期至',
                  suffixIcon: Icon(Icons.calendar_month_outlined),
                ),
                child: Text(_expireLabel),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('仅会员可领'),
              value: _membersOnly,
              onChanged: (v) => setState(() => _membersOnly = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('上架'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? '保存中…' : '保存'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 会员开通/编辑弹层 ───

class _MemberSheet extends StatefulWidget {
  const _MemberSheet({this.member, this.plans = const []});

  final AdminMembership? member;
  final List<AdminMemberPlan> plans;

  @override
  State<_MemberSheet> createState() => _MemberSheetState();
}

class _MemberSheetState extends State<_MemberSheet> {
  late final TextEditingController _userId;
  late final TextEditingController _levelName;
  late DateTime _expireAt;
  int? _planId;
  bool _saving = false;

  bool get _editing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _userId = TextEditingController(text: '${member?.userId ?? ''}');
    _levelName = TextEditingController(text: member?.levelName ?? '手作会员');
    _expireAt =
        DateTime.tryParse(member?.expireAt ?? '') ??
        DateTime.now().add(const Duration(days: 30));
    _planId = null;
  }

  @override
  void dispose() {
    _userId.dispose();
    _levelName.dispose();
    super.dispose();
  }

  Future<void> _pickExpireAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expireAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expireAt),
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

  void _fillFromPlan(int? planId) {
    final plan = widget.plans.where((p) => p.id == planId).firstOrNull;
    if (plan == null) return;
    setState(() {
      _expireAt = DateTime.now().add(Duration(days: plan.durationDays));
    });
  }

  Future<void> _save() async {
    final userId = int.tryParse(_userId.text.trim());
    if (!_editing && (userId == null || userId <= 0)) {
      _toast('请输入用户ID');
      return;
    }
    final levelName = _levelName.text.trim();
    if (levelName.isEmpty) {
      _toast('请输入会员等级');
      return;
    }
    setState(() => _saving = true);
    try {
      if (_editing) {
        await AdminApi.updateMembership(widget.member!.id, {
          'levelName': levelName,
          'expireAt': _expireAt.toIso8601String(),
        });
      } else {
        await AdminApi.createMembership({
          'userId': userId,
          'levelName': levelName,
          'expireAt': _expireAt.toIso8601String(),
        });
      }
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String get _expireLabel {
    final d = _expireAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editing ? '编辑会员' : '开通会员',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _userId,
              enabled: !_editing,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '用户ID',
                hintText: '输入要开通会员的用户ID',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _levelName,
              decoration: const InputDecoration(
                labelText: '会员等级',
                hintText: '如：手作会员',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickExpireAt,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '有效期至',
                  suffixIcon: Icon(Icons.calendar_month_outlined),
                ),
                child: Text(_expireLabel),
              ),
            ),
            if (!_editing && widget.plans.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _planId,
                decoration: const InputDecoration(
                  labelText: '按套餐开通（快捷填充有效期）',
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('不按套餐，手动选择有效期'),
                  ),
                  for (final plan in widget.plans)
                    DropdownMenuItem<int?>(
                      value: plan.id,
                      child: Text('${plan.name}（${plan.durationDays} 天）'),
                    ),
                ],
                onChanged: (v) {
                  setState(() => _planId = v);
                  _fillFromPlan(v);
                },
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? '保存中…' : '保存'),
            ),
          ],
        ),
      ),
    );
  }
}
