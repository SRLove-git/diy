import 'package:flutter/material.dart';

import '../../core/chat_api.dart';
import '../../core/post_api.dart';
import '../../features/community/domain/community_models.dart';

/// 作品详情页：大图 + 文案 + 评论区 + 底部互动栏
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Post? _post;
  List<Comment> _comments = [];
  bool _loading = true;
  bool _liked = false;
  int _likeCount = 0;
  final _commentCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final post = await PostApi.fetchDetail(widget.postId);
      final comments = await PostApi.fetchComments(widget.postId);
      if (!mounted) return;
      setState(() {
        _post = post;
        _comments = comments.items;
        _liked = false;
        _likeCount = post.likeCount;
        _loading = false;
      });
      _syncLike(post);
    } on Exception {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _syncLike(Post post) async {
    try {
      final liked = await PostApi.isLiked(post.id);
      if (mounted) setState(() => _liked = liked);
    } on Exception {
      // 状态同步失败不阻塞页面
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    try {
      await PostApi.toggleLike(_post!.id);
    } on Exception {
      if (mounted) {
        setState(() {
          _liked = !_liked;
          _likeCount += _liked ? 1 : -1;
        });
      }
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _post == null || _sending) return;
    setState(() => _sending = true);
    try {
      final c = await PostApi.addComment(_post!.id, text);
      if (!mounted) return;
      setState(() => _comments = [..._comments, c]);
      _commentCtrl.clear();
      FocusScope.of(context).unfocus();
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('评论失败，请稍后再试')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111111),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '作品详情',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : post == null
              ? _LoadFailed(onRetry: _load)
              : _buildBody(post),
      bottomNavigationBar: post == null
          ? null
          : _buildCommentBar(),
    );
  }

  Widget _buildBody(Post post) {
    final images = <String>[
      for (final m in post.medias)
        if (m.type == 'image') ChatApi.resolveUrl(m.url),
      for (final i in post.images)
        if (i.isNotEmpty) ChatApi.resolveUrl(i),
    ];
    final author = post.author;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (images.isNotEmpty)
          SizedBox(
            height: 360,
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, i) => Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFEFEFEF),
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 34,
                    color: Color(0xFFED4956),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    author?.nickname ?? '用户${post.userId}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeAgo(post.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA8A8A8),
                    ),
                  ),
                ],
              ),
              if (post.content.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final t in post.tags)
                      Text(
                        '#$t',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFED4956),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Text(
                '评论 ${_comments.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              if (_comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      '还没有评论，来说两句吧',
                      style: TextStyle(color: Color(0xFFA8A8A8)),
                    ),
                  ),
                )
              else
                for (final c in _comments) _CommentTile(comment: c),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _toggleLike,
              icon: Icon(
                _liked ? Icons.favorite : Icons.favorite_border,
                color: _liked
                    ? const Color(0xFFED4956)
                    : const Color(0xFF737373),
              ),
            ),
            Text(
              formatCount(_likeCount),
              style: const TextStyle(fontSize: 12, color: Color(0xFF737373)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _commentCtrl,
                decoration: InputDecoration(
                  hintText: '说点什么…',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFFA8A8A8)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendComment(),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _sending ? null : _sendComment,
              child: const Text(
                '发送',
                style: TextStyle(
                  color: Color(0xFFED4956),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final nickname = comment.author?.nickname ?? '用户${comment.userId}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 32, color: Color(0xFFED4956)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo(comment.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA8A8A8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                comment.liked ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: comment.liked
                    ? const Color(0xFFED4956)
                    : const Color(0xFFA8A8A8),
              ),
              if (comment.likeCount > 0)
                Text(
                  '${comment.likeCount}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFA8A8A8)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('加载失败', style: TextStyle(color: Color(0xFFA8A8A8))),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
