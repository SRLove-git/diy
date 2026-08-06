import 'dart:io' show Platform;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

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

/// 选店步骤顶部地图：Android 用 OpenStreetMap（免 API Key），iOS 用 Apple Maps
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
      map = _StoreOsmMap(data: data);
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

/// 已选中门店的坐标（未选中或无经纬度时返回 null）
({Store store, double lat, double lng})? _selectedOf(
  List<Store> stores,
  int? selectedId,
) {
  if (selectedId == null) return null;
  for (final s in _geocoded(stores)) {
    if (s.store.id == selectedId) return s;
  }
  return null;
}

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

// ===== Android：OpenStreetMap（flutter_map 瓦片地图，免 API Key）=====

class _StoreOsmMap extends StatefulWidget {
  const _StoreOsmMap({required this.data});

  final StoreMapViewData data;

  @override
  State<_StoreOsmMap> createState() => _StoreOsmMapState();
}

class _StoreOsmMapState extends State<_StoreOsmMap> {
  final MapController _controller = MapController();
  bool _fitted = false;

  @override
  void didUpdateWidget(_StoreOsmMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.stores != widget.data.stores) {
      // 门店列表变化（加载/定位重排/搜索过滤）：重新适配视野
      _fitted = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitOnce());
    } else if (oldWidget.data.selectedStoreId != widget.data.selectedStoreId) {
      // 切换选中门店：地图跟随到该门店
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnSelected());
    }
  }

  void _fitOnce() {
    if (_fitted || widget.data.stores.isEmpty) return;
    _fitted = true;
    final b = _boundsOf(widget.data.stores, widget.data.userLocation);
    _controller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          ll.LatLng(b.minLat, b.minLng),
          ll.LatLng(b.maxLat, b.maxLng),
        ),
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  /// 将视野中心移动到已选门店（地图外选择列表门店时跟随刷新）
  void _centerOnSelected() {
    if (!mounted) return;
    final selected = _selectedOf(widget.data.stores, widget.data.selectedStoreId);
    if (selected == null) return;
    _controller.move(ll.LatLng(selected.lat, selected.lng), 14);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final center = _centerOf(data.stores);
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: ll.LatLng(center.lat, center.lng),
        initialZoom: 13,
        onMapReady: _fitOnce,
        // 与原生地图一致：禁用旋转，保留拖动/缩放
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.diy.diy_mobile',
        ),
        MarkerLayer(markers: _markers()),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }

  List<Marker> _markers() {
    final data = widget.data;
    return [
      // 定位点：蓝色圆点（与原生地图“我的位置”视觉一致）
      if (data.userLocation != null)
        Marker(
          point: ll.LatLng(data.userLocation!.lat, data.userLocation!.lng),
          width: 16,
          height: 16,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF1A73E8),
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Colors.white, width: 3),
              ),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
          ),
        ),
      for (final s in _geocoded(data.stores))
        Marker(
          point: ll.LatLng(s.lat, s.lng),
          width: 170,
          // 图钉尖（图标底部）对准门店坐标，标签在钉尖上方
          height: s.store.id == data.selectedStoreId ? 86 : 64,
          alignment: Alignment.topCenter,
          child: _StoreOsmMarker(
            store: s.store,
            selected: s.store.id == data.selectedStoreId,
            onTap: () => data.onSelectStore(s.store),
          ),
        ),
    ];
  }
}

/// OSM 门店标记：图钉 + 店名标签，选中门店额外展示地址，
/// 便于在搜索后按店名/地址在地图上确认门店
class _StoreOsmMarker extends StatelessWidget {
  const _StoreOsmMarker({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final Store store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 170),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFF2E7D32)
                        : Colors.black87,
                  ),
                ),
                if (selected)
                  Text(
                    store.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            Icons.location_on,
            size: 36,
            color: selected ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
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
    if (oldWidget.data.stores != widget.data.stores) {
      // 门店列表变化（加载/定位重排/搜索过滤）：重新适配视野
      _fitted = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitOnce());
    } else if (oldWidget.data.selectedStoreId != widget.data.selectedStoreId) {
      // 切换选中门店：地图跟随到该门店
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnSelected());
    }
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

  /// 将视野中心移动到已选门店（地图外选择列表门店时跟随刷新）
  void _centerOnSelected() {
    if (!mounted) return;
    final c = _controller;
    final selected = _selectedOf(widget.data.stores, widget.data.selectedStoreId);
    if (c == null || selected == null) return;
    c.moveCamera(
      apple.CameraUpdate.newCameraPosition(
        apple.CameraPosition(
          target: apple.LatLng(selected.lat, selected.lng),
          zoom: 14,
        ),
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
