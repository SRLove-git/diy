import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../core/post_api.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/state_widgets.dart';
import '../community/post_detail_page.dart';

/// 我的作品列表
class MyWorksPage extends StatefulWidget {
  const MyWorksPage({super.key});

  @override
  State<MyWorksPage> createState() => _MyWorksPageState();
}

class _MyWorksPageState extends State<MyWorksPage> {
  final _posts = <Post>[];
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
      final result = await PostApi.fetchMine();
      if (mounted) {
        setState(() {
          _posts.clear();
          _posts.addAll(result.items);
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
    return Scaffold(
      appBar: AppBar(title: const Text('个人作品')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
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

    if (_posts.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const EmptyWidget(
              icon: Icons.photo_library_outlined,
              message: '还没有发布作品',
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _posts.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PostCard(
        post: _posts[i],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailPage(postId: _posts[i].id),
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
    final cover = _coverOf(post);
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
            if (cover.isNotEmpty)
              Hero(
                tag: 'post-img-${post.id}-0',
                child: GestureDetector(
                  onTap: () => showImageViewer(
                    context,
                    image: networkViewerImage(cover),
                    heroTag: 'post-img-${post.id}-0',
                    precache: NetworkImage(cover),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      cover,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => Container(
                        color: colors.placeholder,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
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

  /// 封面图：优先 medias 首项，其次 images 首项，兼容 /uploads/ 相对路径
  String _coverOf(Post post) {
    final mediaList = post.medias.isNotEmpty
        ? post.medias
        : post.images
            .map(
              (url) => PostMedia(type: 'image', url: url, aspectRatio: 4 / 5),
            )
            .toList();
    if (mediaList.isEmpty) return '';
    final raw = mediaList.first.url;
    return raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : ChatApi.resolveUrl(raw);
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
