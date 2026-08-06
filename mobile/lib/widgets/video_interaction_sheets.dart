import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/video_api.dart';
import '../features/community/domain/community_models.dart';
import '../pages/short_video_models.dart';

/// 短视频 / 笔记作品通用的深色评论弹层。
///
/// 视频信息流与个人主页详情页共用：拉取评论、发布评论、新增后回调外层刷新计数。
class VideoCommentSheet extends StatefulWidget {
  const VideoCommentSheet({super.key, required this.video, required this.onAdded});

  final ShortVideo video;

  /// 每新增一条评论回调（用于更新外层计数）
  final VoidCallback onAdded;

  @override
  State<VideoCommentSheet> createState() => _VideoCommentSheetState();
}

class _VideoCommentSheetState extends State<VideoCommentSheet> {
  List<CommunityComment> _comments = [];
  bool _loading = true;
  final _inputCtrl = TextEditingController();
  final _focusNode = FocusNode();

  /// 当前回复目标；null 表示发表顶级评论
  CommunityComment? _replyTo;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _totalCount => _comments.fold(
        0,
        (sum, c) => sum + 1 + c.replies.length,
      );

  Future<void> _loadComments() async {
    try {
      final r = await VideoApi.fetchComments(widget.video.id);
      if (!mounted) return;
      setState(() {
        _comments = r.items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    final target = _replyTo;
    try {
      final parentId = target == null ? null : (target.parentId ?? target.id);
      final comment = await VideoApi.addComment(
        widget.video.id,
        text,
        parentId: parentId,
        replyToId: target?.user.id,
      );
      if (!mounted) return;
      setState(() {
        if (parentId == null) {
          _comments.insert(0, comment);
        } else {
          _appendReply(parentId, comment);
        }
        _inputCtrl.clear();
        _replyTo = null;
      });
      // 视频评论总数只统计顶级评论，与后端保持一致
      if (parentId == null) widget.onAdded();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评论失败：$e'), behavior: SnackBarBehavior.floating),
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
      await VideoApi.toggleCommentLike(widget.video.id, comment.id);
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A44),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                const Text(
                  '评论',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_totalCount',
                  style: const TextStyle(
                    color: Color(0xFF8A8A96),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white30),
                  )
                : _comments.isEmpty
                ? const Center(
                    child: Text(
                      '还没有评论，来抢沙发～',
                      style: TextStyle(color: Color(0xFF8A8A96)),
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
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _replyTo == null
                      ? '友善评论，温暖手作圈…'
                      : '回复 @${_replyTo!.user.nickname}',
                  hintStyle: const TextStyle(color: Color(0xFF777788)),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFF25252E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
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

/// 深色评论行
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
    final u = comment.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: u.avatarUrl.isEmpty
                  ? _fallbackAvatar(u)
                  : Image.network(
                      u.avatarUrl,
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackAvatar(u),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        u.nickname,
                        style: const TextStyle(
                          color: Color(0xFF9A9AA6),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo(comment.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF6A6A76),
                          fontSize: 11,
                        ),
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
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            '回复',
                            style: TextStyle(
                              color: Color(0xFF6A6A76),
                              fontSize: 12,
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
                                    : const Color(0xFF6A6A76),
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
                                      : const Color(0xFF6A6A76),
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
    final replyTo = comment.replyTo;
    if (replyTo == null) {
      return Text(
        comment.content,
        style: const TextStyle(
          color: Color(0xFFE6E6EC),
          fontSize: 14,
          height: 1.4,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFFE6E6EC),
          fontSize: 14,
          height: 1.4,
        ),
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

  Widget _fallbackAvatar(CommunityUser u) {
    return Container(
      width: 34,
      height: 34,
      color: const Color(0xFF2C2C36),
      child: Center(
        child: Text(
          u.initial,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}

/// 深色分享弹层（信息流与个人主页详情页共用）。
class VideoShareSheet extends StatelessWidget {
  const VideoShareSheet({super.key, this.onShared});

  /// 用户选择任一分享渠道时回调（上报分享数）
  final VoidCallback? onShared;

  static const _options = [
    (icon: Icons.link_rounded, label: '复制链接'),
    (icon: Icons.chat_rounded, label: '微信'),
    (icon: Icons.camera_alt_rounded, label: '朋友圈'),
    (icon: Icons.more_horiz_rounded, label: '更多'),
  ];

  void _pick(BuildContext context, String label) {
    Navigator.pop(context);
    onShared?.call();
    if (label == '复制链接') {
      Clipboard.setData(
        const ClipboardData(text: 'https://diy.example.com/video/1'),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: const Color(0xFF3A3A44),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '分享到',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Palette.accent, Palette.accentDark],
                            ),
                          ),
                          child: Icon(o.icon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          o.label,
                          style: const TextStyle(
                            color: Color(0xFFB8B8C4),
                            fontSize: 12,
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

/// 深色详情页右侧动作项：图标 + 计数/文案。
class DarkActionItem extends StatelessWidget {
  const DarkActionItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
