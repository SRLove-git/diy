import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'auth_store.dart';
import 'models.dart';

/// 认证 / 用户 / 门店 / 预约 / 活动 / 会员 / 曲库 / 关注 / 上传
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// 注册：用户名 + 密码 + 邮箱绑定（注册成功即自动登录）
  Future<
    ({int userId, bool isNewUser, String accessToken, String refreshToken})
  >
  register({
    required String username,
    required String email,
    required String password,
    String? deviceId,
    String? captchaId,
    String? captchaText,
  }) async {
    final data =
        await ApiClient.instance.post(
              '/auth/register',
              body: {
                'username': username,
                'email': email,
                'password': password,
                if (deviceId != null && deviceId.isNotEmpty)
                  'deviceId': deviceId,
                if (captchaId != null && captchaId.isNotEmpty)
                  'captchaId': captchaId,
                if (captchaText != null && captchaText.isNotEmpty)
                  'captchaText': captchaText,
              },
            )
            as Map<String, dynamic>;
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
    {
    String? captchaId,
    String? captchaText,
  }
  ) async {
    final data =
        await ApiClient.instance.post(
              '/auth/login',
              body: {
                'account': account,
                'password': password,
                if (captchaId != null && captchaId.isNotEmpty)
                  'captchaId': captchaId,
                if (captchaText != null && captchaText.isNotEmpty)
                  'captchaText': captchaText,
              },
            )
            as Map<String, dynamic>;
    return (
      userId: (data['userId'] as num).toInt(),
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  /// 获取图形验证码：返回 id 与 SVG 图片字节（data URI 解码）
  Future<({String id, Uint8List image})> captcha() async {
    final data =
        await ApiClient.instance.get('/captcha') as Map<String, dynamic>;
    return AuthService.captchaFromJson(data);
  }

  /// 纯函数：把服务端验证码响应解析为 id + SVG 字节，便于单元测试
  static ({String id, Uint8List image}) captchaFromJson(
    Map<String, dynamic> data,
  ) {
    final id = data['id'] as String;
    final image = data['imageBase64'] as String? ?? '';
    if (image.isEmpty) {
      throw Exception('captcha image missing');
    }
    return (id: id, image: base64Decode(image));
  }

  /// 修改登录密码（登录态下，需校验原密码）
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return ApiClient.instance.post(
      '/auth/change-password',
      body: {
        if (oldPassword.isNotEmpty) 'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<User> me() async {
    final data =
        await ApiClient.instance.get('/auth/me') as Map<String, dynamic>;
    return User.fromJson(data);
  }
}

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  Future<User> updateMe(Map<String, dynamic> body) async {
    final data =
        await ApiClient.instance.patch('/users/me', body: body)
            as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<List<User>> searchByUsername(String username) async {
    final data =
        await ApiClient.instance.get(
              '/users/search',
              query: {'username': username},
            )
            as List;
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
    final data =
        await ApiClient.instance.get('/stores/$id') as Map<String, dynamic>;
    return Store.fromJson(data);
  }
}

class AppointmentService {
  AppointmentService._();
  static final AppointmentService instance = AppointmentService._();

  Future<Appointment> create(Map<String, dynamic> body) async {
    final data =
        await ApiClient.instance.post('/appointments', body: body)
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  Future<List<Appointment>> myList({int page = 1, int pageSize = 50}) async {
    final data =
        await ApiClient.instance.get(
              '/appointments',
              query: {'page': page, 'pageSize': pageSize},
            )
            as Map<String, dynamic>;
    return (data['items'] as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Appointment> detail(int id) async {
    final data =
        await ApiClient.instance.get('/appointments/$id')
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 取消预约（幂等）：网络类失败（响应超时/连接中断）自动重试最多 2 次。
  /// 服务端取消已幂等——重复取消直接返回成功，重试不会报「仅可取消…」，
  /// 避免「服务端已取消但响应超时 → 客户端放弃 → 残留 booked 单」的连锁问题。
  Future<Appointment> cancel(int id, {int retries = 2}) async {
    try {
      final data =
          await ApiClient.instance.post('/appointments/$id/cancel')
              as Map<String, dynamic>;
      return Appointment.fromJson(data);
    } on ApiException catch (e) {
      // statusCode == null：请求未收到 HTTP 响应（超时/断网），
      // 服务端可能已处理成功，重试安全且能拿到最终状态
      if (retries > 0 && e.statusCode == null) {
        return cancel(id, retries: retries - 1);
      }
      rethrow;
    }
  }

  Future<Appointment> checkIn(String code) async {
    final data =
        await ApiClient.instance.post(
              '/appointments/checkin',
              body: {'code': code},
            )
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 下钟（结束服务）：返回完成后的预约（含下钟时间）。
  Future<Appointment> clockOut(int id) async {
    final data =
        await ApiClient.instance.post('/appointments/$id/clockout')
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  Future<Appointment> findByCode(String code) async {
    final data =
        await ApiClient.instance.get('/appointments/code/$code')
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 门店桌位可用性（storeId + date），返回每桌已占用时段窗口
  Future<List<TableAvailability>> availability({
    required int storeId,
    required String date,
  }) async {
    final data =
        await ApiClient.instance.get(
              '/appointments/availability',
              query: {'storeId': storeId, 'date': date},
            )
            as List;
    return data
        .map((e) => TableAvailability.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ActivitySession>> activitySessions(int activityId) async {
    final data =
        await ApiClient.instance.get(
              '/appointments/activity-sessions',
              query: {'activityId': activityId},
            )
            as List;
    return data
        .map((e) => ActivitySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class ActivityService {
  ActivityService._();
  static final ActivityService instance = ActivityService._();

  Future<List<Activity>> list() async {
    final data = await ApiClient.instance.get('/activities') as List;
    return data
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Activity> detail(int id) async {
    final data =
        await ApiClient.instance.get('/activities/$id') as Map<String, dynamic>;
    return Activity.fromJson(data);
  }
}

class MemberService {
  MemberService._();
  static final MemberService instance = MemberService._();

  Future<Membership> myMembership() async {
    final data =
        await ApiClient.instance.get('/members/me') as Map<String, dynamic>;
    return Membership.fromJson(data);
  }

  Future<List<MemberPlan>> plans() async {
    final data = await ApiClient.instance.get('/members/plans') as List;
    return data
        .map((e) => MemberPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MemberOrder> purchase(int planId) async {
    final data =
        await ApiClient.instance.post(
              '/members/purchase',
              body: {'planId': planId},
            )
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
    final data =
        await ApiClient.instance.post('/members/coupons/$couponId/receive')
            as Map<String, dynamic>;
    return Coupon.fromJson(data);
  }

  Future<List<Coupon>> wallet() async {
    final data = await ApiClient.instance.get('/members/wallet') as List;
    return data.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }
}

/// 管理端：预约订单 / 扫码核销（需 admin 角色，服务端权限守卫兜底）。
class AdminAppointmentService {
  AdminAppointmentService._();
  static final AdminAppointmentService instance = AdminAppointmentService._();

  /// 所有预约列表（分页，可按状态 / 关键字 / 预约码筛选）。
  Future<({List<Appointment> items, int total})> list({
    String? status,
    String? keyword,
    String? code,
    int? storeId,
    String? date,
    int page = 1,
    int limit = 20,
  }) async {
    final data =
        await ApiClient.instance.get(
              '/admin/appointments',
              query: {
                if (status != null && status.isNotEmpty) 'status': status,
                if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
                if (code != null && code.isNotEmpty) 'code': code,
                'storeId': ?storeId,
                if (date != null && date.isNotEmpty) 'date': date,
                'page': page,
                'limit': limit,
              },
            )
            as List;
    final items = (data[0] as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: (data[1] as num?)?.toInt() ?? items.length);
  }

  /// 按预约码查询（核销前确认）。
  Future<Appointment> findByCode(String code) async {
    final data =
        await ApiClient.instance.get(
              '/appointments/code/${Uri.encodeComponent(code)}',
            )
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 输码核销（店员代操作）：核销即上钟。
  Future<Appointment> checkInByCode(String code) async {
    final data =
        await ApiClient.instance.post(
              '/admin/appointments/checkin-code',
              body: {'code': code},
            )
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 管理端按 ID 核销（核销即上钟）。
  Future<Appointment> checkIn(int id) async {
    final data =
        await ApiClient.instance.post('/admin/appointments/$id/checkin')
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 管理端上钟（已核销 → 服务中）。
  Future<Appointment> clockIn(int id) async {
    final data =
        await ApiClient.instance.post('/admin/appointments/$id/clockin')
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 管理端确认预约（待确认 → 待核销）。
  Future<Appointment> confirm(int id) async {
    final data =
        await ApiClient.instance.post('/admin/appointments/$id/confirm')
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 管理端取消预约（店员代操作）。
  Future<Appointment> cancel(int id) async {
    final data =
        await ApiClient.instance.post('/admin/appointments/$id/cancel')
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// 管理端下钟（服务中 → 已完成）。
  Future<Appointment> clockOut(int id) async {
    final data =
        await ApiClient.instance.post('/admin/appointments/$id/clockout')
            as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }
}

/// 管理端：会员运营（会员列表 / 套餐 / 优惠券 / 会员订单 / 券码核销）。
class AdminMemberService {
  AdminMemberService._();
  static final AdminMemberService instance = AdminMemberService._();

  /// 会员列表（分页，可按用户ID / 用户名 / 昵称 / 会员编号搜索）。
  Future<({List<AdminMembership> items, int total})> memberships({
    String? keyword,
    int page = 1,
  }) async {
    final data =
        await ApiClient.instance.get(
              '/admin/members',
              query: {
                if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
                'page': page,
              },
            )
            as List;
    final items = (data[0] as List)
        .map((e) => AdminMembership.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: (data[1] as num?)?.toInt() ?? items.length);
  }

  /// 会员开通申请列表（分页，可按用户关键字 / 状态筛选）。
  Future<({List<MemberOrder> items, int total})> orders({
    String? keyword,
    String? status,
    int page = 1,
  }) async {
    final data =
        await ApiClient.instance.get(
              '/admin/members/orders',
              query: {
                if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
                if (status != null && status.isNotEmpty) 'status': status,
                'page': page,
              },
            )
            as List;
    final items = (data[0] as List)
        .map((e) => MemberOrder.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: (data[1] as num?)?.toInt() ?? items.length);
  }

  /// 全部套餐（含已下架）。
  Future<List<MemberPlan>> plans() async {
    final data = await ApiClient.instance.get('/admin/members/plans') as List;
    return data
        .map((e) => MemberPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 全部优惠券。
  Future<List<Coupon>> coupons() async {
    final data = await ApiClient.instance.get('/admin/members/coupons') as List;
    return data.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 按券核销码查询（核销前确认）。
  Future<Coupon> findCouponByCode(String code) async {
    final data =
        await ApiClient.instance.get(
              '/members/coupons/code/${Uri.encodeComponent(code)}',
            )
            as Map<String, dynamic>;
    return Coupon.fromJson(data);
  }

  /// 输码核销优惠券（店员代操作）。
  Future<Coupon> redeemCouponByCode(String code) async {
    final data =
        await ApiClient.instance.post(
              '/admin/members/coupons/redeem-code',
              body: {'code': code},
            )
            as Map<String, dynamic>;
    return Coupon.fromJson(data);
  }

  /// 确认会员开通申请（到店收款后开通 / 顺延）。
  Future<void> confirmOrder(int id) {
    return ApiClient.instance.post('/admin/members/orders/$id/confirm');
  }

  /// 取消会员开通申请。
  Future<void> cancelOrder(int id) {
    return ApiClient.instance.post('/admin/members/orders/$id/cancel');
  }

  /// 上架 / 下架套餐。
  Future<void> togglePlan(int id, bool enabled) {
    return ApiClient.instance.patch(
      '/admin/members/plans/$id/enabled',
      body: {'enabled': enabled},
    );
  }

  /// 启用 / 停用优惠券。
  Future<void> toggleCoupon(int id, bool enabled) {
    return ApiClient.instance.patch(
      '/admin/members/coupons/$id/enabled',
      body: {'enabled': enabled},
    );
  }

  /// 后台开通会员（按用户 ID 直接开通）。
  Future<void> createMembership({
    required int userId,
    String? levelName,
    required DateTime expireAt,
  }) {
    return ApiClient.instance.post(
      '/admin/members',
      body: {
        'userId': userId,
        if (levelName != null && levelName.isNotEmpty) 'levelName': levelName,
        'expireAt': expireAt.toIso8601String(),
      },
    );
  }

  /// 后台编辑会员（等级 / 有效期）。
  Future<void> updateMembership(
    int id, {
    String? levelName,
    required DateTime expireAt,
  }) {
    return ApiClient.instance.patch(
      '/admin/members/$id',
      body: {
        if (levelName != null && levelName.isNotEmpty) 'levelName': levelName,
        'expireAt': expireAt.toIso8601String(),
      },
    );
  }

  /// 删除会员记录（会员资格立即失效）。
  Future<void> deleteMembership(int id) {
    return ApiClient.instance.delete('/admin/members/$id');
  }

  /// 新增套餐。
  Future<void> createPlan(Map<String, dynamic> body) {
    return ApiClient.instance.post('/admin/members/plans', body: body);
  }

  /// 编辑套餐。
  Future<void> updatePlan(int id, Map<String, dynamic> body) {
    return ApiClient.instance.patch('/admin/members/plans/$id', body: body);
  }

  /// 新增优惠券。
  Future<void> createCoupon(Map<String, dynamic> body) {
    return ApiClient.instance.post('/admin/members/coupons', body: body);
  }

  /// 编辑优惠券。
  Future<void> updateCoupon(int id, Map<String, dynamic> body) {
    return ApiClient.instance.patch('/admin/members/coupons/$id', body: body);
  }
}

class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  Future<Page<Music>> list({String? keyword, int page = 1}) async {
    final raw = await ApiClient.instance.get(
      '/musics',
      query: {
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'page': page,
      },
    );
    return Page.parse<Music>(raw, Music.fromJson);
  }
}

class FollowService {
  FollowService._();
  static final FollowService instance = FollowService._();

  Future<List<FollowUser>> following() async {
    final data = await ApiClient.instance.get('/follows/following') as List;
    return data
        .map((e) => FollowUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FollowStatus> status(int targetId) async {
    final data =
        await ApiClient.instance.get('/follows/$targetId')
            as Map<String, dynamic>;
    return FollowStatus.fromJson(data);
  }

  Future<FollowStatus> setFollow(int targetId, bool following) async {
    final data =
        await ApiClient.instance.put(
              '/follows/$targetId',
              body: {'following': following},
            )
            as Map<String, dynamic>;
    return FollowStatus.fromJson(data);
  }

  Future<Page<FollowUser>> followers(int targetId, {int page = 1}) async {
    final raw = await ApiClient.instance.get(
      '/follows/$targetId/followers',
      query: {'page': page},
    );
    return Page.parse<FollowUser>(raw, FollowUser.fromJson);
  }

  Future<Page<FollowUser>> followingFor(int targetId, {int page = 1}) async {
    final raw = await ApiClient.instance.get(
      '/follows/$targetId/following',
      query: {'page': page},
    );
    return Page.parse<FollowUser>(raw, FollowUser.fromJson);
  }
}

class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  /// 上传图片，folder ∈ chat/avatar/post，返回相对 url。
  Future<String> uploadImage(
    List<int> bytes,
    String filename, {
    String folder = 'post',
  }) async {
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
  Future<String> uploadAudio(
    List<int> bytes,
    String filename, {
    String? contentType,
  }) async {
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
    // 仅接受当前账号自己的订单：管理员代顾客核销/上钟时，服务端会把变更
    // 实时推送给顾客本人（WebSocket），管理员端不应把顾客订单合入本地
    // 乐观状态，否则管理员首页会错误展示其他用户的「服务中」订单。
    final uid = AuthStore.instance.userId;
    if (appointment != null && uid != null && appointment.userId != uid) {
      return;
    }
    _pending = appointment;
    notifyListeners();
  }
}
