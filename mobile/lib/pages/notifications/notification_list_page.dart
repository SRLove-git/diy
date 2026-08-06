import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/notification_api.dart';
import '../../widgets/state_widgets.dart';

/// 我的通知列表页
///
/// 展示平台推送的通知（全体/角色/定向），支持单条已读与全部已读，
/// 退出后首页会刷新未读角标。
class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final List<AppNotification> _items = [];
  int _page = 1;
  int _unread = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
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
      _page = 1;
      _hasMore = true;
    });
    try {
      final result = await NotificationApi.fetchMine(page: 1);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _unread = result.unread;
        _hasMore = result.items.length >= 20 && _items.length < result.total;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败，请重试';
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await NotificationApi.fetchMine(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _page += 1;
        _unread = result.unread;
        _hasMore = _items.length < result.total;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// 打开通知详情并标记已读
  Future<void> _open(AppNotification item) async {
    if (!item.read) {
      _markRead(item.id);
      setState(() {
        final i = _items.indexWhere((n) => n.id == item.id);
        if (i >= 0) {
          _items[i] = AppNotification(
            id: item.id,
            title: item.title,
            content: item.content,
            createdAt: item.createdAt,
            read: true,
          );
        }
        _unread = (_unread - 1).clamp(0, 1 << 31);
      });
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final colors = AppColors.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatTime(item.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, thickness: 1, color: colors.divider),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: SingleChildScrollView(
                    child: Text(
                      item.content,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markRead(int id) async {
    try {
      await NotificationApi.markRead(id);
    } catch (_) {
      // 已读失败不阻塞浏览，下次进入再重试
    }
  }

  Future<void> _markAllRead() async {
    if (_unread <= 0) return;
    try {
      await NotificationApi.markAllRead();
      if (!mounted) return;
      setState(() {
        _unread = 0;
        for (var i = 0; i < _items.length; i++) {
          final n = _items[i];
          _items[i] = AppNotification(
            id: n.id,
            title: n.title,
            content: n.content,
            createdAt: n.createdAt,
            read: true,
          );
        }
      });
      _toast('已全部标记为已读');
    } catch (_) {
      _toast('操作失败，请稍后再试');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的通知'),
        actions: [
          TextButton(
            onPressed: _unread > 0 ? _markAllRead : null,
            child: const Text('全部已读'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_loading) return const LoadingWidget(message: '加载通知…');
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    if (_items.isEmpty) {
      return const EmptyWidget(
        icon: Icons.notifications_none_rounded,
        message: '暂无通知',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 300) {
            _loadMore();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _items.length + 1,
          separatorBuilder: (_, i) => i == _items.length
              ? const SizedBox.shrink()
              : const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == _items.length) {
              if (_loadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                );
              }
              if (!_hasMore) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '没有更多了',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox(height: 16);
            }
            return _NotificationCard(
              item: _items[index],
              onTap: () => _open(_items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  /// 内容较短时与标题同行展示，避免出现孤立的单字内容行。
  bool get _inlineContent {
    final title = item.title.trim();
    final content = item.content.trim();
    return title.isNotEmpty &&
        content.isNotEmpty &&
        title.length <= 14 &&
        content.length <= 12 &&
        !content.contains('\n');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: item.read
          ? Colors.transparent
          : colors.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.textPrimary),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!item.read) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTitleRow(colors)),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(item.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (!_inlineContent) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: item.read
                              ? colors.textSecondary
                              : colors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(AppColors colors) {
    if (!_inlineContent) {
      return Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          fontWeight: item.read ? FontWeight.w600 : FontWeight.w800,
          color: colors.textPrimary,
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: item.read ? FontWeight.w600 : FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          flex: 2,
          child: Text(
            '：${item.content.trim()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w400,
              color: item.read
                  ? colors.textSecondary
                  : colors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatTime(DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);
  String two(int v) => v.toString().padLeft(2, '0');
  final hm = '${two(time.hour)}:${two(time.minute)}';
  if (day == today) return '今天 $hm';
  if (day == today.subtract(const Duration(days: 1))) return '昨天 $hm';
  return '${time.year}-${two(time.month)}-${two(time.day)} $hm';
}
