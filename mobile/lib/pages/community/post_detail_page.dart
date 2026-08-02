import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/post_api.dart';

/// 作品详情页
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Post? _post;
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
      final post = await PostApi.fetchDetail(widget.postId);
      if (mounted) setState(() => _post = post);
    } catch (e) {
      if (mounted) setState(() => _error = '加载失败');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('作品详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('作品详情')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFF8A8A8A)),
              const SizedBox(height: 12),
              Text(_error ?? '作品不存在', style: const TextStyle(color: Color(0xFF8A8A8A))),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    final post = _post!;
    return Scaffold(
      appBar: AppBar(title: const Text('作品详情')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片轮播（简化：首图大图 + 缩略图列表）
            if (post.images.isNotEmpty)
              Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Container(
                      color: const Color(0xFFF7F5F2),
                      child: Image.network(post.images.first, fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                  if (post.images.length > 1)
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: post.images.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 6),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(post.images[i], width: 54, height: 54, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                ],
              ),

            // 文案
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.content, style: const TextStyle(fontSize: 15, height: 1.6)),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: post.tags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0x1AE8633A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#$t',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFE8633A)),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(post.createdAt),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                  ),
                ],
              ),
            ),

            const Divider(),

            // 互动栏（点赞/收藏/评论 - 一期仅展示计数，二期接入互动 API）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionChip(icon: Icons.favorite_border, label: '${post.likeCount}', onTap: () {}),
                  _ActionChip(icon: Icons.bookmark_border, label: '${post.collectCount}', onTap: () {}),
                  _ActionChip(icon: Icons.chat_bubble_outline, label: '${post.commentCount}', onTap: () {}),
                ],
              ),
            ),

            const Divider(),

            // 评论区占位
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('暂无评论', style: TextStyle(color: Color(0xFF8A8A8A))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8A8A8A)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Color(0xFF8A8A8A))),
        ],
      ),
    );
  }
}
