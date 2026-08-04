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

  /// 头像绝对地址（兼容 /uploads/ 相对路径）
  static String resolveAvatar(String avatar) =>
      avatar.isEmpty ? '' : ChatApi.resolveUrl(avatar);
}
