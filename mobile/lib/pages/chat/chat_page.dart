import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../widgets/state_widgets.dart';

enum _SendState { pending, sent, failed }

class _ViewMsg {
  _ViewMsg({required this.message, this.state = _SendState.sent});
  ChatMessage message;
  _SendState state;
}

/// 聊天页：单聊会话
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversation});

  final Conversation conversation;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgs = <_ViewMsg>[]; // 新的在前（配合 reverse ListView）
  final _input = TextEditingController();
  final _rand = Random();
  StreamSubscription<ChatEvent>? _sub;
  bool _loading = true;
  String? _error;
  int? _nextCursor;
  bool _loadingMore = false;
  late final int _meId;

  @override
  void initState() {
    super.initState();
    _meId = AuthService.instance.user?.id ?? 0;
    ChatService.instance.ensureConnected();
    ChatService.instance.markRead(widget.conversation.id);
    _sub = ChatService.instance.events.listen(_onEvent);
    _loadHistory();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _input.dispose();
    super.dispose();
  }

  void _onEvent(ChatEvent event) {
    if (event is NewMessageEvent) {
      final m = event.message;
      if (m.conversationId != widget.conversation.id) return;
      setState(() {
        if (!_msgs.any((vm) => vm.message.id != null && vm.message.id == m.id)) {
          _msgs.insert(0, _ViewMsg(message: m));
        }
      });
      // 对方消息：本地回执已读
      ChatService.instance.markRead(widget.conversation.id);
    } else if (event is ReadEvent) {
      if (event.conversationId != widget.conversation.id) return;
      final readAt = event.readAt ?? DateTime.now();
      setState(() {
        for (final vm in _msgs) {
          if (vm.message.senderId == _meId && vm.message.readAt == null) {
            vm.message = vm.message.copyWith(readAt: readAt);
          }
        }
      });
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await ChatApi.fetchMessages(widget.conversation.id);
      if (mounted) {
        setState(() {
          _msgs
            ..clear()
            ..addAll(r.items.reversed.map((m) => _ViewMsg(message: m)));
          _nextCursor = r.nextCursor;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = '加载失败，请重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final r = await ChatApi.fetchMessages(widget.conversation.id, cursor: cursor);
      if (mounted) {
        setState(() {
          _msgs.addAll(r.items.map((m) => _ViewMsg(message: m)));
          _nextCursor = r.nextCursor;
        });
      }
    } catch (_) {
      // 失败忽略，下次滚动到顶部再试
    } finally {
      _loadingMore = false;
    }
  }

  String _genMsgId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_rand.nextInt(1 << 32)}';

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    final clientMsgId = _genMsgId();
    final local = ChatMessage(
      id: null,
      conversationId: widget.conversation.id,
      senderId: _meId,
      content: text,
      createdAt: DateTime.now(),
      clientMsgId: clientMsgId,
    );
    setState(
      () => _msgs.insert(0, _ViewMsg(message: local, state: _SendState.pending)),
    );

    final confirmed = await ChatService.instance.sendMessage(
      conversationId: widget.conversation.id,
      content: text,
      clientMsgId: clientMsgId,
    );
    if (!mounted) return;
    setState(() {
      final idx = _msgs.indexWhere((vm) => vm.message.clientMsgId == clientMsgId);
      if (idx >= 0) {
        _msgs[idx] = confirmed != null
            ? _ViewMsg(message: confirmed)
            : _ViewMsg(message: local, state: _SendState.failed);
      }
    });
  }

  void _resend(_ViewMsg vm) {
    final clientMsgId = _genMsgId();
    final retry = ChatMessage(
      id: null,
      conversationId: widget.conversation.id,
      senderId: _meId,
      content: vm.message.content,
      createdAt: DateTime.now(),
      clientMsgId: clientMsgId,
    );
    final idx = _msgs.indexWhere((m) => identical(m, vm));
    setState(() {
      if (idx >= 0) {
        _msgs[idx] = _ViewMsg(message: retry, state: _SendState.pending);
      }
    });
    ChatService.instance
        .sendMessage(
          conversationId: widget.conversation.id,
          content: vm.message.content,
          clientMsgId: clientMsgId,
        )
        .then((confirmed) {
      if (!mounted) return;
      setState(() {
        final i = _msgs.indexWhere((m) => m.message.clientMsgId == clientMsgId);
        if (i >= 0) {
          _msgs[i] = confirmed != null
              ? _ViewMsg(message: confirmed)
              : _ViewMsg(message: retry, state: _SendState.failed);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title())),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessages()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  String _title() {
    final n = widget.conversation.peerNickname;
    return n.isEmpty ? '用户 #${widget.conversation.peerId}' : n;
  }

  Widget _buildMessages() {
    if (_loading) return const LoadingWidget();
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _loadHistory);
    }
    if (_msgs.isEmpty) {
      return const EmptyWidget(icon: Icons.chat_bubble_outline, message: '打个招呼吧');
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _msgs.length + 1, // 末尾一项：顶部加载更多
      itemBuilder: (_, i) {
        if (i == _msgs.length) {
          if (_nextCursor == null) return const SizedBox(height: 4);
          // 滚动到顶部可见时加载更早的消息
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
          return const Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final vm = _msgs[i];
        return _MessageBubble(
          vm: vm,
          meId: _meId,
          onResend: () => _resend(vm),
        );
      },
    );
  }

  Widget _buildInputBar() {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: '发消息…',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: colors.placeholder.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _send,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.vm,
    required this.meId,
    required this.onResend,
  });

  final _ViewMsg vm;
  final int meId;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final m = vm.message;
    final mine = m.senderId == meId;
    final colors = AppColors.of(context);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: mine ? colors.primary : colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              m.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: mine ? Colors.white : colors.textPrimary,
              ),
            ),
            if (mine) ...[
              const SizedBox(height: 2),
              _buildStatus(colors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(AppColors colors) {
    switch (vm.state) {
      case _SendState.pending:
        return Text(
          '发送中…',
          style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
        );
      case _SendState.failed:
        return InkWell(
          onTap: onResend,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 14, color: colors.danger),
              const SizedBox(width: 3),
              Text(
                '发送失败，点击重发',
                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        );
      case _SendState.sent:
        return Text(
          vm.message.readAt != null ? '已读' : '已发送',
          style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
        );
    }
  }
}
