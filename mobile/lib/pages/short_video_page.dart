import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/auth_service.dart';
import '../features/community/domain/community_models.dart';
import 'shoot_page.dart';
import 'short_video_models.dart';

/// 短视频信息流页面（TikTok 风格）
///
/// 竖屏全屏视频滑动（Mock 播放：AnimationController 模拟进度并循环），
/// 双击点赞、右侧交互栏（关注/点赞/评论/分享/旋转唱片）、底部信息区，
/// 顶部「关注 / 推荐」双 Feed 与「+发布」入口。
class ShortVideoPage extends StatefulWidget {
  const ShortVideoPage({super.key});

  @override
  State<ShortVideoPage> createState() => _ShortVideoPageState();
}

class _ShortVideoPageState extends State<ShortVideoPage> {
  final PageController _pageCtrl = PageController();

  /// 视频列表（待接入后端真实数据，当前为空；点赞/评论数在此更新）
  final List<ShortVideo> _videos = [];

  /// 已关注作者 ID 集合
  final Set<int> _followedIds = {};

  /// 0=关注 1=推荐
  int _tabIndex = 1;
  int _currentIndex = 0;

  /// 当前 Feed：推荐=全部；关注=已关注作者的视频
  List<ShortVideo> get _feed => _tabIndex == 1
      ? _videos
      : _videos.where((v) => _followedIds.contains(v.authorId)).toList();

  /// 按 id 定位 _videos 中的索引（-1 表示已不在列表）
  int _indexOf(ShortVideo v) => _videos.indexWhere((x) => x.id == v.id);

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  /// 打开作品拍摄页（仅 UI，拍摄/发布功能后续接入）
  void _onPublish() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShootPage()),
    );
  }

  void _switchTab(int index) {
    if (index == _tabIndex) return;
    setState(() {
      _tabIndex = index;
      _currentIndex = 0;
    });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
  }

  void _toggleLike(ShortVideo v) {
    final idx = _indexOf(v);
    if (idx < 0) return;
    final cur = _videos[idx];
    final liked = !cur.liked;
    setState(() {
      _videos[idx] = cur.copyWith(
        liked: liked,
        likeCount: cur.likeCount + (liked ? 1 : -1),
      );
    });
  }

  void _toggleFollow(ShortVideo v) {
    setState(() {
      if (!_followedIds.add(v.authorId)) {
        _followedIds.remove(v.authorId);
      }
    });
    // 关注 Feed 取关后列表可能缩短/清空，回退索引
    if (_tabIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final f = _feed;
        setState(
          () => _currentIndex = f.isEmpty
              ? 0
              : (_currentIndex >= f.length ? f.length - 1 : _currentIndex),
        );
      });
    }
  }

  void _onCommentAdded(ShortVideo v) {
    final idx = _indexOf(v);
    if (idx < 0) return;
    final cur = _videos[idx];
    setState(() {
      _videos[idx] = cur.copyWith(commentCount: cur.commentCount + 1);
    });
  }

  void _openComments(ShortVideo v) {
    final user = AuthService.instance.user;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentSheet(
        video: v,
        me: CommunityUser(
          id: user?.id ?? 0,
          nickname: user?.nickname ?? '',
          avatarUrl: user?.avatar ?? '',
        ),
        onAdded: () => _onCommentAdded(v),
      ),
    );
  }

  void _openShare() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ShareSheet(),
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

  @override
  Widget build(BuildContext context) {
    final feed = _feed;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 视频 Feed（竖屏滑动，文字/右侧栏随视频一起滑动） ──
          if (feed.isEmpty)
            _buildEmptyFollow()
          else
            PageView.builder(
              key: ValueKey(_tabIndex),
              controller: _pageCtrl,
              scrollDirection: Axis.vertical,
              itemCount: feed.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
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
                  followed: _followedIds.contains(feed[i].authorId),
                  onDoubleTapLike: () => _toggleLike(feed[i]),
                  onFollow: () => _toggleFollow(feed[i]),
                  onLike: () => _toggleLike(feed[i]),
                  onComment: () => _openComments(feed[i]),
                  onShare: _openShare,
                ),
              ),
            ),

          // ── 顶部栏（固定） ──
          SafeArea(child: _buildTopBar()),
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
          const Text(
            '暂无视频内容',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            '视频数据接入中，敬请期待',
            style: TextStyle(color: Color(0xFF777788), fontSize: 12.5),
          ),
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
    required this.followed,
    required this.onDoubleTapLike,
    required this.onFollow,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final ShortVideo video;

  /// 是否为当前页（当前页自动播放，离屏暂停并复位）
  final bool active;

  /// 当前用户是否已关注该作者
  final bool followed;

  /// 双击点赞回调
  final VoidCallback onDoubleTapLike;
  final VoidCallback onFollow;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  State<_VideoItemPage> createState() => _VideoItemPageState();
}

class _VideoItemPageState extends State<_VideoItemPage>
    with TickerProviderStateMixin {
  /// Mock 播放进度（模拟视频流；接入真实视频后替换为 video_player）
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.video.duration,
  );

  bool _playing = false;

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
  }

  @override
  void didUpdateWidget(_VideoItemPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _progress.forward(from: _progress.value);
        _playing = true;
      } else {
        _progress.stop();
        _progress.reset();
        _playing = false;
      }
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _burst.dispose();
    super.dispose();
  }

  void _togglePlay() {
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
            // 视频封面（Mock 播放载体）
            Image.network(
              video.cover,
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
            ),

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

            // 播放进度条（左右等距，与信息区底部对齐）
            Positioned(
              left: 14,
              right: 14,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        minHeight: 3,
                        backgroundColor: Colors.white24,
                        color: const Color(0xFFFE2C55),
                      ),
                    ),
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 6),
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
            child: Image.network(
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
          child: Image.network(
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
    required this.me,
    required this.onAdded,
  });

  final ShortVideo video;
  final CommunityUser me;

  /// 每新增一条评论回调（用于更新外层计数）
  final VoidCallback onAdded;

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  late final List<CommunityComment> _comments = List.of(widget.video.comments);
  final _inputCtrl = TextEditingController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(
        0,
        CommunityComment(
          user: widget.me,
          content: text,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      _inputCtrl.clear();
    });
    widget.onAdded();
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
            child: _comments.isEmpty
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
  const _ShareSheet();

  static const _options = [
    (icon: Icons.link_rounded, label: '复制链接'),
    (icon: Icons.chat_rounded, label: '微信'),
    (icon: Icons.camera_alt_rounded, label: '朋友圈'),
    (icon: Icons.more_horiz_rounded, label: '更多'),
  ];

  void _pick(BuildContext context, String label) {
    Navigator.pop(context);
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
