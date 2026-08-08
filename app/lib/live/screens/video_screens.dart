import 'package:flutter/material.dart' hide Page;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../api/api_client.dart';
import '../../api/api_config.dart';
import '../../api/auth_store.dart';
import '../../api/content_services.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';
import 'profile_screens.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key, this.root = false});

  final bool root;

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

/// 抖音风全屏竖滑信息流（对齐 Pixso 16-Reels 设计）。
class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageCtrl = PageController();
  List<Video> _videos = [];
  final Set<int> _liked = {};
  final Set<int> _followed = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await VideoService.instance.recommend();
      final liked = await VideoService.instance
          .batchLiked(page.items.map((v) => v.id).toList());
      if (mounted) {
        setState(() {
          _videos = page.items;
          _liked
            ..clear()
            ..addAll(liked.entries.where((e) => e.value).map((e) => e.key));
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleLike(Video video) async {
    try {
      final liked = await VideoService.instance.toggleLike(video.id);
      if (mounted) {
        setState(() {
          if (liked) {
            _liked.add(video.id);
          } else {
            _liked.remove(video.id);
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _toggleFollow(Video video) async {
    final targetId = video.userId;
    try {
      final status = await FollowService.instance.setFollow(targetId, true);
      if (mounted) {
        setState(() {
          if (status.following) {
            _followed.add(targetId);
          } else {
            _followed.remove(targetId);
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _share(Video video) async {
    VideoService.instance.recordShare(video.id).catchError((_) {});
    showLiveSnack(context, '已复制分享链接（模拟）');
  }

  /// 评论面板：从底部向上滑出（对齐抖音交互）。
  Future<void> _openComments(Video video) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LiveColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _CommentSheet(video: video),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      fullBleed: true,
      backgroundColor: Colors.black,
      child: _loading
          ? const LoadingView()
          : _error != null
              ? Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18, 12, 0, 0),
                      child: _ReelsHeader(),
                    ),
                    Expanded(child: ErrorView(message: _error!, onRetry: _load)),
                  ],
                )
              : _videos.isEmpty
                  ? const EmptyView(text: '暂无视频，去发布第一条吧', icon: Icons.videocam_outlined)
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          scrollDirection: Axis.vertical,
                          itemCount: _videos.length,
                          onPageChanged: (i) {
                            final v = _videos[i];
                            VideoService.instance.recordView(v.id).catchError((_) {});
                            VideoService.instance.addHistory(v.id).catchError((_) {});
                          },
                          itemBuilder: (_, i) {
                            final video = _videos[i];
                            final isSelf = video.userId == AuthStore.instance.userId;
                            return _ReelPage(
                              video: video,
                              liked: _liked.contains(video.id),
                              followed: _followed.contains(video.userId),
                              hideFollow: isSelf,
                              onTapAuthor: () => LiveRoutes.push(
                                context,
                                UserProfileScreen(userId: video.userId),
                              ),
                              onLike: () => _toggleLike(video),
                              onComment: () => _openComments(video),
                              onShare: () => _share(video),
                              onFollow: () => _toggleFollow(video),
                              onOpen: () => LiveRoutes.push(
                                context,
                                VideoDetailScreen(videoId: video.id),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 10, 12, 0),
                              child: Row(
                                children: [
                                  const _ReelsHeader(),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.search, color: Colors.white, size: 26),
                                    onPressed: () => LiveRoutes.push(context, const VideoSearchScreen()),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.videocam, color: Colors.white, size: 26),
                                    onPressed: () => LiveRoutes.push(context, const CaptureScreen()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LiveTabBar(current: 2),
                        ),
                      ],
                    ),
    );
  }
}

class _ReelsHeader extends StatelessWidget {
  const _ReelsHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Reels',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
      ),
    );
  }
}

/// 单条全屏视频页：封面 + 左下作者/文案/音乐 + 右侧操作栏。
class _ReelPage extends StatelessWidget {
  const _ReelPage({
    required this.video,
    required this.liked,
    required this.followed,
    required this.hideFollow,
    required this.onTapAuthor,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onOpen,
  });

  final Video video;
  final bool liked;
  final bool followed;
  final bool hideFollow;
  final VoidCallback onTapAuthor;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback onOpen;

  String get _cover {
    if (video.cover.isNotEmpty) return video.cover;
    if (video.photos.isNotEmpty) return video.photos.first;
    return '';
  }

  String get _caption {
    if (video.title.isNotEmpty) return video.title;
    if (video.content.isNotEmpty) return video.content;
    return '来自 ${video.author?.displayName ?? '手作星球'} 的作品';
  }

  @override
  Widget build(BuildContext context) {
    final author = video.author;
    return GestureDetector(
      onTap: onOpen,
      onDoubleTap: onLike,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(url: _cover),
          // 底部渐变压暗，保证白字可读
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.55, 1],
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          // 左下：作者 + 文案 + 音乐
          Positioned(
            left: 18,
            right: 86,
            bottom: 116,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onTapAuthor,
                  child: Row(
                    children: [
                      Avatar(url: author?.avatar ?? '', name: author?.nickname ?? '', size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '@${author?.displayName ?? '手作星球'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.4,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                ),
                if (video.music.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.music_note, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${video.music} - ${author?.displayName ?? '手作星球'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // 右侧操作栏：头像+关注 / 点赞 / 评论 / 分享
          Positioned(
            right: 10,
            bottom: 130,
            child: Column(
              children: [
                if (!hideFollow) ...[
                  _RailAvatar(
                    avatar: author?.avatar ?? '',
                    name: author?.nickname ?? '',
                    followed: followed,
                    onTap: onTapAuthor,
                    onFollow: onFollow,
                  ),
                  const SizedBox(height: 20),
                ],
                _RailButton(
                  icon: liked ? Icons.favorite : Icons.favorite_border,
                  label: fmtCount(video.likeCount),
                  active: liked,
                  onTap: onLike,
                ),
                const SizedBox(height: 18),
                _RailButton(
                  icon: Icons.mode_comment_outlined,
                  label: fmtCount(video.commentCount),
                  onTap: onComment,
                ),
                const SizedBox(height: 18),
                _RailButton(
                  icon: Icons.share_outlined,
                  label: fmtCount(video.shareCount),
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: active ? LiveColors.danger : Colors.white,
              shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailAvatar extends StatelessWidget {
  const _RailAvatar({
    required this.avatar,
    required this.name,
    required this.followed,
    required this.onTap,
    required this.onFollow,
  });

  final String avatar;
  final String name;
  final bool followed;
  final VoidCallback onTap;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Avatar(url: avatar, name: name, size: 44),
              Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: Center(
                  child: Material(
                    color: followed ? Colors.white24 : LiveColors.danger,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: followed ? null : onFollow,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(
                          followed ? Icons.check : Icons.add,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// 评论底部面板（从下往上滑出）。
class _CommentSheet extends StatefulWidget {
  const _CommentSheet({required this.video});

  final Video video;

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _inputCtrl = TextEditingController();
  List<Comment> _comments = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await VideoService.instance.comments(widget.video.id);
      if (mounted) setState(() => _comments = page.items);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final c = await VideoService.instance.addComment(widget.video.id, text);
      if (mounted) {
        _inputCtrl.clear();
        setState(() => _comments = [c, ..._comments]);
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final caption = video.title.isNotEmpty ? video.title : video.content;
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: LiveColors.textTertiary.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Text(
                    '评论 ${video.commentCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: LiveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                child: Row(
                  children: [
                    const Icon(Icons.music_note, size: 14, color: LiveColors.brand),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: LiveColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 16, color: LiveColors.divider),
            Expanded(
              child: _loading
                  ? const LoadingView()
                  : _error != null
                      ? ErrorView(message: _error!, onRetry: _load)
                      : _comments.isEmpty
                          ? const EmptyView(
                              text: '还没有评论，来抢沙发',
                              icon: Icons.mode_comment_outlined,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              itemCount: _comments.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, color: LiveColors.divider),
                              itemBuilder: (_, i) => _VideoCommentTile(
                                comment: _comments[i],
                              ),
                            ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        decoration: InputDecoration(
                          hintText: '说点什么…',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: LiveColors.brand,
                              ),
                            )
                          : const Icon(Icons.send, color: LiveColors.brand),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReelCard extends StatelessWidget {
  const _ReelCard({required this.video, required this.onTap, required this.onAuthorTap});

  final Video video;
  final VoidCallback onTap;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: LiveColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LiveColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 0.8,
                  child: NetImage(url: video.cover.isEmpty ? (video.photos.isNotEmpty ? video.photos.first : '') : video.cover),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, size: 34, color: Colors.white),
                ),
                if (video.duration > 0)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(fmtDuration(video.duration),
                          style: const TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onAuthorTap,
                    child: Row(
                      children: [
                        Avatar(url: video.author?.avatar ?? '', name: video.author?.nickname ?? '', size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            video.author?.displayName ?? '用户',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.title.isEmpty ? video.content : video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LiveColors.textPrimary, height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 14, color: LiveColors.danger),
                      const SizedBox(width: 2),
                      Text('${fmtCount(video.likeCount)}',
                          style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.chat_bubble_outline, size: 14, color: LiveColors.textSecondary),
                      const SizedBox(width: 2),
                      Text('${fmtCount(video.commentCount)}',
                          style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary)),
                      const Spacer(),
                      Text('播放 ${fmtCount(video.viewCount)}',
                          style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary)),
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

class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({super.key, required this.videoId});

  final int videoId;

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  Video? _video;
  bool _liked = false;
  List<Comment> _comments = [];
  bool _loading = true;
  String? _error;
  bool _hot = false;
  final _commentCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
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
      final video = await VideoService.instance.detail(widget.videoId);
      final liked = await VideoService.instance.isLiked(widget.videoId);
      final comments = await VideoService.instance.comments(widget.videoId);
      VideoService.instance.recordView(widget.videoId).catchError((_) {});
      VideoService.instance.addHistory(widget.videoId).catchError((_) {});
      if (mounted) {
        setState(() {
          _video = video;
          _liked = liked;
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
      final liked = await VideoService.instance.toggleLike(widget.videoId);
      if (mounted) {
        setState(() {
          _liked = liked;
          final v = _video;
          if (v != null) {
            _video = Video(
              id: v.id,
              userId: v.userId,
              title: v.title,
              content: v.content,
              cover: v.cover,
              videoUrl: v.videoUrl,
              photos: v.photos,
              likeCount: v.likeCount + (liked ? 1 : -1),
              commentCount: v.commentCount,
              shareCount: v.shareCount,
              viewCount: v.viewCount,
              createdAt: v.createdAt,
              author: v.author,
              liked: liked,
            );
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final c = await VideoService.instance.addComment(widget.videoId, text);
      if (mounted) {
        _commentCtrl.clear();
        setState(() => _comments = [c, ..._comments]);
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _openPlayer() {
    final v = _video;
    if (v == null) return;
    LiveRoutes.push(context, VideoPlayerPage(video: v));
  }

  @override
  Widget build(BuildContext context) {
    final shownComments = _hot
        ? ([..._comments]
          ..sort((a, b) => b.likeCount.compareTo(a.likeCount)))
        : _comments;
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '视频详情'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _video == null
                        ? const EmptyView()
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView(
                              padding: const EdgeInsets.all(18),
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: GestureDetector(
                                    onTap: _openPlayer,
                                    child: AspectRatio(
                                      aspectRatio: 0.8,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          NetImage(
                                            url: _video!.cover.isEmpty
                                                ? (_video!.photos.isNotEmpty ? _video!.photos.first : '')
                                                : _video!.cover,
                                          ),
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: const BoxDecoration(
                                                color: Colors.black38,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
                                            ),
                                          ),
                                          if (_video!.duration > 0)
                                            Positioned(
                                              right: 8,
                                              bottom: 8,
                                              child: Text(fmtDuration(_video!.duration),
                                                  style: const TextStyle(fontSize: 12, color: Colors.white)),
                                            ),
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black38,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                onPressed: _openPlayer,
                                                icon: const Icon(Icons.fullscreen, size: 20, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () => LiveRoutes.push(
                                    context,
                                    UserProfileScreen(userId: _video!.userId),
                                  ),
                                  child: Row(
                                    children: [
                                      Avatar(
                                        url: _video!.author?.avatar ?? '',
                                        name: _video!.author?.nickname ?? '',
                                        size: 36,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _video!.author?.displayName ?? '用户',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
                                        ),
                                      ),
                                      if (_video!.music.isNotEmpty)
                                        const TagChip(label: '♪ 配乐'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _video!.title.isEmpty ? _video!.content : _video!.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: LiveColors.textPrimary, height: 1.4),
                                ),
                                if (_video!.content.isNotEmpty && _video!.title.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(_video!.content,
                                      style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary, height: 1.45)),
                                ],
                                if (_video!.tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: _video!.tags
                                        .map((t) => Text(t.startsWith('#') ? t : '#$t',
                                            style: const TextStyle(fontSize: 13, color: LiveColors.brand)))
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _DetailLikeButton(
                                      liked: _liked,
                                      count: _video!.likeCount,
                                      onTap: _toggleLike,
                                    ),
                                    const SizedBox(width: 18),
                                    Row(
                                      children: [
                                        const Icon(Icons.share_outlined, size: 19, color: LiveColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text('${fmtCount(_video!.shareCount)}',
                                            style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text('浏览 ${fmtCount(_video!.viewCount)}',
                                        style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
                                  ],
                                ),
                                const Divider(height: 26, color: LiveColors.divider),
                                Row(
                                  children: [
                                    Text('评论 ${_video!.commentCount}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary)),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () => setState(() => _hot = !_hot),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _hot
                                              ? LiveColors.textPrimary
                                              : LiveColors.card,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '最热',
                                          style: TextStyle(
                                            fontSize: 11.6,
                                            fontWeight: FontWeight.w600,
                                            color: _hot
                                                ? Colors.white
                                                : LiveColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_comments.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: EmptyView(text: '还没有评论', icon: Icons.mode_comment_outlined),
                                  )
                                else
                                  ...shownComments
                                      .map((c) => _VideoCommentTile(comment: c)),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
          ),
          SafeArea(
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
                    onPressed: _sending ? null : _sendComment,
                    icon: const Icon(Icons.send, color: LiveColors.brand),
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

/// 56-视频播放页：全屏播放器（时间 / 倍速 / 标题 / 作者）。
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.video});

  final Video video;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  bool _showControls = true;
  double _speed = 1.0;

  static const _speeds = [0.5, 1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    VideoService.instance.recordView(widget.video.id).catchError((_) {});
    VideoService.instance.addHistory(widget.video.id).catchError((_) {});
    final url = widget.video.videoUrl.isNotEmpty
        ? widget.video.videoUrl
        : (widget.video.photos.isNotEmpty
            ? widget.video.photos.first
            : widget.video.cover);
    if (url.isEmpty) {
      _failed = true;
      return;
    }
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(ApiConfig.resolve(url)),
    );
    _controller!.addListener(() {
      if (mounted) setState(() {});
    });
    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _controller!.play();
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _toggleSpeed() {
    final idx = _speeds.indexOf(_speed);
    _speed = _speeds[(idx + 1) % _speeds.length];
    _controller?.setPlaybackSpeed(_speed);
    setState(() {});
  }

  String get _cover {
    if (widget.video.cover.isNotEmpty) return widget.video.cover;
    if (widget.video.photos.isNotEmpty) return widget.video.photos.first;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.video.title.isNotEmpty
        ? widget.video.title
        : widget.video.content;
    final authorLine =
        '@${widget.video.author?.displayName ?? '手作星球'}'
        '${title.isNotEmpty ? ' · $title' : ''}';
    final pos = _controller?.value.position ?? Duration.zero;
    final total = _controller?.value.duration ?? Duration.zero;
    final playing = _controller?.value.isPlaying ?? false;
    return LivePage(
      fullBleed: true,
      backgroundColor: Colors.black,
      child: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_ready && !_failed)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else if (_failed)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 330,
                      child: NetImage(url: _cover),
                    ),
                    const SizedBox(height: 10),
                    const Icon(Icons.play_circle_outline, size: 44, color: Colors.white70),
                    const SizedBox(height: 8),
                    const Text(
                      '视频暂时无法播放，仅展示封面',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 330,
                      child: NetImage(url: _cover),
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            if (_showControls) ...[
              // 顶部：返回 + 标题/作者
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 10, 18, 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.video.title.isNotEmpty
                                  ? widget.video.title
                                  : '视频播放',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authorLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
              // 底部：时间 / 倍速
              if (_ready && !_failed)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final c = _controller;
                            if (c == null) return;
                            if (playing) {
                              c.pause();
                            } else {
                              c.play();
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _fmt(pos),
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _toggleSpeed,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_speed.toStringAsFixed(1)}x',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '/ ${_fmt(total)}',
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: () => LiveRoutes.push(
                            context,
                            VideoLandscapePage(video: widget.video),
                          ),
                          icon: const Icon(Icons.fullscreen, size: 22, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 59-视频横屏全屏播放。
class VideoLandscapePage extends StatefulWidget {
  const VideoLandscapePage({super.key, required this.video});

  final Video video;

  @override
  State<VideoLandscapePage> createState() => _VideoLandscapePageState();
}

class _VideoLandscapePageState extends State<VideoLandscapePage> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  double _speed = 1.0;
  static const _speeds = [0.5, 1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    final url = widget.video.videoUrl.isNotEmpty
        ? widget.video.videoUrl
        : widget.video.cover;
    if (url.isEmpty) {
      _failed = true;
      return;
    }
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(ApiConfig.resolve(url)),
    );
    _controller!.addListener(() {
      if (mounted) setState(() {});
    });
    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _controller!.play();
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _toggleSpeed() {
    final idx = _speeds.indexOf(_speed);
    _speed = _speeds[(idx + 1) % _speeds.length];
    _controller?.setPlaybackSpeed(_speed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pos = _controller?.value.position ?? Duration.zero;
    final total = _controller?.value.duration ?? Duration.zero;
    final playing = _controller?.value.isPlaying ?? false;
    return LivePage(
      fullBleed: true,
      backgroundColor: Colors.black,
      child: RotatedBox(
        quarterTurns: 1,
        child: SizedBox(
          width: 956,
          height: 440,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_ready && !_failed)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                )
              else if (_failed)
                const Center(
                  child: Text(
                    '视频暂时无法播放',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          final c = _controller;
                          if (c == null) return;
                          if (playing) {
                            c.pause();
                          } else {
                            c.play();
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      Text(
                        _fmt(pos),
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _toggleSpeed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_speed.toStringAsFixed(1)}x',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '/ ${_fmt(total)}',
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.fullscreen_exit,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 18,
                child: SafeArea(
                  bottom: false,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLikeButton extends StatelessWidget {
  const _DetailLikeButton({required this.liked, required this.count, required this.onTap});

  final bool liked;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(liked ? Icons.favorite : Icons.favorite_border,
              size: 19, color: liked ? LiveColors.danger : LiveColors.textSecondary),
          const SizedBox(width: 4),
          Text('${fmtCount(count)}',
              style: TextStyle(fontSize: 13, color: liked ? LiveColors.danger : LiveColors.textSecondary)),
        ],
      ),
    );
  }
}

class _VideoCommentTile extends StatelessWidget {
  const _VideoCommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
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
                Text(comment.content,
                    style: const TextStyle(fontSize: 13, color: LiveColors.textPrimary, height: 1.4)),
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

/// 18-拍摄页（抖音风）：拍一张封面后进入发布视频。
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool _taking = false;

  Future<void> _takePhoto() async {
    setState(() => _taking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final url = await UploadService.instance.uploadImage(
        bytes,
        picked.name.isEmpty ? 'capture_${DateTime.now().millisecondsSinceEpoch}.jpg' : picked.name,
        folder: 'post',
      );
      if (mounted) {
        LiveRoutes.push(context, VideoPublishScreen(initialCover: url));
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } catch (e) {
      if (mounted) showLiveSnack(context, '拍摄失败：$e');
    } finally {
      if (mounted) setState(() => _taking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      fullBleed: true,
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 顶部工具
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final t in ['美化', '特效', '倒计时', '滤镜', '直播'])
                    InkWell(
                      onTap: () => showLiveSnack(context, '$t 敬请期待'),
                      child: Text(
                        t,
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 取景占位
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_camera_outlined, size: 64, color: Colors.white38),
                const SizedBox(height: 10),
                const Text(
                  '相机预览',
                  style: TextStyle(fontSize: 13, color: Colors.white54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('视频', style: TextStyle(fontSize: 12, color: Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    const Text('拍照', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          // 底部：最近 / 选音乐 + 快门
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => LiveRoutes.push(context, const MusicPickerScreen()),
                      child: const Column(
                        children: [
                          Icon(Icons.music_note, size: 20, color: Colors.white),
                          SizedBox(height: 2),
                          Text('选音乐', style: TextStyle(fontSize: 10, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _taking ? null : _takePhoto,
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: _taking
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '最近',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
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

class VideoPublishScreen extends StatefulWidget {
  const VideoPublishScreen({super.key, this.initialCover = ''});

  final String initialCover;

  @override
  State<VideoPublishScreen> createState() => _VideoPublishScreenState();
}

class _VideoPublishScreenState extends State<VideoPublishScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  Music? _music;
  String _cover = '';
  bool _uploading = false;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _cover = widget.initialCover;
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _contentCtrl, _tagsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCover() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      setState(() => _uploading = true);
      final bytes = await picked.readAsBytes();
      final url = await UploadService.instance.uploadImage(bytes, picked.name, folder: 'post');
      if (mounted) setState(() => _cover = url);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } catch (e) {
      if (mounted) showLiveSnack(context, '选择封面失败：$e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _publish() async {
    if (_titleCtrl.text.trim().isEmpty && _contentCtrl.text.trim().isEmpty) {
      showLiveSnack(context, '请输入标题或文案');
      return;
    }
    setState(() => _publishing = true);
    try {
      final body = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'cover': _cover,
        if (_music != null) ...{
          'music': _music!.title,
          'musicId': _music!.id,
        },
        'tags': _tagsCtrl.text
            .split(RegExp(r'[，#\s]+'))
            .where((s) => s.isNotEmpty)
            .map((s) => s.startsWith('#') ? s : '#$s')
            .toList(),
      };
      final video = await VideoService.instance.create(body);
      if (!mounted) return;
      showLiveSnack(context, '发布成功');
      LiveRoutes.push(context, VideoDetailScreen(videoId: video.id));
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
            title: '发布视频',
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
              padding: const EdgeInsets.all(18),
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: _uploading ? null : _pickCover,
                      child: Container(
                        width: 110,
                        height: 140,
                        decoration: BoxDecoration(
                          color: LiveColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _cover.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_uploading)
                                    const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: LiveColors.brand),
                                    )
                                  else ...[
                                    const Icon(Icons.add_photo_alternate_outlined, size: 28, color: LiveColors.textTertiary),
                                    const SizedBox(height: 6),
                                    const Text('选择封面',
                                        style: TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
                                  ],
                                ],
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  NetImage(url: _cover),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _cover = ''),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('封面（必填建议 9:16）', style: TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              final m = await LiveRoutes.push<Music?>(
                                context,
                                const MusicPickerScreen(),
                              );
                              if (m != null) setState(() => _music = m);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: LiveColors.card,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.music_note, size: 18, color: LiveColors.brand),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _music == null ? '选择配乐' : '${_music!.title} - ${_music!.artist}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: LiveColors.textPrimary),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, size: 16, color: LiveColors.textTertiary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: '标题 / 文案')),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: '视频描述（选填）', alignLabelWithHint: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagsCtrl,
                  decoration: const InputDecoration(hintText: '话题标签，如 #手作 拼豆'),
                ),
                const SizedBox(height: 20),
                const Text(
                  '提示：当前版本发布照片作品（封面 + 配乐），完整视频上传可在后续接入',
                  style: TextStyle(fontSize: 11, color: LiveColors.textTertiary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MusicPickerScreen extends StatefulWidget {
  const MusicPickerScreen({super.key});

  @override
  State<MusicPickerScreen> createState() => _MusicPickerScreenState();
}

class _MusicPickerScreenState extends State<MusicPickerScreen> {
  List<Music> _list = [];
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
      final page = await MusicService.instance.list();
      if (mounted) setState(() => _list = page.items);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          const LiveAppBar(title: '选择音乐'),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _list.isEmpty
                        ? const EmptyView(text: '曲库暂无音乐')
                        : ListView.separated(
                            padding: const EdgeInsets.all(18),
                            itemCount: _list.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: LiveColors.divider),
                            itemBuilder: (_, i) {
                              final m = _list[i];
                              return InkWell(
                                onTap: () => Navigator.of(context).pop(m),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: NetImage(url: m.cover),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(m.title,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LiveColors.textPrimary)),
                                            Text('${m.artist}${m.duration > 0 ? ' · ${fmtDuration(m.duration)}' : ''}',
                                                style: const TextStyle(fontSize: 12, color: LiveColors.textTertiary)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: LiveColors.brandLight,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text('使用',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LiveColors.brand)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class VideoSearchScreen extends StatefulWidget {
  const VideoSearchScreen({super.key});

  @override
  State<VideoSearchScreen> createState() => _VideoSearchScreenState();
}

class _VideoSearchScreenState extends State<VideoSearchScreen> {
  final _ctrl = TextEditingController();
  List<Video> _videos = [];
  String _sort = 'all'; // all / latest / hot
  bool _loading = false;

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    setState(() => _loading = true);
    try {
      final page = await VideoService.instance.recommend(q: q);
      if (mounted) setState(() => _videos = page.items);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Video> get _sorted {
    if (_sort == 'hot') {
      return [..._videos]..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }
    return _videos;
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '搜索视频',
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
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
            child: Row(
              children: [
                for (final t in [
                  ('all', '综合'),
                  ('latest', '最新'),
                  ('hot', '最热'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => setState(() => _sort = t.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _sort == t.$1 ? LiveColors.textPrimary : LiveColors.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          t.$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _sort == t.$1 ? Colors.white : LiveColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) return const LoadingView();
    final list = _sorted;
    if (list.isEmpty) return const EmptyView(text: '输入关键词搜索视频');
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _ReelCard(
        video: list[i],
        onTap: () => LiveRoutes.push(
          context,
          VideoDetailScreen(videoId: list[i].id),
        ),
        onAuthorTap: () => LiveRoutes.push(
          context,
          UserProfileScreen(userId: list[i].userId),
        ),
      ),
    );
  }
}
