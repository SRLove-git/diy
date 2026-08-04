import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../core/follow_api.dart';
import '../../core/post_api.dart';
import '../../widgets/follow_button.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/state_widgets.dart';
import '../chat/chat_page.dart';
import 'post_detail_page.dart';

/// 作者主页：查看他人的作品列表
class AuthorProfilePage extends StatefulWidget {
  const AuthorProfilePage({super.key, required this.userId});

  final int userId;

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage> {
  final _posts = <Post>[];
  bool _loading = true;
  String? _error;

  /// 与作者的关注关系（含粉丝/关注数）
  FollowStatus? _follow;
  bool _followBusy = false;

  bool get _isSelf => AuthService.instance.user?.id == widget.userId;

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
      // 作品与关注关系并行加载（Future.wait 统一处理两路错误）
      final results = await Future.wait<Object>([
        PostApi.fetchByUser(widget.userId),
        FollowApi.status(widget.userId),
      ]);
      final result = results[0] as ({List<Post> items, int total});
      final follow = results[1] as FollowStatus;
      if (mounted) {
        setState(() {
          _posts.clear();
          _posts.addAll(result.items);
          _follow = follow;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '加载失败，请下拉重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 关注/取消关注
  Future<void> _toggleFollow(bool following) async {
    setState(() => _followBusy = true);
    try {
      final st = await FollowApi.setFollow(widget.userId, following: following);
      if (mounted) setState(() => _follow = st);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('操作失败，请稍后再试')),
        );
      }
    } finally {
      if (mounted) setState(() => _followBusy = false);
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

  /// 发起会话并进入聊天页（不看自己的主页时显示入口）
  Future<void> _openChat() async {
    ChatService.instance.ensureConnected();
    try {
      final conv = await ChatApi.createConversation(widget.userId);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatPage(conversation: conv)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发起会话失败，请稍后再试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户 #${widget.userId}'),
        actions: [
          if (!_isSelf)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: '发消息',
              onPressed: _openChat,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  /// 作者信息行：头像 + 昵称 + 粉丝/关注 + 关注按钮
  Widget _buildHeader() {
    final colors = AppColors.of(context);
    final st = _follow;
    final avatar = st?.avatar ?? '';
    final validAvatar =
        avatar.startsWith('http://') ||
        avatar.startsWith('https://') ||
        avatar.startsWith('/uploads/');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          ClipOval(
            child: validAvatar
                ? Image.network(
                    FollowApi.resolveAvatar(avatar),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    cacheWidth: 168,
                    errorBuilder: (_, _, _) => _avatarFallback(colors),
                  )
                : _avatarFallback(colors),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (st?.nickname.isNotEmpty ?? false)
                      ? st!.nickname
                      : '用户 #${widget.userId}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${st?.followerCount ?? 0} 粉丝 · ${st?.followingCount ?? 0} 关注',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                if (st?.mutual == true) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '互相关注',
                      style: TextStyle(fontSize: 11, color: colors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!_isSelf)
            FollowButton(
              following: st?.following ?? false,
              enabled: !_followBusy,
              onChanged: _toggleFollow,
            ),
        ],
      ),
    );
  }

  Widget _avatarFallback(AppColors colors) => Container(
        width: 56,
        height: 56,
        color: colors.primary,
        child: const Icon(Icons.person, color: Colors.white, size: 30),
      );

  Widget _buildBody() {
    if (_loading) {
      return const LoadingWidget();
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: AppErrorWidget(message: _error!, onRetry: _load),
          ),
        ],
      );
    }

    if (_posts.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: const EmptyWidget(
              icon: Icons.brush_outlined,
              message: '该用户暂无作品',
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

/// 作品卡片（与社区页一致的设计）
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
