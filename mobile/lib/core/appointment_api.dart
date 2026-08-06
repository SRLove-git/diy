import 'package:dio/dio.dart';

import 'api_client.dart';
import '../features/member/domain/member_models.dart';

/// 附近可约门店（预约单价/会员价用于确认页计价）
class Store {
  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.businessHours,
    required this.images,
    this.price = 39.9,
    this.memberPrice,
  });

  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double rating;
  final String businessHours;
  final List<String> images;

  /// 门市价（元/人/次）
  final double price;

  /// 会员价（0 = 会员免费，null = 无会员价）
  final double? memberPrice;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String,
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 5,
        businessHours: (json['businessHours'] ?? '') as String,
        images: ((json['images'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
        price: (json['price'] as num?)?.toDouble() ?? 39.9,
        memberPrice: (json['memberPrice'] as num?)?.toDouble(),
      );
}

/// 可预约活动
class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.date,
    required this.desc,
    required this.tag,
    required this.address,
    required this.price,
    required this.bookable,
    this.lat,
    this.lng,
    this.memberPrice,
  });

  final int id;
  final String title;

  /// 展示时间文案，如 `08-16 14:00`
  final String date;
  final String desc;
  final String tag;
  final String address;
  final double price;
  final double? memberPrice;
  final bool bookable;
  final double? lat;
  final double? lng;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        date: (json['date'] ?? '') as String,
        desc: (json['desc'] ?? '') as String,
        tag: (json['tag'] ?? '') as String,
        address: (json['address'] ?? '') as String,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        memberPrice: (json['memberPrice'] as num?)?.toDouble(),
        bookable: json['bookable'] == true,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

/// 活动场次（含剩余名额）
class ActivitySession {
  const ActivitySession({
    required this.id,
    required this.activityId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.remaining,
  });

  final int id;
  final int activityId;
  final String date;
  final String startTime;
  final String endTime;
  final int capacity;
  final int remaining;

  String get label => '$date $startTime-$endTime';

  factory ActivitySession.fromJson(Map<String, dynamic> json) =>
      ActivitySession(
        id: json['id'] as int,
        activityId: (json['activityId'] as num?)?.toInt() ?? 0,
        date: (json['date'] ?? '') as String,
        startTime: (json['startTime'] ?? '') as String,
        endTime: (json['endTime'] ?? '') as String,
        capacity: (json['capacity'] as num?)?.toInt() ?? 1,
        remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      );
}

class StoreTable {
  const StoreTable({required this.id, required this.name, required this.capacity});

  final int id;
  final String name;
  final int capacity;

  factory StoreTable.fromJson(Map<String, dynamic> json) => StoreTable(
        id: json['id'] as int,
        name: json['name'] as String,
        capacity: json['capacity'] as int,
      );
}

class TimeSlot {
  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  final int id;
  final String startTime;
  final String endTime;

  String get label => '$startTime - $endTime';

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        id: json['id'] as int,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
      );
}

class TableAvailability {
  const TableAvailability({
    required this.id,
    required this.name,
    required this.capacity,
    required this.available,
  });

  final int id;
  final String name;
  final int capacity;
  final bool available;

  factory TableAvailability.fromJson(Map<String, dynamic> json) =>
      TableAvailability(
        id: json['id'] as int,
        name: json['name'] as String,
        capacity: json['capacity'] as int,
        available: json['available'] as bool,
      );
}

class Appointment {
  const Appointment({
    required this.id,
    required this.storeName,
    required this.tableName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.peopleCount,
    required this.code,
    required this.status,
    this.type = 'store',
    this.activityName = '',
    this.amount = 0,
    this.originalAmount = 0,
    this.couponDiscount = 0,
    this.payStatus = 'paid',
    this.payMethod = '',
    this.serviceStartTime,
  });

  final int id;
  final String storeName;
  final String tableName;
  final String date;
  final String startTime;
  final String endTime;
  final int peopleCount;
  final String code;
  final String status;

  /// 预约类型：store / activity
  final String type;
  final String activityName;

  /// 实付金额（会员折扣后）
  final double amount;

  /// 原价金额（会员折扣前）
  final double originalAmount;

  /// 优惠券抵扣金额
  final double couponDiscount;

  /// paid / unpaid
  final String payStatus;

  /// wechat / alipay
  final String payMethod;

  /// 上钟（开始服务）时间，in_service 状态下存在
  final String? serviceStartTime;

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as int,
        storeName: json['storeName'] as String,
        tableName: json['tableName'] as String,
        date: json['date'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        peopleCount: json['peopleCount'] as int,
        code: json['code'] as String,
        status: json['status'] as String,
        type: (json['type'] ?? 'store') as String,
        activityName: (json['activityName'] ?? '') as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        originalAmount: (json['originalAmount'] as num?)?.toDouble() ?? 0,
        couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0,
        payStatus: (json['payStatus'] ?? 'unpaid') as String,
        payMethod: (json['payMethod'] ?? '') as String,
        serviceStartTime: json['serviceStartTime'] as String?,
      );
}

/// 预约流程 API
class AppointmentApi {
  AppointmentApi._();

  /// 附近可约门店列表
  static Future<List<Store>> fetchStores() async {
    final resp = await ApiClient.instance.get('/stores');
    return (resp.data as List)
        .map((e) => Store.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 门店详情（含桌位与时段）
  static Future<({Store store, List<StoreTable> tables, List<TimeSlot> slots})>
      fetchStoreDetail(int storeId) async {
    final resp = await ApiClient.instance.get('/stores/$storeId');
    final json = resp.data as Map<String, dynamic>;
    return (
      store: Store.fromJson(json),
      tables: ((json['tables'] ?? []) as List)
          .map((e) => StoreTable.fromJson(e as Map<String, dynamic>))
          .toList(),
      slots: ((json['slots'] ?? []) as List)
          .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 查询某日某时段桌位可用性
  static Future<List<TableAvailability>> fetchAvailability(
    int storeId,
    String date,
    int slotId,
  ) async {
    final resp = await ApiClient.instance.get(
      '/appointments/availability',
      queryParameters: {'storeId': storeId, 'date': date, 'slotId': slotId},
    );
    return (resp.data as List)
        .map((e) => TableAvailability.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 生成预约单
  static Future<Appointment> create({
    String type = 'store',
    int? storeId,
    int? tableId,
    int? slotId,
    int? activityId,
    int? activitySessionId,
    String? date,
    required int peopleCount,
    required String payMethod,
    int? userCouponId,
  }) async {
    final resp = await ApiClient.instance.post(
      '/appointments',
      data: {
        'type': type,
        'storeId': ?storeId,
        'tableId': ?tableId,
        'slotId': ?slotId,
        'activityId': ?activityId,
        'activitySessionId': ?activitySessionId,
        'date': ?date,
        'peopleCount': peopleCount,
        'payMethod': payMethod,
        'userCouponId': ?userCouponId,
      },
    );
    return Appointment.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 卡包中未使用的优惠券（确认支付页选券用）
  static Future<List<MemberWalletCoupon>> fetchWalletCoupons() async {
    final resp = await ApiClient.instance.get('/members/wallet');
    return (resp.data as List)
        .map((e) => MemberWalletCoupon.fromJson(e as Map<String, dynamic>))
        .where((c) => c.status == 'unused')
        .toList();
  }

  /// 附近可约活动列表（bookable 的活动）
  static Future<List<Activity>> fetchActivities() async {
    final all = await fetchAllActivities();
    return all.where((a) => a.bookable).toList();
  }

  /// 全部上架活动（活动专区展示用）
  static Future<List<Activity>> fetchAllActivities() async {
    final resp = await ApiClient.instance.get('/activities');
    return (resp.data as List)
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 活动场次（含剩余名额）
  static Future<List<ActivitySession>> fetchActivitySessions(
    int activityId,
  ) async {
    final resp = await ApiClient.instance.get(
      '/appointments/activity-sessions',
      queryParameters: {'activityId': activityId},
    );
    return (resp.data as List)
        .map((e) => ActivitySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 当前用户是否为有效会员（用于预约计价）
  static Future<bool> fetchMemberActive() async {
    final resp = await ApiClient.instance.get('/members/me');
    return (resp.data as Map<String, dynamic>)['status'] == 'active';
  }

  /// 提取后端错误信息（与登录页一致的格式）
  static String messageOf(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join('，') : m.toString();
    }
    return '网络异常，请稍后再试';
  }
}
