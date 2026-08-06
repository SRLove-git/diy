import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../core/post_api.dart';
import '../../widgets/state_widgets.dart';
import '../community/post_detail_page.dart';

/// 作品列表排序模式
enum WorksListMode {
  /// 新品推荐：按最新发布
  latest,

  /// 热门排行：按点赞数
  hot,
}

/// 作品列表页（新品推荐 / 热门排行共用）
///
/// 数据来自社区作品接口，点击进入作品详情。
class WorksListPage extends StatefulWidget {
  const WorksListPage({super.key, required this.mode});

  final WorksListMode mode;

  @override
  State<WorksListPage> createState() => _WorksListPageState();
}

class _WorksListPageState extends State<WorksListPage> {
  final List<Post> _posts = [];
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  String get _title => widget.mode == WorksListMode.latest ? '新品推荐' : '热门排行';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<({List<Post> items, int total})> _fetch(int page) =>
      widget.mode == WorksListMode.latest
          ? PostApi.fetchLatest(page: page)
          : PostApi.fetchHot(page: page);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
    });
    try {
      final result = await _fetch(1);
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(result.items);
        _hasMore = result.items.length >= 20 && result.items.length < result.total;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败，请下拉重试';
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _fetch(_page + 1);
      if (!mounted) return;
      setState(() {
        _posts.addAll(result.items);
        _page += 1;
        _hasMore = _posts.length < result.total;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 300) {
      _loadMore();
    }
    return false;
  }

  void _openDetail(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_loading) return const LoadingWidget(message: '加载中…');
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    if (_posts.isEmpty) {
      return const EmptyWidget(
        icon: Icons.brush_outlined,
        message: '还没有作品，去看看社区吧',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _posts.length + 1,
          separatorBuilder: (_, i) => i == _posts.length
              ? const SizedBox.shrink()
              : const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == _posts.length) {
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
              return const SizedBox(height: 12);
            }
            return _WorkListCard(
              post: _posts[index],
              onTap: () => _openDetail(_posts[index]),
            );
          },
        ),
      ),
    );
  }
}

class _WorkListCard extends StatelessWidget {
  const _WorkListCard({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  String get _cover {
    final mediaList = post.medias.isNotEmpty
        ? post.medias
        : post.images
            .map(
              (url) => PostMedia(type: 'image', url: url, aspectRatio: 4 / 5),
            )
            .toList();
    if (mediaList.isEmpty) return '';
    return ChatApi.resolveUrl(mediaList.first.url);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cover = _cover;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.textPrimary),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: cover.isEmpty
                    ? Container(
                        width: 92,
                        height: 92,
                        color: colors.placeholder,
                        child: Icon(
                          Icons.image_outlined,
                          color: colors.textSecondary,
                        ),
                      )
                    : Image.network(
                        cover,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 92,
                          height: 92,
                          color: colors.placeholder,
                          child: Icon(
                            Icons.image_outlined,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 92,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.content.isEmpty ? post.title : post.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        post.author?.nickname ?? '用户 #${post.userId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _CountChip(
                            icon: Icons.workspace_premium_outlined,
                            count: post.collectCount,
                          ),
                          const SizedBox(width: 12),
                          _CountChip(
                            icon: Icons.favorite_border_rounded,
                            count: post.likeCount,
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(post.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.textSecondary),
        const SizedBox(width: 3),
        Text(
          _formatCount(count),
          style: TextStyle(fontSize: 11, color: colors.textSecondary),
        ),
      ],
    );
  }
}

String _formatCount(int count) {
  if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}w';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return '$count';
}

String _formatDate(String raw) {
  final time = DateTime.tryParse(raw);
  if (time == null) return '';
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
  if (diff.inDays < 1) return '${diff.inHours} 小时前';
  if (diff.inDays < 30) return '${diff.inDays} 天前';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)}';
}
