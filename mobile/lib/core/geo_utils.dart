import 'dart:math' as math;

/// 经纬度坐标点
class GeoPoint {
  const GeoPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

/// 两坐标点之间的大圆距离（公里），使用 Haversine 公式
double haversineKm(GeoPoint a, GeoPoint b) {
  const earthRadiusKm = 6371.0;
  final dLat = _rad(b.lat - a.lat);
  final dLng = _rad(b.lng - a.lng);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) *
          math.cos(_rad(b.lat)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.sqrt(h));
}

double _rad(double degree) => degree * math.pi / 180;

/// 把公里数格式化成「距你 850m / 1.2km」
String formatDistanceKm(double km) {
  if (km < 1) return '距你 ${(km * 1000).round()}m';
  return '距你 ${km.toStringAsFixed(1)}km';
}
