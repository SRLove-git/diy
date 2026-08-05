import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/api_client.dart';
import 'package:diy_mobile/pages/checkin/my_checkin_qr_page.dart';

/// 到店核销页：待核销预约应可直接取消（预约后最自然的取消入口）
class _FakeAdapter implements HttpClientAdapter {
  final List<RequestOptions> calls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    if (options.path.endsWith('/cancel')) {
      return ResponseBody.fromString(
        '{"id":1,"status":"cancelled"}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == '/appointments') {
      const body = '''
      [
        {
          "id": 1,
          "storeName": "1号",
          "tableName": "B2",
          "date": "2026-08-06",
          "startTime": "10:00",
          "endTime": "11:30",
          "peopleCount": 1,
          "code": "197208",
          "status": "booked",
          "serviceStartTime": null
        }
      ]
      ''';
      return ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString('{}', 404, headers: {});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() {
    dotenv.testLoad();
  });

  testWidgets('到店核销页可取消待核销预约', (tester) async {
    final adapter = _FakeAdapter();
    ApiClient.instance.httpClientAdapter = adapter;

    await tester.pumpWidget(const MaterialApp(home: MyCheckInQrPage()));
    await tester.pumpAndSettle();

    // 预约卡片与取消按钮
    expect(find.text('1号'), findsOneWidget);
    expect(find.text('取消预约'), findsOneWidget);

    // 点击取消 → 确认弹窗
    await tester.tap(find.text('取消预约'));
    await tester.pumpAndSettle();
    expect(find.text('确认取消该预约吗？'), findsOneWidget);

    // 确认取消 → POST /appointments/1/cancel
    await tester.tap(find.text('确认取消'));
    await tester.pumpAndSettle();
    expect(
      adapter.calls.any(
        (c) => c.method == 'POST' && c.path == '/appointments/1/cancel',
      ),
      isTrue,
    );
  });
}
