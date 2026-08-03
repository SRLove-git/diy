import 'package:flutter/material.dart';

import '../../domain/community_models.dart';

/// 视频组件（Mock 播放）
///
/// 封面图 + 中央播放/暂停键 + 视频圆角 16 + 时长/播放进度。
/// 采用 AnimationController 模拟播放进度，不依赖真实视频流；
/// 接入真实视频时，将封面图替换为 `video_player` 的 VideoPlayer 即可。
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _controller.forward(from: _controller.value);
      } else {
        _controller.stop();
      }
    });
  }

  String get _timeText {
    final s = _total.inSeconds % 60;
    final m = _total.inMinutes % 60;
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '0:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 封面图
            Image.network(
              widget.item.url,
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
            ),
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
              child: _playing ? _buildProgress() : _buildDurationBadge(),
            ),
          ],
        ),
      ),
    );
  }

  /// 播放中：底部细进度条
  Widget _buildProgress() {
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
  Widget _buildDurationBadge() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _timeText,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
