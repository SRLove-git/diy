import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/community_models.dart';
import '../community_palette.dart';
import 'community_avatar.dart';

/// 底部弹层集合：评论 / 分享 / 更多操作

/// 评论弹层：展示评论列表 + 输入框（Mock，本地追加）
Future<void> showCommentSheet(
  BuildContext context, {
  required FeedPost post,
  required List<CommunityComment> comments,
  required CommunityUser currentUser,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _CommentSheet(post: post, comments: comments, currentUser: currentUser),
  );
}

class _CommentSheet extends StatefulWidget {
  const _CommentSheet({
    required this.post,
    required this.comments,
    required this.currentUser,
  });

  final FeedPost post;
  final List<CommunityComment> comments;
  final CommunityUser currentUser;

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

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(
        0,
        CommunityComment(
          user: widget.currentUser,
          content: text,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      _controller.clear();
    });
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
              icon: const Icon(Icons.send_rounded, color: Color(0xFFFF718D)),
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

/// 分享弹层
Future<void> showShareSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ShareSheet(),
  );
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet();

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
        const ClipboardData(text: 'https://diy.example.com/post/1'),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label == '复制链接' ? '链接已复制' : '分享到 $label（演示）'),
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
                              colors: [Color(0xFFFF718D), Color(0xFF8B73F6)],
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

/// 更多操作弹层
Future<void> showMoreSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _MoreSheet(),
  );
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet();

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
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${a.label}（演示）'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
