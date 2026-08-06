import 'package:flutter/material.dart';

import '../../core/chat_api.dart';
import '../../core/post_api.dart';
import '../../features/community/domain/community_models.dart';
import '../post/post_detail_page.dart';

/// 信息流作品卡片（首页/社区共用）
///
/// 展示作者行 + 图文内容 + 互动栏，点赞即时反馈（乐观更新 + [PostApi] 同步）。
class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post, this.compact = false});

  final Post post;

  /// 紧凑模式：首页信息流使用，不展示互动数字
  final bool compact;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked = false;
  late int _likeCount = widget.post.likeCount;
  bool _liking = false;

  String _resolve(String path) => path.isEmpty ? '' : ChatApi.resolveUrl(path);

  List<String> get _images {
    final list = <String>[];
    for (final m in widget.post.medias) {
      if (m.type == 'image') list.add(_resolve(m.url));
    }
    if (list.isEmpty) {
      for (final i in widget.post.images) {
        if (i.isNotEmpty) list.add(_resolve(i));
      }
    }
    return list;
  }

  String? get _videoCover {
    for (final m in widget.post.medias) {
      if (m.type == 'video') return _resolve(m.url);
    }
    return null;
  }

  Future<void> _toggleLike() async {
    if (_liking) return;
    setState(() {
      _liking = true;
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    try {
      final liked = await PostApi.toggleLike(widget.post.id);
      if (!mounted) return;
      setState(() {
        _liked = liked;
        _likeCount = widget.post.likeCount + (liked ? 1 : 0);
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _liked = !_liked;
        _likeCount += _liked ? 1 : -1;
      });
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final images = _images;
    final author = post.author;
    final nickname = author?.nickname ?? '用户${post.userId}';
    final avatar = _resolve(author?.avatar ?? '');
    final tag = post.channelTag.isNotEmpty
        ? post.channelTag
        : (post.tags.isNotEmpty ? '#${post.tags.first}' : '');

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostDetailPage(postId: post.id),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(url: avatar, nickname: nickname, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      if (tag.isNotEmpty)
                        Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFED4956),
                          ),
                        ),
                    ],
                  ),
                ),
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
              const SizedBox(height: 10),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: Color(0xFF111111),
                ),
              ),
            ],
            if (images.isNotEmpty) ...[
              const SizedBox(height: 10),
              _MediaGrid(images: images, cover: _videoCover),
            ] else if (_videoCover != null) ...[
              const SizedBox(height: 10),
              _VideoCover(cover: _videoCover!),
            ],
            if (!widget.compact) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _ActionButton(
                    icon: _liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _liked
                        ? const Color(0xFFED4956)
                        : const Color(0xFF737373),
                    label: formatCount(_likeCount),
                    onTap: _toggleLike,
                  ),
                  const SizedBox(width: 18),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: formatCount(post.commentCount),
                    onTap: () {},
                  ),
                  const SizedBox(width: 18),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: formatCount(post.shareCount),
                    onTap: () {},
                  ),
                  const Spacer(),
                  const _ActionButton(
                    icon: Icons.bookmark_border,
                    label: '',
                    onTap: null,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.nickname, required this.size});

  final String url;
  final String nickname;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = nickname.isEmpty
        ? '?'
        : String.fromCharCode(nickname.runes.first);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFEDA75),
            Color(0xFFFA7E1E),
            Color(0xFFD62976),
            Color(0xFF962FBF),
            Color(0xFF4F5BD5),
          ],
        ),
      ),
      child: url.isEmpty
          ? Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ClipOval(
              child: Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: const Color(0xFFEFEFEF),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: const Color(0xFFA8A8A8),
                        fontSize: size * 0.42,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.images, this.cover});

  final List<String> images;
  final String? cover;

  @override
  Widget build(BuildContext context) {
    final imgs = images.take(9).toList();
    final single = imgs.length == 1;
    final cross = single ? 1 : (imgs.length == 2 ? 2 : 3);
    final ratio = single ? 1.2 : 1.0;
    return GridView.count(
      crossAxisCount: cross,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: ratio,
      children: [
        for (final img in imgs)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              img,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFEFEFEF),
                child: Icon(Icons.image_not_supported_outlined,
                    color: Color(0xFFA8A8A8)),
              ),
            ),
          ),
      ],
    );
  }
}

class _VideoCover extends StatelessWidget {
  const _VideoCover({required this.cover});

  final String cover;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              cover,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFEFEFEF),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF737373),
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF737373)),
            ),
          ],
        ],
      ),
    );
  }
}
