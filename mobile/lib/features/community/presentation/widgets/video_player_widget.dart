import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/chat_api.dart';
import '../../domain/community_models.dart';

/// 视频组件：真实视频流播放（`video_player`）。
///
/// 媒体项为视频时优先初始化真实网络播放器；视频流加载失败
/// （如开发期占位封面）时回退到封面图 + 模拟进度，保证 UI 不中断。
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.item,
    this.borderRadius = 16,
  });

  final MediaItem item;

  /// 圆角，默认 16（网格内小方块可传更小值）
  final double borderRadius;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  late final Duration _total =
      widget.item.duration ?? const Duration(seconds: 30);

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _total);

  bool _playing = false;

  /// 真实视频播放器；初始化失败时保持 null 走模拟封面
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      // 播完自动回到暂停态并复位进度
      if (status == AnimationStatus.completed) {
        setState(() => _playing = false);
        _controller.reset();
      }
    });
    if (widget.item.type == MediaType.video && _looksLikeVideo(widget.item.url)) {
      _initVideo();
    }
  }

  /// 是否为真实视频地址（排除 picsum 等占位图片）
  static bool _looksLikeVideo(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('picsum.photos') || lower.contains('pravatar.cc')) {
      return false;
    }
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('/uploads/video');
  }

  Future<void> _initVideo() async {
    final ctrl = VideoPlayerController.networkUrl(
      Uri.parse(ChatApi.resolveUrl(widget.item.url)),
    );
    _videoCtrl = ctrl;
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      if (!mounted) return;
      setState(() => _videoReady = true);
    } catch (_) {
      // 播放失败回退模拟封面（_videoReady 保持 false）
      ctrl.dispose();
      if (_videoCtrl == ctrl) _videoCtrl = null;
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        if (_videoReady) {
          _videoCtrl?.play();
        } else {
          _controller.forward(from: _controller.value);
        }
      } else {
        if (_videoReady) {
          _videoCtrl?.pause();
        } else {
          _controller.stop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final video = _videoCtrl;
    return GestureDetector(
      onTap: _toggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 真实视频画面（就绪时）
            if (_videoReady && video != null)
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: video.value.size.width,
                  height: video.value.size.height,
                  child: VideoPlayer(video),
                ),
              )
            else
              _buildCover(),
            // 中央播放/暂停键
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70),
                ),
                child: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            // 播放进度条 / 时长徽标
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: _playing ? _buildProgress(video) : _buildDurationBadge(video),
            ),
          ],
        ),
      ),
    );
  }

  /// 封面（真实播放器就绪前 / 回退时展示）
  Widget _buildCover() {
    return Image.network(
      ChatApi.resolveUrl(widget.item.url),
      fit: BoxFit.cover,
      cacheWidth: 900,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Container(
          color: const Color(0xFFE9E9EF),
          child: const Center(
            child: Icon(Icons.play_circle_outline_rounded,
                color: Color(0xFFB8B8C4), size: 40),
          ),
        );
      },
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFE9E9EF),
        child: const Center(
          child: Icon(Icons.videocam_off_outlined,
              color: Color(0xFFB8B8C4), size: 40),
        ),
      ),
    );
  }

  String get _timeText {
    final s = _total.inSeconds % 60;
    final m = _total.inMinutes % 60;
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '0:$s';
  }

  /// 播放中：底部细进度条（真实播放器读 position，模拟封面读动画）
  Widget _buildProgress(VideoPlayerController? video) {
    if (video != null && _videoReady) {
      return ValueListenableBuilder(
        valueListenable: video,
        builder: (context, value, _) {
          final total = value.duration.inMilliseconds;
          final pos = value.position.inMilliseconds;
          final progress = total > 0 ? pos / total : 0.0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          );
        },
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: _controller.value,
          minHeight: 3,
          backgroundColor: Colors.white24,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 暂停：右下角时长徽标
  Widget _buildDurationBadge(VideoPlayerController? video) {
    var text = _timeText;
    if (video != null && _videoReady && video.value.duration.inSeconds > 0) {
      final total = video.value.duration.inSeconds;
      text = '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
    }
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
