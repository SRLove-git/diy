import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/post_api.dart';
import 'community/create_post_page.dart';
import 'community/post_detail_page.dart';

/// 社区信息流：最新/热门切换
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _posts = <Post>[];
  bool _loading = true;
  String? _error;
  bool _isHot = false; // false=最新，true=热门

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
      final result = _isHot
          ? await PostApi.fetchHot()
          : await PostApi.fetchLatest();
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

  void _toggleSort() {
    setState(() {
      _isHot = !_isHot;
      _loading = true;
    });
    _load();
  }

  Future<void> _openCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostPage()),
    );
    if (result == true) _load(); // 发布成功后刷新列表
  }

  void _openDetail(int postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailPage(postId: postId)),
    );
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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('社区'),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _SortTab(label: '最新', active: !_isHot, onTap: _isHot ? _toggleSort : null),
                  _SortTab(label: '热门', active: _isHot, onTap: _isHot ? null : _toggleSort),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE8633A)),
            onPressed: _openCreate,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Color(0xFF8A8A8A)),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Color(0xFF8A8A8A))),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_posts.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.brush_outlined, size: 64, color: Color(0xFF8A8A8A)),
                  SizedBox(height: 12),
                  Text('还没有作品，来发布第一个吧', style: TextStyle(color: Color(0xFF8A8A8A))),
                ],
              ),
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
        onTap: () => _openDetail(_posts[i].id),
        formatTime: _formatTime,
      ),
    );
  }
}

/// 最新/热门 切换标签
class _SortTab extends StatelessWidget {
  const _SortTab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: active
            ? BoxDecoration(
                color: const Color(0xFFE8633A),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? Colors.white : const Color(0xFF8A8A8A),
          ),
        ),
      ),
    );
  }
}

/// 作品卡片
class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onTap, required this.formatTime});

  final Post post;
  final VoidCallback onTap;
  final String Function(String) formatTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片（显示第一张或暂无图片占位）
            if (post.images.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(post.images.first, fit: BoxFit.cover, width: double.infinity),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 文案（最多 3 行）
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
                                style: const TextStyle(fontSize: 11, color: Color(0xFFE8633A)),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // 底部：时间 + 互动计数
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(post.createdAt),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A))),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 2),
        Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A))),
      ],
    );
  }
}
