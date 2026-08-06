import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../widgets/state_widgets.dart';

/// Reels 管理：短视频/照片作品列表 + 状态筛选 + 审核/下架/删除（对齐网页管理端视频管理）
class AdminReelsPage extends StatefulWidget {
  const AdminReelsPage({super.key});

  @override
  State<AdminReelsPage> createState() => _AdminReelsPageState();
}

class _AdminReelsPageState extends State<AdminReelsPage> {
  List<AdminVideo> _videos = [];
  bool _loading = true;
  String? _error;
  String _status = '';
  int _page = 1;
  int _total = 0;

  static const _pageSize = 20;

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
      final paged = await AdminApi.fetchVideos(status: _status, page: _page);
      if (mounted) {
        setState(() {
          _videos = paged.items;
          _total = paged.total;
        });
      }
    } on DioException catch (e) {
      if (mounted) setState(() => _error = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _switchStatus(String v) {
    if (_status == v) return;
    setState(() {
      _status = v;
      _page = 1;
    });
    _load();
  }

  int get _totalPages => (_total / _pageSize).ceil().clamp(1, 1 << 31);

  void _goPage(int p) {
    if (p < 1 || p > _totalPages) return;
    setState(() => _page = p);
    _load();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _approve(AdminVideo v) async {
    try {
      await AdminApi.updateVideoStatus(v.id, 'approved');
      if (mounted) {
        _toast('已通过');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _openReject(AdminVideo v) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('驳回视频'),
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
      await AdminApi.updateVideoStatus(v.id, 'rejected', rejectReason: reason);
      if (mounted) {
        _toast('已驳回');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _remove(AdminVideo v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('下架作品'),
        content: const Text('确认下架该作品？下架后信息流和主页中将不再展示。'),
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
      await AdminApi.removeVideo(v.id);
      if (mounted) {
        _toast('已下架');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _hardDelete(AdminVideo v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除作品'),
        content: const Text('确认永久删除该作品？删除后不可恢复，其点赞与评论记录将一并清除。'),
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
      await AdminApi.hardDeleteVideo(v.id);
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
        title: const Text('Reels 管理'),
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
              itemBuilder: (context, i) => _FilterChip(
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
    if (_videos.isEmpty) {
      return const EmptyWidget(
        icon: Icons.play_circle_outline,
        message: '暂无视频数据',
      );
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final v in _videos) ...[
            _buildVideoCard(v, colors),
            const SizedBox(height: 12),
          ],
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
                  '$_page / $_totalPages（共 $_total 条）',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
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
      ),
    );
  }

  Widget _buildVideoCard(AdminVideo v, AppColors colors) {
    final statusColor = _statusColors[v.status] ?? colors.textSecondary;
    final coverUrl = v.cover.isEmpty ? '' : ChatApi.resolveUrl(v.cover);
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
                '作品 #${v.id}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '用户 ${v.userId}',
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
                  _statusLabels[v.status] ?? v.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coverUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    coverUrl,
                    width: 72,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 72,
                      height: 96,
                      color: colors.placeholder,
                      child: Icon(
                        v.isPhotoWork
                            ? Icons.photo_outlined
                            : Icons.play_circle_outline,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (v.title.isNotEmpty) ...[
                      Text(
                        v.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (v.content.isNotEmpty)
                      Text(
                        v.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      v.isPhotoWork
                          ? '照片 ${v.photos.length} 张'
                          : '视频',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (v.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final t in v.tags.take(5))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.placeholder,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$t',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Palette.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _stat(Icons.favorite_outline, '${v.likeCount}', colors),
              const SizedBox(width: 16),
              _stat(Icons.chat_bubble_outline, '${v.commentCount}', colors),
              const SizedBox(width: 16),
              _stat(Icons.reply_outlined, '${v.shareCount}', colors),
              const SizedBox(width: 16),
              _stat(Icons.visibility_outlined, '${v.viewCount}', colors),
              const Spacer(),
              Text(
                _fmtTime(v.createdAt),
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
          if (v.rejectReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '驳回原因：${v.rejectReason}',
              style: const TextStyle(fontSize: 12, color: Palette.danger),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          if (v.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _approve(v),
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
                    onPressed: () => _openReject(v),
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
                    onPressed: () => _hardDelete(v),
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
          else if (v.status == 'approved')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _remove(v),
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
                    onPressed: () => _hardDelete(v),
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
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _approve(v),
                    style: FilledButton.styleFrom(
                      backgroundColor: Palette.success,
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('上架'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _hardDelete(v),
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
    return '${d.year}-${p(d.month)}-${p(d.day)} ${p(d.hour)}:${p(d.minute)}';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
