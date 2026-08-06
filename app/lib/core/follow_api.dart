import 'package:dio/dio.dart';

import 'api_client.dart';
import 'chat_api.dart';

/// 关注关系状态（含目标用户信息与粉丝/关注数）
class FollowStatus {
  const FollowStatus({
    required this.following,
    required this.followedMe,
    required this.mutual,
    required this.followerCount,
    required this.followingCount,
    this.nickname = '',
    this.avatar = '',
  });

  /// 我是否关注了对方
  final bool following;

  /// 对方是否关注了我
  final bool followedMe;

  /// 是否互相关注
  final bool mutual;
  final int followerCount;
  final int followingCount;
  final String nickname;
  final String avatar;

  factory FollowStatus.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] ?? const {}) as Map<String, dynamic>;
    return FollowStatus(
      following: (json['following'] ?? false) as bool,
      followedMe: (json['followedMe'] ?? false) as bool,
      mutual: (json['mutual'] ?? false) as bool,
      followerCount: ((json['followerCount'] ?? 0) as num).toInt(),
      followingCount: ((json['followingCount'] ?? 0) as num).toInt(),
      nickname: (user['nickname'] ?? '') as String,
      avatar: (user['avatar'] ?? '') as String,
    );
  }
}

/// 关注 REST API
class FollowApi {
  FollowApi._();

  /// 我关注的人（发起群聊选人用）
  static Future<List<FollowUser>> fetchFollowing() async {
    final resp = await ApiClient.instance.get('/follows/following');
    return (resp.data as List)
        .map((e) => FollowUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 查询与目标用户的关注关系
  static Future<FollowStatus> status(int targetId) async {
    final resp = await ApiClient.instance.get('/follows/$targetId');
    return FollowStatus.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 关注/取消关注，返回最新状态
  static Future<FollowStatus> setFollow(
    int targetId, {
    required bool following,
  }) async {
    final resp = await ApiClient.instance.put(
      '/follows/$targetId',
      data: {'following': following},
    );
    return FollowStatus.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 某用户的粉丝列表（分页）
  static Future<FollowPage> fetchFollowers(
    int targetId, {
    int page = 1,
    int limit = 20,
  }) =>
      _fetchList(targetId, 'followers', page: page, limit: limit);

  /// 某用户的关注列表（分页）
  static Future<FollowPage> fetchUserFollowing(
    int targetId, {
    int page = 1,
    int limit = 20,
  }) =>
      _fetchList(targetId, 'following', page: page, limit: limit);

  static Future<FollowPage> _fetchList(
    int targetId,
    String type, {
    required int page,
    required int limit,
  }) async {
    final resp = await ApiClient.instance.get(
      '/follows/$targetId/$type',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = resp.data as List;
    return FollowPage(
      items: ((data.isNotEmpty ? data[0] : const []) as List)
          .map((e) => FollowListUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data.length > 1 ? (data[1] as num?)?.toInt() ?? 0 : 0,
    );
  }

  /// 头像绝对地址（兼容 /uploads/ 相对路径）
  static String resolveAvatar(String avatar) =>
      avatar.isEmpty ? '' : ChatApi.resolveUrl(avatar);

  /// 提取后端错误信息
  static String messageOf(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join('，') : m.toString();
    }
    return '网络异常，请稍后再试';
  }
}

/// 我关注的人（简版用户信息）
class FollowUser {
  const FollowUser({
    required this.id,
    required this.nickname,
    required this.avatar,
  });

  final int id;
  final String nickname;
  final String avatar;

  String get resolvedAvatar =>
      avatar.isEmpty ? '' : ChatApi.resolveUrl(avatar);

  factory FollowUser.fromJson(Map<String, dynamic> json) => FollowUser(
        id: (json['id'] as num).toInt(),
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
      );
}

/// 关注/粉丝列表分页结果（后端返回 [items, total] 元组）
class FollowPage {
  const FollowPage({required this.items, required this.total});

  final List<FollowListUser> items;
  final int total;
}

/// 关注/粉丝列表条目：用户信息 + 与我的关系
class FollowListUser {
  const FollowListUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.following,
    required this.followedMe,
    required this.mutual,
  });

  final int id;
  final String nickname;
  final String avatar;

  /// 我是否关注了对方
  final bool following;

  /// 对方是否关注了我
  final bool followedMe;

  /// 是否互相关注
  final bool mutual;

  String get resolvedAvatar =>
      avatar.isEmpty ? '' : ChatApi.resolveUrl(avatar);

  factory FollowListUser.fromJson(Map<String, dynamic> json) => FollowListUser(
        id: (json['id'] as num).toInt(),
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
        following: (json['following'] ?? false) as bool,
        followedMe: (json['followedMe'] ?? false) as bool,
        mutual: (json['mutual'] ?? false) as bool,
      );
}
