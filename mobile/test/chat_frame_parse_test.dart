import 'dart:typed_data';

import 'package:diy_mobile/core/chat_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

void main() {
  test('groupNewMessage 帧 msgpack 往返 + GroupMessage.fromJson', () {
    // 与服务端 serializeGroupMessage + onGroupSend 完全一致的载荷
    final payload = {
      'type': 'groupNewMessage',
      'groupId': 2,
      'message': {
        'id': 123,
        'groupId': 2,
        'senderId': 3,
        'contentType': 'text',
        'content': 'hello',
        'createdAt': '2026-08-05T10:00:00.000Z',
        'author': {'id': 3, 'nickname': '张三', 'avatar': null},
      },
    };
    final bytes = Uint8List.fromList(serialize(payload));
    final decoded = deserialize(bytes) as Map;
    final frame = Map<String, dynamic>.from(decoded);
    final rawMsg = frame['message'] as Map;
    final msg = GroupMessage.fromJson(Map<String, dynamic>.from(rawMsg));
    expect(msg.id, 123);
    expect(msg.groupId, 2);
    expect(msg.senderId, 3);
    expect(msg.content, 'hello');
    expect(msg.authorNickname, '张三');
    expect(msg.createdAt, DateTime.parse('2026-08-05T10:00:00.000Z'));
  });

  test('newMessage 帧 msgpack 往返 + ChatMessage.fromJson', () {
    final payload = {
      'type': 'newMessage',
      'message': {
        'id': 456,
        'conversationId': 7,
        'senderId': 3,
        'contentType': 'text',
        'content': 'hi',
        'readAt': null,
        'createdAt': '2026-08-05T10:00:00.000Z',
      },
    };
    final bytes = Uint8List.fromList(serialize(payload));
    final decoded = deserialize(bytes) as Map;
    final frame = Map<String, dynamic>.from(decoded);
    final raw = frame['message'] as Map;
    final msg = ChatMessage.fromJson(Map<String, dynamic>.from(raw));
    expect(msg.id, 456);
    expect(msg.conversationId, 7);
  });
}
