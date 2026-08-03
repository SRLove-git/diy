import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/community_models.dart';
import 'photo_viewer_page.dart';
import 'video_player_widget.dart';

/// 帖子媒体自适应展示系统
///
/// - 1 张图片：单张大图，宽 = 屏宽-32，按宽高比定高（最高 500），圆角 16
/// - 1 个视频：横屏(宽高比>1.3) 16:9 全宽；竖屏 9:16 全宽、限高 600 裁剪
/// - 2 / 3 / 4 张：2 / 3 / 2 列正方形网格（间距 6）
/// - 5-9 张：3×3 网格；超过 9 张时第 9 张叠加 "+剩余"
/// - 图片 + 视频混排：按媒体顺序统一进入网格
class MediaGrid extends StatelessWidget {
  const MediaGrid({super.key, required this.medias});

  final List<MediaItem> medias;

  @override
  Widget build(BuildContext context) {
    final media = medias;
    if (media.length == 1) {
      final m = media.first;
      if (m.type == MediaType.video) return _buildVideoBlock(m);
      return _buildSingleImage(context, m);
    }
    return _buildGrid(context, media);
  }

  // ── 单张图片 ────────────────────────────────────────────────

  Widget _buildSingleImage(BuildContext context, MediaItem item) {
    final maxWidth = MediaQuery.of(context).size.width - 32;
    final ratio = item.aspectRatio > 0 ? item.aspectRatio : 1.0;
    final width = math.min(maxWidth, MediaQuery.of(context).size.width);
    final height = math.min(width / ratio, 500.0);

    return Center(
      child: GestureDetector(
        onTap: () => _openViewer(context, [item], item),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: width,
            height: height,
            child: _cover(item),
          ),
        ),
      ),
    );
  }

  // ── 单视频（横屏 16:9 / 竖屏 9:16 限高裁剪） ────────────────

  Widget _buildVideoBlock(MediaItem item) {
    if (item.isLandscapeVideo) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayerWidget(item: item),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = math.min(width * 16 / 9, 600.0);
        return SizedBox(
          height: height,
          child: ClipRect(child: VideoPlayerWidget(item: item)),
        );
      },
    );
  }

  // ── 多图 / 混合网格 ─────────────────────────────────────────

  Widget _buildGrid(BuildContext context, List<MediaItem> media) {
    final count = media.length;
    // 2 / 3 / 4 张 → 2 / 3 / 2 列；5-9 张 → 3 列
    final crossAxisCount = count == 4 ? 2 : (count <= 3 ? count : 3);
    // 最多展示 9 张，超出在第 9 张叠加 "+剩余"
    final visible = media.take(9).toList();
    final hiddenCount = media.length - visible.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: visible.length,
        itemBuilder: (_, i) {
          final m = visible[i];
          final showPlus = i == 8 && hiddenCount > 0;
          return _GridTile(
            item: m,
            showPlus: showPlus,
            plusCount: hiddenCount,
            onTap: m.type == MediaType.image
                ? () => _openViewer(context, visible, m)
                : null,
          );
        },
      ),
    );
  }

  /// 打开图片查看器（仅图片，最多 9 张，保持原顺序）
  void _openViewer(
    BuildContext context,
    List<MediaItem> visible,
    MediaItem tapped,
  ) {
    final images = visible.where((m) => m.type == MediaType.image).toList();
    final index = images.indexWhere((m) => identical(m, tapped));
    if (index < 0) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PhotoViewerPage(images: images, initialIndex: index),
      ),
    );
  }

  /// 媒体封面（加载/失败兜底）
  Widget _cover(MediaItem item) {
    return Image.network(
      item.url,
      fit: BoxFit.cover,
      cacheWidth: 900,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Container(
          color: const Color(0xFFEFEEF2),
          child: const Center(
            child: Icon(Icons.image_outlined, color: Color(0xFFB8B8C4), size: 32),
          ),
        );
      },
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFEFEEF2),
        child: const Center(
          child: Icon(Icons.broken_image_outlined,
              color: Color(0xFFB8B8C4), size: 32),
        ),
      ),
    );
  }
}

/// 网格单元格：图片（可点开查看器）或视频（自管理播放）
class _GridTile extends StatelessWidget {
  const _GridTile({
    required this.item,
    required this.showPlus,
    required this.plusCount,
    this.onTap,
  });

  final MediaItem item;
  final bool showPlus;
  final int plusCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (item.type == MediaType.video) {
      return VideoPlayerWidget(item: item, borderRadius: 8);
    }
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.url,
              fit: BoxFit.cover,
              cacheWidth: 600,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return Container(
                  color: const Color(0xFFEFEEF2),
                  child: const Icon(Icons.image_outlined,
                      color: Color(0xFFB8B8C4)),
                );
              },
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFEFEEF2),
                child: const Icon(Icons.broken_image_outlined,
                    color: Color(0xFFB8B8C4)),
              ),
            ),
            // 第 9 张且仍有隐藏：深色遮罩 + "+剩余"
            if (showPlus)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                alignment: Alignment.center,
                child: Text(
                  '+$plusCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
