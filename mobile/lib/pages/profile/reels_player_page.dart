import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/video_api.dart';
import '../../features/community/domain/community_models.dart';
import '../../features/community/presentation/widgets/video_player_widget.dart';
import '../../widgets/video_interaction_sheets.dart';
import '../short_video_models.dart';

/// Reels 全屏详情页（个人主页）
///
/// 视频作品走真实播放器（加载失败自动回退封面模拟进度）；
/// 照片作品支持多图左右轮播 + 底部分段指示条；
/// 右侧交互栏支持点赞 / 评论 / 分享，内容区双击点赞；
/// 底部展示标题、标签与互动数据。进入时上报一次浏览。
class ReelsPlayerPage extends StatefulWidget {
  const ReelsPlayerPage({super.key, required this.video});

  final ShortVideo video;

  @override
  State<ReelsPlayerPage> createState() => _ReelsPlayerPageState();
}

class _ReelsPlayerPageState extends State<ReelsPlayerPage>
    with SingleTickerProviderStateMixin {
  late bool _liked = widget.video.liked;
  late int _likeCount = widget.video.likeCount;
  late int _commentCount = widget.video.commentCount;
  late int _shareCount = widget.video.shareCount;

  /// 笔记多图轮播
  final PageController _photoCtrl = PageController();
  int _photoIndex = 0;

  /// 点赞弹跳动画
  late final AnimationController _likeAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _likeScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.4,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.4,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 55,
    ),
  ]).animate(_likeAnim);

  /// 双击点赞爱心动画
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _burstScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.5,
        end: 1.3,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 60,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.3,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 40,
    ),
  ]).animate(_burst);

  bool get _isPhoto => widget.video.isPhoto || widget.video.videoUrl.isEmpty;

  /// 展示用图片列表：优先照片，回退封面
  List<String> get _photos {
    final photos = widget.video.photos.where((u) => u.isNotEmpty).toList();
    if (photos.isNotEmpty) return photos;
    if (widget.video.cover.isNotEmpty) return [widget.video.cover];
    return const [];
  }

  @override
  void initState() {
    super.initState();
    VideoApi.recordView(widget.video.id).catchError((_) {});
    VideoApi.addHistory(widget.video.id).catchError((_) {});
  }

  @override
  void dispose() {
    _photoCtrl.dispose();
    _likeAnim.dispose();
    _burst.dispose();
    super.dispose();
  }

  // ==================== 交互 ====================

  void _toggleLike() {
    _likeAnim.forward(from: 0);
    final target = !_liked;
    setState(() {
      _liked = target;
      _likeCount += target ? 1 : -1;
    });
    VideoApi.toggleLike(widget.video.id)
        .then((serverLiked) {
          if (!mounted || serverLiked == _liked) return;
          setState(() {
            _liked = serverLiked;
            _likeCount += serverLiked ? 1 : -1;
          });
        })
        .catchError((_) {
          // 失败回滚
          if (!mounted) return;
          setState(() {
            _liked = widget.video.liked;
            _likeCount = widget.video.likeCount;
          });
        });
  }

  void _onDoubleTap() {
    if (!_liked) _toggleLike();
    _burst.forward(from: 0);
  }

  void _openComments() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoCommentSheet(
        video: widget.video,
        onAdded: () {
          if (mounted) setState(() => _commentCount += 1);
        },
      ),
    );
  }

  void _openShare() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoShareSheet(
        onShared: () {
          VideoApi.recordShare(widget.video.id).catchError((_) {});
          if (mounted) setState(() => _shareCount += 1);
        },
      ),
    );
  }

  // ==================== 构建 ====================

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 内容：笔记多图轮播 / 视频真实播放
          if (_isPhoto)
            _buildPhotoLayer()
          else
            VideoPlayerWidget(
              item: MediaItem(
                type: MediaType.video,
                url: video.videoUrl.isNotEmpty ? video.videoUrl : video.cover,
                duration: video.duration,
                aspectRatio: video.aspectRatio > 0 ? video.aspectRatio : 9 / 16,
              ),
              borderRadius: 0,
              onDoubleTap: _onDoubleTap,
            ),

          // 双击点赞爱心
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _burst,
              builder: (context, _) => Center(
                child: Opacity(
                  opacity: _burst.isAnimating
                      ? (1 - _burst.value).clamp(0.0, 1.0)
                      : 0.0,
                  child: Transform.scale(
                    scale: _burstScale.value,
                    child: const Icon(
                      Icons.favorite,
                      color: Palette.accent,
                      size: 96,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 底部渐变压暗（保证文字可读）
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.72, 1.0],
                    colors: const [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 关闭按钮
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.35),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),

          // 右侧交互栏：点赞 / 评论 / 分享
          Positioned(
            right: 10,
            bottom: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DarkActionItem(
                  icon: ScaleTransition(
                    scale: _likeScale,
                    child: Icon(
                      _liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: _liked ? Palette.accent : Colors.white,
                      size: 34,
                    ),
                  ),
                  label: formatCount(_likeCount),
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 20),
                DarkActionItem(
                  icon: const Icon(
                    Icons.comment_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  label: formatCount(_commentCount),
                  onTap: _openComments,
                ),
                const SizedBox(height: 20),
                DarkActionItem(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  label: formatCount(_shareCount),
                  onTap: _openShare,
                ),
              ],
            ),
          ),

          // 底部信息区
          Positioned(
            left: 14,
            right: 84,
            bottom: 0.2,
            child: SafeArea(
              top: false,
              child: _buildInfo(video),
            ),
          ),

          // 底部进度指示：笔记多图 → 分段白条；单图/视频 → 隐藏（播放器自带进度）
          if (_isPhoto && _photos.length > 1)
            Positioned(
              left: 14,
              right: 14,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        for (var i = 0; i < _photos.length; i++)
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i == _photoIndex
                                    ? Colors.white
                                    : Colors.white30,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 笔记内容层：多图 PageView 轮播，支持双击点赞
  Widget _buildPhotoLayer() {
    final photos = _photos;
    if (photos.isEmpty) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _onDoubleTap,
        child: const ColoredBox(
          color: Color(0xFF181818),
          child: Center(
            child: Icon(Icons.image_outlined, color: Colors.white38, size: 48),
          ),
        ),
      );
    }
    if (photos.length == 1) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _onDoubleTap,
        child: _photoImage(photos.first),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: _onDoubleTap,
      child: PageView.builder(
        controller: _photoCtrl,
        itemCount: photos.length,
        onPageChanged: (i) {
          if (mounted) setState(() => _photoIndex = i);
        },
        itemBuilder: (_, i) => _photoImage(photos[i]),
      ),
    );
  }

  Widget _photoImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFF181818),
        child: Center(
          child: Icon(Icons.image_outlined, color: Colors.white38, size: 48),
        ),
      ),
    );
  }

  /// 底部信息：标题 + 标签
  Widget _buildInfo(ShortVideo video) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (video.title.isNotEmpty) ...[
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (video.tags.isNotEmpty)
          Text(
            video.tags.map((t) => '#$t').join(' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
        if (video.music.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  video.music,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }
}
