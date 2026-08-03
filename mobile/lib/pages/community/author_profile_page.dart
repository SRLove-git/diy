import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../core/post_api.dart';
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
      final result = await PostApi.fetchByUser(widget.userId);
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
    final isSelf = AuthService.instance.user?.id == widget.userId;
    return Scaffold(
      appBar: AppBar(
        title: Text('用户 #${widget.userId}'),
        actions: [
          if (!isSelf)
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
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(post.images.first, fit: BoxFit.cover, width: double.infinity),
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
