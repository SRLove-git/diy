import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'appointment_api.dart';
import 'geo_utils.dart';

/// 外部地图导航：把门店坐标转换为各地图应用的坐标系后，
/// 用系统 URL Scheme 调起本机安装的地图 App 进行导航。
///
/// 坐标系约定：后台录入的门店经纬度按国内通用 GCJ-02（国测局火星坐标）
/// 处理。高德/腾讯直接使用；百度需转 BD-09；Apple/Google 需转 WGS-84。
/// 若后台实际录入的是 WGS-84 坐标，把下面的开关改为 false 即可。
const bool kStoreCoordsAreGcj02 = true;

typedef StoreNavigationLauncher = Future<bool> Function(Uri uri);

/// 地图应用选项（展示信息 + 依次尝试的跳转链接）
class MapAppOption {
  const MapAppOption({
    required this.label,
    required this.subtitle,
    required this.glyph,
    required this.color,
    required this.uris,
  });

  final String label;
  final String subtitle;

  /// 圆形图标里的单字（如 高/百/腾）
  final String glyph;
  final Color color;

  /// 按优先级排列：App 自定义 Scheme 在前，网页链接兜底
  final List<Uri> uris;
}

/// 生成某门店可用的导航地图选项。
/// [platform] 仅影响「系统地图」的命名，测试可注入。
List<MapAppOption> storeNavigationOptions(
  Store store, {
  TargetPlatform? platform,
}) {
  final target = platform ?? defaultTargetPlatform;
  final name = store.name;
  final lat = store.lat;
  final lng = store.lng;
  if (lat == null || lng == null) return const [];
  final gcj = GeoPoint(lat: lat, lng: lng);
  // 百度使用 BD-09，Apple/Google 使用 WGS-84
  final bd = kStoreCoordsAreGcj02 ? gcj02ToBd09(gcj) : gcj;
  final wgs = kStoreCoordsAreGcj02 ? gcj02ToWgs84(gcj) : gcj;
  final isIos = !kIsWeb && Platform.isIOS;

  // 系统地图：iOS → Apple 地图，其他 → Google 地图
  final system = MapAppOption(
    label: target == TargetPlatform.iOS ? 'Apple 地图' : 'Google 地图',
    subtitle: '系统地图导航',
    glyph: target == TargetPlatform.iOS ? 'A' : 'G',
    color: const Color(0xFF4285F4),
    uris: target == TargetPlatform.iOS
        ? [
            Uri.parse(
              'https://maps.apple.com/?daddr=${wgs.lat},${wgs.lng}'
              '&q=${Uri.encodeComponent(name)}',
            ),
          ]
        : [
            Uri.parse('google.navigation:q=${wgs.lat},${wgs.lng}&mode=d'),
            Uri.parse(
              'https://www.google.com/maps/dir/?api=1'
              '&destination=${wgs.lat},${wgs.lng}',
            ),
          ],
  );

  // 高德地图（GCJ-02 直用）
  final amapScheme = isIos
      ? 'iosamap://navi?sourceApplication=diy_mobile&poiname='
          '${Uri.encodeComponent(name)}&lat=${gcj.lat}&lon=${gcj.lng}&dev=0'
      : 'androidamap://navi?sourceApplication=diy_mobile&poiname='
          '${Uri.encodeComponent(name)}&lat=${gcj.lat}&lon=${gcj.lng}&dev=0';
  final amap = MapAppOption(
    label: '高德地图',
    subtitle: '驾车导航',
    glyph: '高',
    color: const Color(0xFF1E88E5),
    uris: [
      Uri.parse(amapScheme),
      Uri.parse(
        'https://uri.amap.com/navigation?to=${gcj.lat},${gcj.lng},'
        '${Uri.encodeComponent(name)}&mode=car&coordinate=gaode',
      ),
    ],
  );

  // 百度地图（BD-09）
  final bdDest = Uri.encodeComponent('latlng:${bd.lat},${bd.lng}|$name');
  final baidu = MapAppOption(
    label: '百度地图',
    subtitle: '驾车导航',
    glyph: '百',
    color: const Color(0xFF2932E1),
    uris: [
      Uri.parse(
        'baidumap://map/direction?destination=$bdDest'
        '&coord_type=bd09ll&mode=driving&src=diy_mobile',
      ),
      Uri.parse(
        'https://api.map.baidu.com/direction?destination=$bdDest'
        '&coord_type=bd09ll&mode=driving&output=html&src=diy_mobile',
      ),
    ],
  );

  // 腾讯地图（GCJ-02 直用）
  final tencent = MapAppOption(
    label: '腾讯地图',
    subtitle: '驾车导航',
    glyph: '腾',
    color: const Color(0xFF0087E5),
    uris: [
      Uri.parse(
        'qqmap://map/routeplan?type=drive&from=我的位置'
        '&to=${Uri.encodeComponent(name)}&tocoord=${gcj.lat},${gcj.lng}'
        '&referer=diy_mobile',
      ),
      Uri.parse(
        'https://apis.map.qq.com/uri/v1/routeplan?type=drive&from=我的位置'
        '&to=${Uri.encodeComponent(name)}&tocoord=${gcj.lat},${gcj.lng}'
        '&referer=diy_mobile',
      ),
    ],
  );

  return [system, amap, baidu, tencent];
}

/// 弹出「选择地图导航」底部面板：选择后按优先级调起本机地图 App
Future<void> showStoreNavigationSheet(
  BuildContext context,
  Store store, {
  StoreNavigationLauncher? launcher,
}) async {
  final options = storeNavigationOptions(store);
  if (options.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该门店暂未配置位置，无法导航')),
      );
    }
    return;
  }
  final colors = Theme.of(context).colorScheme;
  final launch = launcher ?? _defaultLauncher;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Text(
                  '选择地图导航',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  store.address,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
              for (final option in options)
                ListTile(
                  key: Key('nav-option-${option.label}'),
                  leading: CircleAvatar(
                    backgroundColor: option.color,
                    child: Text(
                      option.glyph,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(option.label),
                  subtitle: Text(option.subtitle),
                  trailing: const Icon(Icons.navigation_outlined),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _launchFirstAvailable(context, launch, option);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> _defaultLauncher(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// 依次尝试跳转链接：App 未安装时兜底到网页版地图
Future<void> _launchFirstAvailable(
  BuildContext context,
  StoreNavigationLauncher launch,
  MapAppOption option,
) async {
  for (final uri in option.uris) {
    try {
      if (await launch(uri)) return;
    } catch (_) {
      // 继续尝试下一个链接
    }
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('未能打开${option.label}，请确认已安装该应用')),
    );
  }
}

// ===== 坐标系转换 =====

/// 判断坐标是否在海外（国内地图偏移只对中国境内坐标生效）
bool _outOfChina(GeoPoint p) =>
    p.lng < 72.004 ||
    p.lng > 137.8347 ||
    p.lat < 0.8293 ||
    p.lat > 55.8271;

/// GCJ-02（高德/腾讯）→ WGS-84（Apple/Google）
GeoPoint gcj02ToWgs84(GeoPoint p) {
  if (_outOfChina(p)) return p;
  final dLat = _transformLat(p.lng - 105.0, p.lat - 35.0);
  final dLng = _transformLng(p.lng - 105.0, p.lat - 35.0);
  final radLat = p.lat / 180.0 * math.pi;
  var magic = math.sin(radLat);
  magic = 1 - _ee * magic * magic;
  final sqrtMagic = math.sqrt(magic);
  final dLatAdj =
      (dLat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtMagic) * math.pi);
  final dLngAdj =
      (dLng * 180.0) / (_a / sqrtMagic * math.cos(radLat) * math.pi);
  return GeoPoint(lat: p.lat - dLatAdj, lng: p.lng - dLngAdj);
}

/// GCJ-02（高德/腾讯）→ BD-09（百度）
GeoPoint gcj02ToBd09(GeoPoint p) {
  final x = p.lng;
  final y = p.lat;
  final z = math.sqrt(x * x + y * y) + 0.00002 * math.sin(y * _xPi);
  final theta = math.atan2(y, x) + 0.000003 * math.cos(x * _xPi);
  return GeoPoint(
    lat: z * math.sin(theta) + 0.006,
    lng: z * math.cos(theta) + 0.0065,
  );
}

const double _a = 6378245.0;
const double _ee = 0.00669342162296594323;
const double _xPi = math.pi * 3000 / 180;

double _transformLat(double x, double y) {
  var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y +
      0.2 * math.sqrt(x.abs());
  ret += (20.0 * math.sin(6.0 * x * math.pi) +
      20.0 * math.sin(2.0 * x * math.pi)) *
      2.0 /
      3.0;
  ret += (20.0 * math.sin(y * math.pi) +
      40.0 * math.sin(y / 3.0 * math.pi)) *
      2.0 /
      3.0;
  ret += (160.0 * math.sin(y / 12.0 * math.pi) +
      320 * math.sin(y * math.pi / 30.0)) *
      2.0 /
      3.0;
  return ret;
}

double _transformLng(double x, double y) {
  var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y +
      0.1 * math.sqrt(x.abs());
  ret += (20.0 * math.sin(6.0 * x * math.pi) +
      20.0 * math.sin(2.0 * x * math.pi)) *
      2.0 /
      3.0;
  ret += (20.0 * math.sin(x * math.pi) +
      40.0 * math.sin(x / 3.0 * math.pi)) *
      2.0 /
      3.0;
  ret += (150.0 * math.sin(x / 12.0 * math.pi) +
      300.0 * math.sin(x / 30.0 * math.pi)) *
      2.0 /
      3.0;
  return ret;
}
