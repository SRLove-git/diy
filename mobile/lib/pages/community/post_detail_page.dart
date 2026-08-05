import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/follow_api.dart';
import '../../core/post_api.dart';
import '../../features/community/domain/community_models.dart';
import '../../features/community/presentation/widgets/media_grid.dart';
import '../../features/community/presentation/widgets/photo_viewer_page.dart';
import '../../features/community/presentation/widgets/video_player_widget.dart';
import 'author_profile_page.dart';

/// 社区作品详情页。
///
/// 页面采用沉浸式内容布局：顶部作者信息、大幅媒体、正文与话题、
/// 评论列表，以及始终可见的点赞 / 收藏 / 评论操作栏。
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Post? _post;
  bool _loading = true;
  String? _error;

  bool _liked = false;
  bool _collected = false;
  List<Comment> _comments = [];
  bool _commentLoading = false;
  bool _sendingComment = false;
  final _commentController = TextEditingController();
  final _commentFocus = FocusNode();

  FollowStatus? _follow;
  bool _followBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
    PostApi.addHistory(widget.postId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  bool get _isSelf => AuthService.instance.user?.id == _post?.userId;

  List<MediaItem> _mediaItems(Post post) {
    final source = post.medias.isNotEmpty
        ? post.medias
        : post.images
              .map(
                (url) => PostMedia(type: 'image', url: url, aspectRatio: 4 / 5),
              )
              .toList();
    return source
        .map(
          (media) => MediaItem(
            type: media.type == 'video' ? MediaType.video : MediaType.image,
            url: ChatApi.resolveUrl(media.url),
            aspectRatio: media.aspectRatio ?? 1,
            duration: media.duration == null
                ? null
                : Duration(seconds: media.duration!.round()),
          ),
        )
        .toList();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final post = await PostApi.fetchDetail(widget.postId);
      if (!mounted) return;
      setState(() => _post = post);
      _loadStatuses(post.userId);
      _loadComments();
    } catch (_) {
      if (mounted) setState(() => _error = '加载失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadStatuses(int authorId) async {
    try {
      final futures = <Future<Object>>[
        PostApi.isLiked(widget.postId),
        PostApi.isCollected(widget.postId),
        if (!_isSelf) FollowApi.status(authorId),
      ];
      final results = await Future.wait(futures);
      if (!mounted) return;
      setState(() {
        _liked = results[0] as bool;
        _collected = results[1] as bool;
        if (!_isSelf && results.length > 2) {
          _follow = results[2] as FollowStatus;
        }
      });
    } catch (_) {
      // 状态接口失败不影响正文阅读。
    }
  }

  Future<void> _loadComments() async {
    setState(() => _commentLoading = true);
    try {
      final result = await PostApi.fetchComments(widget.postId);
      if (mounted) setState(() => _comments = result.items);
    } catch (_) {
      // 评论失败时保留空态，正文仍可正常阅读。
    } finally {
      if (mounted) setState(() => _commentLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final authorId = _post?.userId;
    if (authorId == null || _isSelf || _followBusy) return;
    setState(() => _followBusy = true);
    try {
      final status = await FollowApi.setFollow(
        authorId,
        following: !(_follow?.following ?? false),
      );
      if (mounted) setState(() => _follow = status);
    } catch (_) {
      if (mounted) _showMessage('操作失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  Future<void> _toggleLike() async {
    try {
      final liked = await PostApi.toggleLike(widget.postId);
      if (!mounted || _post == null) return;
      setState(() {
        _liked = liked;
        _post = _post!.copyWith(
          likeCount: liked
              ? _post!.likeCount + 1
              : (_post!.likeCount - 1).clamp(0, 999999),
        );
      });
    } catch (_) {
      if (mounted) _showMessage('点赞失败，请稍后再试');
    }
  }

  Future<void> _toggleCollect() async {
    try {
      final collected = await PostApi.toggleCollect(widget.postId);
      if (!mounted || _post == null) return;
      setState(() {
        _collected = collected;
        _post = _post!.copyWith(
          collectCount: collected
              ? _post!.collectCount + 1
              : (_post!.collectCount - 1).clamp(0, 999999),
        );
      });
    } catch (_) {
      if (mounted) _showMessage('收藏失败，请稍后再试');
    }
  }

  Future<void> _sharePost() async {
    final post = _post;
    if (post == null) return;
    await Clipboard.setData(
      ClipboardData(text: 'https://diy.example.com/posts/${post.id}'),
    );
    try {
      await PostApi.recordShare(post.id);
      if (mounted) {
        setState(() {
          _post = _post?.copyWith(shareCount: post.shareCount + 1);
        });
      }
    } catch (_) {
      // 链接已复制，分享计数失败不阻塞用户操作。
    }
    if (mounted) _showMessage('作品链接已复制');
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _sendingComment) return;
    setState(() => _sendingComment = true);
    try {
      final comment = await PostApi.addComment(widget.postId, text);
      if (!mounted || _post == null) return;
      _commentController.clear();
      _commentFocus.unfocus();
      setState(() {
        _comments = [comment, ..._comments];
        _post = _post!.copyWith(commentCount: _post!.commentCount + 1);
      });
    } catch (_) {
      if (mounted) _showMessage('评论发送失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatPostDate(String iso) {
    try {
      return DateFormat('MM-dd').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  String _formatCommentDate(String iso) {
    try {
      final value = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (value.year == now.year &&
          value.month == now.month &&
          value.day == now.day) {
        return DateFormat('HH:mm').format(value);
      }
      return DateFormat('MM-dd').format(value);
    } catch (_) {
      return iso;
    }
  }

  void _openAuthor(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AuthorProfilePage(userId: post.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (_loading) return _buildLoading(colors);
    if (_error != null || _post == null) return _buildError(colors);

    final post = _post!;
    final media = _mediaItems(post);
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _buildAppBar(post, colors),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: colors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  if (media.isNotEmpty) _buildMedia(media),
                  _buildPostBody(post, colors),
                  Divider(
                    height: 1,
                    color: colors.divider.withValues(alpha: 0.55),
                  ),
                  _buildComments(post, colors),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomBar(post, colors),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Post post, AppColors colors) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leadingWidth: 48,
      leading: IconButton(
        tooltip: '返回',
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openAuthor(post),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(
              post.author?.avatar ?? '',
              size: 38,
              fallbackColor: colors.placeholder,
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                post.author?.nickname ?? '用户 #${post.userId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!_isSelf)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _FollowPill(
              following: _follow?.following ?? false,
              loading: _followBusy,
              color: colors.primary,
              onTap: _toggleFollow,
            ),
          ),
        IconButton(
          tooltip: '分享',
          onPressed: _sharePost,
          icon: Icon(
            Icons.ios_share_rounded,
            color: colors.textPrimary,
            size: 27,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildLoading(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(),
      ),
      body: Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
      ),
    );
  }

  Widget _buildError(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('作品详情'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? '作品不存在',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _load, child: const Text('重新加载')),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia(List<MediaItem> media) {
    if (media.length != 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: MediaGrid(medias: media),
      );
    }

    final item = media.first;
    if (item.type == MediaType.video) {
      final ratio = item.aspectRatio > 0 ? item.aspectRatio : 16 / 9;
      return AspectRatio(
        aspectRatio: ratio.clamp(0.72, 1.78),
        child: VideoPlayerWidget(item: item),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = item.aspectRatio > 0 ? item.aspectRatio : 1.0;
        final height = (constraints.maxWidth / ratio).clamp(260.0, 620.0);
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PhotoViewerPage(images: [item], initialIndex: 0),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: Image.network(
              item.url,
              fit: BoxFit.cover,
              cacheWidth: 1200,
              frameBuilder: (context, child, frame, syncLoaded) {
                if (syncLoaded || frame != null) return child;
                return Container(
                  color: const Color(0xFFF0F0F0),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFF0F0F0),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 42,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostBody(Post post, AppColors colors) {
    final tags = post.tags
        .map((tag) => tag.startsWith('#') ? tag : '#$tag')
        .toList();
    final channel = post.channelTag.isNotEmpty
        ? post.channelTag.replaceFirst(RegExp(r'^#'), '')
        : (post.tags.isNotEmpty
              ? post.tags.first.replaceFirst(RegExp(r'^#'), '')
              : '社区');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.title.trim().isNotEmpty) ...[
            Text(
              post.title.trim(),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (post.content.trim().isNotEmpty)
            Text(
              post.content.trim(),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                height: 1.55,
              ),
            ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 5,
              children: tags
                  .map(
                    (tag) => Text(
                      tag,
                      style: const TextStyle(
                        color: Color(0xFF24558A),
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TopicPill(
                icon: Icons.flag_outlined,
                prefix: '活动',
                text: channel,
              ),
              if (post.tags.length > 1)
                _TopicPill(
                  icon: Icons.search_rounded,
                  prefix: '猜你想搜',
                  text: post.tags[1].replaceFirst(RegExp(r'^#'), ''),
                ),
            ],
          ),
          const SizedBox(height: 19),
          Row(
            children: [
              Text(
                _formatPostDate(post.createdAt),
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              if (post.location.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    post.location.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showMessage('已减少此类内容推荐'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied_outlined,
                        size: 17,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '不喜欢',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
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
    );
  }

  Widget _buildComments(Post post, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 19, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '共 ${post.commentCount} 条评论',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 5),
              Icon(Icons.sort_rounded, size: 20, color: colors.textPrimary),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickComment(colors),
          const SizedBox(height: 20),
          if (_commentLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
            )
          else if (_comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 34),
              child: Center(
                child: Text(
                  '还没有评论，来聊聊你的想法吧',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            )
          else
            for (var index = 0; index < _comments.length; index++) ...[
              _buildCommentItem(_comments[index], post, colors),
              if (index != _comments.length - 1) const SizedBox(height: 22),
            ],
        ],
      ),
    );
  }

  Widget _buildQuickComment(AppColors colors) {
    final user = AuthService.instance.user;
    return Row(
      children: [
        _buildAvatar(
          user?.avatar ?? '',
          size: 38,
          fallbackColor: colors.placeholder,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _commentFocus.requestFocus,
            child: Container(
              height: 44,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.placeholder,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                '有话要说，快来评论',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment, Post post, AppColors colors) {
    final isAuthor = comment.userId == post.userId;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(
          comment.author?.avatar ?? '',
          size: 38,
          fallbackColor: colors.placeholder,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      comment.author?.nickname ?? '用户 #${comment.userId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isAuthor) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '作者',
                        style: TextStyle(color: colors.primary, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 7),
              Text(
                comment.content,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    _formatCommentDate(comment.createdAt),
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      _commentController.text =
                          '@${comment.author?.nickname ?? '用户'} ';
                      _commentController.selection = TextSelection.collapsed(
                        offset: _commentController.text.length,
                      );
                      _commentFocus.requestFocus();
                    },
                    child: Text(
                      '回复',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Post post, AppColors colors) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Material(
      color: colors.surface,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.placeholder,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocus,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendComment(),
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '说点什么...',
                      hintStyle: TextStyle(color: colors.textSecondary),
                      prefixIcon: Icon(
                        Icons.edit_outlined,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: keyboardOpen
                          ? IconButton(
                              tooltip: '发送',
                              onPressed: _sendingComment ? null : _sendComment,
                              icon: _sendingComment
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.send_rounded,
                                      color: colors.primary,
                                      size: 20,
                                    ),
                            )
                          : null,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),
              if (!keyboardOpen) ...[
                const SizedBox(width: 8),
                _BottomAction(
                  icon: _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  count: post.likeCount,
                  active: _liked,
                  activeColor: colors.primary,
                  color: colors.textPrimary,
                  onTap: _toggleLike,
                ),
                _BottomAction(
                  icon: _collected
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  count: post.collectCount,
                  active: _collected,
                  activeColor: const Color(0xFFFFB326),
                  color: colors.textPrimary,
                  onTap: _toggleCollect,
                ),
                _BottomAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  count: post.commentCount,
                  active: false,
                  activeColor: colors.primary,
                  color: colors.textPrimary,
                  onTap: _commentFocus.requestFocus,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(
    String rawUrl, {
    required double size,
    required Color fallbackColor,
  }) {
    final colors = AppColors.of(context);
    final url = rawUrl.isEmpty ? '' : ChatApi.resolveUrl(rawUrl);
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fallbackColor, shape: BoxShape.circle),
      child: Icon(
        Icons.person_rounded,
        color: colors.textSecondary,
        size: size * 0.58,
      ),
    );
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class _FollowPill extends StatelessWidget {
  const _FollowPill({
    required this.following,
    required this.loading,
    required this.color,
    required this.onTap,
  });

  final bool following;
  final bool loading;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: loading ? null : onTap,
      child: Container(
        width: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: following ? const Color(0xFFAAAAAA) : color,
            width: 1.2,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Text(
                following ? '已关注' : '关注',
                style: TextStyle(
                  color: following ? const Color(0xFF777777) : color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  const _TopicPill({
    required this.icon,
    required this.prefix,
    required this.text,
  });

  final IconData icon;
  final String prefix;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        border: Border.all(color: colors.divider.withValues(alpha: 0.65)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colors.textPrimary),
          const SizedBox(width: 5),
          Text(
            prefix,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(width: 1, height: 15, color: colors.divider),
          ),
          Text(text, style: TextStyle(color: colors.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.count,
    required this.active,
    required this.activeColor,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final bool active;
  final Color activeColor;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final current = active ? activeColor : color;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: current, size: 26),
            const SizedBox(width: 3),
            Text(
              _formatActionCount(count),
              style: TextStyle(
                color: current,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatActionCount(int count) {
  if (count >= 10000) {
    final value = count / 10000;
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}万';
  }
  if (count >= 1000) return '999+';
  return '$count';
}
