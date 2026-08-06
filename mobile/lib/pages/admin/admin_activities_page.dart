import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 活动管理：活动列表 + 新增/编辑 + 上/下架 + 排序（对齐网页管理端）
class AdminActivitiesPage extends StatefulWidget {
  const AdminActivitiesPage({super.key});

  @override
  State<AdminActivitiesPage> createState() => _AdminActivitiesPageState();
}

class _AdminActivitiesPageState extends State<AdminActivitiesPage> {
  List<AdminActivity> _activities = [];
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
      final list = await AdminApi.fetchActivities();
      if (mounted) setState(() => _activities = list);
    } on DioException catch (e) {
      if (mounted) setState(() => _error = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openForm([AdminActivity? activity]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ActivityFormDialog(activity: activity),
    );
    if (result == null) return;
    try {
      if (activity == null) {
        await AdminApi.createActivity(result);
      } else {
        await AdminApi.updateActivity(activity.id, result);
      }
      if (mounted) {
        _toast(activity == null ? '新增活动成功' : '保存成功');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _toggle(AdminActivity activity) async {
    try {
      await AdminApi.toggleActivity(activity.id, !activity.enabled);
      if (mounted) {
        _toast(activity.enabled ? '已下架' : '已上架');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _move(AdminActivity activity, int delta) async {
    final sorted = [..._activities]
      ..sort((a, b) {
        final c = a.sort.compareTo(b.sort);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    final idx = sorted.indexWhere((x) => x.id == activity.id);
    final targetIdx = idx + delta;
    if (idx < 0 || targetIdx < 0 || targetIdx >= sorted.length) return;
    final target = sorted[targetIdx];
    try {
      await Future.wait([
        AdminApi.updateActivity(activity.id, {'sort': target.sort}),
        AdminApi.updateActivity(target.id, {'sort': activity.sort}),
      ]);
      if (mounted) _load();
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活动管理'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
            tooltip: '新增活动',
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const LoadingWidget(message: '加载中…')
            : _error != null
                ? AppErrorWidget(message: _error!, onRetry: _load)
                : _activities.isEmpty
                    ? EmptyWidget(
                        icon: Icons.event_outlined,
                        message: '暂无活动',
                        actionLabel: '新增活动',
                        onAction: () => _openForm(),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _activities.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final a = _activities[i];
                            return _ActivityCard(
                              activity: a,
                              isFirst: i == 0,
                              isLast: i == _activities.length - 1,
                              onEdit: () => _openForm(a),
                              onToggle: () => _toggle(a),
                              onMoveUp: () => _move(a, -1),
                              onMoveDown: () => _move(a, 1),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onToggle,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final AdminActivity activity;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Opacity(
      opacity: activity.enabled ? 1 : 0.55,
      child: Card(
        elevation: 0,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.textPrimary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (activity.membersOnly)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '会员专属',
                        style: TextStyle(fontSize: 10, color: colors.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, size: 13, color: colors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    activity.date,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  if (activity.tag.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.local_offer_outlined, size: 13, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      activity.tag,
                      style: TextStyle(fontSize: 12, color: colors.primary),
                    ),
                  ],
                ],
              ),
              if (activity.desc.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  activity.desc,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (activity.bookable) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.sell_outlined,
                      size: 14,
                      color: Palette.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.memberPrice != null
                          ? '可预约 · 会员价 ¥${_fmtNum(activity.memberPrice!)} / ${_fmtNum(activity.price)}'
                          : '可预约 · ${_fmtNum(activity.price)} 元/人',
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 24),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                    onPressed: isFirst ? null : onMoveUp,
                    tooltip: '上移',
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    onPressed: isLast ? null : onMoveDown,
                    tooltip: '下移',
                  ),
                  const Spacer(),
                  Text(
                    activity.enabled ? '已上架' : '已下架',
                    style: TextStyle(
                      fontSize: 12,
                      color: activity.enabled ? Palette.success : colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: activity.enabled,
                    onChanged: (_) => onToggle(),
                  ),
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _SessionsManagerDialog(
                        activity: activity,
                      ),
                    ),
                    child: const Text('场次管理'),
                  ),
                  TextButton(onPressed: onEdit, child: const Text('编辑')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityFormDialog extends StatefulWidget {
  const _ActivityFormDialog({this.activity});

  final AdminActivity? activity;

  @override
  State<_ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<_ActivityFormDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _tagCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _sortCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _memberPriceCtrl;
  late bool _membersOnly;
  late bool _bookable;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _dateCtrl = TextEditingController(text: a?.date ?? '');
    _tagCtrl = TextEditingController(text: a?.tag ?? '');
    _descCtrl = TextEditingController(text: a?.desc ?? '');
    _sortCtrl = TextEditingController(text: (a?.sort ?? 0).toString());
    _addressCtrl = TextEditingController(text: a?.address ?? '');
    _latCtrl = TextEditingController(text: (a?.lat ?? 30.3).toString());
    _lngCtrl = TextEditingController(text: (a?.lng ?? 120.1).toString());
    _priceCtrl = TextEditingController(text: (a?.price ?? 0).toString());
    _memberPriceCtrl = TextEditingController(
      text: a?.memberPrice == null ? '' : a!.memberPrice.toString(),
    );
    _membersOnly = a?.membersOnly ?? false;
    _bookable = a?.bookable ?? false;
    _enabled = a?.enabled ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _tagCtrl.dispose();
    _descCtrl.dispose();
    _sortCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _priceCtrl.dispose();
    _memberPriceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty || _dateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('标题和活动时间不能为空')));
      return;
    }
    Navigator.of(context).pop({
      'title': _titleCtrl.text.trim(),
      'date': _dateCtrl.text.trim(),
      'tag': _tagCtrl.text.trim(),
      'desc': _descCtrl.text.trim(),
      'membersOnly': _membersOnly,
      'bookable': _bookable,
      'address': _addressCtrl.text.trim(),
      'lat': double.tryParse(_latCtrl.text.trim()) ?? 30.3,
      'lng': double.tryParse(_lngCtrl.text.trim()) ?? 120.1,
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      if (_memberPriceCtrl.text.trim().isNotEmpty)
        'memberPrice': double.tryParse(_memberPriceCtrl.text.trim()) ?? 0,
      'enabled': _enabled,
      'sort': int.tryParse(_sortCtrl.text.trim()) ?? 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AlertDialog(
      title: Text(widget.activity == null ? '新增活动' : '编辑活动'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: '标题', hintText: '如 周末拼豆沙龙'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(labelText: '活动时间', hintText: '如 08-16 14:00 / 08-22 起'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tagCtrl,
              decoration: const InputDecoration(labelText: '标签', hintText: '如 限会员 / 早鸟 8 折'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: '描述'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: '活动地址',
                hintText: '可预约活动必填，用于附近排序',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: '纬度'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: '经度'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '门市价（元/人）',
                      hintText: '如 68',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _memberPriceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '会员价（元/人）',
                      hintText: '0 = 会员免费',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sortCtrl,
              decoration: const InputDecoration(labelText: '排序权重', hintText: '越小越靠前'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('可预约（进入预约流程）'),
              value: _bookable,
              onChanged: (v) => setState(() => _bookable = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('会员专属'),
              value: _membersOnly,
              onChanged: (v) => setState(() => _membersOnly = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('上架'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: colors.primary),
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 活动场次管理弹层：查看 / 新增 / 删除场次
class _SessionsManagerDialog extends StatefulWidget {
  const _SessionsManagerDialog({required this.activity});

  final AdminActivity activity;

  @override
  State<_SessionsManagerDialog> createState() => _SessionsManagerDialogState();
}

class _SessionsManagerDialogState extends State<_SessionsManagerDialog> {
  late final List<AdminActivitySession> _sessions = [
    ...widget.activity.sessions,
  ];
  final _dateCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '12');
  bool _saving = false;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_dateCtrl.text.trim().isEmpty ||
        _startCtrl.text.trim().isEmpty ||
        _endCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写日期、开始和结束时间')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final session = await AdminApi.addActivitySession(widget.activity.id, {
        'date': _dateCtrl.text.trim(),
        'startTime': _startCtrl.text.trim(),
        'endTime': _endCtrl.text.trim(),
        'capacity': int.tryParse(_capacityCtrl.text.trim()) ?? 12,
      });
      if (!mounted) return;
      setState(() {
        _sessions.add(session);
        _saving = false;
        _dateCtrl.clear();
        _startCtrl.clear();
        _endCtrl.clear();
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AdminApi.messageOf(e))),
      );
    }
  }

  Future<void> _remove(AdminActivitySession session) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除场次'),
        content: Text('确认删除 ${session.date} ${session.startTime}-${session.endTime}？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.removeActivitySession(session.id);
      if (!mounted) return;
      setState(() => _sessions.removeWhere((s) => s.id == session.id));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AdminApi.messageOf(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final sorted = [..._sessions]..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.startTime.compareTo(b.startTime);
      });
    return AlertDialog(
      title: Text('场次管理 · ${widget.activity.title}'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in sorted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${s.date} ${s.startTime}-${s.endTime} · 上限 ${s.capacity} 人',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _remove(s),
                        tooltip: '删除',
                      ),
                    ],
                  ),
                ),
              const Divider(height: 16),
              Text(
                '新增场次（日期格式 YYYY-MM-DD）',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateCtrl,
                decoration: const InputDecoration(
                  labelText: '日期',
                  hintText: '如 2026-08-10',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startCtrl,
                      decoration: const InputDecoration(
                        labelText: '开始',
                        hintText: '如 14:00',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _endCtrl,
                      decoration: const InputDecoration(
                        labelText: '结束',
                        hintText: '如 16:00',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _capacityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '名额',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _add,
                  child: Text(_saving ? '添加中…' : '添加场次'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

String _fmtNum(double value) {
  if (value == value.roundToDouble()) return '${value.toInt()}';
  return value.toStringAsFixed(2);
}
