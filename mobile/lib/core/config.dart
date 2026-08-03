import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 应用配置。
///
/// API 基址读取顺序（后两项为回退）：
///   1. `.env` 文件中的 `API_BASE_URL`（编辑后热重启即可生效）
///   2. 编译期注入：flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000/api
///   3. 本地开发默认值
class AppConfig {
  AppConfig._();

  static String get apiBaseUrl {
    final env = dotenv.maybeGet('API_BASE_URL');
    if (env != null && env.isNotEmpty) return env;
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000/api',
    );
  }
}
