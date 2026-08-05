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

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

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
    try {
      final comment = await VideoApi.addComment(widget.video.id, text);
      if (!mounted) return;
      setState(() {
        _comments.insert(0, comment);
        _inputCtrl.clear();
      });
      widget.onAdded();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评论失败：$e'), behavior: SnackBarBehavior.floating),
      );
    }
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
                  '${_comments.length}',
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
                    itemBuilder: (_, i) => _CommentRow(comment: _comments[i]),
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '友善评论，温暖手作圈…',
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
  const _CommentRow({required this.comment});

  final CommunityComment comment;

  @override
  Widget build(BuildContext context) {
    final u = comment.user;
    return Row(
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
              Text(
                comment.content,
                style: const TextStyle(
                  color: Color(0xFFE6E6EC),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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
