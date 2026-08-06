import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/api_client.dart';
import 'package:diy_mobile/core/auth_service.dart';
import 'package:diy_mobile/core/chat_api.dart';
import 'package:diy_mobile/core/chat_service.dart';

/// 模拟后端响应的 HTTP 适配器（记录请求，按 token 区分账号）
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Object? Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
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

Map<String, dynamic> _userJson(int id, String nickname) => {
  'id': id,
  'phone': '1380000000$id',
  'nickname': nickname,
  'avatar': '',
  'role': 'user',
};

Map<String, dynamic> _conversationJson(int id, int peerId, String nickname) => {
  'id': id,
  'peer': {
    'id': peerId,
    'nickname': nickname,
    'avatar': '',
    'online': false,
  },
  'lastMessagePreview': 'text:你好',
  'lastMessageAt': '2026-08-05T04:43:30.000Z',
  'unreadCount': 0,
  'pinned': false,
};

Map<String, dynamic> _groupJson() => {
  'id': 1,
  'name': '测试群聊',
  'ownerId': 2,
  'memberCount': 2,
  'memberAvatars': <Object>[],
  'lastMessagePreview': 'text:大家好',
  'lastMessageAt': '2026-08-05T04:43:30.000Z',
  'unreadCount': 0,
  'isOwner': true,
};

void main() {
  late HttpServer wsServer;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    // 本地 WebSocket 服务：ChatService 切号后重连时能握手成功，
    // 否则测试环境会因连接被拒产生未处理异常。
    wsServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    wsServer.listen((req) async {
      if (req.uri.path == '/ws' && WebSocketTransformer.isUpgradeRequest(req)) {
        final ws = await WebSocketTransformer.upgrade(req);
        ws.listen((_) {}, onError: (_) {});
      } else {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
      }
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:${wsServer.port}/api');

    // 内存版 secure storage：读写直接返回/记录，避免命中原生插件
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'read':
            case 'readAll':
              return null;
            case 'write':
            case 'delete':
            case 'deleteAll':
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() async {
    await AuthService.instance.logout();
    ChatService.instance.disconnect();
    ApiClient.instance.httpClientAdapter = IOHttpClientAdapter();
    await wsServer.close(force: true);
  });

  test('切换账号后立即以新账号拉取会话与群聊缓存，无需手动刷新', () async {
    final adapter = _FakeAdapter((options) {
      final auth = (options.headers['Authorization'] ?? '') as String;
      switch ('${options.method} ${options.path}') {
        case 'POST /auth/login':
          return {
            'accessToken': 'token-a',
            'refreshToken': 'refresh-a',
            'isNewUser': false,
          };
        case 'GET /auth/me':
          return auth.contains('token-b')
              ? _userJson(2, '账号B')
              : _userJson(1, '账号A');
        case 'GET /conversations':
          return {
            'items': [_conversationJson(10, 99, '手作达人')],
            'total': 1,
          };
        case 'GET /groups':
          return {
            'items': [_groupJson()],
            'total': 1,
          };
        default:
          return {};
      }
    });
    ApiClient.instance.httpClientAdapter = adapter;

    // 先用账号 A 登录，产生「已保存会话」供切换
    await AuthService.instance.login('13800000001', '1234');
    expect(AuthService.instance.user?.id, 1);
    expect(ChatService.instance.conversations, isEmpty);

    // 切换前先灌入账号 A 的旧缓存，模拟切号前消息页已有列表
    ChatService.instance.conversations = [
      Conversation(
        id: 1,
        peerId: 8,
        peerNickname: '旧账号会话',
        peerAvatar: '',
      ),
    ];

    final ok = await AuthService.instance.switchToSession(
      const SavedSession(
        userId: 2,
        nickname: '账号B',
        avatar: '',
        accessToken: 'token-b',
        refreshToken: 'refresh-b',
      ),
    );

    expect(ok, isTrue);
    expect(AuthService.instance.user?.id, 2);

    // 切换后缓存被新账号数据覆盖（消息页 Listener 依赖此缓存渲染）
    expect(ChatService.instance.conversations, hasLength(1));
    expect(ChatService.instance.conversations.first.peerNickname, '手作达人');
    expect(ChatService.instance.groups, hasLength(1));

    // 会话/群聊列表请求发生在切换之后，且携带新账号 token
    final switchedAt = adapter.requests.indexOf(
      adapter.requests.lastWhere(
        (r) => r.method == 'GET' && r.path == '/auth/me',
      ),
    );
    for (final path in ['/conversations', '/groups']) {
      final listRequests = adapter.requests
          .where((r) => r.method == 'GET' && r.path == path)
          .toList();
      expect(listRequests, isNotEmpty, reason: '切换后应刷新 $path');
      final last = listRequests.last;
      expect(adapter.requests.indexOf(last), greaterThan(switchedAt),
          reason: '$path 应在切号后请求');
      expect(last.headers['Authorization'], 'Bearer token-b');
    }
  });
}
