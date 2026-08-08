import 'package:flutter/material.dart' hide Page;

import '../../api/api_client.dart';
import '../../api/content_services.dart';
import '../../api/models.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';
import 'post_screens.dart';
import 'profile_screens.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key, this.root = false});

  final bool root;

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  String _tab = 'latest'; // following / latest / hot
  late Future<Page<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Page<Post>> _load() {
    return switch (_tab) {
      'following' => CommunityService.instance.following(),
      'hot' => CommunityService.instance.hot(),
      _ => CommunityService.instance.latest(),
    };
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return LivePage(
      bottomBar: const LiveTabBar(current: 1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 12, 4),
            child: Row(
              children: [
                const SizedBox(width: 44),
                const Expanded(
                  child: Text(
                    '社区',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: LiveColors.textPrimary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: LiveColors.textPrimary),
                  onPressed: () => LiveRoutes.push(context, const SearchScreen()),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: LiveColors.textPrimary),
                  onPressed: () => LiveRoutes.push(context, const PostPublishScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _SegmentedTabs(
            current: _tab,
            onChanged: (t) {
              if (_tab != t) {
                setState(() {
                  _tab = t;
                  _future = _load();
                });
              }
            },
          ),
          const SizedBox(height: 6),
          Expanded(
            child: FutureBuilder<Page<Post>>(
              future: _future,
              builder: (context, snap) {
                if (snap.hasError) {
                  return ErrorView(message: _msg(snap.error), onRetry: _retry);
                }
                if (!snap.hasData) return const LoadingView();
                final posts = snap.data!.items;
                if (posts.isEmpty) {
                  return const EmptyView(
                    text: '暂无内容，关注更多作者或发布第一件作品吧',
                    icon: Icons.article_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _retry(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => PostCard(
                      post: posts[i],
                      onTap: () => LiveRoutes.push(
                        context,
                        PostDetailScreen(postId: posts[i].id),
                      ),
                      onAuthorTap: () => LiveRoutes.push(
                        context,
                        UserProfileScreen(userId: posts[i].userId),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 社区页顶部胶囊分段器（对齐 Pixso：灰底圆角容器 + 选中白色胶囊带阴影）。
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.current, required this.onChanged});

  final String current;
  final ValueChanged<String> onChanged;

  static const _tabs = [
    ('following', '关注'),
    ('latest', '最新'),
    ('hot', '热门'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: LiveColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            for (final t in _tabs)
              Expanded(
                child: _SegmentedTab(
                  label: t.$2,
                  selected: current == t.$1,
                  onTap: () => onChanged(t.$1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTab extends StatelessWidget {
  const _SegmentedTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.6,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? LiveColors.textPrimary : LiveColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onAuthorTap,
  });

  final Post post;
  final VoidCallback onTap;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final urls = post.mediaUrls;
    final author = post.author;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LiveColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LiveColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onAuthorTap,
              child: Row(
                children: [
                  Avatar(url: author?.avatar ?? '', name: author?.nickname ?? ''),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author?.displayName ?? '用户',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
                        ),
                        Text(
                          fmtTime(post.createdAt),
                          style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  if (post.channelTag.isNotEmpty)
                    TagChip(label: post.channelTag, color: LiveColors.brand),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (post.title.isNotEmpty)
              Text(
                post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
              ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: LiveColors.textPrimary, height: 1.45),
              ),
            ],
            if (urls.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: urls.length == 1 ? 190 : 120,
                child: urls.length == 1
                    ? NetImage(url: urls.first, radius: 12)
                    : GridView.count(
                        crossAxisCount: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        children: urls.take(9).map((u) => NetImage(url: u, radius: 6)).toList(),
                      ),
              ),
            ],
            const SizedBox(height: 10),
            if (post.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: post.tags
                    .map((t) => Text(t.startsWith('#') ? t : '#$t',
                        style: const TextStyle(fontSize: 12, color: LiveColors.brand)))
                    .toList(),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ActionIcon(Icons.favorite_border, '${fmtCount(post.likeCount)}'),
                const SizedBox(width: 16),
                _ActionIcon(Icons.chat_bubble_outline, '${fmtCount(post.commentCount)}'),
                const SizedBox(width: 16),
                _ActionIcon(Icons.star_border, '${fmtCount(post.collectCount)}'),
                const Spacer(),
                Text('浏览 ${fmtCount(post.viewCount)}',
                    style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: LiveColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary)),
      ],
    );
  }
}

String _msg(Object? e) =>
    e is ApiException ? e.message : '加载失败，请确认后端服务已启动';
