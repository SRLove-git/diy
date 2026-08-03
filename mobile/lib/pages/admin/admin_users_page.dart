import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 用户管理：用户列表 + 手机号搜索 + 分页 + 封禁/解封（对齐网页管理端）
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<AdminUser> _users = [];
  int _total = 0;
  int _page = 1;
  bool _loading = true;
  String? _error;
  final _search = TextEditingController();

  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final paged = await AdminApi.fetchUsers(
        page: _page,
        phone: _search.text.trim().isEmpty ? null : _search.text.trim(),
      );
      if (mounted) {
        setState(() {
          _users = paged.items;
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

  void _doSearch() {
    _page = 1;
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

  Future<void> _toggleBan(AdminUser u) async {
    final banning = !u.isBanned;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(banning ? '封禁用户' : '解封用户'),
        content: Text(
          banning
              ? '确认封禁该用户？封禁后该用户将无法使用平台功能。'
              : '确认解封该用户？解封后该用户可正常使用平台。',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: banning ? AppColors.of(ctx).danger : const Color(0xFF2E9E5B),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(banning ? '确认封禁' : '确认解封'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.setBan(u.id, banning);
      if (mounted) {
        _toast(banning ? '已封禁' : '已解封');
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
      appBar: AppBar(title: const Text('用户管理')),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onSubmitted: (_) => _doSearch(),
                    decoration: InputDecoration(
                      hintText: '搜索手机号',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _doSearch,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
                  child: const Text('搜索'),
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
    if (_users.isEmpty) {
      return const EmptyWidget(icon: Icons.people_outline, message: '暂无用户数据');
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final u in _users) ...[
            _buildUserCard(u, colors),
            const SizedBox(height: 12),
          ],
          // 分页
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

  Widget _buildUserCard(AdminUser u, AppColors colors) {
    final isAdmin = u.role == 'admin';
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
                  u.nickname.isEmpty ? u.phone : u.nickname,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              _tag(isAdmin ? '管理员' : '用户', isAdmin ? const Color(0xFFE6A23C) : colors.textSecondary),
              const SizedBox(width: 6),
              _tag(u.isBanned ? '已封禁' : '正常', u.isBanned ? colors.danger : const Color(0xFF2E9E5B)),
            ],
          ),
          const SizedBox(height: 8),
          _row('ID', '${u.id}', colors),
          _row('手机号', u.phone, colors),
          _row('注册时间', _fmtTime(u.createdAt), colors),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _toggleBan(u),
              style: OutlinedButton.styleFrom(
                foregroundColor: u.isBanned ? const Color(0xFF2E9E5B) : colors.danger,
                side: BorderSide(color: u.isBanned ? const Color(0xFF2E9E5B) : colors.danger),
                minimumSize: const Size(0, 38),
              ),
              child: Text(u.isBanned ? '解封' : '封禁'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha(140)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _row(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  String _fmtTime(String t) {
    final d = DateTime.tryParse(t);
    if (d == null) return t;
    String p(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${p(d.month)}-${p(d.day)} ${p(d.hour)}:${p(d.minute)}';
  }
}
