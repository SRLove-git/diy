import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/post_api.dart';
import 'author_profile_page.dart';

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

  bool _liked = false;
  bool _collected = false;
  List<Comment> _comments = [];
  bool _commentLoading = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    // 记录浏览历史，fire and forget
    PostApi.addHistory(widget.postId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final post = await PostApi.fetchDetail(widget.postId);
      if (!mounted) return;
      setState(() => _post = post);

      // 加载点赞和收藏状态
      _loadStatuses();
      // 加载评论
      _loadComments();
    } catch (e) {
      if (mounted) setState(() => _error = '加载失败');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadStatuses() async {
    try {
      final results = await Future.wait([
        PostApi.isLiked(widget.postId),
        PostApi.isCollected(widget.postId),
      ]);
      if (mounted) {
        setState(() {
          _liked = results[0];
          _collected = results[1];
        });
      }
    } catch (_) {
      // 静默失败，使用默认值
    }
  }

  Future<void> _loadComments() async {
    setState(() => _commentLoading = true);
    try {
      final result = await PostApi.fetchComments(widget.postId);
      if (mounted) {
        setState(() => _comments = result.items);
      }
    } catch (_) {
      // 静默失败
    } finally {
      if (mounted) setState(() => _commentLoading = false);
    }
  }

  Future<void> _toggleLike() async {
    try {
      final liked = await PostApi.toggleLike(widget.postId);
      if (mounted) {
        setState(() {
          _liked = liked;
          _post = Post(
            id: _post!.id,
            userId: _post!.userId,
            content: _post!.content,
            images: _post!.images,
            tags: _post!.tags,
            status: _post!.status,
            likeCount: liked ? _post!.likeCount + 1 : (_post!.likeCount - 1).clamp(0, 999999),
            collectCount: _post!.collectCount,
            commentCount: _post!.commentCount,
            createdAt: _post!.createdAt,
          );
        });
      }
    } catch (_) {
      // 静默失败
    }
  }

  Future<void> _toggleCollect() async {
    try {
      final collected = await PostApi.toggleCollect(widget.postId);
      if (mounted) {
        setState(() {
          _collected = collected;
          _post = Post(
            id: _post!.id,
            userId: _post!.userId,
            content: _post!.content,
            images: _post!.images,
            tags: _post!.tags,
            status: _post!.status,
            likeCount: _post!.likeCount,
            collectCount: collected
                ? _post!.collectCount + 1
                : (_post!.collectCount - 1).clamp(0, 999999),
            commentCount: _post!.commentCount,
            createdAt: _post!.createdAt,
          );
        });
      }
    } catch (_) {
      // 静默失败
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await PostApi.addComment(widget.postId, text);
      _commentController.clear();
      if (mounted) {
        setState(() {
          _post = Post(
            id: _post!.id,
            userId: _post!.userId,
            content: _post!.content,
            images: _post!.images,
            tags: _post!.tags,
            status: _post!.status,
            likeCount: _post!.likeCount,
            collectCount: _post!.collectCount,
            commentCount: _post!.commentCount + 1,
            createdAt: _post!.createdAt,
          );
        });
        _loadComments();
      }
    } catch (_) {
      // 静默失败
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 作者信息行
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuthorProfilePage(userId: post.userId),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFE8633A),
                            child: Icon(Icons.person, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '用户 #${post.userId}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: Color(0xFF8A8A8A), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // 图片轮播
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

                  // 互动栏
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ActionChip(
                          icon: _liked ? Icons.favorite : Icons.favorite_border,
                          label: '${post.likeCount}',
                          active: _liked,
                          onTap: _toggleLike,
                        ),
                        _ActionChip(
                          icon: _collected ? Icons.bookmark : Icons.bookmark_border,
                          label: '${post.collectCount}',
                          active: _collected,
                          onTap: _toggleCollect,
                        ),
                        _ActionChip(
                          icon: Icons.chat_bubble_outline,
                          label: '${post.commentCount}',
                          active: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // 评论区
                  if (_commentLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (_comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('暂无评论', style: TextStyle(color: Color(0xFF8A8A8A))),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _comments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final c = _comments[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFFE8633A),
                              child: Icon(Icons.person, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '用户 #${c.userId}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2B2B2B),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatTime(c.createdAt),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF8A8A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.content,
                                    style: const TextStyle(fontSize: 14, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  // 底部留白给输入栏让位
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // 底部评论输入栏
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: '写下你的评论...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFE8633A)),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: active ? const Color(0xFFE8633A) : const Color(0xFF8A8A8A),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFFE8633A) : const Color(0xFF8A8A8A),
            ),
          ),
        ],
      ),
    );
  }
}
