import 'package:dio/dio.dart';

import 'api_client.dart';
import 'config.dart';

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
    this.peerOnline = false,
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

  /// 对端是否在线（服务端 Redis 在线状态）
  final bool peerOnline;

  /// 去掉 "text:" 等类型前缀后的预览文本
  String get lastMessageText {
    final p = lastMessagePreview;
    if (p == null) return '';
    if (p.startsWith('image:')) return '[图片]';
    if (p.startsWith('voice:')) return '[语音]';
    if (p.startsWith('text:')) return p.substring(5);
    return p;
  }

  Conversation copyWith({
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? pinned,
    bool? peerOnline,
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
        peerOnline: peerOnline ?? this.peerOnline,
      );

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // msgpack 解出的嵌套 map 是 Map<dynamic, dynamic>，需深转一层
    final peer = Map<String, dynamic>.from(json['peer'] as Map? ?? const {});
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
      peerOnline: (peer['online'] ?? false) as bool,
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

  ChatMessage copyWith({
    DateTime? readAt,
    String? content,
    String? contentType,
    String? clientMsgId,
    int? senderId,
  }) =>
      ChatMessage(
        id: id,
        conversationId: conversationId,
        senderId: senderId ?? this.senderId,
        contentType: contentType ?? this.contentType,
        content: content ?? this.content,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
        clientMsgId: clientMsgId ?? this.clientMsgId,
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
  static Future<ChatMessage> sendMessage(
    int conversationId,
    String content, {
    String contentType = 'text',
  }) async {
    final resp = await ApiClient.instance.post(
      '/conversations/$conversationId/messages',
      data: {'content': content, 'contentType': contentType},
    );
    return ChatMessage.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 上传图片，返回可访问的相对路径（如 /uploads/chat/2026/08/xxx.jpg）
  /// [folder] 可选 'chat'（默认）| 'avatar' | 'post'
  static Future<String> uploadImage(String filePath, {String folder = 'chat'}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final resp = await ApiClient.instance.post(
      '/uploads/images',
      data: form,
      queryParameters: {'folder': folder},
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return (resp.data as Map<String, dynamic>)['url'] as String;
  }

  /// 上传聊天语音，返回可访问的相对路径（如 /uploads/chat/2026/08/xxx.m4a）
  static Future<String> uploadAudio(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final resp = await ApiClient.instance.post(
      '/uploads/audio',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return (resp.data as Map<String, dynamic>)['url'] as String;
  }

  /// 相对路径（/uploads/...）转绝对 URL（聊天图片展示用）
  static String resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final api = Uri.parse(AppConfig.apiBaseUrl);
    return '${api.scheme}://${api.authority}$path';
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

// ──── 群聊模型 ────

/// 群聊会话
class GroupChat {
  const GroupChat({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberCount,
    required this.memberAvatars,
    required this.unreadCount,
    required this.isOwner,
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  final int id;
  final String name;
  final int ownerId;
  final int memberCount;
  final List<String> memberAvatars;
  final int unreadCount;
  final bool isOwner;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;

  /// 去掉类型前缀后的预览文本
  String get lastMessageText {
    final p = lastMessagePreview;
    if (p == null) return '';
    if (p.startsWith('image:')) return '[图片]';
    if (p.startsWith('voice:')) return '[语音]';
    if (p.startsWith('text:')) return p.substring(5);
    return p;
  }

  GroupChat copyWith({
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) =>
      GroupChat(
        id: id,
        name: name,
        ownerId: ownerId,
        memberCount: memberCount,
        memberAvatars: memberAvatars,
        unreadCount: unreadCount ?? this.unreadCount,
        isOwner: isOwner,
        lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      );

  factory GroupChat.fromJson(Map<String, dynamic> json) => GroupChat(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? '') as String,
        ownerId: (json['ownerId'] as num?)?.toInt() ?? 0,
        memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
        memberAvatars: ((json['memberAvatars'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        isOwner: json['isOwner'] == true,
        lastMessagePreview: json['lastMessagePreview'] as String?,
        lastMessageAt: json['lastMessageAt'] == null
            ? null
            : DateTime.tryParse(json['lastMessageAt'].toString()),
      );
}

/// 群成员信息
class GroupMemberInfo {
  const GroupMemberInfo({
    required this.id,
    required this.nickname,
    required this.avatar,
  });

  final int id;
  final String nickname;
  final String avatar;

  factory GroupMemberInfo.fromJson(Map<String, dynamic> json) =>
      GroupMemberInfo(
        id: (json['id'] as num).toInt(),
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
      );
}

/// 群消息（含发送者信息）
class GroupMessage {
  const GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.contentType,
    required this.content,
    required this.createdAt,
    this.authorNickname = '',
    this.authorAvatar = '',
  });

  final int id;
  final int groupId;
  final int senderId;
  final String contentType;
  final String content;
  final DateTime createdAt;
  final String authorNickname;
  final String authorAvatar;

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    // msgpack 解出的嵌套 map 是 Map<dynamic, dynamic>，需深转一层
    final author = Map<String, dynamic>.from(json['author'] as Map? ?? const {});
    return GroupMessage(
      id: (json['id'] as num).toInt(),
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      senderId: (json['senderId'] as num).toInt(),
      contentType: (json['contentType'] ?? 'text') as String,
      content: (json['content'] ?? '') as String,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      authorNickname: (author['nickname'] ?? '') as String,
      authorAvatar: (author['avatar'] ?? '') as String,
    );
  }
}

/// 群聊 REST API
class GroupApi {
  GroupApi._();

  /// 创建群聊
  static Future<GroupChat> createGroup({
    required String name,
    required List<int> memberIds,
  }) async {
    final resp = await ApiClient.instance.post('/groups', data: {
      'name': name,
      'memberIds': memberIds,
    });
    return GroupChat.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 我的群列表
  static Future<List<GroupChat>> fetchGroups() async {
    final resp = await ApiClient.instance.get('/groups');
    final data = resp.data as Map<String, dynamic>;
    final items = (data['items'] ?? []) as List;
    return items
        .map((e) => GroupChat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 群成员
  static Future<List<GroupMemberInfo>> fetchMembers(int groupId) async {
    final resp = await ApiClient.instance.get('/groups/$groupId/members');
    return (resp.data as List)
        .map((e) => GroupMemberInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 群历史消息（游标分页）
  static Future<({List<GroupMessage> items, int? nextCursor})> fetchMessages(
    int groupId, {
    int cursor = 0,
    int limit = 50,
  }) async {
    final resp = await ApiClient.instance.get(
      '/groups/$groupId/messages',
      queryParameters: {'cursor': cursor, 'limit': limit},
    );
    final data = resp.data as Map<String, dynamic>;
    return (
      items: ((data['items'] ?? []) as List)
          .map((e) => GroupMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: data['nextCursor'] as int?,
    );
  }

  /// REST 发群消息（WebSocket 兜底）
  static Future<GroupMessage> sendMessage(
    int groupId,
    String content, {
    String contentType = 'text',
  }) async {
    final resp = await ApiClient.instance.post(
      '/groups/$groupId/messages',
      data: {'content': content, 'contentType': contentType},
    );
    return GroupMessage.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 标记群已读
  static Future<void> markRead(int groupId, int lastMessageId) async {
    await ApiClient.instance.post(
      '/groups/$groupId/read',
      data: {'lastMessageId': lastMessageId},
    );
  }

  /// 提取后端错误信息
  static String messageOf(DioException e) => ChatApi.messageOf(e);
}
