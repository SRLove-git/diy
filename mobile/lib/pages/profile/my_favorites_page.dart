import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/post_api.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/state_widgets.dart';
import '../community/post_detail_page.dart';

/// 我的收藏列表
class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  final _favoritePosts = <Post>[];
  final _likedPosts = <Post>[];
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
      final results = await Future.wait([
        PostApi.fetchLikedPosts(),
        PostApi.fetchFavorites(),
      ]);
      if (mounted) {
        setState(() {
          _likedPosts
            ..clear()
            ..addAll(results[0].items);
          _favoritePosts
            ..clear()
            ..addAll(results[1].items);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '加载失败，请下拉重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('MM-dd HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('点赞与收藏'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '我赞过的'),
              Tab(text: '我收藏的'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AppErrorWidget(message: _error!, onRetry: _load),
          ),
        ],
      );
    }

    return TabBarView(
      children: [
        _buildList(
          _likedPosts,
          icon: Icons.favorite_border,
          emptyMessage: '还没有点赞作品',
        ),
        _buildList(
          _favoritePosts,
          icon: Icons.bookmark_border,
          emptyMessage: '还没有收藏作品',
        ),
      ],
    );
  }

  Widget _buildList(
    List<Post> posts, {
    required IconData icon,
    required String emptyMessage,
  }) {
    if (posts.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyWidget(icon: icon, message: emptyMessage),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PostCard(
        post: posts[i],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailPage(postId: posts[i].id),
            ),
          );
        },
        formatTime: _formatTime,
      ),
    );
  }
}

/// 作品卡片
class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onTap,
    required this.formatTime,
  });

  final Post post;
  final VoidCallback onTap;
  final String Function(String) formatTime;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      color: colors.surface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.images.isNotEmpty)
              Hero(
                tag: 'post-img-${post.id}-0',
                child: GestureDetector(
                  onTap: () => showImageViewer(
                    context,
                    image: networkViewerImage(post.images.first),
                    heroTag: 'post-img-${post.id}-0',
                    precache: NetworkImage(post.images.first),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(post.images.first, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: post.tags
                          .map((t) => Text(
                                '#$t',
                                style: TextStyle(fontSize: 11, color: colors.textSecondary),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(post.createdAt),
                          style: TextStyle(fontSize: 11, color: colors.textSecondary)),
                      Row(
                        children: [
                          _CountChip(const Icon(Icons.favorite_border, size: 14), '${post.likeCount}'),
                          const SizedBox(width: 12),
                          _CountChip(const Icon(Icons.chat_bubble_outline, size: 14), '${post.commentCount}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip(this.icon, this.text);
  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 2),
        Text(text, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
      ],
    );
  }
}
