import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../domain/community_models.dart';
import '../community_palette.dart';
import 'community_avatar.dart';
import 'media_grid.dart';

/// 频道信息流帖子卡片
///
/// 结构：作者行 → 文案 → 媒体网格 → Reaction 标签 → 底部数据栏。
/// 卡片通栏铺满全屏宽度，文本区域左右 12px 留白。
class FeedCard extends StatefulWidget {
  const FeedCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard>
    with SingleTickerProviderStateMixin {
  /// 点赞弹跳动画
  late final AnimationController _likeAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  late final Animation<double> _likeScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.45)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.45, end: 1.0)
          .chain(CurveTween(curve: Curves.elasticOut)),
      weight: 55,
    ),
  ]).animate(_likeAnim);

  late bool _liked = widget.post.liked;

  @override
  void didUpdateWidget(FeedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部状态变为已赞时触发弹跳
    if (widget.post.liked && !oldWidget.post.liked) {
      _likeAnim.forward(from: 0);
    }
    _liked = widget.post.liked;
  }

  @override
  void dispose() {
    _likeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final post = widget.post;
    final author = CommunityUser(
      id: post.id,
      nickname: post.username,
      avatarUrl: post.avatar,
    );

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(author, colors),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Text(
              post.content,
              style: TextStyle(
                fontSize: 18,
                height: 1.45,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (post.medias.isNotEmpty) MediaGrid(medias: post.medias),
          _buildReactions(colors),
          _buildFooter(colors),
        ],
      ),
    );
  }

  /// 作者行：头像 / 昵称 / 频道标签
  Widget _buildHeader(CommunityUser author, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          CommunityAvatar(user: author, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.post.channelTag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Reaction 标签：胶囊 Wrap
  Widget _buildReactions(AppColors colors) {
    final reactions = widget.post.reactions;
    if (reactions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final r in reactions)
            IntrinsicWidth(
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  r,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 底部数据栏：左「浏览 xxx」右「点赞 / 评论 / 分享」
  Widget _buildFooter(AppColors colors) {
    final post = widget.post;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Row(
        children: [
          Text(
            '浏览 ${formatCount(post.viewCount)}',
            style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
          ),
          const Spacer(),
          // 点赞
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onLike,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _likeScale,
                  child: Icon(
                    _liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 22,
                    color: _liked ? CommunityPalette.love : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  formatCount(post.likeCount),
                  style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // 评论
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onComment,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 22, color: colors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  formatCount(post.commentCount),
                  style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // 分享
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onShare,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send_rounded, size: 22, color: colors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  formatCount(post.shareCount),
                  style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
