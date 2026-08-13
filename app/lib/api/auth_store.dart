import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// 本地记住的一个已登录账号（用于「切换账号」时免密快速切回）。
class SavedAccount {
  const SavedAccount({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    this.displayName,
    this.avatar,
    this.role,
  });

  final int userId;
  final String accessToken;
  final String refreshToken;

  /// 账号昵称（未拉取到时为 null，界面回退为「用户 #id」）。
  final String? displayName;
  final String? avatar;

  /// 账号角色（admin / user；未拉取到角色信息时为 null）。
  final String? role;

  String get label => displayName != null && displayName!.isNotEmpty
      ? displayName!
      : '用户 #$userId';

  SavedAccount copyWith({
    String? displayName,
    String? avatar,
    String? role,
  }) => SavedAccount(
    userId: userId,
    accessToken: accessToken,
    refreshToken: refreshToken,
    displayName: displayName ?? this.displayName,
    avatar: avatar ?? this.avatar,
    role: role ?? this.role,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    if (displayName != null) 'displayName': displayName,
    if (avatar != null) 'avatar': avatar,
    if (role != null) 'role': role,
  };

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
    userId: (json['userId'] as num).toInt(),
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    displayName: json['displayName'] as String?,
    avatar: json['avatar'] as String?,
    role: json['role'] as String?,
  );
}

/// 登录态（JWT）的内存 + 本地持久化存储。
///
/// 除当前账号外，额外保留最近登录过的账号列表（最多 [maxSavedAccounts] 个），
/// 支撑「切换账号」：切换不销毁旧账号的登录态，可直接免密切回；
/// 仅「退出登录」会把当前账号从列表移除。
class AuthStore extends ChangeNotifier {
  AuthStore._();

  static AuthStore? _instance;
  static AuthStore get instance => _instance ??= AuthStore._();

  /// 本地最多保留的账号数（超出后淘汰最早登录的账号）。
  static const int maxSavedAccounts = 5;

  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kUserId = 'auth_user_id';
  static const _kAccounts = 'auth_accounts';

  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  List<SavedAccount> _accounts = [];
  bool _loaded = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;
  bool get loaded => _loaded;

  /// 记住的账号列表（含当前账号，最近的在前）。
  List<SavedAccount> get accounts => List.unmodifiable(_accounts);

  /// 当前账号对应的记住条目（未登录时为 null）。
  SavedAccount? get currentAccount {
    final id = _userId;
    if (id == null) return null;
    for (final a in _accounts) {
      if (a.userId == id) return a;
    }
    return null;
  }

  /// 当前账号角色（未拉取到角色时为 null）。
  String? get currentRole => currentAccount?.role;

  /// 当前账号是否为管理员（管理端角色）。
  bool get isAdmin => currentRole == 'admin';

  SavedAccount? accountOf(int userId) {
    for (final a in _accounts) {
      if (a.userId == userId) return a;
    }
    return null;
  }

  /// App 启动时从本地恢复登录态。
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_kAccess);
    _refreshToken = prefs.getString(_kRefresh);
    _userId = prefs.getInt(_kUserId);
    _accounts = _decodeAccounts(prefs.getString(_kAccounts));
    _loaded = true;
    notifyListeners();
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required int userId,
    String? displayName,
    String? avatar,
    String? role,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _loaded = true;

    // 当前账号加入记住列表（去重后置顶，超出上限淘汰最早账号）。
    final existing = accountOf(userId);
    _accounts.removeWhere((a) => a.userId == userId);
    _accounts.insert(
      0,
      SavedAccount(
        userId: userId,
        accessToken: accessToken,
        refreshToken: refreshToken,
        displayName: displayName ?? existing?.displayName,
        avatar: avatar ?? existing?.avatar,
        role: role ?? existing?.role,
      ),
    );
    if (_accounts.length > maxSavedAccounts) {
      _accounts.removeRange(maxSavedAccounts, _accounts.length);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, accessToken);
    await prefs.setString(_kRefresh, refreshToken);
    await prefs.setInt(_kUserId, userId);
    await _persistAccounts(prefs);
    notifyListeners();
  }

  /// 切到本地记住的另一账号：恢复其登录态，不销毁任何账号。
  /// 目标账号不存在时抛 [StateError]。
  Future<void> switchTo(int userId) async {
    final target = accountOf(userId);
    if (target == null) {
      throw StateError('没有记住的账号 #$userId，无法切换');
    }
    _accessToken = target.accessToken;
    _refreshToken = target.refreshToken;
    _userId = userId;
    _accounts.removeWhere((a) => a.userId == userId);
    _accounts.insert(0, target);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, target.accessToken);
    await prefs.setString(_kRefresh, target.refreshToken);
    await prefs.setInt(_kUserId, userId);
    await _persistAccounts(prefs);
    notifyListeners();
  }

  /// 刷新账号的展示信息（昵称/头像），不影响登录态。
  Future<void> updateAccountInfo({
    required int userId,
    String? displayName,
    String? avatar,
    String? role,
  }) async {
    final index = _accounts.indexWhere((a) => a.userId == userId);
    if (index < 0) return;
    _accounts[index] = _accounts[index].copyWith(
      displayName: displayName,
      avatar: avatar,
      role: role,
    );
    final prefs = await SharedPreferences.getInstance();
    await _persistAccounts(prefs);
    notifyListeners();
  }

  /// 用 /auth/me 返回的用户信息刷新本地账号（昵称/头像/角色）。
  Future<void> applyMe(User user) {
    return updateAccountInfo(
      userId: user.id,
      displayName: user.nickname.isNotEmpty
          ? user.nickname
          : (user.username?.isNotEmpty == true ? user.username : null),
      avatar: user.avatar.isEmpty ? null : user.avatar,
      role: user.role,
    );
  }

  /// 仅清空当前登录态（会话过期/切换账号时保留记住列表）。
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    await prefs.remove(_kUserId);
    await _persistAccounts(prefs);
    notifyListeners();
  }

  /// 退出登录：清空当前登录态，并把当前账号从记住列表移除。
  Future<void> logout() async {
    final currentId = _userId;
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    if (currentId != null) {
      _accounts.removeWhere((a) => a.userId == currentId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    await prefs.remove(_kUserId);
    await _persistAccounts(prefs);
    notifyListeners();
  }

  static List<SavedAccount> _decodeAccounts(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((e) => SavedAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _persistAccounts(SharedPreferences prefs) {
    return prefs.setString(
      _kAccounts,
      jsonEncode(_accounts.map((a) => a.toJson()).toList(growable: false)),
    );
  }
}
