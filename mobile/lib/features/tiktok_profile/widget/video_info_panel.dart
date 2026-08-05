import 'package:flutter/material.dart';

import '../model/tiktok_video_model.dart';
import 'music_marquee.dart';

/// 播放页底部信息面板（widget 组件层）
///
/// 抖音式布局：
/// - 作者昵称（小字，标题上方）；
/// - 作品简介文案（最多两行，加粗白字）；
/// - 话题标签（`#手作` 灰白字）；
/// - 背景音乐跑马灯（音乐名过长时横向滚动 + 旋转唱片）。
///
/// 整个面板不接收手势（外层由播放页包 IgnorePointer），
/// 保证竖屏上下滑动视频时手势穿透。
class VideoInfoPanel extends StatelessWidget {
  const VideoInfoPanel({
    super.key,
    required this.item,
    required this.nickname,
  });

  final TiktokVideoModel item;

  /// 作者昵称（个人主页视频页固定显示当前用户昵称）
  final String nickname;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 作者昵称
        Text(
          '@$nickname',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
        if (item.title.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
        if (item.tags.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            item.tags.map((t) => '#$t').join(' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
        ],
        if (item.music.isNotEmpty) ...[
          const SizedBox(height: 9),
          MusicMarquee(
            text: item.music,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
