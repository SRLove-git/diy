import 'package:flutter/material.dart';

import '../model/tiktok_video_model.dart';

/// 播放页「更多」操作弹层（widget 组件层）
///
/// 深色圆角底部弹层，提供不感兴趣 / 举报 / 复制链接等常规操作。
/// 交互暂为演示（SnackBar 提示），后续可接入举报与推荐屏蔽接口。
class VideoMoreSheet extends StatelessWidget {
  const VideoMoreSheet({super.key, required this.item});

  final TiktokVideoModel item;

  static Future<void> show(BuildContext context, TiktokVideoModel item) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoMoreSheet(item: item),
    );
  }

  void _toast(BuildContext context, String msg) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _MoreTile(
              icon: Icons.visibility_off_outlined,
              label: '不感兴趣',
              onTap: () => _toast(context, '已标记为不感兴趣'),
            ),
            _MoreTile(
              icon: Icons.flag_outlined,
              label: '举报作品',
              onTap: () => _toast(context, '举报功能开发中'),
            ),
            _MoreTile(
              icon: Icons.link_rounded,
              label: '复制作品链接',
              onTap: () => _toast(context, '链接已复制（演示）'),
            ),
            _MoreTile(
              icon: Icons.cancel_outlined,
              label: '取消',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 21),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
            ),
          ],
        ),
      ),
    );
  }
}
