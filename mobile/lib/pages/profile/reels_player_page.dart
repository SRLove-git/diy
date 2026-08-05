import 'package:flutter/material.dart';

import '../../core/chat_api.dart';
import '../../core/video_api.dart';
import '../../features/community/domain/community_models.dart';
import '../../features/community/presentation/widgets/video_player_widget.dart';
import '../short_video_models.dart';

/// Reels 全屏播放页（个人主页）
///
/// 视频作品走真实播放器（加载失败自动回退封面模拟进度）；
/// 照片作品展示封面大图。进入时上报一次浏览。
class ReelsPlayerPage extends StatefulWidget {
  const ReelsPlayerPage({super.key, required this.video});

  final ShortVideo video;

  @override
  State<ReelsPlayerPage> createState() => _ReelsPlayerPageState();
}

class _ReelsPlayerPageState extends State<ReelsPlayerPage> {
  @override
  void initState() {
    super.initState();
    VideoApi.recordView(widget.video.id).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final isPhoto = video.isPhoto || video.videoUrl.isEmpty;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: isPhoto
                ? _buildPhoto(video)
                : VideoPlayerWidget(
                    item: MediaItem(
                      type: MediaType.video,
                      url: video.videoUrl.isNotEmpty
                          ? video.videoUrl
                          : video.cover,
                      duration: video.duration,
                      aspectRatio: video.aspectRatio > 0
                          ? video.aspectRatio
                          : 9 / 16,
                    ),
                    borderRadius: 0,
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
          // 底部信息
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
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
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF718D),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${video.likeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${video.commentCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  Widget _buildPhoto(ShortVideo video) {
    final photo = video.photos.isNotEmpty
        ? video.photos.first
        : video.cover;
    if (photo.isEmpty) {
      return const ColoredBox(
        color: Color(0xFF181818),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Colors.white38,
            size: 48,
          ),
        ),
      );
    }
    return Image.network(
      ChatApi.resolveUrl(photo),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFF181818),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Colors.white38,
            size: 48,
          ),
        ),
      ),
    );
  }
}
