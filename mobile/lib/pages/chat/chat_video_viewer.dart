import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/chat_api.dart';

/// 聊天视频全屏播放页：进入自动播放，点击暂停/继续
class ChatVideoViewer extends StatefulWidget {
  const ChatVideoViewer({super.key, required this.url, this.localPath});

  /// 服务端相对/绝对地址
  final String url;

  /// 上传中/失败时的本地视频文件
  final String? localPath;

  @override
  State<ChatVideoViewer> createState() => _ChatVideoViewerState();
}

class _ChatVideoViewerState extends State<ChatVideoViewer> {
  VideoPlayerController? _ctrl;
  bool _failed = false;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final VideoPlayerController ctrl;
    try {
      final local = widget.localPath;
      if (local != null && File(local).existsSync()) {
        ctrl = VideoPlayerController.file(File(local));
      } else {
        ctrl = VideoPlayerController.networkUrl(
          Uri.parse(ChatApi.resolveUrl(widget.url)),
        );
      }
      await ctrl.initialize();
      await ctrl.setLooping(false);
      await ctrl.play();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      setState(() => _ctrl = ctrl);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _controlsVisible = !_controlsVisible);
    final c = _ctrl;
    if (c == null) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 用 SizedBox.expand 让 Stack 铺满整个窗口，避免 Stack 按非定位子组件
      // （顶栏）收缩，导致视频播放区域被顶到窗口顶部。
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: _buildVideo(),
              ),
            ),
            // 顶栏：返回 + 标题（只避让顶部安全区）
            AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      '视频消息',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            if (_failed)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        color: Colors.white54, size: 56),
                    SizedBox(height: 10),
                    Text(
                      '视频加载失败',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            if (_ctrl != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: _buildProgress(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo() {
    final c = _ctrl;
    if (c == null && !_failed) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
      );
    }
    if (c == null) return const SizedBox.shrink();
    return Center(
      child: AspectRatio(
        aspectRatio: c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9,
        child: VideoPlayer(c),
      ),
    );
  }

  Widget _buildProgress() {
    final c = _ctrl!;
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: c,
      builder: (context, value, _) {
        final total = value.duration.inMilliseconds;
        final pos = value.position.inMilliseconds;
        final progress = total > 0 ? pos / total : 0.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_fmt(value.position)} / ${_fmt(value.duration)}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        );
      },
    );
  }

  String _fmt(Duration d) {
    final s = d.inSeconds % 60;
    final m = d.inMinutes % 60;
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '0:${s.toString().padLeft(2, '0')}';
  }
}
