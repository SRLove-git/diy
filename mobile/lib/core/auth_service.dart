import 'dart:async';
import 'dart:convert';

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
    this.username,
    this.usernameUpdatedAt,
    this.bio = '',
    this.gender = 'secret',
    this.birthday,
    this.location = '',
  });

  final int id;
  final String phone;
  final String nickname;
  final String avatar;
  final String role;

  /// 用户名（2-30 位字母/数字/下划线），null 表示未设置
  final String? username;

  /// 用户名最近一次修改时间（一年内只能修改一次），null 表示从未修改
  final DateTime? usernameUpdatedAt;

  /// 个人简介，空串表示未设置
  final String bio;

  /// 性别：male 男 / female 女 / secret 保密
  final String gender;

  /// 生日（YYYY-MM-DD），null 表示未设置
  final String? birthday;

  /// 所在地，空串表示未设置
  final String location;

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        phone: json['phone'] as String,
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
        role: (json['role'] ?? 'user') as String,
        username: json['username'] as String?,
        usernameUpdatedAt:
            DateTime.tryParse((json['usernameUpdatedAt'] as String?) ?? ''),
        bio: (json['bio'] ?? '') as String,
        gender: (json['gender'] ?? 'secret') as String,
        birthday: json['birthday'] as String?,
        location: (json['location'] ?? '') as String,
      );
}

/// 已保存的多账号会话（登录后自动记录，供「切换账号」快速切换）。
class SavedSession {
  const SavedSession({
    required this.userId,
    required this.nickname,
    required this.avatar,
    required this.accessToken,
    required this.refreshToken,
  });

  final int userId;
  final String nickname;
  final String avatar;
  final String accessToken;
  final String refreshToken;

  SavedSession copyWith({String? nickname, String? avatar}) => SavedSession(
        userId: userId,
        nickname: nickname ?? this.nickname,
        avatar: avatar ?? this.avatar,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

  factory SavedSession.fromJson(Map<String, dynamic> json) => SavedSession(
        userId: (json['userId'] as num).toInt(),
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
        accessToken: (json['accessToken'] ?? '') as String,
        refreshToken: (json['refreshToken'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'nickname': nickname,
        'avatar': avatar,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
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
  static const _kSessions = 'saved_sessions';

  User? _user;
  String? _accessToken;
  String? _refreshToken;
  Map<int, SavedSession> _sessions = {};
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

  /// 已保存的多账号会话（不含当前账号；切换/移除用）
  List<SavedSession> get savedSessions => _sessions.values.toList();

  /// 启动时恢复登录态；token 失效则尝试用 refresh token 续期
  Future<void> init() async {
    try {
      _accessToken = await _storage.read(key: _kAccess);
      _refreshToken = await _storage.read(key: _kRefresh);
    } catch (_) {
      // Keychain 读取失败则当作未登录
    }
    try {
      final raw = await _storage.read(key: _kSessions);
      if (raw != null && raw.isNotEmpty) {
        _sessions = {
          for (final e in (jsonDecode(raw) as List))
            ((e as Map<String, dynamic>)['userId'] as num).toInt():
                SavedSession.fromJson(e),
        };
      }
    } catch (_) {
      _sessions = {};
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
    await _saveCurrentSession();
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
    await _saveCurrentSession();
    notifyListeners();
  }

  /// 用户名 + 密码登录
  Future<void> usernameLogin(String username, String password) async {
    final resp = await ApiClient.instance.post('/auth/username-login',
        data: {'username': username, 'password': password});
    await _saveTokens(
      resp.data['accessToken'] as String,
      resp.data['refreshToken'] as String,
    );
    await _fetchMe();
    await _saveCurrentSession();
    notifyListeners();
  }

  /// 设置/重置密码（短信验证码校验后生效），可选同时设置用户名
  Future<void> setPassword(String phone, String code, String password,
      {String? username}) async {
    final data = <String, dynamic>{
      'phone': phone,
      'code': code,
      'password': password,
    };
    if (username != null) data['username'] = username;
    await ApiClient.instance.post('/auth/set-password', data: data);
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

  Future<void> updateNickname(String nickname) =>
      updateProfile(nickname: nickname);

  /// 更新个人资料（昵称 / 用户名 / 简介 / 性别 / 生日 / 所在地）。
  /// 传 null 的字段保持不变；生日清空时传空串。
  Future<void> updateProfile({
    String? nickname,
    String? username,
    String? bio,
    String? gender,
    String? birthday,
    String? location,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (gender != null) data['gender'] = gender;
    if (birthday != null) data['birthday'] = birthday;
    if (location != null) data['location'] = location;
    final resp = await ApiClient.instance.patch('/users/me', data: data);
    _user = User.fromJson(resp.data as Map<String, dynamic>);
    await _refreshCurrentSessionMeta();
    notifyListeners();
  }

  /// 上传并更新头像：先上传图片到 /uploads/avatar，再 PATCH 到用户资料。
  /// 上传后的相对路径存库，展示侧统一用 ChatApi.resolveUrl 拼绝对地址。
  Future<void> updateAvatar(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final upload = await ApiClient.instance.post(
      '/uploads/images',
      queryParameters: {'folder': 'avatar'},
      data: form,
      options: ApiClient.uploadOptions(
        headers: {'Content-Type': Headers.multipartFormDataContentType},
      ),
    );
    final url = (upload.data as Map<String, dynamic>)['url'] as String;
    final resp = await ApiClient.instance
        .patch('/users/me', data: {'avatar': url});
    _user = User.fromJson(resp.data as Map<String, dynamic>);
    await _refreshCurrentSessionMeta();
    notifyListeners();
  }

  Future<void> logout() async {
    ChatService.instance.disconnect();
    _sessionInvalid = false;
    await _removeSession(_user?.id);
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    try {
      // 只清当前会话 token；已保存的多账号会话保留，供下次「切换账号」使用
      await _storage.delete(key: _kAccess);
      await _storage.delete(key: _kRefresh);
    } catch (_) {
      // Keychain 删除失败忽略
    }
    notifyListeners();
  }

  /// 把当前登录会话加入多账号列表（登录成功后自动调用）。
  Future<bool> saveCurrentSession() => _saveCurrentSession();

  Future<bool> _saveCurrentSession() async {
    final u = _user;
    if (u == null || _accessToken == null || _refreshToken == null) {
      return false;
    }
    _sessions[u.id] = SavedSession(
      userId: u.id,
      nickname: u.nickname,
      avatar: u.avatar,
      accessToken: _accessToken!,
      refreshToken: _refreshToken!,
    );
    await _persistSessions();
    return true;
  }

  /// 更新已保存会话的展示信息（昵称 / 头像变更后同步）。
  Future<void> _refreshCurrentSessionMeta() async {
    final u = _user;
    if (u == null || _accessToken == null || _refreshToken == null) return;
    final s = _sessions[u.id];
    if (s == null) return;
    _sessions[u.id] = s.copyWith(nickname: u.nickname, avatar: u.avatar);
    await _persistSessions();
  }

  /// 切换到已保存的账号会话：先存档当前会话，再替换 token 并拉取目标用户资料。
  Future<bool> switchToSession(SavedSession session) async {
    if (_accessToken == null || _refreshToken == null) return false;
    final previous = _user;
    if (previous != null) {
      _sessions[previous.id] = SavedSession(
        userId: previous.id,
        nickname: previous.nickname,
        avatar: previous.avatar,
        accessToken: _accessToken!,
        refreshToken: _refreshToken!,
      );
    }
    _accessToken = session.accessToken;
    _refreshToken = session.refreshToken;
    await _secureWrite(_kAccess, session.accessToken);
    await _secureWrite(_kRefresh, session.refreshToken);
    _sessions.remove(session.userId);
    await _persistSessions();
    await _fetchMe();
    // 目标会话 token 可能已过期：尝试刷新一次；
    // 若 refresh token 被服务端拒绝，tryRefresh 会清空登录态并回到登录页。
    if (_user == null) {
      await tryRefresh();
    }
    if (_user != null) {
      await _saveCurrentSession();
    }
    ChatService.instance.disconnect();
    notifyListeners();
    return _user != null;
  }

  /// 移除一个已保存会话（不影响当前登录态）。
  Future<void> removeSession(int userId) async {
    _sessions.remove(userId);
    await _persistSessions();
  }

  Future<void> _removeSession(int? userId) async {
    if (userId != null) {
      _sessions.remove(userId);
    }
    await _persistSessions();
  }

  Future<void> _persistSessions() async {
    try {
      await _secureWrite(
        _kSessions,
        jsonEncode(_sessions.values.map((s) => s.toJson()).toList()),
      );
    } catch (_) {
      // 会话缓存写入失败不影响主登录态
    }
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
