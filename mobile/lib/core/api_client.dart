import 'package:dio/dio.dart';

import 'config.dart';

/// 统一 API 客户端：管理后台与客户端共用同一套 /api 前缀接口。
class ApiClient {
  ApiClient._();

  /// 大文件上传专用超时（短视频可达数百 MB，远超普通 JSON 请求的 10s）
  static const Duration uploadTimeout = Duration(minutes: 10);

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// 文件上传请求的 Options：放宽发送/接收超时，避免大视频上传途中超时失败
  static Options uploadOptions({Map<String, dynamic>? headers}) {
    return Options(
      sendTimeout: uploadTimeout,
      receiveTimeout: uploadTimeout,
      headers: headers,
    );
  }
}
