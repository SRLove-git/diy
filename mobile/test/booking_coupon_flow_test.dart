import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/api_client.dart';
import 'package:diy_mobile/core/appointment_api.dart';
import 'package:diy_mobile/features/member/domain/member_models.dart';
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
];

final _coupons = [
  MemberWalletCoupon(
    userCouponId: '55',
    title: '新人专享券',
    amount: '¥20',
    threshold: '无门槛',
    expireAt: DateTime(2026, 8, 31),
    status: 'unused',
    receivedAt: null,
  ),
];

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:1/api');
  });

  testWidgets('活动预约：确认页选优惠券 → 抵扣金额 → 提交携带券 ID', (tester) async {
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
          'amount': 178,
          'originalAmount': 256,
          'couponDiscount': 20,
          'payStatus': 'paid',
          'payMethod': 'wechat',
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
          couponsLoader: () async => _coupons,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 切换到活动预约并走到确认页
    await tester.tap(find.text('活动预约'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '下一步'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('14:00-16:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '下一步'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '下一步'));
    await tester.pumpAndSettle();

    // 确认页：默认无券，按钮为原价
    expect(find.text('选择优惠券'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '确认支付 ¥198'), findsOneWidget);

    // 选择优惠券：抵扣 ¥20，实付 ¥178
    await tester.tap(find.text('选择优惠券'));
    await tester.pumpAndSettle();
    expect(find.text('新人专享券'), findsOneWidget);
    expect(find.text('-¥20'), findsOneWidget);
    await tester.tap(find.text('新人专享券'));
    await tester.pumpAndSettle();

    expect(find.text('优惠券已抵扣 ¥20'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '确认支付 ¥178'), findsOneWidget);

    // 提交：携带券 ID
    await tester.tap(find.widgetWithText(FilledButton, '确认支付 ¥178'));
    await tester.pumpAndSettle();
    expect(createdPayload, isNotNull);
    expect(createdPayload!['userCouponId'], 55);

    // 成功页展示抵扣
    expect(find.text('预约成功'), findsWidgets);
    expect(find.text('优惠券已抵扣 ¥20'), findsOneWidget);
  });
}
