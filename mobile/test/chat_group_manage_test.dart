import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/api_client.dart';
import 'package:diy_mobile/pages/chat/conversation_list_page.dart';
import 'package:diy_mobile/pages/chat/group_chat_page.dart';
import 'package:diy_mobile/pages/chat/group_manage_page.dart';

/// 模拟后端响应的 HTTP 适配器（支持群管理全部接口）
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

Map<String, dynamic> _member(int id, String name) =>
    {'id': id, 'nickname': name, 'avatar': '', 'role': 'user'};

Map<String, dynamic> _groupJson({bool isOwner = true}) => {
      'id': 1,
      'name': '测试群聊',
      'ownerId': 5,
      'memberCount': 2,
      'memberAvatars': <String>[],
      'lastMessagePreview': 'text:大家好',
      'lastMessageAt': '2026-08-05T04:43:30.000Z',
      'unreadCount': 0,
      'isOwner': isOwner,
      'createdAt': '2026-08-05T04:43:27.000Z',
    };

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:1/api');
  });

  testWidgets('群主可从右上角进入群信息：拉人 + 移出成员', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    var members = [_member(5, '我'), _member(2, '小明')];
    var groupName = '测试群聊';
    ApiClient.instance.httpClientAdapter = _FakeAdapter((options) {
      switch ('${options.method} ${options.path}') {
        case 'GET /conversations':
          return {'items': <Object>[], 'total': 0};
        case 'GET /groups':
          return {
            'items': [_groupJson()..['name'] = groupName],
            'total': 1,
          };
        case 'GET /groups/1/members':
          return members;
        case 'GET /groups/1/messages':
          return {'items': <Object>[], 'total': 0, 'nextCursor': null};
        case 'POST /groups/1/read':
          return {'ok': true};
        case 'GET /follows/following':
          // 小明已在群内，拉人列表应只出现小红
          return [_member(2, '小明'), _member(9, '小红')];
        case 'POST /groups/1/members':
          final data = options.data as Map<String, dynamic>;
          for (final id in (data['memberIds'] as List)) {
            members.add(_member(id as int, id == 9 ? '小红' : '新成员'));
          }
          return {'ok': true};
        case 'DELETE /groups/1/members/2':
          members = members.where((m) => m['id'] != 2).toList();
          return {'ok': true};
        case 'PATCH /groups/1':
          final data = options.data as Map<String, dynamic>;
          groupName = data['name'] as String;
          return {'ok': true};
        default:
          return {};
      }
    });

    await tester.pumpWidget(const MaterialApp(home: ConversationListPage()));
    await tester.pump(const Duration(milliseconds: 700));

    // 进入群聊
    await tester.tap(find.text('测试群聊'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GroupChatPage), findsOneWidget);

    // 右上角入口 → 群聊信息页
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GroupManagePage), findsOneWidget);
    expect(find.text('群聊信息（2）'), findsOneWidget);
    expect(find.text('邀请'), findsOneWidget);
    expect(find.text('群聊名称'), findsOneWidget);
    expect(find.text('解散群聊'), findsOneWidget);
    expect(find.text('退出群聊'), findsNothing);
    expect(find.text('主'), findsOneWidget); // 群主角标

    // 群主可修改群聊名称
    await tester.tap(find.text('群聊名称'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '新群名');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(GroupManagePage),
        matching: find.text('新群名'),
      ),
      findsOneWidget,
    );
    // 等改名提示消失，避免遮挡底部按钮
    await tester.pump(const Duration(milliseconds: 2300));

    // 拉人：小红可选，已入群的小明不出现
    await tester.tap(find.text('邀请'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    final picker = find.byType(Scaffold).last;
    expect(find.descendant(of: picker, matching: find.text('小红')),
        findsOneWidget);
    expect(find.descendant(of: picker, matching: find.text('小明')),
        findsNothing);
    await tester.tap(find.descendant(of: picker, matching: find.text('小红')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(
        find.descendant(of: picker, matching: find.text('添加（1）')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 回到群聊信息页：小红已入群，成员数 3
    expect(find.byType(GroupManagePage), findsOneWidget);
    expect(find.text('群聊信息（3）'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(GroupManagePage),
        matching: find.text('小红'),
      ),
      findsOneWidget,
    );

    // 点成员弹详情 → 移出群聊 → 确认
    await tester.tap(
      find.descendant(
        of: find.byType(GroupManagePage),
        matching: find.text('小明'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('移出群聊'));
    await tester.pumpAndSettle();
    expect(find.text('移出群聊'), findsOneWidget); // 确认弹窗
    await tester.tap(find.text('移出'));
    await tester.pumpAndSettle();

    // 小明已被移出，小红仍在
    expect(
      find.descendant(
        of: find.byType(GroupManagePage),
        matching: find.text('小明'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(GroupManagePage),
        matching: find.text('小红'),
      ),
      findsOneWidget,
    );
    expect(find.text('已移出 小明'), findsOneWidget);
  });

  testWidgets('普通成员可从群信息页退出群聊', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    var groupExists = true;
    final members = [_member(5, '群主'), _member(1, '我')];
    ApiClient.instance.httpClientAdapter = _FakeAdapter((options) {
      switch ('${options.method} ${options.path}') {
        case 'GET /conversations':
          return {'items': <Object>[], 'total': 0};
        case 'GET /groups':
          return groupExists
              ? {
                  'items': [_groupJson(isOwner: false)],
                  'total': 1,
                }
              : {'items': <Object>[], 'total': 0};
        case 'GET /groups/1/members':
          return members;
        case 'GET /groups/1/messages':
          return {'items': <Object>[], 'total': 0, 'nextCursor': null};
        case 'POST /groups/1/read':
          return {'ok': true};
        case 'DELETE /groups/1/members/me':
          groupExists = false;
          return {'ok': true};
        default:
          return {};
      }
    });

    await tester.pumpWidget(const MaterialApp(home: ConversationListPage()));
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.text('测试群聊'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 非群主：无解散入口；点成员弹详情也没有移出入口
    expect(find.text('退出群聊'), findsOneWidget);
    expect(find.text('解散群聊'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(GroupManagePage),
        matching: find.text('群主'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find
          .descendant(
            of: find.byType(GroupManagePage),
            matching: find.text('我'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('移出群聊'), findsNothing);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    // 确认退出 → 返回聊天列表，群聊消失
    await tester.tap(find.text('退出群聊'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('退出'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(GroupChatPage), findsNothing);
    expect(find.text('测试群聊'), findsNothing);
  });
}
