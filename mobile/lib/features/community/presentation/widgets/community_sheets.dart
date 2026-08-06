import 'dart:math' as math;

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
  final _focusNode = FocusNode();

  /// 当前回复目标；null 表示发表顶级评论
  CommunityComment? _replyTo;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _totalCount => _comments.fold(
        0,
        (sum, c) => sum + 1 + c.replies.length,
      );

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final target = _replyTo;
    try {
      final parentId = target == null ? null : (target.parentId ?? target.id);
      final comment = await PostApi.addComment(
        widget.post.id,
        text,
        parentId: parentId,
        replyToId: target?.user.id,
      );
      if (!mounted) return;
      setState(() {
        final newComment = CommunityComment(
          id: comment.id,
          user: CommunityUser(
            id: comment.userId,
            nickname: comment.author?.nickname ?? widget.currentUser.nickname,
            avatarUrl: comment.author != null
                ? ChatApi.resolveUrl(comment.author!.avatar)
                : widget.currentUser.avatarUrl,
          ),
          content: comment.content,
          createdAt: comment.createdAt,
          parentId: parentId,
          replyTo: comment.replyTo == null
              ? null
              : CommunityUser(
                  id: comment.replyToId ?? 0,
                  nickname: comment.replyTo!.nickname,
                  avatarUrl: comment.replyTo!.avatar,
                ),
        );
        if (parentId == null) {
          _comments.insert(0, newComment);
        } else {
          _appendReply(parentId, newComment);
        }
        _controller.clear();
        _replyTo = null;
      });
      // 帖子评论总数只统计顶级评论，与后端保持一致
      if (parentId == null) widget.onCommentAdded?.call();
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

  /// 将回复挂到对应顶级评论下
  void _appendReply(int parentId, CommunityComment reply) {
    final index = _comments.indexWhere((c) => c.id == parentId);
    if (index < 0) {
      _comments.insert(0, reply);
      return;
    }
    _comments[index] = _comments[index].copyWith(
      replies: [..._comments[index].replies, reply],
    );
  }

  Future<void> _toggleLike(CommunityComment comment) async {
    final liked = !comment.liked;
    _updateComment(
      comment.id,
      (c) => c.copyWith(
        liked: liked,
        likeCount: math.max(0, c.likeCount + (liked ? 1 : -1)),
      ),
    );
    try {
      await PostApi.toggleCommentLike(widget.post.id, comment.id);
    } catch (_) {
      if (!mounted) return;
      _updateComment(
        comment.id,
        (c) => c.copyWith(
          liked: !liked,
          likeCount: math.max(0, c.likeCount + (liked ? -1 : 1)),
        ),
      );
    }
  }

  /// 按 id 更新顶级评论或其任一回复
  void _updateComment(
    int id,
    CommunityComment Function(CommunityComment) fn,
  ) {
    if (!mounted) return;
    setState(() {
      final topIndex = _comments.indexWhere((c) => c.id == id);
      if (topIndex >= 0) {
        _comments[topIndex] = fn(_comments[topIndex]);
        return;
      }
      for (var i = 0; i < _comments.length; i++) {
        final replies = _comments[i].replies;
        final rIndex = replies.indexWhere((r) => r.id == id);
        if (rIndex >= 0) {
          _comments[i] = _comments[i].copyWith(
            replies: [
              for (var j = 0; j < replies.length; j++)
                if (j == rIndex) fn(replies[j]) else replies[j],
            ],
          );
          return;
        }
      }
    });
  }

  void _startReply(CommunityComment comment) {
    setState(() => _replyTo = comment);
    _focusNode.requestFocus();
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
                  '$_totalCount',
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
                    itemBuilder: (_, i) => _CommentRow(
                      comment: _comments[i],
                      onLike: _toggleLike,
                      onReply: _startReply,
                    ),
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
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: _replyTo == null
                      ? '友善评论，温暖手作圈…'
                      : '回复 @${_replyTo!.user.nickname}',
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
  const _CommentRow({
    required this.comment,
    required this.onLike,
    required this.onReply,
  });

  final CommunityComment comment;
  final void Function(CommunityComment) onLike;
  final void Function(CommunityComment) onReply;

  @override
  Widget build(BuildContext context) {
    final palette = CommunityPalette.of(context);
    final secondaryColor = palette.isDark
        ? const Color(0xFF9A9AA6)
        : const Color(0xFF8A8A94);
    final faintColor = palette.isDark
        ? const Color(0xFF6A6A76)
        : const Color(0xFFB0B0BA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                          color: secondaryColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo(comment.createdAt),
                        style: TextStyle(fontSize: 11, color: faintColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  _commentContent(context, comment: comment),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => onReply(comment),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            '回复',
                            style: TextStyle(
                              fontSize: 12,
                              color: faintColor,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onLike(comment),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                comment.liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 16,
                                color: comment.liked
                                    ? Palette.accent
                                    : faintColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                comment.likeCount > 0
                                    ? formatCount(comment.likeCount)
                                    : '赞',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: comment.liked
                                      ? Palette.accent
                                      : faintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // 子回复缩进展示
        for (final reply in comment.replies)
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 12),
            child: _CommentRow(
              comment: reply,
              onLike: onLike,
              onReply: onReply,
            ),
          ),
      ],
    );
  }

  /// 回复内联组件：被回复时展示「回复 @昵称：」
  Widget _commentContent(
    BuildContext context, {
    required CommunityComment comment,
  }) {
    final textColor = _textColorOf(context);
    final replyTo = comment.replyTo;
    if (replyTo == null) {
      return Text(
        comment.content,
        style: TextStyle(fontSize: 14, height: 1.4, color: textColor),
      );
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, height: 1.4, color: textColor),
        children: [
          TextSpan(
            text: '回复 @${replyTo.nickname}：',
            style: const TextStyle(
              color: Palette.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: comment.content),
        ],
      ),
    );
  }

  Color _textColorOf(BuildContext context) {
    final palette = CommunityPalette.of(context);
    return palette.isDark
        ? const Color(0xFFE6E6EC)
        : const Color(0xFF2B2B33);
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

/// 更多操作弹层：收藏 / 不感兴趣（真实接口）
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
                    color: palette.isDark
                        ? const Color(0xFFE6E6EC)
                        : const Color(0xFF2B2B33),
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
