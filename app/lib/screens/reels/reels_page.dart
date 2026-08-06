import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/short_video_models.dart';
import '../../core/video_api.dart';
import '../../features/community/domain/community_models.dart';

/// Reels 页：全屏竖屏短视频沉浸流
class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  List<ShortVideo> _videos = [];
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
      final result = await VideoApi.fetchRecommend(page: 1);
      if (!mounted) return;
      setState(() {
        _videos = result.items;
        _loading = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '加载失败，请检查网络';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorView(onRetry: _load)
                : _videos.isEmpty
                    ? const Center(
                        child: Text(
                          '还没有视频，去发布第一条吧',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : PageView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _videos.length,
                        onPageChanged: (i) => VideoApi.recordView(
                          _videos[i].id,
                        ),
                        itemBuilder: (context, i) =>
                            _ReelsItem(video: _videos[i]),
                      ),
      ),
    );
  }
}

class _ReelsItem extends StatefulWidget {
  const _ReelsItem({required this.video});

  final ShortVideo video;

  @override
  State<_ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<_ReelsItem> {
  VideoPlayerController? _controller;
  bool _initFailed = false;
  bool _liked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.video.likeCount;
    _syncLiked();
    if (widget.video.videoUrl.isNotEmpty) _initVideo();
    Future.microtask(() => VideoApi.recordView(widget.video.id));
  }

  Future<void> _syncLiked() async {
    try {
      final liked = await VideoApi.isLiked(widget.video.id);
      if (mounted) setState(() => _liked = liked);
    } on Exception {
      // 忽略
    }
  }

  Future<void> _initVideo() async {
    try {
      final c = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );
      await c.initialize();
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _initFailed = false;
      });
      c.setLooping(true);
      c.play();
    } on Exception {
      if (mounted) setState(() => _initFailed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    try {
      await VideoApi.toggleLike(widget.video.id);
    } on Exception {
      if (mounted) {
        setState(() {
          _liked = !_liked;
          _likeCount += _liked ? 1 : -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMedia(),
        // 渐变遮罩（底部信息可读性）
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black45],
              stops: [0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 14,
          right: 76,
          bottom: 64,
          child: _InfoPanel(video: v),
        ),
        Positioned(
          right: 12,
          bottom: 80,
          child: _ActionRail(
            video: v,
            liked: _liked,
            likeCount: _likeCount,
            onLike: _toggleLike,
          ),
        ),
        Positioned(
          left: 14,
          top: 8,
          child: const Row(
            children: [
              Text(
                '推荐',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedia() {
    final v = widget.video;
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: c.value.size.width,
          height: c.value.size.height,
          child: VideoPlayer(c),
        ),
      );
    }
    if (v.isPhoto && v.photos.isNotEmpty) {
      return Image.network(
        v.photos.first,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (v.cover.isNotEmpty && !_initFailed) {
      return Image.network(
        v.cover,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => const ColoredBox(
        color: Color(0xFF1D1D1F),
        child: Center(
          child: Icon(Icons.smart_display, color: Colors.white24, size: 64),
        ),
      );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.video});

  final ShortVideo video;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '@${video.user}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          video.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final t in video.tags.take(3))
              Text(
                '#$t',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                video.music.isEmpty ? '原声' : video.music,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.video,
    required this.liked,
    required this.likeCount,
    required this.onLike,
  });

  final ShortVideo video;
  final bool liked;
  final int likeCount;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Avatar(url: video.avatar, nickname: video.user),
        const SizedBox(height: 16),
        _RailButton(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          label: formatCount(likeCount),
          color: liked ? const Color(0xFFED4956) : Colors.white,
          onTap: onLike,
        ),
        const SizedBox(height: 16),
        _RailButton(
          icon: Icons.chat_bubble_outline,
          label: formatCount(video.commentCount),
          color: Colors.white,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        _RailButton(
          icon: Icons.share_outlined,
          label: formatCount(video.shareCount),
          color: Colors.white,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        const _RailButton(
          icon: Icons.more_horiz,
          label: '',
          color: Colors.white,
          onTap: null,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.nickname});

  final String url;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    final initial =
        nickname.isEmpty ? '?' : String.fromCharCode(nickname.runes.first);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFEDA75),
            Color(0xFFFA7E1E),
            Color(0xFFD62976),
            Color(0xFF962FBF),
            Color(0xFF4F5BD5),
          ],
        ),
      ),
      child: url.isEmpty
          ? Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ClipOval(
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white38, size: 44),
          const SizedBox(height: 12),
          const Text(
            '加载失败，请检查网络',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
