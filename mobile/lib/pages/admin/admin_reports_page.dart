import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 举报处理：举报列表 + 状态筛选 + 处理/驳回（对齐网页管理端）
class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  List<AdminReport> _reports = [];
  int _total = 0;
  int _page = 1;
  bool _loading = true;
  String? _error;
  String _status = '';

  static const _pageSize = 20;

  static const _tabs = [
    (value: '', label: '全部'),
    (value: 'pending', label: '待处理'),
    (value: 'resolved', label: '已处理'),
    (value: 'dismissed', label: '已驳回'),
  ];

  static const _statusLabels = {
    'pending': '待处理',
    'resolved': '已处理',
    'dismissed': '已驳回',
  };

  static const _statusColors = {
    'pending': Palette.warning,
    'resolved': Palette.success,
    'dismissed': Palette.textTertiary,
  };

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
      final paged = await AdminApi.fetchReports(status: _status, page: _page);
      if (mounted) {
        setState(() {
          _reports = paged.items;
          _total = paged.total;
        });
      }
    } on DioException catch (e) {
      if (mounted) setState(() => _error = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _totalPages => (_total / _pageSize).ceil().clamp(1, 1 << 31);

  void _switchStatus(String v) {
    if (_status == v) return;
    setState(() {
      _status = v;
      _page = 1;
    });
    _load();
  }

  void _goPage(int p) {
    if (p < 1 || p > _totalPages) return;
    setState(() => _page = p);
    _load();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _operate(AdminReport r, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action == 'resolve' ? '处理举报' : '驳回举报'),
        content: Text(
          action == 'resolve' ? '确认标记为已处理？' : '确认驳回该举报？',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: action == 'resolve'
                  ? Palette.success
                  : AppColors.of(ctx).danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action == 'resolve' ? '处理' : '驳回'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      if (action == 'resolve') {
        await AdminApi.resolveReport(r.id);
      } else {
        await AdminApi.dismissReport(r.id);
      }
      if (mounted) {
        _toast(action == 'resolve' ? '已处理' : '已驳回');
        _load();
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
        title: const Text('举报处理'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          // 状态 Tab
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colors.placeholder,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                for (final t in _tabs)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchStatus(t.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _status == t.value ? colors.textPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          t.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _status == t.value ? FontWeight.w600 : FontWeight.w400,
                            color: _status == t.value ? colors.surface : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingWidget();
    if (_error != null) return AppErrorWidget(message: _error!, onRetry: _load);
    if (_reports.isEmpty) {
      return const EmptyWidget(icon: Icons.verified_outlined, message: '暂无举报数据');
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final r in _reports) ...[
            _buildReportCard(r, colors),
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

  Widget _buildReportCard(AdminReport r, AppColors colors) {
    final statusColor = _statusColors[r.status] ?? colors.textSecondary;
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
              Text(
                '举报 #${r.id}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '举报人 ${r.reporterId} → 作品 ${r.postId}',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: statusColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabels[r.status] ?? r.status,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.placeholder,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              r.reason.isEmpty ? '（无举报原因）' : r.reason,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '提交 ${_fmtTime(r.createdAt)}',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              if (r.status != 'pending')
                Text(
                  ' · 处理 ${_fmtTime(r.updatedAt)}',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
            ],
          ),
          if (r.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _operate(r, 'resolve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Palette.success,
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('处理'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _operate(r, 'dismiss'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.danger,
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('驳回'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fmtTime(String t) {
    final d = DateTime.tryParse(t);
    if (d == null) return t;
    String p(int n) => n.toString().padLeft(2, '0');
    return '${d.month}-${p(d.day)} ${p(d.hour)}:${p(d.minute)}';
  }
}
