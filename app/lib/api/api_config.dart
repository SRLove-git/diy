/// 后端地址配置。
///
/// 优先读取编译期参数：
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
/// 未指定时默认使用生产 API 地址：
///   https://diy.medical-sg.com:8443
class ApiConfig {
  ApiConfig._();

  static const String _defined = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_defined.isNotEmpty) return _defined;
    return 'https://diy.medical-sg.com:8443';
  }

  /// REST 前缀：/api
  static String get apiBase => '$baseUrl/api';

  /// WebSocket 地址（聊天实时推送，预留）
  static String get wsUrl {
    final http = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    return '$http/ws';
  }

  /// 把服务端返回的相对路径（如 /uploads/xxx）解析成完整 URL。
  static String resolve(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$baseUrl$url';
    return '$baseUrl/$url';
  }
}
