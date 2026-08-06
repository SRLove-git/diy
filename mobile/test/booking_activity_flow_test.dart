import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/api_client.dart';
import 'package:diy_mobile/core/appointment_api.dart';
import 'package:diy_mobile/pages/booking/booking_flow_page.dart';

/// 模拟后端响应的 HTTP 适配器（仅预约创建接口）
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

const _activities = [
  Activity(
    id: 1,
    title: '中秋月饼 DIY 特别场',
    date: '09-06 起',
    desc: '含月饼礼盒一份',
    tag: '早鸟 8 折',
    address: '杭州市滨江区江南大道 2 号',
    price: 128,
    memberPrice: 99,
    bookable: true,
    lat: 30.3,
    lng: 120.1,
  ),
  Activity(
    id: 2,
    title: '拼豆作品大赛',
    date: '08-22 起',
    desc: '作品评选',
    tag: '双倍积分',
    address: '',
    price: 0,
    bookable: false,
  ),
];

const _sessions = [
  ActivitySession(
    id: 11,
    activityId: 1,
    date: '2026-08-10',
    startTime: '14:00',
    endTime: '16:00',
    capacity: 12,
    remaining: 12,
  ),
  ActivitySession(
    id: 12,
    activityId: 1,
    date: '2026-08-11',
    startTime: '18:00',
    endTime: '20:00',
    capacity: 12,
    remaining: 5,
  ),
];

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:1/api');
  });

  testWidgets('活动专区进入：直接打开「选场次」页（预约 2/4）', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: BookingFlowPage(
          initialType: 'activity',
          initialActivityId: 1,
          storesLoader: () async => const <Store>[],
          locate: () async => null,
          activitiesLoader: () async => _activities,
          sessionsLoader: (id) async => _sessions,
          memberLoader: () async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 不经过「选门店/活动」步骤，直接落在场次选择页
    expect(find.text('预约（2/4）'), findsOneWidget);
    expect(find.text('选择活动场次'), findsOneWidget);
    expect(find.text('中秋月饼 DIY 特别场'), findsOneWidget);
    expect(find.textContaining('14:00-16:00'), findsOneWidget);
    expect(find.textContaining('剩余 12 个名额'), findsOneWidget);
  });

  testWidgets('活动预约：选活动→场次→人数→会员价与支付→成功', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    Map<String, dynamic>? createdPayload;
    ApiClient.instance.httpClientAdapter = _FakeAdapter((options) {
      if (options.method == 'POST' && options.path == '/appointments') {
        createdPayload = options.data as Map<String, dynamic>;
        return {
          'id': 1,
          'type': 'activity',
          'storeName': '中秋月饼 DIY 特别场',
          'tableName': '',
          'date': '2026-08-10',
          'startTime': '14:00',
          'endTime': '16:00',
          'peopleCount': 2,
          'code': '123456',
          'status': 'booked',
          'activityName': '中秋月饼 DIY 特别场',
          'amount': 198,
          'originalAmount': 256,
          'payStatus': 'paid',
          'payMethod': 'alipay',
          'serviceStartTime': null,
        };
      }
      return {'message': 'not found'};
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BookingFlowPage(
          storesLoader: () async => const <Store>[],
          locate: () async => null,
          activitiesLoader: () async => _activities,
          sessionsLoader: (id) async => _sessions,
          memberLoader: () async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 默认门店预约，切换活动预约
    expect(find.text('门店预约'), findsOneWidget);
    expect(find.text('活动预约'), findsOneWidget);
    await tester.tap(find.text('活动预约'));
    await tester.pumpAndSettle();

    // 活动列表：仅展示可预约活动，会员价/门市价可见
    expect(find.text('中秋月饼 DIY 特别场'), findsOneWidget);
    expect(find.text('拼豆作品大赛'), findsNothing);
    expect(find.textContaining('会员价'), findsOneWidget);

    // 进入场次选择
    await tester.tap(find.widgetWithText(FilledButton, '下一步'));
    await tester.pumpAndSettle();
    expect(find.text('选择活动场次'), findsOneWidget);
    expect(find.textContaining('14:00-16:00'), findsOneWidget);
    expect(find.textContaining('剩余 12 个名额'), findsOneWidget);

    await tester.tap(find.textContaining('14:00-16:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '下一步'));
    await tester.pumpAndSettle();

    // 人数：默认 1 人，加到 2 人，展示单价与合计
    expect(find.text('选择人数'), findsOneWidget);
    expect(find.text('1 人'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('2 人'), findsOneWidget);
    expect(find.textContaining('共 ¥198'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '下一步'));
    await tester.pumpAndSettle();

    // 确认页：会员价、应付金额、支付方式
    expect(find.text('会员价'), findsOneWidget);
    expect(find.text('¥198'), findsWidgets);
    expect(find.text('微信支付'), findsOneWidget);
    expect(find.text('支付宝'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '确认支付 ¥198'), findsOneWidget);

    // 选择支付宝并确认支付
    await tester.tap(find.text('支付宝'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '确认支付 ¥198'));
    await tester.pumpAndSettle();

    // 提交参数：活动预约 + 支付宝
    expect(createdPayload, isNotNull);
    expect(createdPayload!['type'], 'activity');
    expect(createdPayload!['activityId'], 1);
    expect(createdPayload!['activitySessionId'], 11);
    expect(createdPayload!['peopleCount'], 2);
    expect(createdPayload!['payMethod'], 'alipay');

    // 成功页：已支付金额与预约码
    expect(find.text('预约成功'), findsWidgets);
    expect(find.text('123456'), findsOneWidget);
    expect(find.textContaining('已支付 ¥198'), findsOneWidget);
    expect(find.textContaining('支付宝'), findsOneWidget);
  });
}
