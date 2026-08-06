import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';

/// 单聊页：历史消息 + WebSocket 实时收发
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversation});

  final Conversation conversation;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;

  int get _conversationId => widget.conversation.id;
  String get _peerName => widget.conversation.peerNickname;

  @override
  void initState() {
    super.initState();
    ChatService.instance.events.listen(_onEvent);
    _load();
    ChatApi.markRead(_conversationId);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await ChatApi.fetchMessages(_conversationId, limit: 50);
      if (!mounted) return;
      setState(() {
        _messages = result.items;
        _loading = false;
      });
      _scrollToBottom();
    } on Exception {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onEvent(ChatEvent event) {
    if (!mounted) return;
    if (event is NewMessageEvent &&
        event.message.conversationId == _conversationId) {
      setState(() => _messages = [..._messages, event.message]);
      _scrollToBottom();
      ChatApi.markRead(_conversationId);
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final clientMsgId = _genId();
    try {
      final confirmed = await ChatService.instance.sendMessage(
        conversationId: _conversationId,
        content: text,
        clientMsgId: clientMsgId,
      );
      if (!mounted) return;
      if (confirmed != null) {
        setState(() => _messages = [..._messages, confirmed]);
      } else {
        setState(() {
          _messages = [
            ..._messages,
            ChatMessage(
              conversationId: _conversationId,
              senderId: AuthService.instance.user?.id ?? 0,
              content: text,
              clientMsgId: clientMsgId,
              createdAt: DateTime.now(),
            ),
          ];
        });
      }
      _inputCtrl.clear();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _genId() {
    final rand = Random().nextInt(1 << 32);
    return '${DateTime.now().millisecondsSinceEpoch}-$rand';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = AuthService.instance.user?.id;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111111),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          children: [
            Text(
              _peerName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.conversation.peerOnline ? '在线' : '',
              style: const TextStyle(fontSize: 11, color: Color(0xFFA8A8A8)),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final mine = m.senderId == myId;
                return _Bubble(message: m, mine: mine);
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: '发消息…',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFA8A8A8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sending ? null : _send,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_upward, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final recalled = message.recalledAt != null;
    final text = switch (message.contentType) {
      'image' => '[图片]',
      'voice' => '[语音]',
      'video' => '[视频]',
      _ => message.content,
    };
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: mine
              ? const Color(0xFF111111)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          recalled ? '该消息已撤回' : text,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.4,
            color: mine ? Colors.white : const Color(0xFF111111),
            fontStyle: recalled ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}
