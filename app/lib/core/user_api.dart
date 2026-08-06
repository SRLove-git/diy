import 'api_client.dart';
import 'chat_api.dart';

/// 搜索结果用户
class SearchedUser {
  const SearchedUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.phoneMasked,
  });

  final int id;
  final String nickname;
  final String avatar;
  final String phoneMasked;

  String get resolvedAvatar =>
      avatar.isEmpty ? '' : ChatApi.resolveUrl(avatar);

  factory SearchedUser.fromJson(Map<String, dynamic> json) => SearchedUser(
        id: (json['id'] as num).toInt(),
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
        phoneMasked: (json['phoneMasked'] ?? '') as String,
      );
}

/// 用户 API
class UserApi {
  UserApi._();

  /// 按手机号搜索用户（添加好友）
  static Future<List<SearchedUser>> searchByPhone(String phone) async {
    final resp = await ApiClient.instance.get(
      '/users/search',
      queryParameters: {'phone': phone},
    );
    return (resp.data as List)
        .map((e) => SearchedUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
