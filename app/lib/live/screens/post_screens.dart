import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

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
                                      label: fmtCount(_post!.likeCount),
                                      color: _liked ? LiveColors.danger : LiveColors.textSecondary,
                                      onTap: _toggleLike,
                                    ),
                                    _DetailAction(
                                      icon: _collected ? Icons.star : Icons.star_border,
                                      label: fmtCount(_post!.collectCount),
                                      color: _collected ? LiveColors.warning : LiveColors.textSecondary,
                                      onTap: _toggleCollect,
                                    ),
                                    _DetailAction(
                                      icon: Icons.share_outlined,
                                      label: fmtCount(_post!.shareCount),
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
    if (_uploading) return;
    final remaining = 9 - _images.length;
    if (remaining <= 0) {
      showLiveSnack(context, '最多选择 9 张图片');
      return;
    }
    // 打开设计稿 41-照片选择面板：拍摄 + 9 宫格多选 + 已选计数 + 预览/完成。
    final picked = await showModalBottomSheet<List<_SelectedPhoto>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PhotoPickerSheet(maxCount: remaining),
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    setState(() => _uploading = true);
    try {
      for (final f in picked) {
        final bytes = await f.bytes();
        final url = await UploadService.instance.uploadImage(
          bytes,
          f.filename,
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('所在位置'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入位置，如：上海 · 徐汇'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('话题'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '多个话题用空格分隔，如 #拼豆 #手作'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
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
                    onTap: _uploading ? null : _pickImages,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 56),
            // 黑色圆形对勾（对齐 Pixso 54-发布成功）
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              '发布成功',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: LiveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '作品已提交审核，审核通过后将展示在社区',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: LiveColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // 审核状态卡（已提交 → 审核中 → 已上架）
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LiveColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        '审核状态',
                        style: TextStyle(
                          fontSize: 13,
                          color: LiveColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF4F4F6), Color(0xFFECECEF)],
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: const Text(
                            '审核中',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: LiveColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _StepNode(
                          icon: Icons.check,
                          label: '已提交',
                          done: true,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: Color(0xFF141414),
                        ),
                      ),
                      Expanded(
                        child: _StepNode(
                          icon: Icons.schedule,
                          label: '审核中',
                          done: true,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: LiveColors.divider,
                        ),
                      ),
                      Expanded(
                        child: _StepNode(
                          icon: Icons.local_fire_department_outlined,
                          label: '已上架',
                          done: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '一般 5 分钟内完成审核，可在「我的内容」查看状态',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: LiveColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: '查看我的作品',
              color: Colors.black,
              textColor: Colors.white,
              onTap: () => LiveRoutes.pushId(context, RoutePaths.postDetail, post.id),
            ),
            const SizedBox(height: 12),
            // 返回社区：浅灰幽灵按钮（对齐设计稿 btn-ghost）
            SizedBox(
              height: 52,
              child: Material(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => LiveRoutes.switchTab(context, 1),
                  child: const Center(
                    child: Text(
                      '返回社区',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: LiveColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// 审核进度节点：黑色圆形图标 + 状态文字（对齐 Pixso 54-发布成功）。
class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.icon,
    required this.label,
    required this.done,
  });

  final IconData icon;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? const Color(0xFF141414) : LiveColors.card,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: done ? Colors.white : LiveColors.textTertiary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: done ? LiveColors.textPrimary : LiveColors.textTertiary,
          ),
        ),
      ],
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

/// 社区搜索：作品关键词 / 用户用户名
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
        final users = await UserService.instance.searchByUsername(q);
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
                            ? const EmptyView(text: '输入用户名搜索用户')
                            : ListView.separated(
                                padding: const EdgeInsets.all(18),
                                itemCount: _users.length,
                                separatorBuilder: (_, _) => const Divider(height: 1, color: LiveColors.divider),
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
                                separatorBuilder: (_, _) => const SizedBox(height: 14),
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
                  Text('@${user.username ?? ''}',
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

// ===== 发布作品-照片选择面板（对齐 Pixso 41-弹窗-照片选择）=====

/// 选中图片的统一封装：相册图片（AssetEntity）或拍照（XFile）。
class _SelectedPhoto {
  _SelectedPhoto.asset(AssetEntity asset)
      : _asset = asset,
        _xfile = null;
  _SelectedPhoto.camera(XFile xfile)
      : _asset = null,
        _xfile = xfile;

  final AssetEntity? _asset;
  final XFile? _xfile;

  AssetEntity? get asset => _asset;

  bool sameAsset(AssetEntity a) => _asset?.id == a.id;

  Future<List<int>> bytes() async {
    if (_xfile != null) return _xfile.readAsBytes();
    final f = await _asset!.originFile;
    return f?.readAsBytes() ?? <int>[];
  }

  String get filename {
    if (_xfile != null) {
      final name = _xfile.name;
      return name.isEmpty
          ? 'post_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : name;
    }
    return _asset!.title ??
        'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}

/// 照片选择底部面板：拍摄 + 3 列宫格多选 + 已选计数 + 预览/完成。
class PhotoPickerSheet extends StatefulWidget {
  const PhotoPickerSheet({super.key, required this.maxCount});

  final int maxCount;

  @override
  State<PhotoPickerSheet> createState() => _PhotoPickerSheetState();
}

class _PhotoPickerSheetState extends State<PhotoPickerSheet> {
  final List<AssetEntity> _assets = [];
  final List<_SelectedPhoto> _selected = [];
  final _scrollCtrl = ScrollController();
  AssetPathEntity? _path;
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _takingPhoto = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (!_loading &&
          _hasMore &&
          _scrollCtrl.position.pixels >
              _scrollCtrl.position.maxScrollExtent - 240) {
        _loadMore();
      }
    });
    _init();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final state = await PhotoManager.requestPermissionExtend();
      if (!state.hasAccess) {
        if (mounted) setState(() => _error = '需要相册权限才能选择图片');
        return;
      }
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        // 按创建时间倒序（从现在到以前），保证相册第一张是最新的照片。
        // 不传该条件时各平台默认排序不一致（Android 常为旧图在前）。
        filterOption: FilterOptionGroup(
          orders: const [
            OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );
      if (mounted) _path = paths.isNotEmpty ? paths.first : null;
      await _loadMore(reset: true);
    } catch (_) {
      if (mounted) setState(() => _error = '读取相册失败');
    }
  }

  Future<void> _loadMore({bool reset = false}) async {
    final path = _path;
    if (path == null) {
      if (mounted && reset) setState(() => _error = '相册中没有图片');
      return;
    }
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final list = await path.getAssetListPaged(page: _page, size: 60);
      if (!mounted) return;
      setState(() {
        if (reset) _assets.clear();
        _assets.addAll(list);
        _page += 1;
        _hasMore = list.length == 60;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '读取相册失败';
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_takingPhoto || _selected.length >= widget.maxCount) return;
    setState(() => _takingPhoto = true);
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (x != null && mounted) {
        setState(() => _selected.add(_SelectedPhoto.camera(x)));
      }
    } catch (e) {
      if (mounted) showLiveSnack(context, '拍照失败：$e');
    } finally {
      if (mounted) setState(() => _takingPhoto = false);
    }
  }

  void _toggle(AssetEntity a) {
    if (_selected.any((p) => p.sameAsset(a))) {
      setState(() => _selected.removeWhere((p) => p.sameAsset(a)));
    } else if (_selected.length < widget.maxCount) {
      setState(() => _selected.add(_SelectedPhoto.asset(a)));
    } else {
      showLiveSnack(context, '最多选择 ${widget.maxCount} 张图片');
    }
  }

  Future<void> _preview() async {
    if (_selected.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: _selected.length,
              itemBuilder: (_, i) => Center(
                child: FutureBuilder<List<int>>(
                  future: _selected[i].bytes(),
                  builder: (_, snap) {
                    final data = snap.data;
                    if (data == null) {
                      return const CircularProgressIndicator(
                        color: Colors.white54,
                      );
                    }
                    return Image.memory(
                      Uint8List.fromList(data),
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selected.length;
    final gridHeight = math.min(
      MediaQuery.of(context).size.height * 0.42,
      360.0,
    );
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: LiveColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E4E8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text(
                  '从相册选择',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: LiveColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '已选 $selectedCount / ${widget.maxCount}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: LiveColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null)
              SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: LiveColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: gridHeight,
                child: GridView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.only(bottom: 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.12,
                  ),
                  itemCount: _assets.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return _PhotoCell(
                        child: InkWell(
                          onTap: _takingPhoto ? null : _takePhoto,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_takingPhoto)
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: LiveColors.textSecondary,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.photo_camera_outlined,
                                    size: 24,
                                    color: LiveColors.textSecondary,
                                  ),
                                const SizedBox(height: 5),
                                const Text(
                                  '拍摄',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: LiveColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    final asset = _assets[i - 1];
                    final selected =
                        _selected.any((p) => p.sameAsset(asset));
                    return _PhotoCell(
                      child: GestureDetector(
                        onTap: () => _toggle(asset),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _AssetThumb(asset: asset),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF141414)
                                      : Colors.white.withValues(alpha: 0.92),
                                  shape: BoxShape.circle,
                                  border: selected
                                      ? null
                                      : Border.all(
                                          color: const Color(0x33000000),
                                        ),
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check,
                                        size: 13,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            // 底部：已选缩略图 + 预览 + 完成
            Container(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: LiveColors.divider),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var i = 0; i < selectedCount && i < 5; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: _SelectedThumb(photo: _selected[i]),
                                ),
                              ),
                            ),
                          if (selectedCount > 5)
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${selectedCount - 5}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SheetButton(
                    label: '预览',
                    ghost: true,
                    onTap: _preview,
                  ),
                  const SizedBox(width: 10),
                  _SheetButton(
                    label: selectedCount > 0 ? '完成 ($selectedCount)' : '完成',
                    ghost: false,
                    onTap: selectedCount > 0
                        ? () => Navigator.pop(context, _selected)
                        : null,
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

/// 宫格单元：圆角裁剪容器。
class _PhotoCell extends StatelessWidget {
  const _PhotoCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: child);
  }
}

/// 相册缩略图（photo_manager 按尺寸生成，网格用）。
class _AssetThumb extends StatelessWidget {
  const _AssetThumb({required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        const ThumbnailSize.square(240),
        quality: 85,
      ),
      builder: (_, snap) {
        final data = snap.data;
        if (data == null) return Container(color: LiveColors.card);
        return Image.memory(data, fit: BoxFit.cover);
      },
    );
  }
}

/// 底部已选缩略图（相册用 thumbnail，拍照用原文件字节）。
class _SelectedThumb extends StatelessWidget {
  const _SelectedThumb({required this.photo});

  final _SelectedPhoto photo;

  @override
  Widget build(BuildContext context) {
    final asset = photo.asset;
    if (asset != null) {
      return FutureBuilder<Uint8List?>(
        future: asset.thumbnailDataWithSize(
          const ThumbnailSize.square(160),
          quality: 85,
        ),
        builder: (_, snap) {
          final data = snap.data;
          if (data == null) return Container(color: LiveColors.card);
          return Image.memory(data, fit: BoxFit.cover);
        },
      );
    }
    return FutureBuilder<List<int>>(
      future: photo.bytes(),
      builder: (_, snap) {
        final data = snap.data;
        if (data == null) return Container(color: LiveColors.card);
        return Image.memory(Uint8List.fromList(data), fit: BoxFit.cover);
      },
    );
  }
}

/// 底部按钮：预览（浅灰）/ 完成（黑底白字）。
class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.ghost,
    required this.onTap,
  });

  final String label;
  final bool ghost;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ghost ? const Color(0xFFF7F7F8) : const Color(0xFF141414),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ghost ? LiveColors.textPrimary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
