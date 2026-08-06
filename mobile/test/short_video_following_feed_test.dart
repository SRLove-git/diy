import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/api_client.dart';
import 'package:diy_mobile/pages/short_video_page.dart';

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

Map<String, dynamic> _videoJson(
  int id,
  int userId,
  String nickname,
  String title,
) =>
    {
      'id': id,
      'userId': userId,
      'title': title,
      'content': '',
      'cover': '/uploads/post/cover.jpg',
      'videoUrl': '/uploads/video/demo.mp4',
      'duration': 10,
      'aspectRatio': 0,
      'music': '',
      'tags': <Object>[],
      'location': '',
      'photos': <Object>[],
      'filter': '',
      'trimStart': 0,
      'trimEnd': 0,
      'speed': 1,
      'rotation': 0,
      'likeCount': 0,
      'commentCount': 0,
      'shareCount': 0,
      'viewCount': 0,
      'createdAt': '2026-08-06T02:00:00.000Z',
      'author': {
        'id': userId,
        'nickname': nickname,
        'avatar': '',
        'followCount': 0,
      },
      'liked': false,
    };

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:1/api');
  });

  testWidgets('关注 Tab 只展示已关注作者的视频（后端异常返回全量时也过滤）', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final allVideos = [
      _videoJson(1, 1, '管理员', '视频A'),
      _videoJson(2, 3, '拾染', '视频B'),
      _videoJson(3, 5, '阿茶', '视频C'),
    ];

    ApiClient.instance.httpClientAdapter = _FakeAdapter((options) {
      switch ('${options.method} ${options.path}') {
        case 'GET /videos':
        case 'GET /videos/following':
          // 关注接口故意返回全量视频，模拟旧版本/异常后端；
          // 客户端仍应按“已关注作者”过滤。
          return [allVideos, allVideos.length];
        case 'GET /follows/following':
          return [
            {'id': 3, 'nickname': '拾染', 'avatar': ''},
          ];
        default:
          return <Object>{};
      }
    });

    await tester.pumpWidget(const MaterialApp(home: ShortVideoPage()));
    await tester.pump(const Duration(milliseconds: 700));

    // 切到「关注」Tab
    await tester.tap(find.byKey(const Key('feedTabFollowing')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // 只显示已关注作者（拾染）的视频，未关注的作者视频一律不出现
    expect(find.text('@拾染'), findsOneWidget);
    expect(find.text('@管理员'), findsNothing);
    expect(find.text('@阿茶'), findsNothing);
  });

  testWidgets('关注 Tab 无已关注作者时为空态', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final allVideos = [
      _videoJson(1, 1, '管理员', '视频A'),
      _videoJson(2, 3, '拾染', '视频B'),
    ];

    ApiClient.instance.httpClientAdapter = _FakeAdapter((options) {
      switch ('${options.method} ${options.path}') {
        case 'GET /videos':
          return [allVideos, allVideos.length];
        case 'GET /videos/following':
          // 后端异常返回全量，但当前用户没有关注任何人
          return [allVideos, allVideos.length];
        case 'GET /follows/following':
          return <Object>[];
        default:
          return <Object>{};
      }
    });

    await tester.pumpWidget(const MaterialApp(home: ShortVideoPage()));
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.byKey(const Key('feedTabFollowing')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('暂无视频内容'), findsOneWidget);
    expect(find.text('@管理员'), findsNothing);
  });
}
