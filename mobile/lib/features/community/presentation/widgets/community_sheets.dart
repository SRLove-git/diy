import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/chat_api.dart';
import '../../../../core/post_api.dart';
import '../../domain/community_models.dart';
import '../community_palette.dart';
import 'community_avatar.dart';

/// 底部弹层集合：评论 / 分享 / 更多操作

/// 评论弹层：展示评论列表 + 输入框（真实接口发布评论）
Future<void> showCommentSheet(
  BuildContext context, {
  required FeedPost post,
  required List<CommunityComment> comments,
  required CommunityUser currentUser,
  VoidCallback? onCommentAdded,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _CommentSheet(
      post: post,
      comments: comments,
      currentUser: currentUser,
      onCommentAdded: onCommentAdded,
    ),
  );
}

class _CommentSheet extends StatefulWidget {
  const _CommentSheet({
    required this.post,
    required this.comments,
    required this.currentUser,
    this.onCommentAdded,
  });

  final FeedPost post;
  final List<CommunityComment> comments;
  final CommunityUser currentUser;
  final VoidCallback? onCommentAdded;

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  late final List<CommunityComment> _comments = List.of(widget.comments);
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    try {
      final comment = await PostApi.addComment(widget.post.id, text);
      if (!mounted) return;
      setState(() {
        _comments.insert(
          0,
          CommunityComment(
            user: CommunityUser(
              id: comment.userId,
              nickname: comment.author?.nickname ?? widget.currentUser.nickname,
              avatarUrl: comment.author != null
                  ? ChatApi.resolveUrl(comment.author!.avatar)
                  : widget.currentUser.avatarUrl,
            ),
            content: comment.content,
            createdAt: comment.createdAt,
          ),
        );
        _controller.clear();
      });
      widget.onCommentAdded?.call();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('评论失败，请稍后再试'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = CommunityPalette.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: palette.isDark
                  ? const Color(0xFF3A3A44)
                  : const Color(0xFFE0E0E6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Text(
                  '评论',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.isDark
                        ? const Color(0xFFE6E6EC)
                        : const Color(0xFF2B2B33),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_comments.length}',
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.isDark
                        ? const Color(0xFF9A9AA6)
                        : const Color(0xFF8A8A94),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Text(
                      '还没有评论，来抢沙发～',
                      style: TextStyle(
                        color: palette.isDark
                            ? const Color(0xFF9A9AA6)
                            : const Color(0xFF8A8A94),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: _comments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _CommentRow(comment: _comments[i]),
                  ),
          ),
          _buildInput(palette),
        ],
      ),
    );
  }

  Widget _buildInput(CommunityPalette palette) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '友善评论，温暖手作圈…',
                  isDense: true,
                  filled: true,
                  fillColor: palette.isDark
                      ? const Color(0xFF23232C)
                      : const Color(0xFFF2F2F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Palette.accent),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});

  final CommunityComment comment;

  @override
  Widget build(BuildContext context) {
    final palette = CommunityPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommunityAvatar(user: comment.user, size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.user.nickname,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: palette.isDark
                          ? const Color(0xFF9A9AA6)
                          : const Color(0xFF8A8A94),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeAgo(comment.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: palette.isDark
                          ? const Color(0xFF6A6A76)
                          : const Color(0xFFB0B0BA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comment.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: palette.isDark
                      ? const Color(0xFFE6E6EC)
                      : const Color(0xFF2B2B33),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 分享弹层：复制链接 / 微信 / 朋友圈 / 更多（复制链接走系统剪贴板，其余记录分享数）
Future<void> showShareSheet(
  BuildContext context, {
  required FeedPost post,
  VoidCallback? onShared,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ShareSheet(post: post, onShared: onShared),
  );
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.post, this.onShared});

  final FeedPost post;
  final VoidCallback? onShared;

  static const _options = [
    (icon: Icons.link_rounded, label: '复制链接'),
    (icon: Icons.chat_rounded, label: '微信'),
    (icon: Icons.camera_alt_rounded, label: '朋友圈'),
    (icon: Icons.more_horiz_rounded, label: '更多'),
  ];

  void _pick(BuildContext context, String label) {
    Navigator.pop(context);
    if (label == '复制链接') {
      Clipboard.setData(
        ClipboardData(text: 'https://diy.example.com/post/${post.id}'),
      );
    }
    // 记录分享数（复制链接与分享到渠道均计入）
    PostApi.recordShare(post.id).catchError((_) {});
    onShared?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label == '复制链接' ? '链接已复制' : '已生成分享链接，去 $label 分享吧'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = CommunityPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: palette.isDark
                    ? const Color(0xFF3A3A44)
                    : const Color(0xFFE0E0E6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '分享到',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: palette.isDark
                    ? const Color(0xFFE6E6EC)
                    : const Color(0xFF2B2B33),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final o in _options)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _pick(context, o.label),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Palette.accent, Palette.purple],
                            ),
                          ),
                          child: Icon(o.icon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          o.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.isDark
                                ? const Color(0xFFB8B8C4)
                                : const Color(0xFF565662),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 更多操作弹层：收藏 / 不感兴趣 / 举报（真实接口）
Future<void> showMoreSheet(
  BuildContext context, {
  required FeedPost post,
  VoidCallback? onCollectedChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _MoreSheet(post: post, onCollectedChanged: onCollectedChanged),
  );
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet({required this.post, this.onCollectedChanged});

  final FeedPost post;
  final VoidCallback? onCollectedChanged;

  static const _actions = [
    (icon: Icons.bookmark_border_rounded, label: '收藏作品'),
    (icon: Icons.not_interested_rounded, label: '不感兴趣'),
    (icon: Icons.report_gmailerrorred_rounded, label: '举报'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = CommunityPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: palette.isDark
                    ? const Color(0xFF3A3A44)
                    : const Color(0xFFE0E0E6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            for (final a in _actions)
              ListTile(
                leading: Icon(
                  a.icon,
                  color: palette.isDark
                      ? const Color(0xFFB8B8C4)
                      : const Color(0xFF565662),
                ),
                title: Text(
                  a.label,
                  style: TextStyle(
                    fontSize: 15,
                    color: a.label == '举报'
                        ? CommunityPalette.love
                        : (palette.isDark
                              ? const Color(0xFFE6E6EC)
                              : const Color(0xFF2B2B33)),
                  ),
                ),
                onTap: () => _onTap(context, a.label),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, String label) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    if (label == '收藏作品') {
      await _toggleCollect(messenger);
    } else if (label == '不感兴趣') {
      _toast(messenger, '已减少此类内容');
    } else if (label == '举报') {
      await _showReportDialog(messenger);
    }
  }

  Future<void> _toggleCollect(ScaffoldMessengerState messenger) async {
    try {
      final collected = await PostApi.toggleCollect(post.id);
      onCollectedChanged?.call();
      _toast(messenger, collected ? '已收藏' : '已取消收藏');
    } catch (_) {
      _toast(messenger, '操作失败，请稍后再试');
    }
  }

  Future<void> _showReportDialog(ScaffoldMessengerState messenger) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: messenger.context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('举报作品'),
        content: TextField(
          controller: controller,
          maxLength: 200,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '请描述举报原因…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('提交举报'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.isEmpty) return;
    try {
      await PostApi.report(post.id, reason);
      _toast(messenger, '举报已提交，我们会尽快处理');
    } catch (_) {
      _toast(messenger, '举报失败，请稍后再试');
    }
  }

  void _toast(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
