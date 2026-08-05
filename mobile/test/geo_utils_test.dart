import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/core/geo_utils.dart';

void main() {
  test('haversineKm 计算上海到杭州距离约为 164km', () {
    const shanghai = GeoPoint(lat: 31.2304, lng: 121.4737);
    const hangzhou = GeoPoint(lat: 30.2741, lng: 120.1551);
    final km = haversineKm(shanghai, hangzhou);
    expect(km, closeTo(164, 6));
  });

  test('haversineKm 同点距离为 0', () {
    const p = GeoPoint(lat: 30.25, lng: 120.15);
    expect(haversineKm(p, p), 0);
  });

  test('formatDistanceKm 按 1km 分界格式化', () {
    expect(formatDistanceKm(0.85), '距你 850m');
    expect(formatDistanceKm(1.23), '距你 1.2km');
    expect(formatDistanceKm(0.045), '距你 45m');
  });
}
