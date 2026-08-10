import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'models.dart';

/// 认证 / 用户 / 门店 / 预约 / 活动 / 会员 / 曲库 / 关注 / 上传
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// 发送邮箱验证码（开发环境返回 code 便于联调）
  Future<String?> sendEmailCode(String email) async {
    final data = await ApiClient.instance.post('/auth/email-code', body: {'email': email});
    return data is Map && data['code'] != null ? data['code'].toString() : null;
  }

  /// 注册：用户名 + 密码 + 邮箱绑定（注册成功即自动登录）
  Future<({int userId, bool isNewUser, String accessToken, String refreshToken})> register({
    required String username,
    required String email,
    required String password,
    required String emailCode,
  }) async {
    final data = await ApiClient.instance.post('/auth/register', body: {
      'username': username,
      'email': email,
      'password': password,
      'emailCode': emailCode,
    }) as Map<String, dynamic>;
    return (
      userId: (data['userId'] as num).toInt(),
      isNewUser: data['isNewUser'] as bool? ?? true,
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  /// 用户名 / 邮箱 + 密码登录
  Future<({int userId, String accessToken, String refreshToken})> login(
    String account,
    String password,
  ) async {
    final data = await ApiClient.instance
        .post('/auth/login', body: {'account': account, 'password': password})
        as Map<String, dynamic>;
    return (
      userId: (data['userId'] as num).toInt(),
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  /// 忘记密码：邮箱验证码 + 新密码
  Future<void> resetPassword({
    required String email,
    required String emailCode,
    required String password,
  }) {
    return ApiClient.instance.post('/auth/reset-password', body: {
      'email': email,
      'emailCode': emailCode,
      'password': password,
    });
  }

  /// 修改登录密码（登录态下，需校验原密码）
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return ApiClient.instance.post('/auth/change-password', body: {
      if (oldPassword.isNotEmpty) 'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  Future<User> me() async {
    final data = await ApiClient.instance.get('/auth/me') as Map<String, dynamic>;
    return User.fromJson(data);
  }
}

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  Future<User> updateMe(Map<String, dynamic> body) async {
    final data = await ApiClient.instance.patch('/users/me', body: body) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<List<User>> searchByUsername(String username) async {
    final data =
        await ApiClient.instance.get('/users/search', query: {'username': username}) as List;
    return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class StoreService {
  StoreService._();
  static final StoreService instance = StoreService._();

  Future<List<Store>> list() async {
    final data = await ApiClient.instance.get('/stores') as List;
    return data.map((e) => Store.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Store> detail(int id) async {
    final data = await ApiClient.instance.get('/stores/$id') as Map<String, dynamic>;
    return Store.fromJson(data);
  }
}

class AppointmentService {
  AppointmentService._();
  static final AppointmentService instance = AppointmentService._();

  Future<Appointment> create(Map<String, dynamic> body) async {
    final data = await ApiClient.instance.post('/appointments', body: body) as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  Future<List<Appointment>> myList({int page = 1, int pageSize = 50}) async {
    final data = await ApiClient.instance
        .get('/appointments', query: {'page': page, 'pageSize': pageSize})
        as Map<String, dynamic>;
    return (data['items'] as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Appointment> detail(int id) async {
    final data = await ApiClient.instance.get('/appointments/$id') as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  Future<Appointment> cancel(int id) async {
    final data = await ApiClient.instance.post('/appointments/$id/cancel') as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  Future<Appointment> checkIn(String code) async {
    final data = await ApiClient.instance.post('/appointments/checkin', body: {'code': code})
        as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 下钟（结束服务）：返回完成后的预约（含下钟时间）。
  Future<Appointment> clockOut(int id) async {
    final data = await ApiClient.instance.post('/appointments/$id/clockout')
        as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  Future<Appointment> findByCode(String code) async {
    final data = await ApiClient.instance.get('/appointments/code/$code') as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 门店桌位可用性（storeId + date），返回每桌已占用时段窗口
  Future<List<TableAvailability>> availability({
    required int storeId,
    required String date,
  }) async {
    final data = await ApiClient.instance
        .get('/appointments/availability', query: {
          'storeId': storeId,
          'date': date,
        })
        as List;
    return data
        .map((e) => TableAvailability.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ActivitySession>> activitySessions(int activityId) async {
    final data = await ApiClient.instance
        .get('/appointments/activity-sessions', query: {'activityId': activityId}) as List;
    return data.map((e) => ActivitySession.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class ActivityService {
  ActivityService._();
  static final ActivityService instance = ActivityService._();

  Future<List<Activity>> list() async {
    final data = await ApiClient.instance.get('/activities') as List;
    return data.map((e) => Activity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Activity> detail(int id) async {
    final data = await ApiClient.instance.get('/activities/$id') as Map<String, dynamic>;
    return Activity.fromJson(data);
  }
}

class MemberService {
  MemberService._();
  static final MemberService instance = MemberService._();

  Future<Membership> myMembership() async {
    final data = await ApiClient.instance.get('/members/me') as Map<String, dynamic>;
    return Membership.fromJson(data);
  }

  Future<List<MemberPlan>> plans() async {
    final data = await ApiClient.instance.get('/members/plans') as List;
    return data.map((e) => MemberPlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MemberOrder> purchase(int planId) async {
    final data = await ApiClient.instance.post('/members/purchase', body: {'planId': planId})
        as Map<String, dynamic>;
    return MemberOrder.fromJson(data);
  }

  Future<List<MemberOrder>> memberOrders() async {
    final data = await ApiClient.instance.get('/members/orders') as List;
    return data
        .map((e) => MemberOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Coupon>> couponCenter() async {
    final data = await ApiClient.instance.get('/members/coupons') as List;
    return data.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Coupon> receive(int couponId) async {
    final data = await ApiClient.instance.post('/members/coupons/$couponId/receive')
        as Map<String, dynamic>;
    return Coupon.fromJson(data);
  }

  Future<List<Coupon>> wallet() async {
    final data = await ApiClient.instance.get('/members/wallet') as List;
    return data.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  Future<Page<Music>> list({String? keyword, int page = 1}) async {
    final raw = await ApiClient.instance.get('/musics', query: {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      'page': page,
    });
    return Page.parse<Music>(raw, Music.fromJson);
  }
}

class FollowService {
  FollowService._();
  static final FollowService instance = FollowService._();

  Future<List<FollowUser>> following() async {
    final data = await ApiClient.instance.get('/follows/following') as List;
    return data.map((e) => FollowUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FollowStatus> status(int targetId) async {
    final data = await ApiClient.instance.get('/follows/$targetId') as Map<String, dynamic>;
    return FollowStatus.fromJson(data);
  }

  Future<FollowStatus> setFollow(int targetId, bool following) async {
    final data = await ApiClient.instance.put('/follows/$targetId', body: {'following': following})
        as Map<String, dynamic>;
    return FollowStatus.fromJson(data);
  }

  Future<Page<FollowUser>> followers(int targetId, {int page = 1}) async {
    final raw = await ApiClient.instance
        .get('/follows/$targetId/followers', query: {'page': page});
    return Page.parse<FollowUser>(raw, FollowUser.fromJson);
  }

  Future<Page<FollowUser>> followingFor(int targetId, {int page = 1}) async {
    final raw = await ApiClient.instance
        .get('/follows/$targetId/following', query: {'page': page});
    return Page.parse<FollowUser>(raw, FollowUser.fromJson);
  }
}

class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  /// 上传图片，folder ∈ chat/avatar/post，返回相对 url。
  Future<String> uploadImage(List<int> bytes, String filename, {String folder = 'post'}) async {
    final data = await ApiClient.instance.upload(
      '/uploads/images',
      field: 'file',
      bytes: bytes,
      filename: filename,
      contentType: 'image/jpeg',
      query: {'folder': folder},
    );
    return (data as Map<String, dynamic>)['url'] as String;
  }

  /// 上传聊天语音，返回相对 url（服务端 /api/uploads/audio）。
  Future<String> uploadAudio(List<int> bytes, String filename, {String? contentType}) async {
    final data = await ApiClient.instance.upload(
      '/uploads/audio',
      field: 'file',
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );
    return (data as Map<String, dynamic>)['url'] as String;
  }
}

/// 首页订单刷新通知：预约成功 / 下钟结束后触发，
/// 首页自动重新拉取订单，无需手动刷新。
class HomeOrdersRefresh extends ChangeNotifier {
  HomeOrdersRefresh._();

  static final HomeOrdersRefresh instance = HomeOrdersRefresh._();

  Appointment? _pending;

  /// 最近一次变更的订单（乐观更新用，首页可立即展示）。
  Appointment? get pending => _pending;

  void refresh([Appointment? appointment]) {
    _pending = appointment;
    notifyListeners();
  }
}
