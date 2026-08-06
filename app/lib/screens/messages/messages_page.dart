import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../core/user_api.dart';
import 'chat_page.dart';

/// 消息页：会话列表（实时 WebSocket 更新 + 未读角标）
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool _searching = false;

  Future<void> _refresh() async {
    await Future.wait([
      ChatService.instance.refreshConversations(),
      ChatService.instance.refreshGroups(),
    ]);
  }

  Future<void> _newConversation() async {
    final phone = await showDialog<String>(
      context: context,
      builder: (_) => const _FindUserDialog(),
    );
    if (phone == null || phone.isEmpty || !mounted) return;
    setState(() => _searching = true);
    try {
      final users = await UserApi.searchByPhone(phone);
      if (users.isEmpty) {
        _toast('未找到该手机号用户');
        return;
      }
      final conv = await ChatApi.createConversation(users.first.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatPage(conversation: conv),
        ),
      );
      _refresh();
    } on DioException catch (e) {
      _toast(ChatApi.messageOf(e));
    } on Exception {
      _toast('网络异常，请稍后再试');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '消息',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _searching ? null : _newConversation,
                    icon: const Icon(
                      Icons.edit_square,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: ChatService.instance,
                builder: (context, _) {
                  final conversations = ChatService.instance.conversations;
                  if (conversations.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 160),
                          Icon(Icons.chat_bubble_outline,
                              color: Color(0xFFA8A8A8), size: 48),
                          SizedBox(height: 12),
                          Center(
                            child: Text(
                              '暂无会话，点击右上角发起新聊天',
                              style: TextStyle(color: Color(0xFFA8A8A8)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 76),
                      itemBuilder: (context, i) {
                        final c = conversations[i];
                        return _ConversationTile(
                          conversation: c,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatPage(conversation: c),
                              ),
                            );
                            _refresh();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final avatar = c.peerAvatar.isEmpty
        ? ''
        : ChatApi.resolveUrl(c.peerAvatar);
    final initial = c.peerNickname.isEmpty
        ? '?'
        : String.fromCharCode(c.peerNickname.runes.first);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFEDA75),
                        Color(0xFFFA7E1E),
                        Color(0xFFD62976),
                        Color(0xFF962FBF),
                        Color(0xFF4F5BD5),
                      ],
                    ),
                  ),
                  child: avatar.isEmpty
                      ? Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : ClipOval(
                          child: Image.network(
                            avatar,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                if (c.peerOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E9E5B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.peerNickname,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.unreadCount > 0
                          ? const Color(0xFF111111)
                          : const Color(0xFFA8A8A8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _timeLabel(c.lastMessageAt),
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFFA8A8A8)),
                ),
                const SizedBox(height: 6),
                if (c.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFED4956),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      c.unreadCount > 99 ? '99+' : '${c.unreadCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(DateTime? t) {
    if (t == null) return '';
    final local = t.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) {
      return '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    }
    if (day == today.subtract(const Duration(days: 1))) return '昨天';
    return '${local.month}月${local.day}日';
  }
}

class _FindUserDialog extends StatefulWidget {
  const _FindUserDialog();

  @override
  State<_FindUserDialog> createState() => _FindUserDialogState();
}

class _FindUserDialogState extends State<_FindUserDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发起聊天', style: TextStyle(fontSize: 17)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          hintText: '输入对方手机号',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
          child: const Text('查找'),
        ),
      ],
    );
  }
}
