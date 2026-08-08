import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 登录态（JWT）的内存 + 本地持久化存储。
class AuthStore extends ChangeNotifier {
  AuthStore._();

  static AuthStore? _instance;
  static AuthStore get instance => _instance ??= AuthStore._();

  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kUserId = 'auth_user_id';

  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  bool _loaded = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;
  bool get loaded => _loaded;

  /// App 启动时从本地恢复登录态。
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_kAccess);
    _refreshToken = prefs.getString(_kRefresh);
    _userId = prefs.getInt(_kUserId);
    _loaded = true;
    notifyListeners();
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, accessToken);
    await prefs.setString(_kRefresh, refreshToken);
    await prefs.setInt(_kUserId, userId);
    notifyListeners();
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    await prefs.remove(_kUserId);
    notifyListeners();
  }
}
