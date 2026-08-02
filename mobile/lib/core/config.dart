/// 应用配置。
///
/// API 基址通过编译期注入，三环境互不影响：
///   flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000/api
/// 默认值用于本地开发。
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}
