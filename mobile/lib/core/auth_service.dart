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
    // 统一注入鉴权头
    ApiClient.instance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
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
      final resp = await ApiClient.instance
          .post('/auth/refresh', data: {'refreshToken': _refreshToken});
      await _saveTokens(
        resp.data['accessToken'] as String,
        resp.data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> updateNickname(String nickname) async {
    final resp = await ApiClient.instance
        .patch('/users/me', data: {'nickname': nickname});
    _user = User.fromJson(resp.data as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> logout() async {
    ChatService.instance.disconnect();
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

  /// 拉取当前用户；401 时自动 refresh 一次再重试
  Future<void> _fetchMe() async {
    try {
      final resp = await ApiClient.instance.get('/auth/me');
      _user = User.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && await tryRefresh()) {
        final resp = await ApiClient.instance.get('/auth/me');
        _user = User.fromJson(resp.data as Map<String, dynamic>);
      } else {
        // 401 且 refresh 失败才清空登录态；网络不通则保留 token 等下次重试
        if (e.response?.statusCode == 401) {
          await logout();
        }
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
