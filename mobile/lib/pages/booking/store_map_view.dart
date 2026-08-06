import 'dart:io' show Platform;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../core/app_colors.dart';
import '../../core/appointment_api.dart';
import '../../core/geo_utils.dart';

/// 选店步骤顶部地图的数据与回调
class StoreMapViewData {
  const StoreMapViewData({
    required this.stores,
    this.userLocation,
    required this.selectedStoreId,
    required this.onSelectStore,
  });

  final List<Store> stores;
  final GeoPoint? userLocation;
  final int? selectedStoreId;
  final ValueChanged<Store> onSelectStore;
}

/// 测试注入用：自定义地图渲染（避免在测试中创建原生地图视图）
typedef StoreMapBuilder =
    Widget Function(BuildContext context, StoreMapViewData data);

/// 选店步骤顶部地图：Android 用 Google Maps，iOS 用 Apple Maps
class StoreMapView extends StatelessWidget {
  const StoreMapView({
    super.key,
    required this.data,
    this.builder,
    this.height = 260,
  });

  final StoreMapViewData data;

  /// 测试注入用，默认按平台选择原生地图
  final StoreMapBuilder? builder;

  final double height;

  @override
  Widget build(BuildContext context) {
    final Widget map;
    if (builder != null) {
      map = builder!(context, data);
    } else if (kIsWeb) {
      map = const _UnsupportedMapHint();
    } else if (Platform.isIOS) {
      map = _StoreAppleMap(data: data);
    } else {
      map = _StoreGoogleMap(data: data);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(height: height, width: double.infinity, child: map),
    );
  }
}

/// 定位点是否在门店区域附近（避免用户与门店跨城市时地图被拉到全国视野）
bool _nearStores(List<Store> stores, GeoPoint user) {
  var minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;
  for (final s in _geocoded(stores)) {
    minLat = s.lat < minLat ? s.lat : minLat;
    maxLat = s.lat > maxLat ? s.lat : maxLat;
    minLng = s.lng < minLng ? s.lng : minLng;
    maxLng = s.lng > maxLng ? s.lng : maxLng;
  }
  const pad = 1.0; // 约 100km
  return user.lat >= minLat - pad &&
      user.lat <= maxLat + pad &&
      user.lng >= minLng - pad &&
      user.lng <= maxLng + pad;
}

/// 仅保留已配置经纬度的门店（地图只展示可定位门店），
/// 以非空坐标记录返回，避免 nullable 字段无法提升
List<({Store store, double lat, double lng})> _geocoded(List<Store> stores) =>
    [
      for (final s in stores)
        if (s.lat != null && s.lng != null)
          (store: s, lat: s.lat!, lng: s.lng!),
    ];

/// 门店区域中心（门店为空时回退杭州）
GeoPoint _centerOf(List<Store> stores) {
  final geocoded = _geocoded(stores);
  if (geocoded.isEmpty) return const GeoPoint(lat: 30.3, lng: 120.1);
  var lat = 0.0, lng = 0.0;
  for (final s in geocoded) { lat += s.lat; lng += s.lng; }
  return GeoPoint(lat: lat / geocoded.length, lng: lng / geocoded.length);
}

/// 计算门店（+定位点）包围盒；单点/零面积时外扩约 1km，
/// 避免搜索筛选后只剩一家店时地图视野退化为点导致异常
({double minLat, double maxLat, double minLng, double maxLng}) _boundsOf(
  List<Store> stores,
  GeoPoint? user,
) {
  var minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;
  for (final s in _geocoded(stores)) {
    minLat = s.lat < minLat ? s.lat : minLat;
    maxLat = s.lat > maxLat ? s.lat : maxLat;
    minLng = s.lng < minLng ? s.lng : minLng;
    maxLng = s.lng > maxLng ? s.lng : maxLng;
  }
  if (user != null && _nearStores(stores, user)) {
    minLat = user.lat < minLat ? user.lat : minLat;
    maxLat = user.lat > maxLat ? user.lat : maxLat;
    minLng = user.lng < minLng ? user.lng : minLng;
    maxLng = user.lng > maxLng ? user.lng : maxLng;
  }
  const minSpan = 0.01; // 约 1km
  if (maxLat - minLat < minSpan) {
    final pad = (minSpan - (maxLat - minLat)) / 2;
    minLat -= pad;
    maxLat += pad;
  }
  if (maxLng - minLng < minSpan) {
    final pad = (minSpan - (maxLng - minLng)) / 2;
    minLng -= pad;
    maxLng += pad;
  }
  return (minLat: minLat, maxLat: maxLat, minLng: minLng, maxLng: maxLng);
}

// ===== Android：Google Maps =====

class _StoreGoogleMap extends StatefulWidget {
  const _StoreGoogleMap({required this.data});

  final StoreMapViewData data;

  @override
  State<_StoreGoogleMap> createState() => _StoreGoogleMapState();
}

class _StoreGoogleMapState extends State<_StoreGoogleMap> {
  gmaps.GoogleMapController? _controller;
  bool _fitted = false;

  @override
  void didUpdateWidget(_StoreGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.stores != widget.data.stores) _fitted = false;
    if (!_fitted) WidgetsBinding.instance.addPostFrameCallback((_) => _fitOnce());
  }

  void _fitOnce() {
    final c = _controller;
    if (c == null || _fitted || widget.data.stores.isEmpty) return;
    _fitted = true;
    final b = _boundsOf(widget.data.stores, widget.data.userLocation);
    c.moveCamera(
      gmaps.CameraUpdate.newLatLngBounds(
        gmaps.LatLngBounds(
          southwest: gmaps.LatLng(b.minLat, b.minLng),
          northeast: gmaps.LatLng(b.maxLat, b.maxLng),
        ),
        48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final center = _centerOf(data.stores);
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(center.lat, center.lng),
        zoom: 13,
      ),
      markers: _markers(),
      myLocationEnabled: data.userLocation != null,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      onMapCreated: (c) {
        _controller = c;
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitOnce());
      },
    );
  }

  Set<gmaps.Marker> _markers() {
    final data = widget.data;
    return {
      for (final s in _geocoded(data.stores))
        gmaps.Marker(
          markerId: gmaps.MarkerId('store-${s.store.id}'),
          position: gmaps.LatLng(s.lat, s.lng),
          infoWindow: gmaps.InfoWindow(title: s.store.name, snippet: s.store.address),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            s.store.id == data.selectedStoreId
                ? gmaps.BitmapDescriptor.hueGreen
                : gmaps.BitmapDescriptor.hueRed,
          ),
          onTap: () => data.onSelectStore(s.store),
        ),
    };
  }
}

// ===== iOS：Apple Maps =====

class _StoreAppleMap extends StatefulWidget {
  const _StoreAppleMap({required this.data});

  final StoreMapViewData data;

  @override
  State<_StoreAppleMap> createState() => _StoreAppleMapState();
}

class _StoreAppleMapState extends State<_StoreAppleMap> {
  apple.AppleMapController? _controller;
  bool _fitted = false;

  @override
  void didUpdateWidget(_StoreAppleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.stores != widget.data.stores) _fitted = false;
    if (!_fitted) WidgetsBinding.instance.addPostFrameCallback((_) => _fitOnce());
  }

  void _fitOnce() {
    final c = _controller;
    if (c == null || _fitted || widget.data.stores.isEmpty) return;
    _fitted = true;
    final b = _boundsOf(widget.data.stores, widget.data.userLocation);
    c.moveCamera(
      apple.CameraUpdate.newLatLngBounds(
        apple.LatLngBounds(
          southwest: apple.LatLng(b.minLat, b.minLng),
          northeast: apple.LatLng(b.maxLat, b.maxLng),
        ),
        48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final center = _centerOf(data.stores);
    return apple.AppleMap(
      initialCameraPosition: apple.CameraPosition(
        target: apple.LatLng(center.lat, center.lng),
        zoom: 13,
      ),
      annotations: _annotations(),
      myLocationEnabled: data.userLocation != null,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      onMapCreated: (c) {
        _controller = c;
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitOnce());
      },
    );
  }

  Set<apple.Annotation> _annotations() {
    final data = widget.data;
    return {
      for (final s in _geocoded(data.stores))
        apple.Annotation(
          annotationId: apple.AnnotationId('store-${s.store.id}'),
          position: apple.LatLng(s.lat, s.lng),
          infoWindow: apple.InfoWindow(title: s.store.name, snippet: s.store.address),
          icon: apple.BitmapDescriptor.markerAnnotationWithHue(
            s.store.id == data.selectedStoreId
                ? apple.BitmapDescriptor.hueGreen
                : apple.BitmapDescriptor.hueRed,
          ),
          onTap: () => data.onSelectStore(s.store),
        ),
    };
  }
}

class _UnsupportedMapHint extends StatelessWidget {
  const _UnsupportedMapHint();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.surfaceAlt,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 32, color: Palette.textSecondary),
            SizedBox(height: 8),
            Text(
              'Web 端暂不支持地图',
              style: TextStyle(
                color: Palette.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '请在下方列表中选择门店',
              style: TextStyle(color: Palette.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
