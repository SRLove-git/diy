import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_colors.dart';
import '../../../core/chat_api.dart';
import '../../../core/video_api.dart';
import '../../../core/video_layout.dart';
import '../../../widgets/video_interaction_sheets.dart';
import '../model/tiktok_video_model.dart';
import '../provider/profile_videos_controller.dart';
import '../widget/like_burst.dart';
import '../widget/video_action_rail.dart';
import '../widget/video_info_panel.dart';
import '../widget/video_more_sheet.dart';

/// 抖音风格全屏上下滑动播放页（page 页面层）
///
/// 从个人主页作品墙点击封面进入：
/// - 竖屏沉浸式全屏，PageView 上下滑动切换视频；
/// - 视频播放依赖 `video_player + chewie`（Chewie 作为播放器宿主，
///   通过 overlay 做全屏裁剪铺满，保留 chewie 的播放生命周期管理）；
/// - 右侧悬浮操作栏：点赞 / 评论 / 转发 / 收藏 / 更多（图标 + 数字）；
/// - 底部：作品简介文案 + 背景音乐跑马灯；
/// - 双击视频爱心点赞动画，单击暂停/播放；
/// - 横竖屏切换：顶栏提供全屏按钮进入横屏播放（chewie 控制条由本页
///   自绘），返回后恢复竖屏；刘海屏安全区域用 SafeArea 处理。
///
/// 页面进入时锁定竖屏 + 沉浸式系统栏（抖音行为），销毁时恢复。
class FullscreenVideoPage extends StatefulWidget {
  const FullscreenVideoPage({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    this.controller,
    required this.nickname,
  });

  /// 作品列表快照（进入播放页后以本地列表为准）
  final List<TiktokVideoModel> videos;

  /// 初始播放下标（从作品墙点击位置进入）
  final int initialIndex;

  /// 作品墙 Provider：互动数据实时同步回作品墙
  final ProfileVideosController? controller;

  /// 作者昵称（顶栏展示）
  final String nickname;

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  late final List<TiktokVideoModel> _videos = List.of(widget.videos);
  late final PageController _pageCtrl =
      PageController(initialPage: widget.initialIndex);
  late int _current = widget.initialIndex;

  /// 已本地计数过的作品 ID（避免反复滑回时浏览量虚增）
  final Set<int> _viewedIds = {};

  /// 每页播放器状态句柄（横屏层需要读取当前页的 VideoPlayerController）
  late final List<GlobalKey<_VideoPageState>> _pageKeys =
      List.generate(widget.videos.length, (_) => GlobalKey());

  /// 是否处于横屏播放态（顶栏全屏按钮触发）
  bool _landscape = false;

  @override
  void initState() {
    super.initState();
    // 抖音行为：播放页锁定竖屏 + 隐藏系统状态栏/导航栏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _recordView(_videos[_current]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _pageCtrl.dispose();
    super.dispose();
  }

  // ──── 数据同步 ────

  TiktokVideoModel? _byId(int id) {
    for (final v in _videos) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// 更新本地列表并同步回作品墙 Provider
  void _updateItem(TiktokVideoModel next) {
    setState(() {
      final i = _videos.indexWhere((v) => v.id == next.id);
      if (i >= 0) _videos[i] = next;
    });
    widget.controller?.syncItem(next);
  }

  /// 浏览上报：每次进入同一作品本地 +1 一次，服务端每次切页都上报
  void _recordView(TiktokVideoModel item) {
    if (!_viewedIds.add(item.id)) return;
    _updateItem(item.copyWith(viewCount: item.viewCount + 1));
    VideoApi.recordView(item.id).catchError((_) {});
  }

  void _onPageChanged(int i) {
    if (!mounted) return;
    setState(() => _current = i);
    _recordView(_videos[i]);
  }

  // ──── 交互 ────

  /// 点赞：乐观更新 + 服务端同步 + 失败回滚（与作品墙 Provider 逻辑一致）
  void _toggleLike(TiktokVideoModel item) {
    final target = !item.liked;
    _updateItem(
      item.copyWith(
        video: item.video.copyWith(
          liked: target,
          likeCount: item.likeCount + (target ? 1 : -1),
        ),
      ),
    );
    VideoApi.toggleLike(item.id).then((serverLiked) {
      if (!mounted) return;
      final cur = _byId(item.id);
      if (cur == null || serverLiked == cur.liked) return;
      _updateItem(
        cur.copyWith(
          video: cur.video.copyWith(
            liked: serverLiked,
            likeCount: cur.likeCount + (serverLiked ? 1 : -1),
          ),
        ),
      );
    }).catchError((_) {
      if (!mounted) return;
      final cur = _byId(item.id);
      if (cur != null) _updateItem(item);
    });
  }

  void _openComments() {
    final item = _videos[_current];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoCommentSheet(
        video: item.video,
        onAdded: () {
          if (!mounted) return;
          final cur = _byId(item.id);
          if (cur == null) return;
          _updateItem(
            cur.copyWith(
              video: cur.video.copyWith(commentCount: cur.commentCount + 1),
            ),
          );
        },
      ),
    );
  }

  void _openShare() {
    final item = _videos[_current];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoShareSheet(
        onShared: () {
          if (!mounted) return;
          VideoApi.recordShare(item.id).catchError((_) {});
          final cur = _byId(item.id);
          if (cur == null) return;
          _updateItem(
            cur.copyWith(
              video: cur.video.copyWith(shareCount: cur.shareCount + 1),
            ),
          );
        },
      ),
    );
  }

  /// 收藏：本地交互（视频收藏接口暂未提供，接入后端后在 Provider 上报）
  void _toggleFavorite() {
    final item = _videos[_current];
    final target = !item.favorited;
    _updateItem(
      item.copyWith(
        favorited: target,
        favoriteCount: item.favoriteCount + (target ? 1 : -1),
      ),
    );
  }

  // ──── 横竖屏切换 ────

  /// 进入横屏播放：读取当前页播放器控制器，隐藏系统栏并旋转
  Future<void> _enterLandscape() async {
    final ctrl = _pageKeys[_current].currentState?.videoController;
    if (ctrl == null) return;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [],
    );
    if (mounted) setState(() => _landscape = true);
  }

  /// 退出横屏：恢复竖屏 + 沉浸式系统栏
  Future<void> _exitLandscape() async {
    if (!mounted) return;
    setState(() => _landscape = false);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // ──── 构建 ────

  /// 当前作品是否为横屏（决定顶栏是否显示「全屏观看」按钮）。
  /// 优先使用服务端下发的展示画幅，缺失时回退播放器原始画幅。
  bool get _isCurrentLandscape {
    final item = _videos[_current];
    final ctrl = _pageKeys[_current].currentState?.videoController;
    return isLandscapeVideo(
      item.aspectRatio > 0 ? item.aspectRatio : ctrl?.value.aspectRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _videos[_current];
    final currentCtrl = _pageKeys[_current].currentState?.videoController;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 竖屏上下滑动视频流
          PageView.builder(
            controller: _pageCtrl,
            scrollDirection: Axis.vertical,
            itemCount: _videos.length,
            allowImplicitScrolling: true,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, i) => _VideoPage(
              key: _pageKeys[i],
              item: _videos[i],
              active: i == _current,
              onDoubleTap: () {
                final item = _videos[_current];
                if (!item.liked) _toggleLike(item);
              },
            ),
          ),

          // ── 竖屏覆盖层（横屏时隐藏） ──
          if (!_landscape) ...[
            // 顶部/底部渐变压暗，保证文字与图标可读
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.14, 0.72, 1.0],
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black54,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 顶部区域：返回 + 昵称 + 全屏按钮
            // 注意：必须用 Positioned 定位（而非 Stack 非定位子节点），
            // 否则 StackFit.expand 会传紧约束给 Row，导致按钮被垂直居中。
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // 全屏观看仅横屏视频提供（竖屏视频本身已全屏铺满）
                      if (_isCurrentLandscape) ...[
                        _RoundIconButton(
                          icon: Icons.crop_free_rounded,
                          onTap: _enterLandscape,
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 右侧悬浮操作栏：点赞/评论/转发/收藏/更多
            Positioned(
              right: 8,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: VideoActionRail(
                    item: current,
                    onLike: () => _toggleLike(current),
                    onComment: _openComments,
                    onShare: _openShare,
                    onFavorite: _toggleFavorite,
                    onMore: () => VideoMoreSheet.show(context, current),
                  ),
                ),
              ),
            ),

            // 底部信息：作品简介 + 背景音乐跑马灯（手势穿透，不挡滑动）
            Positioned(
              left: 14,
              right: 86,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: IgnorePointer(
                    child: VideoInfoPanel(
                      item: current,
                      nickname: widget.nickname,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── 横屏播放层（覆盖在竖屏之上，PageView 保持挂载） ──
          if (_landscape && currentCtrl != null)
            _LandscapePlayer(
              controller: currentCtrl,
              onExit: _exitLandscape,
            ),
        ],
      ),
    );
  }
}

// =====================================================================
// 单条视频页：Chewie 播放 + 全屏裁剪 + 双击点赞 + 单击暂停/播放
// =====================================================================

class _VideoPage extends StatefulWidget {
  const _VideoPage({
    super.key,
    required this.item,
    required this.active,
    required this.onDoubleTap,
  });

  final TiktokVideoModel item;

  /// 是否为当前页（当前页自动播放，离屏暂停）
  final bool active;

  final VoidCallback onDoubleTap;

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;

  /// 视频初始化成功（成功后展示真实画面）
  bool _ready = false;

  /// 播放状态（由 chewie 通知同步，驱动暂停态中央播放键）
  bool _playing = false;

  /// 笔记多图轮播（照片作品；单图/视频作品不使用）
  final PageController _photoCtrl = PageController();
  int _photoIndex = 0;

  /// 双击点赞爱心
  final GlobalKey<LikeBurstState> _burstKey = GlobalKey<LikeBurstState>();

  /// 供父页面横屏层读取
  VideoPlayerController? get videoController => _videoCtrl;

  @override
  void initState() {
    super.initState();
    if (!widget.item.isPhoto && widget.item.videoUrl.isNotEmpty) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final ctrl = VideoPlayerController.networkUrl(
      Uri.parse(ChatApi.resolveUrl(widget.item.videoUrl)),
    );
    _videoCtrl = ctrl;
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      if (!mounted) return;
      final chewie = ChewieController(
        videoPlayerController: ctrl,
        autoPlay: widget.active,
        looping: true,
        // 抖音风格：关闭 chewie 原生控制条，使用自定义覆盖层
        showControls: false,
        // 覆盖层把视频按 BoxFit.cover 全屏裁剪铺满（TikTok 画幅）
        overlay: _FullBleedVideo(item: widget.item),
      );
      chewie.addListener(_onChewieChanged);
      if (!mounted) {
        chewie.removeListener(_onChewieChanged);
        ctrl.dispose();
        _videoCtrl = null;
        return;
      }
      setState(() {
        _chewieCtrl = chewie;
        _ready = true;
        _playing = widget.active;
      });
    } catch (_) {
      // 视频流初始化失败：回退封面静态图（保证 UI 不中断）
      ctrl.dispose();
      if (mounted && identical(_videoCtrl, ctrl)) {
        setState(() => _videoCtrl = null);
      }
    }
  }

  void _onChewieChanged() {
    final playing = _chewieCtrl?.isPlaying ?? false;
    if (playing != _playing && mounted) {
      setState(() => _playing = playing);
    }
  }

  @override
  void didUpdateWidget(_VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      final chewie = _chewieCtrl;
      if (chewie != null) {
        if (widget.active) {
          chewie.play();
        } else {
          chewie.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _chewieCtrl?.removeListener(_onChewieChanged);
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final chewie = _chewieCtrl;
    if (chewie == null) return;
    if (chewie.isPlaying) {
      chewie.pause();
    } else {
      chewie.play();
    }
  }

  void _onDoubleTap() {
    _burstKey.currentState?.trigger();
    widget.onDoubleTap();
  }

  /// 笔记展示图：优先照片列表，回退封面
  List<String> get _photos {
    final photos = widget.item.video.photos
        .where((u) => u.isNotEmpty)
        .toList();
    if (photos.isNotEmpty) return photos;
    if (widget.item.cover.isNotEmpty) return [widget.item.cover];
    return const [];
  }

  Widget _photoImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, sync) {
        if (sync || frame != null) return child;
        return _placeholder();
      },
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final photos = _photos;
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _togglePlay,
        onDoubleTap: _onDoubleTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 照片作品：多图左右轮播 / 单图铺满
            if (item.isPhoto) ...[
              if (photos.length > 1)
                PageView.builder(
                  controller: _photoCtrl,
                  itemCount: photos.length,
                  onPageChanged: (i) {
                    if (mounted) setState(() => _photoIndex = i);
                  },
                  itemBuilder: (_, i) => _photoImage(photos[i]),
                )
              else if (photos.isNotEmpty)
                _photoImage(photos.first)
              else
                _placeholder(),

              // 多图页码角标（避免与顶部操作栏重叠，放在其下方）
              if (photos.length > 1)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 62,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_photoIndex + 1}/${photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ] else ...[
              // 视频作品：Chewie 播放器（overlay 已全屏裁剪）
              if (_ready && _chewieCtrl != null)
                Chewie(controller: _chewieCtrl!)
              else if (item.cover.isNotEmpty)
                Image.network(
                  item.cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(),
                )
              else
                _placeholder(),

              // 初始化中：中央加载指示
              if (!_ready)
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: Colors.white60,
                  ),
                ),
            ],

            // 双击点赞爱心
            LikeBurst(key: _burstKey, size: 96),

            // 暂停态中央播放键（播放时隐藏）
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _playing || _chewieCtrl == null
                  ? const SizedBox.shrink()
                  : Center(
                      key: const ValueKey('play-indicator'),
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFF14141C),
      child: Center(
        child: Icon(Icons.movie_outlined, color: Color(0xFF3A3A48), size: 48),
      ),
    );
  }
}

/// Chewie overlay：竖屏视频按源画幅 cover 全屏裁剪铺满（TikTok 画幅）；
/// 横屏/方形视频完整显示（contain + 模糊背景补齐），避免被裁成竖条。
///
/// 依赖 ChewieControllerProvider（Chewie 内部注入），
/// 读取当前控制器后渲染与视频流同源的画面。
class _FullBleedVideo extends StatelessWidget {
  const _FullBleedVideo({this.item});

  /// 服务端下发的展示画幅（0 表示使用视频文件原始画幅）
  final TiktokVideoModel? item;

  @override
  Widget build(BuildContext context) {
    final chewie = ChewieController.of(context);
    final ctrl = chewie.videoPlayerController;
    return SizedBox.expand(
      child: _AdaptiveVideoFrame(
        controller: ctrl,
        displayAspectRatio: item?.aspectRatio,
      ),
    );
  }
}

/// 自适应视频画面层：与信息流页横屏处理一致。
///
/// - 竖屏（画幅 <= 0.82）：cover 铺满全屏；
/// - 横屏/方形（画幅 > 0.82）：完整显示（contain）+ 同帧模糊背景补齐，
///   避免横向视频被 cover 放大裁切成窄竖条导致比例观感错误。
class _AdaptiveVideoFrame extends StatelessWidget {
  const _AdaptiveVideoFrame({
    required this.controller,
    this.displayAspectRatio,
    this.alwaysContain = false,
  });

  final VideoPlayerController controller;

  /// 展示画幅（width / height）；为 null 时使用视频文件原始画幅
  final double? displayAspectRatio;

  /// 横屏播放层使用：无论画幅都完整显示（竖屏视频横放时不裁切）
  final bool alwaysContain;

  @override
  Widget build(BuildContext context) {
    final source = normalizeVideoAspectRatio(controller.value.aspectRatio);
    final display = displayAspectRatio != null && displayAspectRatio! > 0
        ? normalizeVideoAspectRatio(displayAspectRatio)
        : source;
    final shouldContain = alwaysContain || shouldContainVideo(display);
    final foreground = Center(
      child: AspectRatio(
        aspectRatio: display,
        child: coverVideoFrame(
          sourceAspectRatio: source,
          child: VideoPlayer(controller),
        ),
      ),
    );
    return ClipRect(
      child: shouldContain
          ? Stack(
              fit: StackFit.expand,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Opacity(
                    opacity: 0.42,
                    child: coverVideoFrame(
                      sourceAspectRatio: source,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
                const ColoredBox(color: Color(0x55000000)),
                foreground,
              ],
            )
          : coverVideoFrame(
              sourceAspectRatio: source,
              child: VideoPlayer(controller),
            ),
    );
  }
}

// =====================================================================
// 横屏播放层：全屏视频 + 播放/进度控制
// =====================================================================

class _LandscapePlayer extends StatefulWidget {
  const _LandscapePlayer({
    required this.controller,
    required this.onExit,
  });

  final VideoPlayerController controller;
  final VoidCallback onExit;

  @override
  State<_LandscapePlayer> createState() => _LandscapePlayerState();
}

class _LandscapePlayerState extends State<_LandscapePlayer> {
  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: widget.controller,
          builder: (context, value, _) {
            final pos = value.position;
            final dur = value.duration;
            final max = dur.inMilliseconds
                .toDouble()
                .clamp(1.0, double.infinity)
                .toDouble();
            return Stack(
              fit: StackFit.expand,
              children: [
                // 视频画面：横屏视频完整显示，竖屏视频横放时也完整显示
                _AdaptiveVideoFrame(
                  controller: widget.controller,
                  alwaysContain: true,
                ),

                // 左上：退出横屏
                Positioned(
                  left: 8,
                  top: 8,
                  child: _RoundIconButton(
                    icon: Icons.fullscreen_exit_rounded,
                    onTap: widget.onExit,
                  ),
                ),

                // 底部控制条：播放/暂停 + 进度 + 时间
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 6,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (value.isPlaying) {
                            widget.controller.pause();
                          } else {
                            widget.controller.play();
                          }
                        },
                        icon: Icon(
                          value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      Text(
                        _fmt(pos.inSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            activeTrackColor: Palette.accent,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: pos.inMilliseconds
                                .toDouble()
                                .clamp(0.0, max)
                                .toDouble(),
                            max: max,
                            onChanged: (v) =>
                                widget.controller.seekTo(
                                  Duration(milliseconds: v.round()),
                                ),
                          ),
                        ),
                      ),
                      Text(
                        _fmt(dur.inSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 顶栏圆形图标按钮
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 21, color: Colors.white),
        ),
      ),
    );
  }
}
