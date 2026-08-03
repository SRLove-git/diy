import 'package:flutter/material.dart';

import '../../domain/community_models.dart';
import '../community_palette.dart';

/// 社区圆形头像
///
/// - 支持外圈渐变环（故事未读态）
/// - 无头像 URL 时使用稳定渐变 + 首字兜底
class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({
    super.key,
    required this.user,
    this.size = 44,
    this.ringColors,
    this.onTap,
  });

  final CommunityUser user;
  final double size;

  /// 外圈渐变环；为 null 时不画环
  final List<Color>? ringColors;
  final VoidCallback? onTap;

  static const _innerGap = 2.5; // 渐变环与头像之间的留白

  @override
  Widget build(BuildContext context) {
    final ring = ringColors;
    final innerSize = ring == null ? size : size - _innerGap * 2;

    final avatar = ClipOval(
      child: SizedBox.square(
        dimension: innerSize,
        child: user.avatarUrl.isEmpty ? _initialAvatar() : _networkAvatar(innerSize),
      ),
    );

    final content = ring == null
        ? avatar
        : Container(
            padding: const EdgeInsets.all(_innerGap),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ring,
              ),
            ),
            child: avatar,
          );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(dimension: size, child: content),
    );
  }

  /// 渐变 + 首字兜底头像（断网/无头像时保证视觉完整）
  Widget _initialAvatar() {
    final colors = CommunityPalette.avatarGradientFor(user.id);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          user.initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _networkAvatar(double size) {
    return Image.network(
      user.avatarUrl,
      fit: BoxFit.cover,
      cacheWidth: (size * 3).round(),
      errorBuilder: (_, _, _) => _initialAvatar(),
    );
  }
}
