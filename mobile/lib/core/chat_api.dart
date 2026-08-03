import 'package:dio/dio.dart';

import 'api_client.dart';

/// 会话模型
class Conversation {
  const Conversation({
    required this.id,
    required this.peerId,
    required this.peerNickname,
    required this.peerAvatar,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.pinned = false,
  });

  final int id;
  final int peerId;
  final String peerNickname;
  final String peerAvatar;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;

  /// 是否置顶
  final bool pinned;

  /// 去掉 "text:" 等类型前缀后的预览文本
  String get lastMessageText {
    final p = lastMessagePreview;
    if (p == null) return '';
    if (p.startsWith('image:')) return '[图片]';
    if (p.startsWith('text:')) return p.substring(5);
    return p;
  }

  Conversation copyWith({
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? pinned,
  }) =>
      Conversation(
        id: id,
        peerId: peerId,
        peerNickname: peerNickname,
        peerAvatar: peerAvatar,
        lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        pinned: pinned ?? this.pinned,
      );

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final peer = (json['peer'] ?? const {}) as Map<String, dynamic>;
    return Conversation(
      id: json['id'] as int,
      peerId: peer['id'] as int,
      peerNickname: (peer['nickname'] ?? '') as String,
      peerAvatar: (peer['avatar'] ?? '') as String,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      unreadCount: (json['unreadCount'] ?? 0) as int,
      pinned: (json['pinned'] ?? false) as bool,
    );
  }
}

/// 消息模型
class ChatMessage {
  const ChatMessage({
    this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.contentType = 'text',
    this.readAt,
    this.createdAt,
    this.clientMsgId,
  });

  final int? id;
  final int conversationId;
  final int senderId;
  final String contentType;
  final String content;
  final DateTime? readAt;
  final DateTime? createdAt;

  /// 本地生成的发送流水号（服务端消息无此字段）
  final String? clientMsgId;

  ChatMessage copyWith({DateTime? readAt}) => ChatMessage(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        contentType: contentType,
        content: content,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
        clientMsgId: clientMsgId,
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // 使用 num.tryParse 等安全转换，避免 msgpack/jwt 等场景下的类型强制转换异常
    int? safeInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    int safeIntOr(dynamic v, int fallback) => safeInt(v) ?? fallback;

    return ChatMessage(
      id: safeInt(json['id']),
      conversationId: safeIntOr(json['conversationId'], 0),
      senderId: safeIntOr(json['senderId'], 0),
      contentType: (json['contentType'] ?? 'text').toString(),
      content: (json['content'] ?? '').toString(),
      readAt: _coerceDateTime(json['readAt']),
      createdAt: _coerceDateTime(json['createdAt']),
    );
  }

  /// 兼容 JSON 字符串与 msgpack 解码后的 DateTime 对象
  static DateTime? _coerceDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// 聊天 REST API（历史/兜底发送/已读）
class ChatApi {
  ChatApi._();

  /// 会话列表
  static Future<({List<Conversation> items, int total})> fetchConversations(
      {int page = 1}) async {
    final resp = await ApiClient.instance
        .get('/conversations', queryParameters: {'page': page});
    final data = resp.data as Map<String, dynamic>;
    final items = ((data['items'] ?? []) as List)
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: data['total'] as int);
  }

  /// 创建或复用会话
  static Future<Conversation> createConversation(int peerUserId) async {
    final resp = await ApiClient.instance
        .post('/conversations', data: {'peerUserId': peerUserId});
    return Conversation.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 历史消息（游标分页，升序返回）
  static Future<({List<ChatMessage> items, int? nextCursor})> fetchMessages(
    int conversationId, {
    int cursor = 0,
    int limit = 50,
  }) async {
    final resp = await ApiClient.instance.get(
      '/conversations/$conversationId/messages',
      queryParameters: {'cursor': cursor, 'limit': limit},
    );
    final data = resp.data as Map<String, dynamic>;
    final items = ((data['items'] ?? []) as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, nextCursor: data['nextCursor'] as int?);
  }

  /// REST 发消息（WebSocket 兜底）
  static Future<ChatMessage> sendMessage(int conversationId, String content) async {
    final resp = await ApiClient.instance.post(
      '/conversations/$conversationId/messages',
      data: {'content': content},
    );
    return ChatMessage.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 标记已读
  static Future<void> markRead(int conversationId) async {
    await ApiClient.instance.post('/conversations/$conversationId/read');
  }

  /// 置顶/取消置顶会话
  static Future<void> pinConversation(int conversationId, bool pinned) async {
    await ApiClient.instance
        .patch('/conversations/$conversationId/pin', data: {'pinned': pinned});
  }

  /// 删除会话（含全部消息，对双方生效）
  static Future<void> deleteConversation(int conversationId) async {
    await ApiClient.instance.delete('/conversations/$conversationId');
  }

  /// 提取后端错误信息
  static String messageOf(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join('，') : m.toString();
    }
    return '网络异常，请稍后再试';
  }
}
