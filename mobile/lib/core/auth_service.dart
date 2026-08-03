import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import 'chat_service.dart';

class User {
  const User({
    required this.id,
    required this.phone,
    required this.nickname,
    required this.avatar,
    required this.role,
  });

  final int id;
  final String phone;
  final String nickname;
  final String avatar;
  final String role;

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        phone: json['phone'] as String,
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
        role: (json['role'] ?? 'user') as String,
      );
}

/// 登录态管理：token 安全存储（Keychain/Keystore）+ 登录/刷新/登出。
class AuthService extends ChangeNotifier {
  AuthService._() {
    // 统一注入鉴权头 + 401 自动刷新重试
    ApiClient.instance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            handler.next(error);
            return;
          }
          // 刷新令牌请求自身的 401 直接透传，避免递归刷新导致死锁
          if (error.requestOptions.extra['skipRefresh'] == true) {
            handler.next(error);
            return;
          }
          // 避免并发 401 时重复刷新
          if (_isRefreshing) {
            // 等待刷新完成后用新 token 重试
            await _waitForRefresh();
            if (_accessToken != null) {
              handler.resolve(await _retry(error.requestOptions));
            } else {
              handler.next(error);
            }
            return;
          }
          // 最近一次刷新刚失败（如断网/超时）：进入冷却期，直接透传，避免连发刷新请求
          if (_lastRefreshAt != null &&
              DateTime.now().difference(_lastRefreshAt!) < _refreshCooldown) {
            handler.next(error);
            return;
          }
          _lastRefreshAt = DateTime.now();
          _isRefreshing = true;
          try {
            final ok = await tryRefresh();
            if (ok) {
              handler.resolve(await _retry(error.requestOptions));
            } else {
              handler.next(error);
            }
          } finally {
            _isRefreshing = false;
          }
        },
      ),
    );
  }

  static final AuthService instance = AuthService._();

  static final _storage = FlutterSecureStorage(
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  User? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _isRefreshing = false;
  /// refresh token 被服务端明确拒绝（会话确实失效）时置位，用于区分瞬时网络错误
  bool _sessionInvalid = false;
  DateTime? _lastRefreshAt;
  /// 刷新失败后的冷却期：避免断网时对刷新接口的连发请求
  static const _refreshCooldown = Duration(seconds: 10);

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// 启动时恢复登录态；token 失效则尝试用 refresh token 续期
  Future<void> init() async {
    try {
      _accessToken = await _storage.read(key: _kAccess);
      _refreshToken = await _storage.read(key: _kRefresh);
    } catch (_) {
      // Keychain 读取失败则当作未登录
    }
    if (_accessToken != null) {
      await _fetchMe();
    }
    notifyListeners();
  }

  /// 发送验证码，返回 code（开发环境），生产环境返回 null
  Future<String?> sendCode(String phone) async {
    final resp = await ApiClient.instance.post('/auth/sms-code', data: {'phone': phone});
    return (resp.data as Map<String, dynamic>)['code'] as String?;
  }

  Future<void> login(String phone, String code) async {
    final resp = await ApiClient.instance
        .post('/auth/login', data: {'phone': phone, 'code': code});
    await _saveTokens(
      resp.data['accessToken'] as String,
      resp.data['refreshToken'] as String,
    );
    await _fetchMe();
    notifyListeners();
  }

  /// 密码登录（需先用验证码设置过密码）
  Future<void> passwordLogin(String phone, String password) async {
    final resp = await ApiClient.instance.post('/auth/password-login',
        data: {'phone': phone, 'password': password});
    await _saveTokens(
      resp.data['accessToken'] as String,
      resp.data['refreshToken'] as String,
    );
    await _fetchMe();
    notifyListeners();
  }

  /// 设置/重置密码（短信验证码校验后生效）
  Future<void> setPassword(String phone, String code, String password) async {
    await ApiClient.instance.post('/auth/set-password', data: {
      'phone': phone,
      'code': code,
      'password': password,
    });
  }

  Future<bool> tryRefresh() async {
    if (_refreshToken == null) return false;
    try {
      final resp = await ApiClient.instance.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
        // 标记跳过拦截器刷新逻辑，避免 401 递归处理
        options: Options(extra: {'skipRefresh': true}),
      );
      await _saveTokens(
        resp.data['accessToken'] as String,
        resp.data['refreshToken'] as String,
      );
      _sessionInvalid = false;
      _lastRefreshAt = null;
      return true;
    } on DioException catch (e) {
      // 服务端明确返回 401：refresh token 已失效，登录态作废，需重新登录
      if (e.response?.statusCode == 401) {
        _sessionInvalid = true;
        await logout();
        return false;
      }
      // 断网、超时等瞬时错误：保留 token 不登出，等下次请求再自动重试刷新
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 等待其他并发请求完成 token 刷新
  Future<void> _waitForRefresh() async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// 用新 token 重试原请求
  Future<Response<dynamic>> _retry(RequestOptions options) {
    options.headers['Authorization'] = 'Bearer $_accessToken';
    return ApiClient.instance.fetch(options);
  }

  Future<void> updateNickname(String nickname) async {
    final resp = await ApiClient.instance
        .patch('/users/me', data: {'nickname': nickname});
    _user = User.fromJson(resp.data as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> logout() async {
    ChatService.instance.disconnect();
    _sessionInvalid = false;
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Keychain 写入失败忽略
    }
    notifyListeners();
  }

  /// 拉取当前用户；401 已由全局拦截器统一处理。
  /// 仅当会话确已失效（refresh token 被服务端拒绝）时才清空登录态，
  /// 瞬时网络错误保留 token，等下次请求自动重试刷新，避免误登出。
  Future<void> _fetchMe() async {
    try {
      final resp = await ApiClient.instance.get('/auth/me');
      _user = User.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && _sessionInvalid) {
        await logout();
      }
    } catch (_) {
      // 网络不通或数据格式异常，保留 token 等下次重试
    }
  }

  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _secureWrite(_kAccess, access);
    await _secureWrite(_kRefresh, refresh);
  }

  /// Keychain 写入容错：iOS 对已存在的项直接 write 会报 -25299（item already exists），
  /// 遇到时先删除再写入。
  Future<void> _secureWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      if (e.code == '-25299' || (e.message ?? '').contains('already exists')) {
        await _storage.delete(key: key);
        await _storage.write(key: key, value: value);
      } else {
        rethrow;
      }
    }
  }
}
