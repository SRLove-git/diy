import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/video_api.dart';
import '../model/tiktok_video_model.dart';

/// 播放页「更多」操作弹层（widget 组件层）
///
/// 深色圆角底部弹层，提供不感兴趣 / 举报 / 复制链接等常规操作。
/// 举报走真实服务端接口（与社区帖子同一套举报体系），复制链接写系统剪贴板。
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
              onTap: () => _report(context),
            ),
            _MoreTile(
              icon: Icons.link_rounded,
              label: '复制作品链接',
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: 'https://diy.example.com/video/${item.id}'),
                );
                if (!context.mounted) return;
                _toast(context, '链接已复制');
              },
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

  Future<void> _report(BuildContext context) async {
    Navigator.of(context).pop();
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('举报作品'),
        content: TextField(
          controller: controller,
          maxLength: 200,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '请描述举报原因…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('提交举报'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.isEmpty) return;
    try {
      await VideoApi.report(item.id, reason);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('举报已提交，我们会尽快处理'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('举报失败，请稍后再试'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
