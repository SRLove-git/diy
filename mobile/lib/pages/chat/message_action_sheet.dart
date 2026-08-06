import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';

/// 消息长按操作
enum MessageAction { copy, quote, forward, delete }

/// 引用快照预览 → 展示文本（text:xxx → xxx；媒体 → [图片]/[语音]/[视频]；已撤回 → 提示）
String chatPreviewText(String? preview) {
  if (preview == null || preview.isEmpty) return '';
  if (preview.startsWith('image:')) return '[图片]';
  if (preview.startsWith('voice:')) return '[语音]';
  if (preview.startsWith('video:')) return '[视频]';
  if (preview.startsWith('recalled:')) return '[原消息已撤回]';
  if (preview.startsWith('text:')) return preview.substring(5);
  return preview;
}

/// 微信风格长按操作面板（复制/引用/转发/删除）
Future<MessageAction?> showMessageActionSheet(
  BuildContext context, {
  required String contentType,
  required bool canQuote,
}) async {
  final actions = <MessageAction>[
    if (canQuote) MessageAction.quote,
    if (contentType == 'text') MessageAction.copy,
    MessageAction.forward,
    MessageAction.delete,
  ];
  if (actions.isEmpty) return null;
  return showModalBottomSheet<MessageAction>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ActionSheet(actions: actions),
  );
}

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({required this.actions});

  final List<MessageAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              childAspectRatio: 0.82,
              children: actions.map((a) => _actionItem(context, a)).toList(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  side: BorderSide(color: colors.textPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('取消'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionItem(BuildContext context, MessageAction action) {
    final colors = AppColors.of(context);
    final (icon, label) = switch (action) {
      MessageAction.copy => (Icons.copy_rounded, '复制'),
      MessageAction.quote => (Icons.format_quote_rounded, '引用'),
      MessageAction.forward => (Icons.shortcut_rounded, '转发'),
      MessageAction.delete => (Icons.delete_outline_rounded, '删除'),
    };
    final color = action == MessageAction.delete
        ? colors.danger
        : colors.textPrimary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).pop(action),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// 转发选择器：列出全部会话（先刷新缓存），选择后回调 [onForward]
Future<void> showForwardPicker(
  BuildContext context, {
  required Future<void> Function(Conversation conversation) onForward,
  int? excludeConversationId,
}) async {
  // 先刷新会话缓存，保证选择器里的会话是最新的
  await ChatService.instance.refreshConversations();
  if (!context.mounted) return;
  final list = ChatService.instance.conversations
      .where((c) => c.id != excludeConversationId)
      .toList();
  if (list.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('暂无可转发的会话')),
    );
    return;
  }
  final colors = AppColors.of(context);
  final selected = await showModalBottomSheet<Conversation>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '转发给',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = list[i];
                  return ListTile(
                    leading: _ForwardAvatar(c),
                    title: Text(
                      c.peerNickname.isEmpty
                          ? '用户 #${c.peerId}'
                          : c.peerNickname,
                      style: const TextStyle(fontSize: 15),
                    ),
                    subtitle: Text(
                      c.lastMessageText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (selected != null) await onForward(selected);
}

class _ForwardAvatar extends StatelessWidget {
  const _ForwardAvatar(this.conversation);

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final url = conversation.peerAvatar.trim();
    final hasImage = url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
    final name = conversation.peerNickname.trim();
    final initial = name.isEmpty ? '?' : String.fromCharCode(name.runes.first);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.placeholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              ChatApi.resolveUrl(url),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
            ),
    );
  }
}
