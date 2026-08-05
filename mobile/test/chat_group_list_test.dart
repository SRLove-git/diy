import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/api_client.dart';
import 'package:diy_mobile/pages/chat/conversation_list_page.dart';
import 'package:diy_mobile/pages/chat/create_group_page.dart';
import 'package:diy_mobile/pages/chat/group_chat_page.dart';

/// 模拟后端响应的 HTTP 适配器
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Object? Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _groupJson() => {
      'id': 1,
      'name': '测试群聊',
      'ownerId': 3,
      'memberCount': 3,
      'memberAvatars': ['https://example.com/a.png'],
      'lastMessagePreview': 'text:大家好',
      'lastMessageAt': '2026-08-05T04:43:30.000Z',
      'unreadCount': 1,
      'isOwner': true,
      'createdAt': '2026-08-05T04:43:27.000Z',
    };

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:1/api');
  });

  testWidgets('创建群聊后返回聊天列表能看到群聊', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    var groupExists = false;
    ApiClient.instance.httpClientAdapter = _FakeAdapter((options) {
      switch ('${options.method} ${options.path}') {
        case 'GET /conversations':
          return {'items': <Object>[], 'total': 0};
        case 'GET /groups':
          return groupExists
              ? {
                  'items': [_groupJson()],
                  'total': 1,
                }
              : {'items': <Object>[], 'total': 0};
        case 'POST /groups':
          groupExists = true;
          return _groupJson();
        case 'GET /follows/following':
          return [
            {'id': 16, 'nickname': '小明', 'avatar': ''},
          ];
        case 'GET /groups/1/messages':
          return {'items': <Object>[], 'total': 0, 'nextCursor': null};
        case 'GET /groups/1/members':
          return <Object>[];
        case 'POST /groups/1/read':
          return {'ok': true};
        default:
          return {};
      }
    });

    await tester.pumpWidget(const MaterialApp(home: ConversationListPage()));
    await tester.pump(const Duration(milliseconds: 700));

    // 初始无会话
    expect(find.text('暂无会话\n去社区找感兴趣的作者聊聊吧'), findsOneWidget);

    // 打开右上角加号菜单 → 发起群聊
    await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('发起群聊'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 输入群名并选择一个成员
    await tester.enterText(
      find.descendant(
        of: find.byType(CreateGroupPage),
        matching: find.byType(TextField),
      ),
      '测试群聊',
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('小明'));
    await tester.pump(const Duration(milliseconds: 200));

    // 创建群聊 → pushReplacement 进入群聊页
    await tester.tap(find.text('创建群聊'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    // 已进入群聊页（空消息态）
    expect(find.text('群聊已建立，来发第一条消息吧'), findsOneWidget);

    // 返回聊天列表
    final back = find.descendant(
      of: find.byType(GroupChatPage),
      matching: find.byType(BackButton),
    );
    await tester.tap(back.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 群聊出现在消息列表中
    expect(find.text('群聊'), findsOneWidget);
    expect(find.text('测试群聊'), findsOneWidget);
    expect(find.text('大家好'), findsOneWidget);
  });
}
