import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/api_client.dart';
import '../../api/content_services.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';
import 'community_screens.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  /// 键盘弹出前（无键盘遮挡时）的窗口高度，用于计算画布缩放比例。
  double? _noKeyboardHeight;
  Post? _post;
  bool _liked = false;
  bool _collected = false;
  List<Comment> _comments = [];
  bool _loading = true;
  String? _error;
  bool _onlyAuthor = false;
  final _commentCtrl = TextEditingController();
  bool _sendingComment = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.viewInsets.bottom == 0) {
      _noKeyboardHeight = mediaQuery.size.height;
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final post = await CommunityService.instance.detail(widget.postId);
      final liked = await CommunityService.instance.isLiked(widget.postId);
      final collected = await CommunityService.instance.isCollected(widget.postId);
      final comments = await CommunityService.instance.comments(widget.postId);
      CommunityService.instance.recordView(widget.postId).catchError((_) {});
      CommunityService.instance.addHistory(widget.postId).catchError((_) {});
      if (mounted) {
        setState(() {
          _post = post;
          _liked = liked;
          _collected = collected;
          _comments = comments.items;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleLike() async {
    try {
      final liked = await CommunityService.instance.toggleLike(widget.postId);
      if (mounted) {
        setState(() {
          _liked = liked;
          final p = _post;
          if (p != null) {
            _post = Post(
              id: p.id,
              userId: p.userId,
              title: p.title,
              content: p.content,
              location: p.location,
              images: p.images,
              medias: p.medias,
              tags: p.tags,
              channelTag: p.channelTag,
              likeCount: p.likeCount + (liked ? 1 : -1),
              collectCount: p.collectCount,
              commentCount: p.commentCount,
              viewCount: p.viewCount,
              shareCount: p.shareCount,
              createdAt: p.createdAt,
              author: p.author,
            );
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _toggleCollect() async {
    try {
      final collected = await CommunityService.instance.toggleCollect(widget.postId);
      if (mounted) {
        setState(() {
          _collected = collected;
          final p = _post;
          if (p != null) {
            _post = Post(
              id: p.id,
              userId: p.userId,
              title: p.title,
              content: p.content,
              location: p.location,
              images: p.images,
              medias: p.medias,
              tags: p.tags,
              channelTag: p.channelTag,
              likeCount: p.likeCount,
              collectCount: p.collectCount + (collected ? 1 : -1),
              commentCount: p.commentCount,
              viewCount: p.viewCount,
              shareCount: p.shareCount,
              createdAt: p.createdAt,
              author: p.author,
            );
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _share() async {
    CommunityService.instance.recordShare(widget.postId).catchError((_) {});
    showLiveSnack(context, '已复制分享链接（模拟）');
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendingComment = true);
    try {
      final c = await CommunityService.instance.addComment(widget.postId, text);
      if (mounted) {
        _commentCtrl.clear();
        setState(() => _comments = [c, ..._comments]);
        showLiveSnack(context, '评论成功');
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 外层 LiveHost 用 FittedBox 把 440x956 画布缩放到屏幕，
    // 底部评论栏的 viewInsets 补偿需按缩放比例放大，才能在屏幕上
    // 恰好把输入框顶到键盘上沿。
    final mediaQuery = MediaQuery.of(context);
    final canvasHeight = _noKeyboardHeight ?? mediaQuery.size.height;
    final canvasScale = math.min(
      mediaQuery.size.width / 440,
      canvasHeight / 956,
    );
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '作品详情'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _post == null
                        ? const EmptyView()
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView(
                              padding: const EdgeInsets.all(18),
                              children: [
                                _PostDetailBody(
                                  post: _post!,
                                  liked: _liked,
                                  collected: _collected,
                                  onAuthorTap: () => LiveRoutes.pushId(
                                    context,
                                    RoutePaths.userDetail,
                                    _post!.userId,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _DetailAction(
                                      icon: _liked ? Icons.favorite : Icons.favorite_border,
                                      label: '${fmtCount(_post!.likeCount)}',
                                      color: _liked ? LiveColors.danger : LiveColors.textSecondary,
                                      onTap: _toggleLike,
                                    ),
                                    _DetailAction(
                                      icon: _collected ? Icons.star : Icons.star_border,
                                      label: '${fmtCount(_post!.collectCount)}',
                                      color: _collected ? LiveColors.warning : LiveColors.textSecondary,
                                      onTap: _toggleCollect,
                                    ),
                                    _DetailAction(
                                      icon: Icons.share_outlined,
                                      label: '${fmtCount(_post!.shareCount)}',
                                      onTap: _share,
                                    ),
                                    const Spacer(),
                                    Text('浏览 ${fmtCount(_post!.viewCount)}',
                                        style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
                                  ],
                                ),
                                const Divider(height: 28, color: LiveColors.divider),
                                Row(
                                  children: [
                                    Text(
                                      '评论 ${_post!.commentCount}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () => setState(() => _onlyAuthor = !_onlyAuthor),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _onlyAuthor
                                              ? LiveColors.textPrimary
                                              : LiveColors.card,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '只看楼主',
                                          style: TextStyle(
                                            fontSize: 11.6,
                                            fontWeight: FontWeight.w600,
                                            color: _onlyAuthor
                                                ? Colors.white
                                                : LiveColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (_comments.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: EmptyView(text: '还没有评论，来抢沙发', icon: Icons.mode_comment_outlined),
                                  )
                                else
                                  ...(_onlyAuthor
                                          ? _comments
                                              .where((c) =>
                                                  c.userId == _post!.userId)
                                              .toList()
                                          : _comments)
                                      .map((c) => _CommentTile(comment: c)),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
          ),
          // 键盘弹出时评论栏跟随键盘上移（viewInsets 补偿），
          // 页面本身不压缩，键盘覆盖页面下半部分。
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom / canvasScale,
            ),
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                decoration: const BoxDecoration(
                  color: LiveColors.bg,
                  border: Border(top: BorderSide(color: LiveColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        decoration: InputDecoration(
                          hintText: '说点什么…',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendingComment ? null : _sendComment,
                      icon: const Icon(Icons.send, color: LiveColors.brand),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostDetailBody extends StatelessWidget {
  const _PostDetailBody({
    required this.post,
    required this.liked,
    required this.collected,
    required this.onAuthorTap,
  });

  final Post post;
  final bool liked;
  final bool collected;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final urls = post.mediaUrls;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onAuthorTap,
          child: Row(
            children: [
              Avatar(url: post.author?.avatar ?? '', name: post.author?.nickname ?? '', size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author?.displayName ?? '用户',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary)),
                    Text(fmtTime(post.createdAt, withYear: true),
                        style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary)),
                  ],
                ),
              ),
              if (post.channelTag.isNotEmpty) TagChip(label: post.channelTag),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (post.title.isNotEmpty)
          Text(post.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LiveColors.textPrimary)),
        if (post.content.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(post.content,
              style: const TextStyle(fontSize: 14, color: LiveColors.textPrimary, height: 1.5)),
        ],
        if (post.location.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('📍 ${post.location}', style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary)),
        ],
        if (post.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: post.tags
                .map((t) => Text(t.startsWith('#') ? t : '#$t',
                    style: const TextStyle(fontSize: 13, color: LiveColors.brand)))
                .toList(),
          ),
        ],
        if (urls.isNotEmpty) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: urls.length == 1
                ? GestureDetector(
                    onTap: () => LiveRoutes.push(
                      context,
                      RoutePaths.viewer,
                      extra: urls.first,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: NetImage(url: urls.first),
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: urls.take(9).map((u) => NetImage(url: u)).toList(),
                  ),
          ),
        ],
      ],
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = LiveColors.textSecondary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final replyTo = comment.replyTo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(url: comment.author?.avatar ?? '', name: comment.author?.nickname ?? '', size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.author?.displayName ?? '用户',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LiveColors.textSecondary)),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      if (replyTo != null)
                        TextSpan(
                          text: '回复 @${replyTo.displayName} ',
                          style: const TextStyle(color: LiveColors.brand, fontSize: 13),
                        ),
                      TextSpan(
                        text: comment.content,
                        style: const TextStyle(color: LiveColors.textPrimary, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(fmtTime(comment.createdAt),
                    style: const TextStyle(fontSize: 10, color: LiveColors.textTertiary)),
              ],
            ),
          ),
          Text('赞 ${fmtCount(comment.likeCount)}',
              style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary)),
        ],
      ),
    );
  }
}

class PostPublishScreen extends StatefulWidget {
  const PostPublishScreen({super.key});

  @override
  State<PostPublishScreen> createState() => _PostPublishScreenState();
}

/// 发布作品（微博风）：图片区 + 正文 + 选项行 + 底部操作栏。
class _PostPublishScreenState extends State<PostPublishScreen> {
  final _contentCtrl = TextEditingController();
  final List<String> _images = [];
  String _location = '';
  String _tags = '';
  String _visibility = '公开';
  bool _uploading = false;
  bool _publishing = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await ImagePicker().pickMultiImage(limit: 9 - _images.length);
      if (picked.isEmpty) return;
      setState(() => _uploading = true);
      for (final f in picked) {
        final bytes = await f.readAsBytes();
        final url = await UploadService.instance.uploadImage(
          bytes,
          f.name.isEmpty ? 'post_${DateTime.now().millisecondsSinceEpoch}.jpg' : f.name,
          folder: 'post',
        );
        if (mounted) setState(() => _images.add(url));
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } catch (e) {
      if (mounted) showLiveSnack(context, '选择图片失败：$e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _editLocation() async {
    final ctrl = TextEditingController(text: _location);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('所在位置'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入位置，如：上海 · 徐汇'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (value != null && mounted) setState(() => _location = value);
  }

  Future<void> _editTags() async {
    final ctrl = TextEditingController(text: _tags);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('话题'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '多个话题用空格分隔，如 #拼豆 #手作'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (value != null && mounted) setState(() => _tags = value);
  }

  Future<void> _pickVisibility() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: LiveColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '谁可以看',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
              ),
            ),
            for (final v in ['公开', '仅自己可见', '好友可见'])
              InkWell(
                onTap: () => Navigator.pop(context, v),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    v,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: v == _visibility ? FontWeight.w700 : FontWeight.w400,
                      color: v == _visibility
                          ? LiveColors.textPrimary
                          : LiveColors.textSecondary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (value != null && mounted) setState(() => _visibility = value);
  }

  Future<void> _publish() async {
    if (_contentCtrl.text.trim().isEmpty) {
      showLiveSnack(context, '说点什么再发布吧');
      return;
    }
    setState(() => _publishing = true);
    try {
      final body = <String, dynamic>{
        'content': _contentCtrl.text.trim(),
        'images': _images,
        'tags': _tags
            .split(RegExp(r'[，#\s]+'))
            .where((s) => s.isNotEmpty)
            .map((s) => s.startsWith('#') ? s : '#$s')
            .toList(),
        if (_location.isNotEmpty) 'location': _location,
      };
      final post = await CommunityService.instance.create(body);
      if (!mounted) return;
      // 收起键盘后再进入成功页，避免键盘与页面上下分离
      FocusManager.instance.primaryFocus?.unfocus();
      LiveRoutes.push(context, RoutePaths.postPublishSuccess, extra: post);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          LiveAppBar(
            title: '发微博',
            leading: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(fontSize: 15, color: LiveColors.textPrimary),
              ),
            ),
            actions: [
              TextButton(
                onPressed: _publishing ? null : _publish,
                child: _publishing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: LiveColors.brand),
                      )
                    : const Text('发布',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: LiveColors.brand)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // 正文（在图片上方）
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
                  child: TextField(
                    controller: _contentCtrl,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: '分享新鲜事…',
                      hintStyle: TextStyle(fontSize: 15, color: LiveColors.textTertiary),
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                // 图片区（240h）
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _ImageArea(
                    images: _images,
                    uploading: _uploading,
                    onPick: _pickImages,
                    onRemove: (u) => setState(() => _images.remove(u)),
                  ),
                ),
                const SizedBox(height: 6),
                _OptionRow(
                  label: '所在位置',
                  value: _location.isEmpty ? '添加位置 ›' : _location,
                  onTap: _editLocation,
                ),
                _OptionRow(
                  label: '话题',
                  value: _tags.isEmpty ? '#拼豆 #手作 ›' : _tags,
                  onTap: _editTags,
                ),
                _OptionRow(
                  label: '谁可以看',
                  value: _visibility,
                  onTap: _pickVisibility,
                ),
                _OptionRow(
                  label: '定时微博',
                  value: '不设',
                  onTap: () => showLiveSnack(context, '定时微博敬请期待'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // 底部操作栏：拍摄 / 相册 / 头条文章 / 直播 / 更多
          SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: LiveColors.bg,
                border: Border(top: BorderSide(color: LiveColors.divider)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _ActionItem(
                    icon: Icons.photo_camera_outlined,
                    label: '拍摄',
                    onTap: () => showLiveSnack(context, '拍摄功能敬请期待'),
                  ),
                  _ActionItem(
                    icon: Icons.photo_library_outlined,
                    label: '相册',
                    onTap: _uploading ? null : _pickImages,
                  ),
                  _ActionItem(
                    icon: Icons.article_outlined,
                    label: '头条文章',
                    onTap: () => showLiveSnack(context, '头条文章敬请期待'),
                  ),
                  _ActionItem(
                    icon: Icons.videocam_outlined,
                    label: '直播',
                    onTap: () => showLiveSnack(context, '直播敬请期待'),
                  ),
                  _ActionItem(
                    icon: Icons.more_horiz,
                    label: '更多',
                    onTap: () => showLiveSnack(context, '更多功能敬请期待'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 54-发布成功·审核中。
class PostPublishSuccessScreen extends StatelessWidget {
  const PostPublishSuccessScreen({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return LivePage(
      resizeToAvoidBottomInset: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 70),
            const Icon(Icons.check_circle, size: 84, color: LiveColors.success),
            const SizedBox(height: 18),
            const Text(
              '发布成功',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: LiveColors.textPrimary),
            ),
            const SizedBox(height: 10),
            const Text(
              '作品已提交，审核通过后将在社区公开展示',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: LiveColors.textSecondary),
            ),
            const Spacer(),
            PrimaryButton(
              label: '查看我的作品',
              onTap: () => LiveRoutes.pushId(context, RoutePaths.postDetail, post.id),
            ),
            const SizedBox(height: 12),
            OutlineButton(
              label: '返回社区',
              onTap: () => LiveRoutes.switchTab(context, 1),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// 图片区：空态虚线占位 / 选中图片横向排列。
class _ImageArea extends StatelessWidget {
  const _ImageArea({
    required this.images,
    required this.uploading,
    required this.onPick,
    required this.onRemove,
  });

  final List<String> images;
  final bool uploading;
  final VoidCallback onPick;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: images.isEmpty
          ? InkWell(
              onTap: uploading ? null : onPick,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: LiveColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (uploading)
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 2, color: LiveColors.brand),
                      )
                    else ...[
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 34,
                        color: LiveColors.textTertiary,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '添加图片',
                        style: TextStyle(fontSize: 13, color: LiveColors.textTertiary),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final u in images)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 120,
                            height: 160,
                            child: NetImage(url: u),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: GestureDetector(
                            onTap: () => onRemove(u),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (images.length < 9)
                  InkWell(
                    onTap: uploading ? null : onPick,
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        color: LiveColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: uploading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: LiveColors.brand),
                              ),
                            )
                          : const Icon(Icons.add, size: 28, color: LiveColors.textTertiary),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: LiveColors.divider)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: LiveColors.textPrimary),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: onTap == null ? LiveColors.textTertiary : LiveColors.textPrimary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.6,
                color: onTap == null ? LiveColors.textTertiary : LiveColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 社区搜索：作品关键词 / 用户手机号
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryCtrl = TextEditingController();
  String _tab = 'all'; // all / user / topic
  List<Post> _posts = [];
  List<User> _users = [];
  final List<String> _history = [];
  int _hotIndex = 0;
  static const _hotPool = ['拼豆', '星空图', '手作阿周', '奶油胶', '新手教程', '七夕派对'];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final q = _queryCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _history.remove(q);
      _history.insert(0, q);
    });
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_tab == 'user') {
        final users = await UserService.instance.searchByPhone(q);
        if (mounted) setState(() => _users = users);
      } else {
        final posts = await CommunityService.instance.latest(q: q);
        if (mounted) setState(() => _posts = posts.items);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> get _hotSearches {
    return [
      for (var i = 0; i < 4; i++)
        _hotPool[(_hotIndex + i) % _hotPool.length],
    ];
  }

  void _searchHot(String word) {
    _queryCtrl.text = word;
    _search();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _queryCtrl.text.trim().isNotEmpty;
    return LivePage(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: TextField(
              controller: _queryCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '搜索作品 / 视频 / 用户 / 话题',
                prefixIcon: const Icon(Icons.search, color: LiveColors.textTertiary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: LiveColors.brand),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Row(
              children: [
                for (final t in [
                  ('all', '综合'),
                  ('user', '用户'),
                  ('topic', '话题'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _Seg(
                      label: t.$2,
                      selected: _tab == t.$1,
                      onTap: () => setState(() => _tab = t.$1),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _search)
                    : !hasQuery
                        ? _SearchLanding(
                            history: _history,
                            hotSearches: _hotSearches,
                            onSearch: _searchHot,
                            onClearHistory: () => setState(_history.clear),
                            onShuffle: () =>
                                setState(() => _hotIndex = (_hotIndex + 2) % _hotPool.length),
                          )
                        : _tab == 'user'
                        ? _users.isEmpty
                            ? const EmptyView(text: '输入手机号搜索用户')
                            : ListView.separated(
                                padding: const EdgeInsets.all(18),
                                itemCount: _users.length,
                                separatorBuilder: (_, __) => const Divider(height: 1, color: LiveColors.divider),
                                itemBuilder: (_, i) => _UserRow(
                                  user: _users[i],
                                  onTap: () => LiveRoutes.pushId(
                                    context,
                                    RoutePaths.userDetail,
                                    _users[i].id,
                                  ),
                                ),
                              )
                        : _posts.isEmpty
                            ? const EmptyView(text: '输入关键词搜索作品')
                            : ListView.separated(
                                padding: const EdgeInsets.all(18),
                                itemCount: _posts.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 14),
                                itemBuilder: (_, i) => PostCard(
                                  post: _posts[i],
                                  onTap: () => LiveRoutes.pushId(
                                    context,
                                    RoutePaths.postDetail,
                                    _posts[i].id,
                                  ),
                                  onAuthorTap: () => LiveRoutes.pushId(
                                    context,
                                    RoutePaths.userDetail,
                                    _posts[i].userId,
                                  ),
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}

class _SearchLanding extends StatelessWidget {
  const _SearchLanding({
    required this.history,
    required this.hotSearches,
    required this.onSearch,
    required this.onClearHistory,
    required this.onShuffle,
  });

  final List<String> history;
  final List<String> hotSearches;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearHistory;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        if (history.isNotEmpty) ...[
          Row(
            children: [
              const Text('搜索历史',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary)),
              const Spacer(),
              InkWell(
                onTap: onClearHistory,
                child: const Text('清空', style: TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: history
                .map((h) => _HistoryChip(label: h, onTap: () => onSearch(h)))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            const Text('热门搜索',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary)),
            const Spacer(),
            InkWell(
              onTap: onShuffle,
              child: const Text('换一批', style: TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: hotSearches
              .map((h) => _HistoryChip(label: h, onTap: () => onSearch(h)))
              .toList(),
        ),
      ],
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: LiveColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12.6, color: LiveColors.textPrimary)),
      ),
    );
  }
}

/// 50-话题频道页。
class TopicChannelScreen extends StatefulWidget {
  const TopicChannelScreen({super.key, this.channelTag = '#手作'});

  final String channelTag;

  @override
  State<TopicChannelScreen> createState() => _TopicChannelScreenState();
}

class _TopicChannelScreenState extends State<TopicChannelScreen> {
  List<Post> _posts = [];
  bool _followed = false;
  bool _hot = false;
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
      final page = await CommunityService.instance.latest(
        channel: widget.channelTag,
      );
      if (mounted) setState(() => _posts = page.items);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _hot
        ? ([..._posts]..sort((a, b) => b.likeCount.compareTo(a.likeCount)))
        : _posts;
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '话题详情'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.all(18),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: LiveColors.brandLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.channelTag,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: LiveColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '3.2k 帖子 · 1.8w 关注',
                                    style: TextStyle(fontSize: 12, color: LiveColors.textSecondary),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlineButton(
                                          label: _followed ? '已关注' : '关注话题',
                                          height: 42,
                                          onTap: () {
                                            setState(() => _followed = !_followed);
                                            showLiveSnack(
                                              context,
                                              _followed ? '已关注话题' : '已取消关注',
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: PrimaryButton(
                                          label: '参与发布',
                                          height: 42,
                                          onTap: () => LiveRoutes.push(
                                            context,
                                            RoutePaths.postPublish,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                for (final t in [
                                  ('latest', '最新'),
                                  ('hot', '热门'),
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: InkWell(
                                      onTap: () => setState(() => _hot = t.$1 == 'hot'),
                                      child: Text(
                                        t.$2,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: (_hot == (t.$1 == 'hot'))
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: (_hot == (t.$1 == 'hot'))
                                              ? LiveColors.textPrimary
                                              : LiveColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (shown.isEmpty)
                              const EmptyView(text: '该话题下暂无内容')
                            else
                              ...shown.map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: PostCard(
                                    post: p,
                                    onTap: () => LiveRoutes.pushId(
                                      context,
                                      RoutePaths.postDetail,
                                      p.id,
                                    ),
                                    onAuthorTap: () => LiveRoutes.pushId(
                                      context,
                                      RoutePaths.userDetail,
                                      p.userId,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? LiveColors.brand : LiveColors.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : LiveColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Avatar(url: user.avatar, name: user.nickname, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: LiveColors.textPrimary)),
                  Text(user.phone,
                      style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: LiveColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
