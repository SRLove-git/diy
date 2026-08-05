import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'auth_service.dart';
import 'chat_api.dart';
import 'local_chat_store.dart';
import 'config.dart';

/// 聊天事件（实时流，页面订阅）
sealed class ChatEvent {
  const ChatEvent();
}

/// 收到新消息（对方发来的）
class NewMessageEvent extends ChatEvent {
  const NewMessageEvent(this.message);
  final ChatMessage message;
}

/// 收到新群消息
class GroupNewMessageEvent extends ChatEvent {
  const GroupNewMessageEvent(this.message);
  final GroupMessage message;
}

/// 对端已读
class ReadEvent extends ChatEvent {
  const ReadEvent(this.conversationId, this.readerId, this.readAt);
  final int conversationId;
  final int readerId;
  final DateTime? readAt;
}

/// 用户在线状态变化
class PresenceEvent extends ChatEvent {
  const PresenceEvent(this.userId, this.online);
  final int userId;
  final bool online;
}

/// 聊天受限：未互相关注且已发满 3 条，服务端拒绝发送
class ChatLimitEvent extends ChatEvent {
  const ChatLimitEvent(this.clientMsgId, this.reason);
  final String clientMsgId;
  final String reason;
}

/// 连接状态
enum ChatConnectionState { disconnected, connecting, connected }

/// 聊天连接管理：WebSocket 实时收发 + 断线重连 + REST 兜底。
class ChatService extends ChangeNotifier with WidgetsBindingObserver {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _events = StreamController<ChatEvent>.broadcast();
  final _pendingSends = <String, Completer<ChatMessage?>>{};
  final _pendingGroupSends = <String, Completer<GroupMessage?>>{};
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _heartbeat;
  Timer? _reconnectTimer;
  ChatConnectionState _state = ChatConnectionState.disconnected;
  bool _manualClose = false;
  int _reconnectAttempt = 0;

  /// 会话列表缓存（列表页/入口角标共用）
  List<Conversation> conversations = const [];

  /// 群聊列表缓存
  List<GroupChat> groups = const [];

  /// 在线状态缓存：userId -> 在线（presence 事件更新）
  final Map<int, bool> _presence = {};

  ChatConnectionState get state => _state;
  bool get connected => _state == ChatConnectionState.connected;
  Stream<ChatEvent> get events => _events.stream;

  /// 查询指定用户是否在线（缺省回退到会话列表缓存）
  bool isPeerOnline(int userId) => _presence[userId] ?? false;

  /// 未读总数（单聊 + 群聊，供入口角标）
  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount) +
      groups.fold(0, (sum, g) => sum + g.unreadCount);

  /// 连接地址：http(s)://host:port/api → ws(s)://host:port/ws
  static Uri _wsUri() {
    final api = Uri.parse(AppConfig.apiBaseUrl);
    final scheme = api.scheme == 'https' ? 'wss' : 'ws';
    return Uri.parse('$scheme://${api.authority}/ws');
  }

  /// 登录后确保连接
  void ensureConnected() {
    WidgetsBinding.instance.addObserver(this);
    if (_channel != null || !AuthService.instance.isLoggedIn) return;
    _manualClose = false;
    _connect();
  }

  /// 登出时断开
  void disconnect() {
    WidgetsBinding.instance.removeObserver(this);
    _manualClose = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _closeChannel();
    conversations = const [];
    groups = const [];
    _setState(ChatConnectionState.disconnected);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 回到前台：连接已断则立即重连
    if (state == AppLifecycleState.resumed && !_manualClose && _channel == null) {
      _connect();
    }
  }

  void _connect() {
    final token = AuthService.instance.accessToken;
    if (token == null) return;
    _setState(ChatConnectionState.connecting);
    final uri = _wsUri().replace(queryParameters: {'token': token});
    try {
      _channel = WebSocketChannel.connect(uri);
    } catch (_) {
      _scheduleReconnect();
      return;
    }
    _sub = _channel!.stream.listen(
      _onFrame,
      onDone: _onDisconnected,
      onError: (_) => _onDisconnected(),
      cancelOnError: true,
    );
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(
      const Duration(seconds: 25),
      (_) => _sendBin({'type': 'ping'}),
    );
  }

  void _onFrame(dynamic raw) {
    // 二进制帧：msgpack 解码
    if (raw is! List<int>) return;
    final Map<String, dynamic> frame;
    try {
      frame = Map<String, dynamic>.from(
          deserialize(Uint8List.fromList(raw)) as Map);
    } catch (_) {
      return;
    }
    try {
      switch (frame['type']) {
        case 'sent':
          final clientMsgId = (frame['clientMsgId'] ?? '') as String;
          final message =
              ChatMessage.fromJson(frame['message'] as Map<String, dynamic>);
          _pendingSends.remove(clientMsgId)?.complete(message);
          // 本地回填服务端 id，置为已发送
          if (message.id != null) {
            LocalChatStore.instance.markSent(clientMsgId, message.id!);
          }
          break;
        case 'groupSent':
          final gClientMsgId = (frame['clientMsgId'] ?? '') as String;
          final gMessage =
              GroupMessage.fromJson(frame['message'] as Map<String, dynamic>);
          _pendingGroupSends.remove(gClientMsgId)?.complete(gMessage);
          break;
        case 'groupNewMessage':
          final rawGroupMsg = frame['message'];
          if (rawGroupMsg is! Map) return;
          final groupMessage = GroupMessage.fromJson(
            Map<String, dynamic>.from(rawGroupMsg),
          );
          _onGroupNewMessage(groupMessage);
          break;
        case 'newMessage':
          final rawMsg = frame['message'];
          if (rawMsg is! Map) return;
          final message = ChatMessage.fromJson(Map<String, dynamic>.from(rawMsg));
          _onNewMessage(message);
          break;
        case 'read':
          final conversationId = (frame['conversationId'] as num).toInt();
          // 本地缓存：对端已读回执
          LocalChatStore.instance.markRead(conversationId);
          _events.add(ReadEvent(
            conversationId,
            (frame['readerId'] as num).toInt(),
            frame['readAt'] != null
                ? DateTime.tryParse(frame['readAt'] as String)
                : null,
          ));
          break;
        case 'presence':
          _applyPresence(
            (frame['userId'] as num).toInt(),
            frame['online'] == true,
          );
          break;
        case 'error':
          final code = (frame['code'] ?? '') as String;
          if (code == 'chat_limited') {
            // 聊天受限：完成等待（不重发），并通知页面移除气泡 + 提示原因
            final clientMsgId = (frame['clientMsgId'] ?? '') as String;
            _pendingSends.remove(clientMsgId)?.complete(null);
            _events.add(ChatLimitEvent(
              clientMsgId,
              (frame['message'] ?? '聊天受限') as String,
            ));
          } else if (code == 'send_failed') {
            final clientMsgId = (frame['clientMsgId'] ?? '') as String;
            _pendingSends.remove(clientMsgId)?.complete(null);
          } else if (code == 'unauthorized' ||
              code == 'token_expired') {
            // token 过期：断开当前连接，刷新后重连
            _closeChannel();
            _setState(ChatConnectionState.disconnected);
            AuthService.instance.tryRefresh().then((ok) {
              if (ok && !_manualClose) _connect();
            });
          }
          break;
      }
    } catch (_) {
      // 单帧解析失败不影响 WebSocket 连接
    }
  }

  void _onNewMessage(ChatMessage message) {
    // 本地缓存落库（以 server_id 去重，幂等）
    LocalChatStore.instance.saveIncoming(message);
    // 更新会话缓存：预览 + 未读数（置顶会话保持在置顶区）
    final idx = conversations.indexWhere((c) => c.id == message.conversationId);
    if (idx >= 0) {
      final old = conversations[idx];
      final list = [...conversations];
      final prefix = switch (message.contentType) {
        'image' => 'image:',
        'voice' => 'voice:',
        _ => 'text:',
      };
      list[idx] = old.copyWith(
        lastMessagePreview: '$prefix${message.content}',
        lastMessageAt: message.createdAt,
        unreadCount: old.unreadCount + 1,
      );
      _sortConversations(list);
      conversations = list;
    }
    notifyListeners();
    _events.add(NewMessageEvent(message));
  }

  /// 新群消息：更新群缓存（预览 + 未读数）并广播事件
  void _onGroupNewMessage(GroupMessage message) {
    final idx = groups.indexWhere((g) => g.id == message.groupId);
    if (idx >= 0) {
      final old = groups[idx];
      final list = [...groups];
      final prefix = switch (message.contentType) {
        'image' => 'image:',
        'voice' => 'voice:',
        _ => 'text:',
      };
      list[idx] = old.copyWith(
        lastMessagePreview: '$prefix${message.content}',
        lastMessageAt: message.createdAt,
        unreadCount: old.unreadCount + 1,
      );
      _sortGroups(list);
      groups = list;
    }
    notifyListeners();
    _events.add(GroupNewMessageEvent(message));
  }

  /// 在线状态变化：更新缓存 + 同步会话列表中的对端在线标记
  void _applyPresence(int userId, bool online) {
    _presence[userId] = online;
    var changed = false;
    final list = [...conversations];
    for (var i = 0; i < list.length; i++) {
      if (list[i].peerId == userId && list[i].peerOnline != online) {
        list[i] = list[i].copyWith(peerOnline: online);
        changed = true;
      }
    }
    if (changed) conversations = list;
    notifyListeners();
    _events.add(PresenceEvent(userId, online));
  }

  /// 置顶会话在前，组内按最后消息时间倒序（与服务端排序一致）
  static void _sortConversations(List<Conversation> list) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return (b.lastMessageAt ?? epoch).compareTo(a.lastMessageAt ?? epoch);
    });
  }

  /// 群聊按最后消息时间倒序（与服务端排序一致）
  static void _sortGroups(List<GroupChat> list) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    list.sort(
      (a, b) => (b.lastMessageAt ?? epoch).compareTo(a.lastMessageAt ?? epoch),
    );
  }

  void _onDisconnected() {
    _closeChannel();
    _setState(ChatConnectionState.disconnected);
    if (!_manualClose) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: min(30, 1 << _reconnectAttempt));
    _reconnectAttempt++;
    _reconnectTimer = Timer(delay, () async {
      if (_manualClose || !AuthService.instance.isLoggedIn) return;
      final token = AuthService.instance.accessToken;
      if (token == null) return;
      // token 已过期：先刷新；刷新失败则跳过本轮，等下一轮退避重连，
      // 避免反复用旧 token 连接被服务端 4001 拒绝形成无效循环
      if (_isTokenExpired(token)) {
        final ok = await AuthService.instance.tryRefresh();
        if (!ok || _manualClose || !AuthService.instance.isLoggedIn) return;
      }
      _connect();
    });
  }

  /// 判断 access token 是否已过期（解析 JWT payload 的 exp 字段）；
  /// 解析失败视为未过期，交由连接结果兜底
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      final padded = normalized.padRight(
        normalized.length + ((4 - normalized.length % 4) % 4),
        '=',
      );
      final payload = utf8.decode(base64.decode(padded));
      final exp = ((jsonDecode(payload) as Map)['exp'] as num?)?.toInt();
      if (exp == null) return false;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
    } catch (_) {
      return false;
    }
  }

  void _closeChannel() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _sub?.cancel();
    _sub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void _setState(ChatConnectionState s) {
    if (_state == s) return;
    _state = s;
    if (s == ChatConnectionState.connected) _reconnectAttempt = 0;
    notifyListeners();
  }

  void _sendBin(Map<String, dynamic> frame) {
    final channel = _channel;
    if (channel == null) return;
    try {
      channel.sink.add(serialize(frame));
    } catch (_) {
      // 写入失败由 onDone/onError 触发重连
    }
  }

  /// 拉取会话列表（刷新缓存）
  Future<bool> refreshConversations() async {
    try {
      final result = await ChatApi.fetchConversations();
      conversations = result.items;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 拉取群聊列表（刷新缓存）
  Future<bool> refreshGroups() async {
    try {
      final result = await GroupApi.fetchGroups();
      groups = result;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 置顶/取消置顶会话：成功后更新缓存并排序
  Future<bool> pinConversation(int conversationId, bool pinned) async {
    try {
      await ChatApi.pinConversation(conversationId, pinned);
    } catch (_) {
      return false;
    }
    final list = [...conversations];
    final idx = list.indexWhere((c) => c.id == conversationId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(pinned: pinned);
      _sortConversations(list);
      conversations = list;
      notifyListeners();
    }
    return true;
  }

  /// 删除会话：成功后从缓存移除，并清理本地消息缓存
  Future<bool> deleteConversation(int conversationId) async {
    try {
      await ChatApi.deleteConversation(conversationId);
    } catch (_) {
      return false;
    }
    conversations = conversations
        .where((c) => c.id != conversationId)
        .toList(growable: false);
    LocalChatStore.instance.clearConversation(conversationId);
    notifyListeners();
    return true;
  }

  /// 发消息：WebSocket 优先（等 sent 回执），超时/失败走 REST 兜底。
  /// 返回服务端确认后的消息；彻底失败返回 null（由页面标记失败态）。
  /// [contentType] 支持 text（文本/表情）与 image（content 为上传后的相对路径）。
  ///
  /// 连接策略：仅 WS 已连接时才发帧并等待回执；未连接时跳过 3s 空等，
  /// 立即走 REST 兜底并尝试恢复连接（避免每次发送停顿数秒）。
  Future<ChatMessage?> sendMessage({
    required int conversationId,
    required String content,
    required String clientMsgId,
    String contentType = 'text',
  }) async {
    // 本地留底（秒开/弱网/发送流水）；本地失败不影响发送
    try {
      await LocalChatStore.instance.insertPending(
        clientMsgId: clientMsgId,
        conversationId: conversationId,
        senderId: AuthService.instance.user?.id ?? 0,
        content: content,
        type: contentType,
      );
    } catch (_) {}
    ChatMessage? confirmed;
    if (connected) {
      final completer = Completer<ChatMessage?>();
      _pendingSends[clientMsgId] = completer;
      _sendBin({
        'type': 'send',
        'conversationId': conversationId,
        'clientMsgId': clientMsgId,
        'contentType': contentType,
        'content': content,
      });
      try {
        confirmed = await completer.future.timeout(const Duration(seconds: 3));
      } on TimeoutException {
        confirmed = null;
      } finally {
        _pendingSends.remove(clientMsgId);
      }
      if (confirmed != null) return confirmed;
    } else {
      // WS 未连接：不等回执，直接 REST 兜底，并尝试恢复连接
      if (_channel == null) _connect();
    }
    try {
      final m = await ChatApi.sendMessage(conversationId, content,
          contentType: contentType);
      if (m.id != null) {
        LocalChatStore.instance.markSent(clientMsgId, m.id!);
      }
      return m;
    } on DioException catch (e) {
      LocalChatStore.instance.markFailed(clientMsgId);
      // 403 = 未互相关注已发满限制：通知页面移除气泡并提示原因
      if (e.response?.statusCode == 403) {
        _events.add(ChatLimitEvent(clientMsgId, ChatApi.messageOf(e)));
      }
      return null;
    } catch (_) {
      LocalChatStore.instance.markFailed(clientMsgId);
      return null;
    }
  }

  /// 发群消息：WebSocket 优先（等 groupSent 回执），超时/失败走 REST 兜底。
  Future<GroupMessage?> sendGroupMessage({
    required int groupId,
    required String content,
    required String clientMsgId,
    String contentType = 'text',
  }) async {
    GroupMessage? confirmed;
    if (connected) {
      final completer = Completer<GroupMessage?>();
      _pendingGroupSends[clientMsgId] = completer;
      _sendBin({
        'type': 'groupSend',
        'groupId': groupId,
        'clientMsgId': clientMsgId,
        'contentType': contentType,
        'content': content,
      });
      try {
        confirmed = await completer.future.timeout(const Duration(seconds: 3));
      } on TimeoutException {
        confirmed = null;
      } finally {
        _pendingGroupSends.remove(clientMsgId);
      }
      if (confirmed != null) return confirmed;
    } else {
      if (_channel == null) _connect();
    }
    try {
      return await GroupApi.sendMessage(groupId, content,
          contentType: contentType);
    } catch (_) {
      return null;
    }
  }

  /// 标记已读：本地清零 + WS 通知对端 + REST 兜底
  Future<void> markRead(int conversationId) async {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx >= 0 && conversations[idx].unreadCount != 0) {
      final list = [...conversations];
      list[idx] = list[idx].copyWith(unreadCount: 0);
      conversations = list;
      notifyListeners();
    }
    _sendBin({'type': 'read', 'conversationId': conversationId});
    try {
      await ChatApi.markRead(conversationId);
    } catch (_) {
      // REST 失败忽略，下次进入会话会再同步
    }
  }

  /// 标记群已读：本地清零 + REST 同步
  Future<void> markGroupRead(int groupId, int lastMessageId) async {
    final idx = groups.indexWhere((g) => g.id == groupId);
    if (idx >= 0 && groups[idx].unreadCount != 0) {
      final list = [...groups];
      list[idx] = list[idx].copyWith(unreadCount: 0);
      groups = list;
      notifyListeners();
    }
    try {
      await GroupApi.markRead(groupId, lastMessageId);
    } catch (_) {
      // REST 失败忽略，下次进入群聊会再同步
    }
  }
}
