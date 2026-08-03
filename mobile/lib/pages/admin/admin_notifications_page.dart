import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 通知管理：发送记录 + 消息模板 + 发送/模板编辑（对齐网页管理端）
class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  int _tab = 0; // 0 发送记录 / 1 消息模板

  // 发送记录
  List<AdminNotification> _notifications = [];
  int _total = 0;
  int _page = 1;
  bool _loading = true;
  String? _error;

  // 模板
  List<AdminNotificationTemplate> _templates = [];
  bool _tplLoading = true;
  String? _tplError;

  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadTemplates();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final paged = await AdminApi.fetchNotifications(page: _page, pageSize: _pageSize);
      if (mounted) {
        setState(() {
          _notifications = paged.items;
          _total = paged.total;
        });
      }
    } on DioException catch (e) {
      if (mounted) setState(() => _error = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _tplLoading = true;
      _tplError = null;
    });
    try {
      final list = await AdminApi.fetchTemplates();
      if (mounted) setState(() => _templates = list);
    } on DioException catch (e) {
      if (mounted) setState(() => _tplError = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _tplLoading = false);
    }
  }

  int get _totalPages => (_total / _pageSize).ceil().clamp(1, 1 << 31);

  void _goPage(int p) {
    if (p < 1 || p > _totalPages) return;
    setState(() => _page = p);
    _loadNotifications();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _removeNotification(AdminNotification n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除通知'),
        content: const Text('确认删除该通知？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.of(ctx).danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.removeNotification(n.id);
      if (mounted) {
        _toast('已删除');
        _loadNotifications();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _openSend([AdminNotificationTemplate? tpl]) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SendSheet(template: tpl),
    );
    if (sent == true && mounted) {
      _toast('发送成功');
      _loadNotifications();
    }
  }

  Future<void> _openTemplateForm([AdminNotificationTemplate? tpl]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TemplateSheet(template: tpl),
    );
    if (saved == true && mounted) {
      _toast('保存成功');
      _loadTemplates();
    }
  }

  Future<void> _removeTemplate(AdminNotificationTemplate t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除模板'),
        content: const Text('确认删除该模板？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.of(ctx).danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.removeTemplate(t.id);
      if (mounted) {
        _toast('已删除');
        _loadTemplates();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知管理'),
        actions: [
          if (_tab == 0)
            TextButton.icon(
              onPressed: () => _openSend(),
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('发送通知'),
            )
          else
            TextButton.icon(
              onPressed: () => _openTemplateForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建模板'),
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
                for (final (i, label) in const [(0, '发送记录'), (1, '消息模板')])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _tab == i ? colors.textPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _tab == i ? FontWeight.w600 : FontWeight.w400,
                            color: _tab == i ? colors.surface : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _tab == 0 ? _buildRecords() : _buildTemplates(),
          ),
        ],
      ),
    );
  }

  // ─── 发送记录 ───
  Widget _buildRecords() {
    if (_loading) return const LoadingWidget();
    if (_error != null) return AppErrorWidget(message: _error!, onRetry: _loadNotifications);
    if (_notifications.isEmpty) {
      return const EmptyWidget(icon: Icons.notifications_none, message: '暂无发送记录');
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final n in _notifications) ...[
            _buildNotificationCard(n, colors),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _page <= 1 ? null : () => _goPage(_page - 1),
                child: const Text('上一页'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_page / $_totalPages（共 $_total 条）',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
              ),
              OutlinedButton(
                onPressed: _page >= _totalPages ? null : () => _goPage(_page + 1),
                child: const Text('下一页'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AdminNotification n, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  n.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(_fmtTime(n.createdAt), style: TextStyle(fontSize: 12, color: colors.textSecondary)),
            ],
          ),
          if (n.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _miniTag(_targetLabel(n), colors),
              const SizedBox(width: 6),
              _miniTag(_channelLabel(n.channels), colors),
              const Spacer(),
              TextButton(
                onPressed: () => _removeNotification(n),
                style: TextButton.styleFrom(
                  foregroundColor: colors.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('删除', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _targetLabel(AdminNotification n) {
    switch (n.targetType) {
      case 'all':
        return '全体用户';
      case 'role':
        return '${n.targetRole == 'admin' ? '管理员' : '用户'}（按角色）';
      default:
        final ids = n.targetUserIds.split(',').where((e) => e.trim().isNotEmpty).length;
        return '指定用户（$ids 人）';
    }
  }

  String _channelLabel(String channels) {
    const map = {'push': '推送', 'sms': '短信', 'email': '邮件'};
    return channels.split(',').map((c) => map[c.trim()] ?? c.trim()).join('、');
  }

  // ─── 消息模板 ───
  Widget _buildTemplates() {
    if (_tplLoading) return const LoadingWidget();
    if (_tplError != null) return AppErrorWidget(message: _tplError!, onRetry: _loadTemplates);
    if (_templates.isEmpty) {
      return const EmptyWidget(icon: Icons.description_outlined, message: '暂无消息模板');
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _loadTemplates,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _templates.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _buildTemplateCard(_templates[i], colors),
      ),
    );
  }

  Widget _buildTemplateCard(AdminNotificationTemplate t, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  t.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              _miniTag(_categoryLabel(t.category), colors),
              const SizedBox(width: 6),
              _miniTag(
                t.enabled ? '启用' : '停用',
                colors,
                color: t.enabled ? const Color(0xFF2E9E5B) : colors.danger,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '标题：${t.titleTemplate}',
            style: TextStyle(fontSize: 13, color: colors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '正文：${t.contentTemplate}',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '更新 ${_fmtTime(t.updatedAt)}',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _openSend(t),
                child: const Text('发送', style: TextStyle(fontSize: 13)),
              ),
              TextButton(
                onPressed: () => _openTemplateForm(t),
                child: const Text('编辑', style: TextStyle(fontSize: 13)),
              ),
              TextButton(
                onPressed: () => _removeTemplate(t),
                style: TextButton.styleFrom(foregroundColor: colors.danger),
                child: const Text('删除', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String text, AppColors colors, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.placeholder,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color ?? colors.textSecondary),
      ),
    );
  }

  String _categoryLabel(String cat) {
    const map = {'system': '系统通知', 'booking': '预约', 'community': '社区互动', 'activity': '活动'};
    return map[cat] ?? cat;
  }

  String _fmtTime(String t) {
    final d = DateTime.tryParse(t);
    if (d == null) return t;
    String p(int n) => n.toString().padLeft(2, '0');
    return '${d.month}-${p(d.day)} ${p(d.hour)}:${p(d.minute)}';
  }
}

/// 发送通知底部弹层
class _SendSheet extends StatefulWidget {
  const _SendSheet({this.template});

  final AdminNotificationTemplate? template;

  @override
  State<_SendSheet> createState() => _SendSheetState();
}

class _SendSheetState extends State<_SendSheet> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  String _targetType = 'all';
  String _targetRole = 'user';
  final _targetUserIds = TextEditingController();
  final _channels = <String>['push'];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.template?.titleTemplate ?? '');
    _content = TextEditingController(text: widget.template?.contentTemplate ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _targetUserIds.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('标题和内容不能为空')));
      return;
    }
    setState(() => _sending = true);
    try {
      final data = <String, dynamic>{
        'title': _title.text.trim(),
        'content': _content.text.trim(),
        'targetType': _targetType,
        'channels': _channels.join(',') == '' ? 'push' : _channels.join(','),
      };
      if (_targetType == 'role') data['targetRole'] = _targetRole;
      if (_targetType == 'user') data['targetUserIds'] = _targetUserIds.text.trim();
      await AdminApi.sendNotification(data);
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AdminApi.messageOf(e))));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('发送通知', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _label('标题', colors),
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                  hintText: '通知标题',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _label('内容', colors),
              TextField(
                controller: _content,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '通知正文',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _label('发送目标', colors),
              DropdownButtonFormField<String>(
                initialValue: _targetType,
                isDense: true,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('全体用户')),
                  DropdownMenuItem(value: 'role', child: Text('按角色')),
                  DropdownMenuItem(value: 'user', child: Text('指定用户')),
                ],
                onChanged: (v) => setState(() => _targetType = v ?? 'all'),
              ),
              if (_targetType == 'role') ...[
                const SizedBox(height: 12),
                _label('目标角色', colors),
                DropdownButtonFormField<String>(
                  initialValue: _targetRole,
                  isDense: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('普通用户')),
                    DropdownMenuItem(value: 'admin', child: Text('管理员')),
                  ],
                  onChanged: (v) => setState(() => _targetRole = v ?? 'user'),
                ),
              ],
              if (_targetType == 'user') ...[
                const SizedBox(height: 12),
                _label('用户ID（逗号分隔）', colors),
                TextField(
                  controller: _targetUserIds,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '如 1,2,3',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _label('发送渠道', colors),
              Row(
                children: [
                  for (final (v, label) in const [
                    ('push', '推送'),
                    ('sms', '短信'),
                    ('email', '邮件'),
                  ])
                    Row(
                      children: [
                        Checkbox(
                          value: _channels.contains(v),
                          onChanged: (on) {
                            setState(() {
                              if (on == true) {
                                if (!_channels.contains(v)) _channels.add(v);
                              } else {
                                _channels.remove(v);
                              }
                            });
                          },
                        ),
                        Text(label, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 12),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sending ? null : () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _sending ? null : _send,
                      child: Text(_sending ? '发送中…' : '确认发送'),
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

  Widget _label(String text, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
      ),
    );
  }
}

/// 模板新建/编辑底部弹层
class _TemplateSheet extends StatefulWidget {
  const _TemplateSheet({this.template});

  final AdminNotificationTemplate? template;

  @override
  State<_TemplateSheet> createState() => _TemplateSheetState();
}

class _TemplateSheetState extends State<_TemplateSheet> {
  late final TextEditingController _name;
  late final TextEditingController _title;
  late final TextEditingController _content;
  String _category = 'system';
  bool _saving = false;

  bool get _isEdit => widget.template != null;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _name = TextEditingController(text: t?.name ?? '');
    _title = TextEditingController(text: t?.titleTemplate ?? '');
    _content = TextEditingController(text: t?.contentTemplate ?? '');
    _category = t?.category ?? 'system';
  }

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入模板名称')));
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'name': _name.text.trim(),
        'titleTemplate': _title.text.trim(),
        'contentTemplate': _content.text.trim(),
        'category': _category,
      };
      if (_isEdit) {
        await AdminApi.updateTemplate(widget.template!.id, data);
      } else {
        await AdminApi.createTemplate(data);
      }
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AdminApi.messageOf(e))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit ? '编辑模板' : '新建模板',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _field(_name, '模板名称', hint: '如：预约成功通知'),
              const SizedBox(height: 12),
              Text(
                '分类',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isDense: true,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('系统通知')),
                  DropdownMenuItem(value: 'booking', child: Text('预约相关')),
                  DropdownMenuItem(value: 'community', child: Text('社区互动')),
                  DropdownMenuItem(value: 'activity', child: Text('活动通知')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'system'),
              ),
              const SizedBox(height: 12),
              _field(_title, '标题模板', hint: '支持变量：{nickname} {store}'),
              const SizedBox(height: 12),
              Text(
                '正文模板',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _content,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '支持变量：{nickname} {store} {time}',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? '保存中…' : (_isEdit ? '保存' : '创建')),
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

  Widget _field(TextEditingController c, String label, {String? hint}) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
