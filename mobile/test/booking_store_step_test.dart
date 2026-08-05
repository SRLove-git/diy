import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/appointment_api.dart';
import 'package:diy_mobile/core/geo_utils.dart';
import 'package:diy_mobile/pages/booking/booking_flow_page.dart';
import 'package:diy_mobile/pages/booking/store_map_view.dart';

/// 测试用假地图：渲染带 key 的门店标记，替代平台原生地图
class _FakeStoreMap extends StatelessWidget {
  const _FakeStoreMap({required this.data});

  final StoreMapViewData data;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE8E8E8),
      child: Stack(
        children: [
          for (final (i, s) in data.stores.indexed)
            Positioned(
              left: 40.0 + i * 40,
              top: 40.0,
              child: GestureDetector(
                key: Key('store-marker-${s.id}'),
                onTap: () => data.onSelectStore(s),
                child: Icon(
                  Icons.location_on,
                  color: s.id == data.selectedStoreId
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _fakeMapBuilder(BuildContext context, StoreMapViewData data) =>
    _FakeStoreMap(data: data);

const _stores = [
  Store(
    id: 1,
    name: '西湖店',
    address: '杭州市西湖区文一西路 1 号',
    lat: 30.250,
    lng: 120.150,
    rating: 4.8,
    businessHours: '09:00-21:00',
    images: [],
  ),
  Store(
    id: 2,
    name: '滨江店',
    address: '杭州市滨江区江南大道 2 号',
    lat: 30.300,
    lng: 120.100,
    rating: 4.6,
    businessHours: '10:00-22:00',
    images: [],
  ),
  Store(
    id: 3,
    name: '余杭店',
    address: '杭州市余杭区文一西路 3 号',
    lat: 30.280,
    lng: 120.020,
    rating: 4.5,
    businessHours: '09:30-21:30',
    images: [],
  ),
];

Future<({Store store, List<StoreTable> tables, List<TimeSlot> slots})>
    _emptyDetail(int storeId) async {
  final store = _stores.firstWhere((s) => s.id == storeId);
  return (
    store: store,
    tables: const <StoreTable>[],
    slots: const <TimeSlot>[],
  );
}

Future<void> _pumpBooking(
  WidgetTester tester, {
  required Future<GeoPoint?> Function() locate,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: BookingFlowPage(
        storesLoader: () async => _stores,
        locate: locate,
        detailLoader: _emptyDetail,
        mapBuilder: _fakeMapBuilder,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('定位可用时：最近门店置顶标记并自动选中', (tester) async {
    // 定位点紧挨西湖店
    await _pumpBooking(
      tester,
      locate: () async => const GeoPoint(lat: 30.251, lng: 120.151),
    );

    // 地图在列表上方
    expect(find.byType(StoreMapView), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(StoreMapView)).dy,
      lessThan(tester.getTopLeft(find.byType(ListView)).dy),
    );

    // 最近门店（西湖店）在最上面，带「最近」标签与距离
    expect(find.text('最近'), findsOneWidget);
    expect(find.text('已按距离从近到远排序'), findsOneWidget);
    expect(find.textContaining('距你'), findsWidgets);
    final xihuY = tester
        .getTopLeft(
          find.descendant(
            of: find.byKey(const Key('store-card-1')),
            matching: find.text('西湖店'),
          ),
        )
        .dy;
    final binjiangY = tester
        .getTopLeft(
          find.descendant(
            of: find.byKey(const Key('store-card-2')),
            matching: find.text('滨江店'),
          ),
        )
        .dy;
    expect(xihuY, lessThan(binjiangY));

    // 自动选中最近门店：卡片有选中标记，底部「下一步」可用
    expect(
      find.descendant(
        of: find.byKey(const Key('store-card-1')),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );
    final nextBtn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '下一步'),
    );
    expect(nextBtn.onPressed, isNotNull);
  });

  testWidgets('定位失败时：保持原顺序、不显示最近标记，仍可进入下一步', (tester) async {
    await _pumpBooking(tester, locate: () async => null);

    expect(find.byType(StoreMapView), findsOneWidget);
    expect(find.text('最近'), findsNothing);
    expect(find.textContaining('距你'), findsNothing);
    expect(find.text('已按距离从近到远排序'), findsNothing);

    final firstY = tester
        .getTopLeft(
          find.descendant(
            of: find.byKey(const Key('store-card-1')),
            matching: find.text('西湖店'),
          ),
        )
        .dy;
    final secondY = tester
        .getTopLeft(
          find.descendant(
            of: find.byKey(const Key('store-card-2')),
            matching: find.text('滨江店'),
          ),
        )
        .dy;
    expect(firstY, lessThan(secondY));

    await tester.tap(find.widgetWithText(FilledButton, '下一步'));
    await tester.pumpAndSettle();
    expect(find.text('选择日期'), findsOneWidget);
  });

  testWidgets('点击地图标记可切换选中门店并同步到列表', (tester) async {
    await _pumpBooking(
      tester,
      locate: () async => const GeoPoint(lat: 30.251, lng: 120.151),
    );

    // 默认选中西湖店，点击滨江店的地图标记后切换
    expect(
      find.descendant(
        of: find.byKey(const Key('store-card-1')),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('store-marker-2')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('store-card-2')),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );
  });

  testWidgets('定位晚到时，自动选中会切到真正的最近门店', (tester) async {
    final completer = Completer<GeoPoint?>();
    // 服务端顺序：滨江店在前
    final reversed = [for (final s in _stores.reversed) s];
    await tester.pumpWidget(
      MaterialApp(
        home: BookingFlowPage(
          storesLoader: () async => reversed,
          locate: () => completer.future,
          detailLoader: _emptyDetail,
          mapBuilder: _fakeMapBuilder,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 定位未返回：按服务端顺序自动选中余杭店（反序后第一）
    expect(
      find.descendant(
        of: find.byKey(const Key('store-card-3')),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );

    // 定位返回（靠近西湖店）：西湖店置顶并自动选中
    completer.complete(const GeoPoint(lat: 30.251, lng: 120.151));
    await tester.pumpAndSettle();

    final xihuY = tester
        .getTopLeft(
          find.descendant(
            of: find.byKey(const Key('store-card-1')),
            matching: find.text('西湖店'),
          ),
        )
        .dy;
    final binjiangY = tester
        .getTopLeft(
          find.descendant(
            of: find.byKey(const Key('store-card-2')),
            matching: find.text('滨江店'),
          ),
        )
        .dy;
    expect(xihuY, lessThan(binjiangY));
    expect(
      find.descendant(
        of: find.byKey(const Key('store-card-1')),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );
  });
}
