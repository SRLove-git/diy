import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/post_api.dart';
import '../../../../pages/community/author_profile_page.dart';
import '../../../../pages/community/post_detail_page.dart';
import 'discover_page.dart';

/// 社区搜索页：按关键词搜索作品（标题 / 文案 / 频道 / 标签）
class DiscoverSearchPage extends StatefulWidget {
  const DiscoverSearchPage({super.key});

  @override
  State<DiscoverSearchPage> createState() => _DiscoverSearchPageState();
}

class _DiscoverSearchPageState extends State<DiscoverSearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  final List<DiscoverPost> _posts = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(text.trim());
    });
  }

  Future<void> _search(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _posts.clear();
        _searched = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
    });
    try {
      final result = await PostApi.fetchLatest(page: 1, q: keyword);
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(result.items.map(DiscoverPost.fromPost));
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '搜索失败，请稍后再试';
      });
    }
  }

  void _openDetail(DiscoverPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id)),
    );
  }

  void _openAuthor(DiscoverPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AuthorProfilePage(userId: post.userId)),
    );
  }

  Future<void> _toggleLike(DiscoverPost post) async {
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i < 0) return;
    final liked = !post.liked;
    setState(() {
      _posts[i] = post.copyWith(
        liked: liked,
        likes: (post.likes + (liked ? 1 : -1)).clamp(0, 1 << 31),
      );
    });
    try {
      await PostApi.toggleLike(post.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _posts[i] = post);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 38,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: Color(0xFF8E8E8E), size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: _onChanged,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (text) {
                    _debounce?.cancel();
                    _search(text.trim());
                  },
                  decoration: const InputDecoration(
                    hintText: '搜索作品 / 频道 / 标签',
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF8E8E8E)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    _onChanged('');
                  },
                  child: const Icon(Icons.cancel_rounded,
                      color: Color(0xFFC0C0C8), size: 18),
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 44, color: DiscoverColors.usernameColor),
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(
                    color: DiscoverColors.usernameColor, fontSize: 14)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _search(_controller.text.trim()),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (!_searched) {
      return const Center(
        child: Text(
          '输入关键词搜索社区作品',
          style: TextStyle(color: DiscoverColors.usernameColor, fontSize: 14),
        ),
      );
    }
    if (_posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 44, color: DiscoverColors.usernameColor),
            SizedBox(height: 10),
            Text(
              '没有找到相关作品',
              style:
                  TextStyle(color: DiscoverColors.usernameColor, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return PostGrid(
      posts: _posts,
      onTapPost: _openDetail,
      onLikePost: _toggleLike,
      onTapAuthor: _openAuthor,
    );
  }
}
