import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'models.dart';

/// 会话 / 单聊 / 群聊 / 黑名单 / 通知
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  Future<Page<ConversationItem>> conversations({int page = 1}) async {
    final raw = await ApiClient.instance.get('/conversations', query: {'page': page});
    return Page.parse<ConversationItem>(raw, ConversationItem.fromJson);
  }

  Future<ConversationItem> createConversation(int peerUserId) async {
    final data = await ApiClient.instance
        .post('/conversations', body: {'peerUserId': peerUserId}) as Map<String, dynamic>;
    return ConversationItem.fromJson(data);
  }

  Future<({List<ChatMessage> items, int? nextCursor})> messages(
    int conversationId, {
    int cursor = 0,
    int limit = 50,
  }) async {
    final raw = await ApiClient.instance.get(
      '/conversations/$conversationId/messages',
      query: {'cursor': cursor, 'limit': limit},
    ) as Map<String, dynamic>;
    return (
      items: (raw['items'] as List? ?? [])
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: (raw['nextCursor'] as num?)?.toInt(),
    );
  }

  Future<ChatMessage> sendMessage(
    int conversationId,
    String content, {
    String contentType = 'text',
    int? replyToId,
  }) async {
    final data = await ApiClient.instance.post(
      '/conversations/$conversationId/messages',
      body: {
        'content': content,
        'contentType': contentType,
        if (replyToId != null) 'replyToId': replyToId,
      },
    ) as Map<String, dynamic>;
    return ChatMessage.fromJson(data);
  }

  Future<void> markRead(int conversationId) =>
      ApiClient.instance.post('/conversations/$conversationId/read');

  Future<void> pinConversation(int id, bool pinned) =>
      ApiClient.instance.patch('/conversations/$id/pin', body: {'pinned': pinned});

  Future<void> deleteConversation(int id) => ApiClient.instance.delete('/conversations/$id');

  Future<void> deleteMessage(int conversationId, int messageId) =>
      ApiClient.instance.delete('/conversations/$conversationId/messages/$messageId');

  Future<List<User>> blocks() async {
    final data = await ApiClient.instance.get('/blocks') as List;
    return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> setBlocked(int targetId, bool blocked) =>
      ApiClient.instance.put('/blocks/$targetId', body: {'blocked': blocked});
}

class GroupService {
  GroupService._();
  static final GroupService instance = GroupService._();

  Future<GroupItem> create(String name, List<int> memberIds) async {
    final data = await ApiClient.instance
        .post('/groups', body: {'name': name, 'memberIds': memberIds}) as Map<String, dynamic>;
    return GroupItem.fromJson(data);
  }

  Future<Page<GroupItem>> mine({int page = 1}) async {
    final raw = await ApiClient.instance.get('/groups', query: {'page': page});
    return Page.parse<GroupItem>(raw, GroupItem.fromJson);
  }

  Future<List<GroupMember>> members(int groupId) async {
    final data = await ApiClient.instance.get('/groups/$groupId/members') as List;
    return data.map((e) => GroupMember.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addMembers(int groupId, List<int> memberIds) =>
      ApiClient.instance.post('/groups/$groupId/members', body: {'memberIds': memberIds});

  Future<void> leave(int groupId) => ApiClient.instance.delete('/groups/$groupId/members/me');

  Future<void> kick(int groupId, int userId) =>
      ApiClient.instance.delete('/groups/$groupId/members/$userId');

  Future<void> dissolve(int groupId) => ApiClient.instance.delete('/groups/$groupId');

  Future<void> rename(int groupId, String name) =>
      ApiClient.instance.patch('/groups/$groupId', body: {'name': name});

  Future<({List<ChatMessage> items, int total, int? nextCursor})> messages(
    int groupId, {
    int cursor = 0,
    int limit = 50,
  }) async {
    final raw = await ApiClient.instance.get(
      '/groups/$groupId/messages',
      query: {'cursor': cursor, 'limit': limit},
    ) as Map<String, dynamic>;
    return (
      items: (raw['items'] as List? ?? [])
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (raw['total'] as num?)?.toInt() ?? 0,
      nextCursor: (raw['nextCursor'] as num?)?.toInt(),
    );
  }

  Future<ChatMessage> sendMessage(
    int groupId,
    String content, {
    String contentType = 'text',
    int? replyToId,
  }) async {
    final data = await ApiClient.instance.post(
      '/groups/$groupId/messages',
      body: {
        'content': content,
        'contentType': contentType,
        if (replyToId != null) 'replyToId': replyToId,
      },
    ) as Map<String, dynamic>;
    return ChatMessage.fromJson(data);
  }

  Future<void> markRead(int groupId, int lastMessageId) =>
      ApiClient.instance.post('/groups/$groupId/read', body: {'lastMessageId': lastMessageId});

  Future<void> deleteMessage(int groupId, int messageId) =>
      ApiClient.instance.delete('/groups/$groupId/messages/$messageId');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// 未读通知数（首页铃铛角标实时监听，标记已读后自动更新）
  final ValueNotifier<int> unread = ValueNotifier<int>(0);

  Future<({List<AppNotification> items, int total, int unread})> mine({
    int page = 1,
    int pageSize = 20,
  }) async {
    final raw = await ApiClient.instance.get('/notifications', query: {
      'page': page,
      'pageSize': pageSize,
    }) as Map<String, dynamic>;
    final unread = (raw['unread'] as num?)?.toInt() ?? 0;
    this.unread.value = unread;
    return (
      items: (raw['items'] as List? ?? [])
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (raw['total'] as num?)?.toInt() ?? 0,
      unread: unread,
    );
  }

  Future<int> unreadCount() async {
    final raw = await ApiClient.instance.get('/notifications/unread-count') as Map<String, dynamic>;
    final count = (raw['count'] as num?)?.toInt() ?? 0;
    unread.value = count;
    return count;
  }

  Future<void> read(int id) async {
    await ApiClient.instance.post('/notifications/$id/read');
    await unreadCount();
  }

  Future<void> readAll() async {
    await ApiClient.instance.post('/notifications/read-all');
    unread.value = 0;
  }
}
