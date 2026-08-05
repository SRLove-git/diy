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
          side: BorderSide(color: colors.divider),
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
  late bool _membersOnly;
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
    _membersOnly = a?.membersOnly ?? false;
    _enabled = a?.enabled ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _tagCtrl.dispose();
    _descCtrl.dispose();
    _sortCtrl.dispose();
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
              controller: _sortCtrl,
              decoration: const InputDecoration(labelText: '排序权重', hintText: '越小越靠前'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
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
