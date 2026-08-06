import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 社区管理：作品列表 + 状态筛选 + 通过/驳回/下架（对齐网页管理端）
class AdminPostsPage extends StatefulWidget {
  const AdminPostsPage({super.key});

  @override
  State<AdminPostsPage> createState() => _AdminPostsPageState();
}

class _AdminPostsPageState extends State<AdminPostsPage> {
  List<AdminPost> _posts = [];
  bool _loading = true;
  String? _error;
  String _status = '';

  static const _tabs = [
    (value: '', label: '全部'),
    (value: 'pending', label: '待审核'),
    (value: 'approved', label: '已通过'),
    (value: 'rejected', label: '已驳回'),
  ];

  static const _statusLabels = {
    'pending': '待审核',
    'approved': '已通过',
    'rejected': '已驳回',
  };

  static const _statusColors = {
    'pending': Palette.warning,
    'approved': Palette.success,
    'rejected': Palette.danger,
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
      final paged = await AdminApi.fetchPosts(status: _status);
      if (mounted) setState(() => _posts = paged.items);
    } on DioException catch (e) {
      if (mounted) setState(() => _error = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _switchStatus(String v) {
    if (_status == v) return;
    setState(() => _status = v);
    _load();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _approve(AdminPost p) async {
    try {
      await AdminApi.updatePostStatus(p.id, 'approved');
      if (mounted) {
        _toast('已通过');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _openReject(AdminPost p) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('驳回作品'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: '请输入驳回原因（选填）',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.of(ctx).danger),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('确认驳回'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    try {
      await AdminApi.updatePostStatus(p.id, 'rejected', rejectReason: reason);
      if (mounted) {
        _toast('已驳回');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _remove(AdminPost p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('下架作品'),
        content: const Text('确认下架该作品？下架后社区中将不再展示。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.of(ctx).danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('下架'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.removePost(p.id);
      if (mounted) {
        _toast('已下架');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _deletePost(AdminPost p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除作品'),
        content: const Text('确认永久删除该作品？删除后不可恢复，其点赞、评论与收藏记录将一并清除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.of(ctx).danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.deletePost(p.id);
      if (mounted) {
        _toast('已删除');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区管理'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _PostFilterChip(
                label: _tabs[i].label,
                active: _status == _tabs[i].value,
                onTap: () => _switchStatus(_tabs[i].value),
              ),
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
    if (_posts.isEmpty) {
      return const EmptyWidget(icon: Icons.article_outlined, message: '暂无作品数据');
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _buildPostCard(_posts[i], colors),
      ),
    );
  }

  Widget _buildPostCard(AdminPost p, AppColors colors) {
    final statusColor = _statusColors[p.status] ?? colors.textSecondary;
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
                '作品 #${p.id}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '用户 ${p.userId}',
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
                  _statusLabels[p.status] ?? p.status,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (p.content.isNotEmpty) ...[
            Text(p.content, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
          ],
          // 标签 + 图片数
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final t in p.tags.take(5))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.placeholder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('#$t', style: const TextStyle(fontSize: 11, color: Palette.primary)),
                ),
              if (p.images.isNotEmpty)
                Text(
                  '${p.images.length} 张图片',
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _stat(Icons.favorite_outline, '${p.likeCount}', colors),
              const SizedBox(width: 16),
              _stat(Icons.star_border, '${p.collectCount}', colors),
              const SizedBox(width: 16),
              _stat(Icons.chat_bubble_outline, '${p.commentCount}', colors),
              const Spacer(),
              Text(
                _fmtTime(p.createdAt),
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
          if (p.rejectReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '驳回原因：${p.rejectReason}',
              style: const TextStyle(fontSize: 12, color: Palette.danger),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // 操作
          if (p.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _approve(p),
                    style: FilledButton.styleFrom(
                      backgroundColor: Palette.success,
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('通过'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _openReject(p),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.danger,
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('驳回'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deletePost(p),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.danger,
                      side: BorderSide(color: colors.danger),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('删除'),
                  ),
                ),
              ],
            )
          else if (p.status == 'approved')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _remove(p),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.danger,
                      side: BorderSide(color: colors.danger),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('下架'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deletePost(p),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.danger,
                      side: BorderSide(color: colors.danger),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('删除'),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _deletePost(p),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.danger,
                  side: BorderSide(color: colors.danger),
                  minimumSize: const Size(0, 38),
                ),
                child: const Text('删除'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, AppColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: colors.textSecondary),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ],
    );
  }

  String _fmtTime(String t) {
    final d = DateTime.tryParse(t);
    if (d == null) return t;
    String p(int n) => n.toString().padLeft(2, '0');
    return '${d.month}-${p(d.day)} ${p(d.hour)}:${p(d.minute)}';
  }
}

class _PostFilterChip extends StatelessWidget {
  const _PostFilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? colors.textPrimary : colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: active ? colors.surface : colors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
