import 'package:flutter/material.dart';

import '../../../core/chat_api.dart';
import '../../../features/community/presentation/community_palette.dart';

/// Instagram 风格共享设计令牌与小组件。
///
/// 供主页信息流 / Reels / DM 三块复用：IG 品牌蓝、故事渐变环、
/// 相对时间文案、带兜底的头像组件。
class IgColors {
  IgColors._();

  /// Instagram 品牌蓝（链接 / 关注按钮 / 已读标记）
  static const blue = Color(0xFF0095F6);

  /// 对方消息气泡（浅色模式）
  static const bubbleIncoming = Color(0xFFF0F1F2);

  /// 对方消息气泡（深色模式）
  static const bubbleIncomingDark = Color(0xFF262626);

  /// 故事未读渐变环（Instagram 官方五色）
  static const storyGradient = CommunityPalette.storyGradient;

  /// 故事已读环
  static const storySeen = Color(0xFFDBDBDB);
}

/// 把时间格式化为 Instagram 风格相对时间（刚刚 / N 分钟前 / N 小时前 /
/// 昨天 / M 月 D 日 / YYYY 年 M 月 D 日）。
String formatAgo(DateTime? time) {
  if (time == null) return '';
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inSeconds < 60) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
  if (diff.inHours < 24) return '${diff.inHours} 小时前';
  if (diff.inDays < 2) return '昨天';
  if (time.year == now.year) return '${time.month} 月 ${time.day} 日';
  return '${time.year} 年 ${time.month} 月 ${time.day} 日';
}

/// 通用头像：网络图 + 首字兜底。
///
/// [size] 圆形直径；[id] 决定兜底渐变（同一用户颜色稳定）。
class IgAvatar extends StatelessWidget {
  const IgAvatar({
    super.key,
    required this.url,
    required this.name,
    required this.size,
    this.id = 0,
  });

  final String url;
  final String name;
  final double size;
  final int id;

  bool get _valid =>
      url.startsWith('http://') ||
      url.startsWith('https://') ||
      url.startsWith('/uploads/');

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: CommunityPalette.avatarGradientFor(id),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name.characters.first,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: _valid
            ? Image.network(
                ChatApi.resolveUrl(url),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              )
            : fallback,
      ),
    );
  }
}

/// 故事环：外层 Instagram 渐变圈（未读）/ 灰圈（已读），内层白边 + 头像。
class StoryRing extends StatelessWidget {
  const StoryRing({
    super.key,
    required this.url,
    required this.name,
    this.size = 64,
    this.seen = false,
    this.id = 0,
  });

  final String url;
  final String name;
  final double size;
  final bool seen;
  final int id;

  @override
  Widget build(BuildContext context) {
    final ringWidth = size * 0.06;
    final innerGap = ringWidth * 0.8;
    final avatarSize = size - 2 * ringWidth - 2 * innerGap;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: seen
            ? null
            : SweepGradient(
                colors: IgColors.storyGradient,
                transform: const GradientRotation(0.2),
              ),
        color: seen ? IgColors.storySeen : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(ringWidth),
        child: Container(
          padding: EdgeInsets.all(innerGap),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: IgAvatar(
              url: url,
              name: name,
              size: avatarSize,
              id: id,
            ),
          ),
        ),
      ),
    );
  }
}
