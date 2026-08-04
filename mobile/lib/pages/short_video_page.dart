import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../core/follow_api.dart';
import '../core/photo_filters.dart';
import '../core/video_api.dart';
import '../features/community/domain/community_models.dart';
import 'shoot_page.dart';
import 'short_video_models.dart';

/// 短视频信息流页面（TikTok 风格）
///
/// 竖屏全屏视频滑动（Mock 播放：AnimationController 模拟进度并循环），
/// 双击点赞、右侧交互栏（关注/点赞/评论/分享/旋转唱片）、底部信息区，
/// 顶部「关注 / 推荐」双 Feed 与「+发布」入口。
///
/// 数据来自后端 videos 模块：推荐流加载全部已通过视频，关注流加载已关注作者的视频；
/// 点赞/评论/分享/浏览/关注均实时上报服务端；发布流程（拍摄页 → 发布页）成功后
/// 把新视频插入推荐流顶部。
class ShortVideoPage extends StatefulWidget {
  const ShortVideoPage({super.key, this.active = true});

  /// 所在 Tab 是否可见（IndexedStack 常驻内存，切换走后置 false 以暂停播放）
  final bool active;

  @override
  State<ShortVideoPage> createState() => _ShortVideoPageState();
}

class _ShortVideoPageState extends State<ShortVideoPage> {
  final PageController _pageCtrl = PageController();

  /// 推荐信息流（服务端数据）
  List<ShortVideo> _recommend = [];

  /// 关注信息流（服务端数据，进入关注 Tab 时拉取）
  List<ShortVideo> _following = [];

  /// 已关注作者 ID 集合（驱动关注徽标 / 关注 Feed 过滤）
  final Set<int> _followedIds = {};

  /// 0=关注 1=推荐
  int _tabIndex = 1;
  int _currentIndex = 0;

  /// 当前照片作品页码角标文案（'' 表示当前视频非照片作品，不显示）
  String _photoBadge = '';

  bool _initialLoading = true;
  String? _error;

  /// 推荐流分页状态
  int _recommendPage = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  /// 当前 Feed：推荐=全部；关注=已关注作者的视频
  List<ShortVideo> get _feed =>
      _tabIndex == 1 ? _recommend : _following;

  ShortVideo? _find(int id) {
    for (final v in _recommend) {
      if (v.id == id) return v;
    }
    for (final v in _following) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// 用最新对象替换两个列表中的同名视频（点赞/评论数在此更新）
  void _updateVideo(ShortVideo updated) {
    setState(() {
      _recommend = [
        for (final x in _recommend)
          if (x.id == updated.id) updated else x,
      ];
      _following = [
        for (final x in _following)
          if (x.id == updated.id) updated else x,
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRecommend();
  }

  @override
  void didUpdateWidget(ShortVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tab 可见性变化时重建，通知当前视频暂停/恢复播放
    if (widget.active != oldWidget.active && mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ==================== 数据加载 ====================

  Future<void> _loadRecommend() async {
    setState(() {
      _initialLoading = true;
      _error = null;
    });
    try {
      final r = await VideoApi.fetchRecommend(page: 1);
      if (!mounted) return;
      setState(() {
        _recommend = r.items;
        _recommendPage = 1;
        _hasMore = r.total > r.items.length;
        _initialLoading = false;
      });
      _recordView(r.items.firstOrNull);
    } on DioException catch (e) {
      _onLoadFailed(VideoApi.messageOf(e));
    } catch (e) {
      _onLoadFailed(e.toString());
    }
  }

  Future<void> _loadFollowing() async {
    try {
      final r = await VideoApi.fetchFollowing(page: 1);
      if (!mounted) return;
      setState(() {
        _following = r.items;
        _error = null;
      });
    } catch (_) {
      // 关注流失败保留旧数据，错误态仅用于推荐流为空时
    }
  }

  /// 滑动到底加载下一页（仅推荐流）
  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _tabIndex != 1) return;
    setState(() => _loadingMore = true);
    try {
      final r = await VideoApi.fetchRecommend(page: _recommendPage + 1);
      if (!mounted) return;
      setState(() {
        _recommend = [..._recommend, ...r.items];
        _recommendPage++;
        _hasMore = _recommend.length < r.total;
      });
    } catch (_) {
      // 加载更多失败静默，下次滑到底再试
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onLoadFailed(String msg) {
    if (!mounted) return;
    setState(() {
      _initialLoading = false;
      _error = msg;
    });
  }

  /// 记录浏览（浏览量 +1，失败静默）
  void _recordView(ShortVideo? v) {
    if (v == null) return;
    VideoApi.recordView(v.id).catchError((_) {});
  }

  // ==================== 交互 ====================

  /// 打开作品拍摄页；发布成功后把新视频插入推荐流顶部
  Future<void> _onPublish() async {
    final created = await Navigator.push<ShortVideo>(
      context,
      MaterialPageRoute(builder: (_) => const ShootPage()),
    );
    if (created == null || !mounted) return;
    setState(() {
      _recommend = [created, ..._recommend];
      _following = [created, ..._following];
      _tabIndex = 1;
      _currentIndex = 0;
    });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
    _toast('发布成功');
  }

  void _switchTab(int index) {
    if (index == _tabIndex) return;
    setState(() {
      _tabIndex = index;
      _currentIndex = 0;
    });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
    if (index == 0 && _following.isEmpty) _loadFollowing();
  }

  void _onPageChanged(int i) {
    setState(() => _currentIndex = i);
    final feed = _feed;
    if (i >= 0 && i < feed.length) {
      _recordView(feed[i]);
      if (i >= feed.length - 1) _loadMore();
    }
  }

  void _toggleLike(ShortVideo v) {
    final liked = !v.liked;
    _updateVideo(
      v.copyWith(liked: liked, likeCount: v.likeCount + (liked ? 1 : -1)),
    );
    VideoApi.toggleLike(v.id).then((serverLiked) {
      if (serverLiked == liked) return;
      final cur = _find(v.id);
      if (cur == null) return;
      _updateVideo(cur.copyWith(
        liked: serverLiked,
        likeCount: cur.likeCount + (serverLiked ? 1 : -1),
      ));
    }).catchError((_) {
      // 失败回滚
      final cur = _find(v.id);
      if (cur == null) return;
      _updateVideo(cur.copyWith(liked: v.liked, likeCount: v.likeCount));
    });
  }

  void _toggleFollow(ShortVideo v) {
    final following = !_followedIds.contains(v.authorId);
    setState(() {
      following
          ? _followedIds.add(v.authorId)
          : _followedIds.remove(v.authorId);
    });
    FollowApi.setFollow(v.authorId, following: following).then((_) {
      // 关注 Feed 取关后列表变化，重新拉取
      if (_tabIndex == 0) _loadFollowing();
    }).catchError((_) {
      // 失败回滚
      if (!mounted) return;
      setState(() {
        following
            ? _followedIds.remove(v.authorId)
            : _followedIds.add(v.authorId);
      });
    });
  }

  void _onCommentAdded(ShortVideo v) {
    final cur = _find(v.id);
    if (cur != null) {
      _updateVideo(cur.copyWith(commentCount: cur.commentCount + 1));
    }
  }

  void _openComments(ShortVideo v) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentSheet(
        video: v,
        onAdded: () => _onCommentAdded(v),
      ),
    );
  }

  void _openShare(ShortVideo v) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(
        onShared: () {
          VideoApi.recordShare(v.id).catchError((_) {});
          final cur = _find(v.id);
          if (cur != null) {
            _updateVideo(cur.copyWith(shareCount: cur.shareCount + 1));
          }
        },
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
  }

  // ==================== 构建 ====================

  @override
  Widget build(BuildContext context) {
    final feed = _feed;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 视频 Feed（竖屏滑动，文字/右侧栏随视频一起滑动） ──
          if (_initialLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            )
          else if (feed.isEmpty)
            _buildEmptyFollow()
          else
            PageView.builder(
              controller: _pageCtrl,
              scrollDirection: Axis.vertical,
              itemCount: feed.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, i) => AnimatedBuilder(
                animation: _pageCtrl,
                builder: (context, child) {
                  // 相邻页滑动时轻微缩放 + 透明度渐变（TikTok 式过渡）
                  // easeOutCubic 缓动：滑动时变化先快后缓，衔接更自然
                  // 首帧构建时 position 可能尚未解析，page 为 null，需兜底
                  final page = _pageCtrl.page;
                  final raw = page == null ? 0.0 : (page - i).abs();
                  final offset =
                      Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
                  final scale = 1 - offset * 0.045;
                  final opacity = 1 - offset * 0.55;
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: _VideoItemPage(
                  key: ValueKey(feed[i].id),
                  video: feed[i],
                  active: i == _currentIndex,
                  pageActive: widget.active,
                  followed: _followedIds.contains(feed[i].authorId),
                  onDoubleTapLike: () => _toggleLike(feed[i]),
                  onFollow: () => _toggleFollow(feed[i]),
                  onLike: () => _toggleLike(feed[i]),
                  onComment: () => _openComments(feed[i]),
                  onShare: () => _openShare(feed[i]),
                  onPhotoBadge: (text) {
                    if (_photoBadge != text) {
                      setState(() => _photoBadge = text);
                    }
                  },
                ),
              ),
            ),

          // ── 顶部栏（固定）+ 照片页码角标（右上角「+发布」正下方） ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTopBar(),
                // 照片作品页码角标：固定显示在「+发布」按钮下方
                if (_photoBadge.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _photoBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 顶部栏 ====================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        children: [
          _tabBtn('关注', active: _tabIndex == 0, onTap: () => _switchTab(0)),
          const SizedBox(width: 18),
          _tabBtn('推荐', active: _tabIndex == 1, onTap: () => _switchTab(1)),
          const Spacer(),
          GestureDetector(
            onTap: () => _toast('搜索（演示）'),
            child: const Icon(Icons.search, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 18),
          GestureDetector(
            onTap: _onPublish,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFE2C55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 2),
                  Text(
                    '发布',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(
    String label, {
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF777788),
          fontSize: active ? 18 : 15,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  // ==================== 空态 ====================
  Widget _buildEmptyFollow() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.movie_filter_outlined,
            color: Color(0xFF555566),
            size: 56,
          ),
          const SizedBox(height: 12),
          Text(
            _error != null ? '视频加载失败' : '暂无视频内容',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            _error ?? '视频数据接入中，敬请期待',
            style: const TextStyle(color: Color(0xFF777788), fontSize: 12.5),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _loadRecommend,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '重新加载',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =====================================================================
// 单条视频页：Mock 播放 + 双击点赞
// =====================================================================

class _VideoItemPage extends StatefulWidget {
  const _VideoItemPage({
    super.key,
    required this.video,
    required this.active,
    required this.pageActive,
    required this.followed,
    required this.onDoubleTapLike,
    required this.onFollow,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    this.onPhotoBadge,
  });

  final ShortVideo video;

  /// 是否为当前页（当前页自动播放，离屏暂停并复位）
  final bool active;

  /// 所在 Tab 是否可见（切换走后暂停播放，避免视频在后台继续播）
  final bool pageActive;

  /// 当前用户是否已关注该作者
  final bool followed;

  /// 双击点赞回调
  final VoidCallback onDoubleTapLike;
  final VoidCallback onFollow;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  /// 照片作品页码角标上报（'' 表示非照片作品；由页面固定在「+发布」下方展示）
  final ValueChanged<String>? onPhotoBadge;

  @override
  State<_VideoItemPage> createState() => _VideoItemPageState();
}

class _VideoItemPageState extends State<_VideoItemPage>
    with TickerProviderStateMixin {
  /// Mock 播放进度（模拟视频流；接入真实视频后替换为 video_player）。
  /// 时长按 裁剪区间/倍速 换算：如 15s 视频 2x 播放用 7.5s 播完。
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _playDuration,
  );

  /// Mock 播放时长：裁剪区间长度 ÷ 倍速
  Duration get _playDuration {
    final v = widget.video;
    var ms = v.duration.inMilliseconds;
    if (v.trimStart > 0 && v.trimEnd > v.trimStart) {
      ms = ((v.trimEnd - v.trimStart) * 1000).round();
    }
    if (v.speed > 0) ms = (ms / v.speed).round();
    return Duration(milliseconds: ms);
  }

  bool _playing = false;

  /// 本视频是否曾真正播放过（区分「首次进入视频 Tab 自动播放」与
  /// 「从其他 Tab 切回保持暂停」）
  bool _everVisible = false;

  /// 真实视频播放器（网络视频；视频作品播放画面，加载失败回退 Mock 封面）
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  /// 照片作品多图轮播页码控制（仅照片多图时使用）
  final PageController _photoCtrl = PageController();
  int _photoIndex = 0;

  /// 最近一次上报的角标文案（避免 build 时重复上报）
  String _lastReportedBadge = '';

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

  @override
  void initState() {
    super.initState();
    _progress.addStatusListener((status) {
      // 播完自动循环（抖音式循环播放）
      if (status == AnimationStatus.completed) {
        _progress.forward(from: 0);
      }
    });
    // 视频作品：初始化真实播放器（照片作品/无视频回退 Mock）
    final v = widget.video;
    if (!v.isPhoto && v.videoUrl.isNotEmpty) {
      _initVideo();
    }
    // 首帧后上报照片页码角标（避免在父页面 build 期间 setState）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _emitBadge();
    });
  }

  /// 初始化真实视频播放器：循环、倍速、裁剪区间，就绪后自动播放
  Future<void> _initVideo() async {
    final url = widget.video.videoUrl;
    if (url.isEmpty) return;
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoCtrl = ctrl;
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      final spd = widget.video.speed;
      if (spd > 0 && spd != 1) await ctrl.setPlaybackSpeed(spd);
      ctrl.addListener(_onVideoTick);
      if (!mounted) return;
      setState(() => _videoReady = true);
      // 当前页且所在 Tab 可见才自动开始播放
      if (widget.active && widget.pageActive) {
        await ctrl.play();
        if (mounted) setState(() => _playing = true);
      }
    } catch (_) {
      // 播放失败回退 Mock 封面（_videoReady 保持 false）
    }
  }

  /// 真实播放同步：裁剪区间循环 + 播放状态回写
  void _onVideoTick() {
    final c = _videoCtrl;
    if (c == null || !c.value.isInitialized) return;
    final v = widget.video;
    // 超出裁剪终点跳回起点（元数据裁剪在播放侧生效）
    if (v.trimStart > 0 && v.trimEnd > v.trimStart) {
      final end = Duration(milliseconds: (v.trimEnd * 1000).round());
      if (c.value.position >= end) {
        c.seekTo(Duration(milliseconds: (v.trimStart * 1000).round()));
      }
    }
    final playing = c.value.isPlaying;
    if (playing != _playing && mounted) {
      setState(() => _playing = playing);
    }
  }

  /// 暂停播放（翻页滑走 或 切换 Tab 离开时）：真实播放器暂停到当前位置，Mock 复位
  void _pausePlayback() {
    if (_videoReady) {
      _videoCtrl?.pause();
    } else {
      _progress.stop();
      _progress.reset();
    }
    _playing = false;
    // 失活时重置上报记录，重新激活后才会重新上报角标
    _lastReportedBadge = '';
  }

  /// 恢复播放：真实播放器继续播，Mock 从暂停位置继续
  void _resumePlayback() {
    if (_videoReady) {
      _videoCtrl?.play();
    } else {
      _progress.forward(from: _progress.value);
    }
    _playing = true;
    _emitBadge();
  }

  @override
  void didUpdateWidget(_VideoItemPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当前视频是否真正可见可播 = 是当前页 且 所在 Tab 可见
    final wasVisible = oldWidget.active && oldWidget.pageActive;
    final nowVisible = widget.active && widget.pageActive;
    if (wasVisible && !nowVisible) {
      // 离开：翻页滑走 或 切换到其他 Tab → 一律暂停
      _pausePlayback();
    } else if (!wasVisible && nowVisible) {
      if (widget.active && !oldWidget.active) {
        // 翻页切到本页：自动播放（TikTok 式）
        _resumePlayback();
        _everVisible = true;
      } else if (!_everVisible) {
        // 首次进入视频 Tab：自动播放当前视频
        _resumePlayback();
        _everVisible = true;
      } else {
        // 从其他 Tab 切回来：保持暂停，等用户点击播放
        _playing = false;
        _emitBadge();
      }
    }
    // 视频对象变化（如翻页复用）时重新上报角标
    if (widget.video.id != oldWidget.video.id) {
      _emitBadge();
    }
  }

  @override
  void dispose() {
    _videoCtrl?.removeListener(_onVideoTick);
    _videoCtrl?.dispose();
    _photoCtrl.dispose();
    _progress.dispose();
    _burst.dispose();
    // 页面销毁时清除右上角照片页码角标（延迟到帧后，避免 dispose 发生在父级 build 期间）
    final cb = widget.onPhotoBadge;
    WidgetsBinding.instance.addPostFrameCallback((_) => cb?.call(''));
    super.dispose();
  }

  /// 上报当前照片页码角标（仅 active 项上报，离屏项不参与避免互相覆盖）。
  /// 仅在事件回调中调用；内部通过 addPostFrameCallback 延迟到帧后，
  /// 避免在父页面 build 期间调用其 setState。
  void _emitBadge() {
    if (!widget.active) return;
    final video = widget.video;
    final text = !video.isPhoto
        ? ''
        : (video.photos.length > 1
            ? '照片 ${_photoIndex + 1}/${video.photos.length}'
            : '照片');
    if (text == _lastReportedBadge) return;
    _lastReportedBadge = text;
    final cb = widget.onPhotoBadge;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) cb?.call(text);
    });
  }

  void _togglePlay() {
    // 真实视频播放器优先
    if (_videoReady) {
      final c = _videoCtrl!;
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
      setState(() => _playing = c.value.isPlaying);
      return;
    }
    // Mock 播放（照片作品/播放器未就绪）
    setState(() {
      if (_playing) {
        _progress.stop();
        _playing = false;
      } else {
        _progress.forward(from: _progress.value);
        _playing = true;
      }
    });
  }

  void _onDoubleTap() {
    _burst.forward(from: 0);
    widget.onDoubleTapLike();
  }

  /// 封面/照片网络图（加载中与失败兜底）。
  /// 统一应用编辑滤镜（ColorFiltered）与照片旋转（RotatedBox）。
  Widget _coverImage(String url) {
    final filter = filterOf(widget.video.filterId).colorFilter;
    final turns = widget.video.rotation % 4;
    Widget image = Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Container(
          color: const Color(0xFF14141C),
          child: const Center(
            child: Icon(
              Icons.movie_outlined,
              color: Color(0xFF3A3A48),
              size: 48,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFF14141C),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF3A3A48),
            size: 48,
          ),
        ),
      ),
    );
    image = ColorFiltered(colorFilter: filter, child: image);
    if (turns != 0) image = RotatedBox(quarterTurns: turns, child: image);
    return image;
  }

  /// 视频真实画面：全屏铺满裁切（BoxFit.cover），应用编辑滤镜
  Widget _videoLayer() {
    final c = _videoCtrl!;
    final filter = filterOf(widget.video.filterId).colorFilter;
    return ColorFiltered(
      colorFilter: filter,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 100,
            height: c.value.aspectRatio > 0 ? 100 / c.value.aspectRatio : 100,
            child: VideoPlayer(c),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _togglePlay,
        onDoubleTap: _onDoubleTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景：照片多图轮播 / 视频真实画面 / 单封面（Mock 播放载体）/ 占位图
            if (video.isPhoto && video.photos.length > 1)
              PageView.builder(
                controller: _photoCtrl,
                itemCount: video.photos.length,
                onPageChanged: (i) {
                  setState(() => _photoIndex = i);
                  _emitBadge();
                },
                itemBuilder: (_, i) => _coverImage(video.photos[i]),
              )
            else if (_videoReady)
              _videoLayer()
            else if (video.cover.isEmpty)
              Container(
                color: const Color(0xFF14141C),
                child: const Center(
                  child: Icon(
                    Icons.movie_outlined,
                    color: Color(0xFF3A3A48),
                    size: 48,
                  ),
                ),
              )
            else
              _coverImage(video.cover),

            // 暂停态中央播放键（播放态隐藏）
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _playing
                  ? const SizedBox.shrink()
                  : Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
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
                        color: Color(0xFFFE2C55),
                        size: 96,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 底部渐变压暗（保证文字可读，随视频滑动）
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

            // 底部毛玻璃层（模糊 + 暗色渐变，模糊随高度淡入避免生硬边缘）
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 160,
              child: ClipRect(
                child: ShaderMask(
                  // 顶部透明 → 底部不透明，让模糊效果渐变淡入
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.0, 0.6],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.75],
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 右侧交互栏（随视频滑动）
            Positioned(
              right: 10,
              bottom: 120,
              child: _RightRail(
                video: widget.video,
                followed: widget.followed,
                onFollow: widget.onFollow,
                onLike: widget.onLike,
                onComment: widget.onComment,
                onShare: widget.onShare,
              ),
            ),

            // 底部信息区（随视频滑动）
            Positioned(
              left: 14,
              right: 84,
              bottom: 0.2,
              child: _buildVideoInfo(widget.video),
            ),

            // 底部进度指示：照片作品（多图）→ 分段白条（当前张高亮，其余偏暗）；
            // 视频/单图 → 播放进度条
            Positioned(
              left: 14,
              right: 14,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: IgnorePointer(
                  child: video.isPhoto && video.photos.length > 1
                      ? Row(
                          children: [
                            for (var i = 0; i < video.photos.length; i++)
                              Expanded(
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  height: 3,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: i == _photoIndex
                                        ? Colors.white
                                        : Colors.white30,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : _videoReady
                          ? ValueListenableBuilder<VideoPlayerValue>(
                              valueListenable: _videoCtrl!,
                              builder: (context, value, _) {
                                // 真实播放进度（原始时间轴比例）
                                final total = value.duration.inMilliseconds;
                                final pos = value.position.inMilliseconds;
                                final display =
                                    total > 0 ? (pos / total).clamp(0.0, 1.0) : 0.0;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: display,
                                    minHeight: 3,
                                    backgroundColor: Colors.white24,
                                    color: const Color(0xFFFE2C55),
                                  ),
                                );
                              },
                            )
                          : AnimatedBuilder(
                          animation: _progress,
                          builder: (context, _) {
                            // 把 Mock 播放进度映射回原始时间轴：
                            // 展示位置 = 裁剪起点 + 已播时长 × 倍速
                            final v = widget.video;
                            final playMs = _playDuration.inMilliseconds;
                            var rawMs = _progress.value * playMs * v.speed;
                            if (v.trimStart > 0 && v.trimEnd > v.trimStart) {
                              rawMs += v.trimStart * 1000;
                            }
                            final totalMs = v.duration.inMilliseconds;
                            final display = totalMs > 0
                                ? (rawMs / totalMs).clamp(0.0, 1.0)
                                : 0.0;
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: display,
                                minHeight: 3,
                                backgroundColor: Colors.white24,
                                color: const Color(0xFFFE2C55),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 底部信息区 ====================
  Widget _buildVideoInfo(ShortVideo v) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '@${v.user}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· ${formatCount(v.followCount)} 粉丝',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            v.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          if (v.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              children: [
                for (final t in v.tags)
                  Text(
                    '#$t',
                    style: const TextStyle(
                      color: Color(0xFFAACCFF),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          if (v.tags.isNotEmpty) const SizedBox(height: 8),
          if (v.music.isNotEmpty)
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
                    v.music,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          if (v.music.isNotEmpty) const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// =====================================================================
// 右侧交互栏
// =====================================================================

class _RightRail extends StatefulWidget {
  const _RightRail({
    required this.video,
    required this.followed,
    required this.onFollow,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final ShortVideo video;
  final bool followed;
  final VoidCallback onFollow;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  State<_RightRail> createState() => _RightRailState();
}

class _RightRailState extends State<_RightRail>
    with SingleTickerProviderStateMixin {
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

  @override
  void dispose() {
    _likeAnim.dispose();
    super.dispose();
  }

  void _onLike() {
    _likeAnim.forward(from: 0);
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(v),
        const SizedBox(height: 26),
        // 点赞
        _ActionItem(
          icon: ScaleTransition(
            scale: _likeScale,
            child: Icon(
              v.liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              color: v.liked ? const Color(0xFFFE2C55) : Colors.white,
              size: 34,
            ),
          ),
          label: formatCount(v.likeCount),
          onTap: _onLike,
        ),
        const SizedBox(height: 20),
        // 评论
        _ActionItem(
          icon: const Icon(
            Icons.comment_rounded,
            color: Colors.white,
            size: 32,
          ),
          label: formatCount(v.commentCount),
          onTap: widget.onComment,
        ),
        const SizedBox(height: 20),
        // 分享
        _ActionItem(
          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 32),
          label: '分享',
          onTap: widget.onShare,
        ),
        const SizedBox(height: 20),
        // 旋转唱片
        _MusicDisc(cover: v.cover),
      ],
    );
  }

  Widget _buildAvatar(ShortVideo v) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onFollow,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: v.avatar.isEmpty
                ? Container(
                    color: const Color(0xFF2C2C36),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white70,
                      size: 22,
                    ),
                  )
                : Image.network(
                    v.avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF2C2C36),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ),
                  ),
          ),
          Positioned(
            bottom: -9,
            right: -3,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFE2C55),
              ),
              child: Icon(
                widget.followed ? Icons.check_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 右侧通用动作项：图标 + 计数
class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label, this.onTap});

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

/// 旋转唱片（封面图 + 永续旋转）
class _MusicDisc extends StatefulWidget {
  const _MusicDisc({required this.cover});

  final String cover;

  @override
  State<_MusicDisc> createState() => _MusicDiscState();
}

class _MusicDiscState extends State<_MusicDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _spin,
      child: Container(
        width: 42,
        height: 42,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFE2C55),
          border: Border.all(color: Colors.white70, width: 1.2),
        ),
        child: ClipOval(
          child: widget.cover.isEmpty
              ? Container(
                  color: const Color(0xFF2C2C36),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              : Image.network(
                  widget.cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF2C2C36),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// =====================================================================
// 评论弹层（深色）
// =====================================================================

class _CommentSheet extends StatefulWidget {
  const _CommentSheet({
    required this.video,
    required this.onAdded,
  });

  final ShortVideo video;

  /// 每新增一条评论回调（用于更新外层计数）
  final VoidCallback onAdded;

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
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
        SnackBar(
          content: Text('评论失败：$e'),
          behavior: SnackBarBehavior.floating,
        ),
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
                    child: CircularProgressIndicator(
                      color: Colors.white30,
                    ),
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
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 14),
                        itemBuilder: (_, i) =>
                            _CommentRow(comment: _comments[i]),
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
              icon: const Icon(Icons.send_rounded, color: Color(0xFFFE2C55)),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

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

// =====================================================================
// 分享弹层（深色）
// =====================================================================

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({this.onShared});

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
                              colors: [Color(0xFFFE2C55), Color(0xFFB31E3D)],
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
