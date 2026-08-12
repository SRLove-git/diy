import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// 安装级设备标识（等价于"MAC 地址"的设备指纹）。
///
/// 现代 iOS / Android 禁止应用读取真实 MAC 地址，因此用安装时生成的
/// 随机 ID 替代：首次启动生成并持久化，之后保持不变。
/// 同一安装内注册的账号共享同一个 deviceId，服务端据此限制
/// 同一设备最多注册 3 个账号（防恶意预约 / 刷号）。
class DeviceIdProvider {
  DeviceIdProvider._();

  static final DeviceIdProvider instance = DeviceIdProvider._();

  static const _kDeviceId = 'install_device_id';
  static const _chars = '0123456789abcdef';
  static final _random = Random.secure();

  String? _cached;

  Future<String> id() async {
    final cached = _cached;
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kDeviceId);
    if (id == null || id.isEmpty || id.length > 64) {
      id = _generate();
      await prefs.setString(_kDeviceId, id);
    }
    _cached = id;
    return id;
  }

  String _generate() {
    final buf = StringBuffer(
      DateTime.now().millisecondsSinceEpoch.toRadixString(16),
    );
    while (buf.length < 32) {
      buf.write(_chars[_random.nextInt(_chars.length)]);
    }
    return buf.toString();
  }
}
