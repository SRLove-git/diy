import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_store.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// 轻量 JSON HTTP 客户端：统一 baseUrl、鉴权头、401 刷新重试、错误解析。
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  final http.Client _client = http.Client();
  bool _refreshing = false;

  Map<String, String> _headers({bool json = true, bool auth = true}) {
    final h = <String, String>{
      if (json) 'Content-Type': 'application/json',
    };
    final token = AuthStore.instance.accessToken;
    if (auth && token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final q = query?.map(
      (k, v) => MapEntry(k, v is List ? v.join(',') : '$v'),
    );
    return Uri.parse('${ApiConfig.apiBase}$path').replace(queryParameters: q);
  }

  static String _errorMessage(Object? body, int statusCode) {
    if (body is Map) {
      final msg = body['message'];
      if (msg is String) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join('\n');
      if (body['error'] is String) return body['error'] as String;
    }
    return '请求失败（$statusCode）';
  }

  Future<dynamic> _send(
    Future<http.Response> Function() send, {
    bool retried = false,
  }) async {
    http.Response res;
    try {
      res = await send();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('网络连接失败，请确认后端服务已启动（$e）');
    }

    if (res.statusCode == 401 && !retried && AuthStore.instance.isLoggedIn) {
      final ok = await _refresh();
      if (ok) return _send(send, retried: true);
    }

    dynamic body;
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = res.body;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(_errorMessage(body, res.statusCode), statusCode: res.statusCode);
  }

  Future<bool> _refresh() async {
    final store = AuthStore.instance;
    final refreshToken = store.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;
    if (_refreshing) return false;
    _refreshing = true;
    try {
      final res = await _client.post(
        _uri('/auth/refresh'),
        headers: _headers(auth: false),
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        await store.save(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          userId: store.userId ?? 0,
        );
        return true;
      }
      await store.clear();
      return false;
    } catch (_) {
      return false;
    } finally {
      _refreshing = false;
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _send(() => _client.get(_uri(path, query), headers: _headers()));
  }

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query}) {
    return _send(() => _client.post(
          _uri(path, query),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Future<dynamic> patch(String path, {Object? body}) {
    return _send(() => _client.patch(
          _uri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Future<dynamic> put(String path, {Object? body}) {
    return _send(() => _client.put(
          _uri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Future<dynamic> delete(String path) {
    return _send(() => _client.delete(_uri(path), headers: _headers()));
  }

  /// multipart 文件上传（图片/音频/视频），返回服务端 JSON。
  Future<dynamic> upload(
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    String? contentType,
    Map<String, String>? query,
  }) {
    return _send(() async {
      final req = http.MultipartRequest('POST', _uri(path, query));
      req.headers.addAll(_headers(auth: true, json: false));
      req.files.add(http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: filename,
        contentType: contentType == null ? null : mediaTypeFromString(contentType),
      ));
      final streamed = await _client.send(req);
      return http.Response.fromStream(streamed);
    });
  }
}

http.MediaType mediaTypeFromString(String value) {
  final parts = value.split('/');
  return http.MediaType(parts.first, parts.last);
}
