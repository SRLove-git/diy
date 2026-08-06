import 'package:dio/dio.dart';

import 'api_client.dart';

// ─── 数据看板 ───

class DashboardOverview {
  const DashboardOverview({
    required this.users,
    required this.appointments,
    required this.community,
    required this.videos,
    required this.pending,
  });

  final ({int total, int today}) users;
  final ({
    int total,
    int today,
    int checkedIn,
    int inService,
    int completed,
  }) appointments;
  final ({
    int totalPosts,
    int todayPosts,
    int todayLikes,
    int todayComments,
  }) community;
  final ({int total, int today}) videos;
  final ({int posts, int videos}) pending;

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    final u = json['users'] as Map<String, dynamic>? ?? const {};
    final a = json['appointments'] as Map<String, dynamic>? ?? const {};
    final c = json['community'] as Map<String, dynamic>? ?? const {};
    final v = json['videos'] as Map<String, dynamic>? ?? const {};
    final p = json['pending'] as Map<String, dynamic>? ?? const {};
    return DashboardOverview(
      users: (
        total: (u['total'] as num?)?.toInt() ?? 0,
        today: (u['today'] as num?)?.toInt() ?? 0,
      ),
      appointments: (
        total: (a['total'] as num?)?.toInt() ?? 0,
        today: (a['today'] as num?)?.toInt() ?? 0,
        checkedIn: (a['checkedIn'] as num?)?.toInt() ?? 0,
        inService: (a['inService'] as num?)?.toInt() ?? 0,
        completed: (a['completed'] as num?)?.toInt() ?? 0,
      ),
      community: (
        totalPosts: (c['totalPosts'] as num?)?.toInt() ?? 0,
        todayPosts: (c['todayPosts'] as num?)?.toInt() ?? 0,
        todayLikes: (c['todayLikes'] as num?)?.toInt() ?? 0,
        todayComments: (c['todayComments'] as num?)?.toInt() ?? 0,
      ),
      videos: (
        total: (v['total'] as num?)?.toInt() ?? 0,
        today: (v['today'] as num?)?.toInt() ?? 0,
      ),
      pending: (
        posts: (p['posts'] as num?)?.toInt() ?? 0,
        videos: (p['videos'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

class TrendItem {
  const TrendItem({
    required this.date,
    required this.users,
    required this.appointments,
    required this.posts,
    required this.likes,
    required this.comments,
    required this.videos,
  });

  final String date;
  final int users;
  final int appointments;
  final int posts;
  final int likes;
  final int comments;
  final int videos;

  factory TrendItem.fromJson(Map<String, dynamic> json) => TrendItem(
        date: (json['date'] ?? '') as String,
        users: (json['users'] as num?)?.toInt() ?? 0,
        appointments: (json['appointments'] as num?)?.toInt() ?? 0,
        posts: (json['posts'] as num?)?.toInt() ?? 0,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        comments: (json['comments'] as num?)?.toInt() ?? 0,
        videos: (json['videos'] as num?)?.toInt() ?? 0,
      );
}

// ─── 门店 / 桌位 / 时段 ───

class AdminStoreTable {
  const AdminStoreTable({
    required this.id,
    required this.name,
    required this.capacity,
    required this.enabled,
  });

  final int id;
  final String name;
  final int capacity;
  final bool enabled;

  factory AdminStoreTable.fromJson(Map<String, dynamic> json) =>
      AdminStoreTable(
        id: json['id'] as int,
        name: (json['name'] ?? '') as String,
        capacity: (json['capacity'] as num?)?.toInt() ?? 1,
        enabled: (json['enabled'] ?? true) as bool,
      );
}

class AdminTimeSlot {
  const AdminTimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.enabled,
  });

  final int id;
  final String startTime;
  final String endTime;
  final bool enabled;

  factory AdminTimeSlot.fromJson(Map<String, dynamic> json) => AdminTimeSlot(
        id: json['id'] as int,
        startTime: (json['startTime'] ?? '') as String,
        endTime: (json['endTime'] ?? '') as String,
        enabled: (json['enabled'] ?? true) as bool,
      );
}

class AdminStore {
  const AdminStore({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.businessHours,
    required this.phone,
    required this.price,
    required this.memberPrice,
    required this.enabled,
    required this.tables,
    required this.slots,
    this.lat,
    this.lng,
  });

  final int id;
  final String name;
  final String address;
  final double? lat;
  final double? lng;
  final double rating;
  final String businessHours;
  final String phone;
  final double price;
  final double? memberPrice;
  final bool enabled;
  final List<AdminStoreTable> tables;
  final List<AdminTimeSlot> slots;

  factory AdminStore.fromJson(Map<String, dynamic> json) => AdminStore(
        id: json['id'] as int,
        name: (json['name'] ?? '') as String,
        address: (json['address'] ?? '') as String,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toDouble() ?? 5,
        businessHours: (json['businessHours'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
        price: (json['price'] as num?)?.toDouble() ?? 39.9,
        memberPrice: (json['memberPrice'] as num?)?.toDouble(),
        enabled: (json['enabled'] ?? true) as bool,
        tables: ((json['tables'] ?? []) as List)
            .map((e) => AdminStoreTable.fromJson(e as Map<String, dynamic>))
            .toList(),
        slots: ((json['slots'] ?? []) as List)
            .map((e) => AdminTimeSlot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ─── 订单 ───

class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.userNickname,
    required this.userPhone,
    required this.storeName,
    required this.tableName,
    required this.type,
    required this.activityName,
    required this.amount,
    required this.couponDiscount,
    required this.couponTitle,
    required this.payStatus,
    required this.payMethod,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.peopleCount,
    required this.code,
    required this.status,
    required this.checkInTime,
    required this.serviceStartTime,
    required this.serviceEndTime,
  });

  final int id;
  final String userNickname;
  final String? userPhone;
  final String storeName;
  final String tableName;
  final String type;
  final String activityName;
  final double amount;
  final double couponDiscount;
  final String couponTitle;
  final String payStatus;
  final String payMethod;
  final String date;
  final String startTime;
  final String endTime;
  final int peopleCount;
  final String code;
  final String status;
  final String? checkInTime;
  final String? serviceStartTime;
  final String? serviceEndTime;

  factory AdminOrder.fromJson(Map<String, dynamic> json) => AdminOrder(
        id: json['id'] as int,
        userNickname: (json['userNickname'] ?? '') as String,
        userPhone: json['userPhone'] as String?,
        storeName: (json['storeName'] ?? '') as String,
        tableName: (json['tableName'] ?? '') as String,
        type: (json['type'] ?? 'store') as String,
        activityName: (json['activityName'] ?? '') as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0,
        couponTitle: (json['couponTitle'] ?? '') as String,
        payStatus: (json['payStatus'] ?? 'unpaid') as String,
        payMethod: (json['payMethod'] ?? '') as String,
        date: (json['date'] ?? '') as String,
        startTime: (json['startTime'] ?? '') as String,
        endTime: (json['endTime'] ?? '') as String,
        peopleCount: (json['peopleCount'] as num?)?.toInt() ?? 1,
        code: (json['code'] ?? '') as String,
        status: (json['status'] ?? '') as String,
        checkInTime: json['checkInTime'] as String?,
        serviceStartTime: json['serviceStartTime'] as String?,
        serviceEndTime: json['serviceEndTime'] as String?,
      );
}

// ─── 作品 ───

class AdminPost {
  const AdminPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
    required this.tags,
    required this.status,
    required this.rejectReason,
    required this.likeCount,
    required this.collectCount,
    required this.commentCount,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String content;
  final List<String> images;
  final List<String> tags;
  final String status;
  final String rejectReason;
  final int likeCount;
  final int collectCount;
  final int commentCount;
  final String createdAt;

  factory AdminPost.fromJson(Map<String, dynamic> json) => AdminPost(
        id: json['id'] as int,
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        content: (json['content'] ?? '') as String,
        images: ((json['images'] ?? []) as List).map((e) => e.toString()).toList(),
        tags: ((json['tags'] ?? []) as List).map((e) => e.toString()).toList(),
        status: (json['status'] ?? '') as String,
        rejectReason: (json['rejectReason'] ?? '') as String,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        collectCount: (json['collectCount'] as num?)?.toInt() ?? 0,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
        createdAt: (json['createdAt'] ?? '') as String,
      );
}

// ─── 用户 ───

class AdminUser {
  const AdminUser({
    required this.id,
    required this.phone,
    required this.nickname,
    required this.avatar,
    required this.isBanned,
    required this.role,
    required this.createdAt,
  });

  final int id;
  final String phone;
  final String nickname;
  final String avatar;
  final bool isBanned;
  final String role;
  final String createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as int,
        phone: (json['phone'] ?? '') as String,
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
        isBanned: (json['isBanned'] ?? false) as bool,
        role: (json['role'] ?? 'user') as String,
        createdAt: (json['createdAt'] ?? '') as String,
      );
}

// ─── 通知 ───

class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.targetType,
    required this.targetRole,
    required this.targetUserIds,
    required this.channels,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String content;
  final String targetType;
  final String? targetRole;
  final String targetUserIds;
  final String channels;
  final String createdAt;

  factory AdminNotification.fromJson(Map<String, dynamic> json) =>
      AdminNotification(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        content: (json['content'] ?? '') as String,
        targetType: (json['targetType'] ?? 'all') as String,
        targetRole: json['targetRole'] as String?,
        targetUserIds: (json['targetUserIds'] ?? '') as String,
        channels: (json['channels'] ?? 'push') as String,
        createdAt: (json['createdAt'] ?? '') as String,
      );
}

class AdminNotificationTemplate {
  const AdminNotificationTemplate({
    required this.id,
    required this.name,
    required this.titleTemplate,
    required this.contentTemplate,
    required this.category,
    required this.enabled,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String titleTemplate;
  final String contentTemplate;
  final String category;
  final bool enabled;
  final String updatedAt;

  factory AdminNotificationTemplate.fromJson(Map<String, dynamic> json) =>
      AdminNotificationTemplate(
        id: json['id'] as int,
        name: (json['name'] ?? '') as String,
        titleTemplate: (json['titleTemplate'] ?? '') as String,
        contentTemplate: (json['contentTemplate'] ?? '') as String,
        category: (json['category'] ?? 'system') as String,
        enabled: (json['enabled'] ?? true) as bool,
        updatedAt: (json['updatedAt'] ?? '') as String,
      );
}

// ─── 会员运营 ───

class AdminMembership {
  const AdminMembership({
    required this.id,
    required this.userId,
    required this.memberNo,
    required this.levelName,
    required this.expireAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String memberNo;
  final String levelName;
  final String expireAt;
  final String updatedAt;

  factory AdminMembership.fromJson(Map<String, dynamic> json) =>
      AdminMembership(
        id: json['id'] as int,
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        memberNo: (json['memberNo'] ?? '') as String,
        levelName: (json['levelName'] ?? '手作会员') as String,
        expireAt: (json['expireAt'] ?? '') as String,
        updatedAt: (json['updatedAt'] ?? '') as String,
      );
}

class AdminMemberPlan {
  const AdminMemberPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.originalPrice,
    required this.benefits,
    required this.badge,
    required this.recommended,
    required this.enabled,
  });

  final int id;
  final String name;
  final int durationDays;
  final double price;
  final double originalPrice;
  final List<String> benefits;
  final String badge;
  final bool recommended;
  final bool enabled;

  factory AdminMemberPlan.fromJson(Map<String, dynamic> json) =>
      AdminMemberPlan(
        id: json['id'] as int,
        name: (json['name'] ?? '') as String,
        durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
        price: _toDoubleValue(json['price']),
        originalPrice: _toDoubleValue(json['originalPrice']),
        benefits: ((json['benefits'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
        badge: (json['badge'] ?? '') as String,
        recommended: json['recommended'] == true,
        enabled: json['enabled'] != false,
      );

  static double _toDoubleValue(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AdminCoupon {
  const AdminCoupon({
    required this.id,
    required this.title,
    required this.amount,
    required this.threshold,
    required this.expireAt,
    required this.stock,
    required this.membersOnly,
    required this.enabled,
  });

  final int id;
  final String title;
  final String amount;
  final String threshold;
  final DateTime expireAt;
  final int stock;
  final bool membersOnly;
  final bool enabled;

  factory AdminCoupon.fromJson(Map<String, dynamic> json) => AdminCoupon(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        amount: (json['amount'] ?? '') as String,
        threshold: (json['threshold'] ?? '无门槛') as String,
        expireAt:
            DateTime.tryParse(json['expireAt']?.toString() ?? '') ??
            DateTime.now(),
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        membersOnly: json['membersOnly'] != false,
        enabled: json['enabled'] != false,
      );
}

/// 管理端短视频/照片作品（Reels）
class AdminVideo {
  const AdminVideo({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.cover,
    required this.videoUrl,
    required this.photos,
    required this.tags,
    required this.status,
    required this.rejectReason,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.viewCount,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String title;
  final String content;
  final String cover;
  final String videoUrl;
  final List<String> photos;
  final List<String> tags;
  final String status;
  final String rejectReason;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final String createdAt;

  bool get isPhotoWork => photos.isNotEmpty;

  factory AdminVideo.fromJson(Map<String, dynamic> json) => AdminVideo(
        id: json['id'] as int,
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        title: (json['title'] ?? '') as String,
        content: (json['content']?.toString() ?? ''),
        cover: (json['cover'] ?? '') as String,
        videoUrl: (json['videoUrl'] ?? '') as String,
        photos: ((json['photos'] ?? const []) as List)
            .map((e) => e.toString())
            .toList(),
        tags: ((json['tags'] ?? const []) as List)
            .map((e) => e.toString())
            .toList(),
        status: (json['status'] ?? 'approved') as String,
        rejectReason: (json['rejectReason'] ?? '') as String,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
        shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        createdAt: (json['createdAt'] ?? '') as String,
      );
}

/// 分页结果（后端统一返回 [items, total] 元组）
class Paged<T> {
  const Paged({required this.items, required this.total});

  final List<T> items;
  final int total;
}

/// 管理端 API：与网页管理端使用同一套 /admin/* 接口（需 admin 角色）
class AdminApi {
  AdminApi._();

  /// 提取后端错误信息
  static String messageOf(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join('，') : m.toString();
    }
    return '网络异常，请稍后再试';
  }

  // ─── 数据看板 ───

  static Future<DashboardOverview> fetchOverview() async {
    final resp = await ApiClient.instance.get('/admin/dashboard/overview');
    return DashboardOverview.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<List<TrendItem>> fetchTrends() async {
    final resp = await ApiClient.instance.get('/admin/dashboard/trends');
    return (resp.data as List)
        .map((e) => TrendItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── 门店管理 ───

  static Future<List<AdminStore>> fetchStores() async {
    final resp = await ApiClient.instance.get('/admin/stores');
    return (resp.data as List)
        .map((e) => AdminStore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<AdminStore> createStore(Map<String, dynamic> data) async {
    final resp = await ApiClient.instance.post('/admin/stores', data: data);
    return AdminStore.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<AdminStore> updateStore(int id, Map<String, dynamic> data) async {
    final resp = await ApiClient.instance.patch('/admin/stores/$id', data: data);
    return AdminStore.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<void> removeStore(int id) async {
    await ApiClient.instance.delete('/admin/stores/$id');
  }

  static Future<AdminStoreTable> addTable(int storeId, Map<String, dynamic> data) async {
    final resp = await ApiClient.instance.post('/admin/stores/$storeId/tables', data: data);
    return AdminStoreTable.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<void> removeTable(int id) async {
    await ApiClient.instance.delete('/admin/stores/tables/$id');
  }

  static Future<AdminTimeSlot> addSlot(int storeId, Map<String, dynamic> data) async {
    final resp = await ApiClient.instance.post('/admin/stores/$storeId/slots', data: data);
    return AdminTimeSlot.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<void> removeSlot(int id) async {
    await ApiClient.instance.delete('/admin/stores/slots/$id');
  }

  // ─── 订单管理 ───

  static Future<List<AdminOrder>> fetchOrders({String? status}) async {
    final resp = await ApiClient.instance.get(
      '/admin/appointments',
      queryParameters: status == null || status.isEmpty ? null : {'status': status},
    );
    final data = resp.data as List;
    // 后端返回 [items, total] 元组；兼容旧版纯数组
    final items = data.isNotEmpty && data.first is List ? data.first as List : data;
    return items
        .map((e) => AdminOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clockIn(int id) async {
    await ApiClient.instance.post('/admin/appointments/$id/clockin');
  }

  static Future<void> clockOut(int id) async {
    await ApiClient.instance.post('/admin/appointments/$id/clockout');
  }

  /// 管理端核销（店员代操作，booked → checked_in）
  static Future<void> adminCheckIn(int id) async {
    await ApiClient.instance.post('/admin/appointments/$id/checkin');
  }

  /// 管理端取消预约（待核销/已核销状态）
  static Future<void> adminCancel(int id) async {
    await ApiClient.instance.post('/admin/appointments/$id/cancel');
  }

  // ─── 社区管理 ───

  static Future<Paged<AdminPost>> fetchPosts({String? status, int page = 1}) async {
    final resp = await ApiClient.instance.get(
      '/admin/posts',
      queryParameters: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final data = resp.data as List;
    return Paged(
      items: ((data.isNotEmpty ? data[0] : const []) as List)
          .map((e) => AdminPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data.length > 1 ? (data[1] as num?)?.toInt() ?? 0 : 0,
    );
  }

  static Future<void> updatePostStatus(
    int id,
    String status, {
    String? rejectReason,
  }) async {
    await ApiClient.instance.patch(
      '/admin/posts/$id/status',
      data: {'status': status, 'rejectReason': ?rejectReason},
    );
  }

  static Future<void> removePost(int id) async {
    await ApiClient.instance.patch('/admin/posts/$id/remove');
  }

  /// 物理删除作品（连同点赞/评论/收藏记录）
  static Future<void> deletePost(int id) async {
    await ApiClient.instance.delete('/admin/posts/$id');
  }

  // ─── 用户管理 ───

  static Future<Paged<AdminUser>> fetchUsers({int page = 1, String? phone}) async {
    final resp = await ApiClient.instance.get(
      '/admin/users',
      queryParameters: {
        'page': page,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    final data = resp.data as List;
    return Paged(
      items: ((data.isNotEmpty ? data[0] : const []) as List)
          .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data.length > 1 ? (data[1] as num?)?.toInt() ?? 0 : 0,
    );
  }

  static Future<void> setBan(int id, bool isBanned) async {
    await ApiClient.instance.patch('/admin/users/$id/ban', data: {'isBanned': isBanned});
  }

  /// 强制下线：立即使该用户全部现有会话失效，需重新登录
  static Future<void> forceOffline(int id) async {
    await ApiClient.instance.patch('/admin/users/$id/offline');
  }

  /// 删除某用户的全部作品（社区帖子 + 短视频/照片）
  static Future<({int posts, int videos})> deleteUserWorks(int id) async {
    final resp = await ApiClient.instance.delete('/admin/users/$id/works');
    final data = resp.data as Map<String, dynamic>;
    return (
      posts: (data['posts'] as num?)?.toInt() ?? 0,
      videos: (data['videos'] as num?)?.toInt() ?? 0,
    );
  }

  /// 删除用户（含其作品、互动、关注、会员、预约、聊天等全部关联数据）
  static Future<void> deleteUser(int id) async {
    await ApiClient.instance.delete('/admin/users/$id');
  }

  // ─── 通知管理 ───

  static Future<Paged<AdminNotification>> fetchNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await ApiClient.instance.get(
      '/admin/notifications',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = resp.data as Map<String, dynamic>;
    return Paged(
      items: ((data['items'] ?? []) as List)
          .map((e) => AdminNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<void> sendNotification(Map<String, dynamic> data) async {
    await ApiClient.instance.post('/admin/notifications', data: data);
  }

  static Future<void> removeNotification(int id) async {
    await ApiClient.instance.delete('/admin/notifications/$id');
  }

  static Future<List<AdminNotificationTemplate>> fetchTemplates() async {
    final resp = await ApiClient.instance.get('/admin/notifications/templates');
    return (resp.data as List)
        .map((e) => AdminNotificationTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> createTemplate(Map<String, dynamic> data) async {
    await ApiClient.instance.post('/admin/notifications/templates', data: data);
  }

  static Future<void> updateTemplate(int id, Map<String, dynamic> data) async {
    await ApiClient.instance.patch('/admin/notifications/templates/$id', data: data);
  }

  static Future<void> removeTemplate(int id) async {
    await ApiClient.instance.delete('/admin/notifications/templates/$id');
  }

  // ─── 会员运营 ───

  static Future<Paged<AdminMembership>> fetchMemberships({
    int page = 1,
    String? keyword,
  }) async {
    final resp = await ApiClient.instance.get(
      '/admin/members',
      queryParameters: {
        'page': page,
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      },
    );
    final data = resp.data as List;
    return Paged(
      items: ((data.isNotEmpty ? data[0] : const []) as List)
          .map((e) => AdminMembership.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data.length > 1 ? (data[1] as num?)?.toInt() ?? 0 : 0,
    );
  }

  /// 后台开通会员（用户ID + 等级 + 有效期）
  static Future<AdminMembership> createMembership(
    Map<String, dynamic> data,
  ) async {
    final resp = await ApiClient.instance.post('/admin/members', data: data);
    return AdminMembership.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 后台编辑会员（等级 + 有效期）
  static Future<AdminMembership> updateMembership(
    int id,
    Map<String, dynamic> data,
  ) async {
    final resp = await ApiClient.instance.patch(
      '/admin/members/$id',
      data: data,
    );
    return AdminMembership.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 后台删除会员记录
  static Future<void> deleteMembership(int id) async {
    await ApiClient.instance.delete('/admin/members/$id');
  }

  static Future<List<AdminMemberPlan>> fetchMemberPlans() async {
    final resp = await ApiClient.instance.get('/admin/members/plans');
    return (resp.data as List)
        .map((e) => AdminMemberPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<AdminMemberPlan> createMemberPlan(
    Map<String, dynamic> data,
  ) async {
    final resp = await ApiClient.instance.post('/admin/members/plans', data: data);
    return AdminMemberPlan.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<AdminMemberPlan> updateMemberPlan(
    int id,
    Map<String, dynamic> data,
  ) async {
    final resp = await ApiClient.instance.patch(
      '/admin/members/plans/$id',
      data: data,
    );
    return AdminMemberPlan.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<void> toggleMemberPlan(int id, bool enabled) async {
    await ApiClient.instance.patch(
      '/admin/members/plans/$id/enabled',
      data: {'enabled': enabled},
    );
  }

  static Future<List<AdminCoupon>> fetchCoupons() async {
    final resp = await ApiClient.instance.get('/admin/members/coupons');
    return (resp.data as List)
        .map((e) => AdminCoupon.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<AdminCoupon> createCoupon(Map<String, dynamic> data) async {
    final resp = await ApiClient.instance.post('/admin/members/coupons', data: data);
    return AdminCoupon.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<AdminCoupon> updateCoupon(
    int id,
    Map<String, dynamic> data,
  ) async {
    final resp = await ApiClient.instance.patch(
      '/admin/members/coupons/$id',
      data: data,
    );
    return AdminCoupon.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<void> toggleCoupon(int id, bool enabled) async {
    await ApiClient.instance.patch(
      '/admin/members/coupons/$id/enabled',
      data: {'enabled': enabled},
    );
  }

  // ─── Reels 视频管理 ───

  static Future<Paged<AdminVideo>> fetchVideos({
    String? status,
    int page = 1,
  }) async {
    final resp = await ApiClient.instance.get(
      '/admin/videos',
      queryParameters: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final data = resp.data as List;
    return Paged(
      items: ((data.isNotEmpty ? data[0] : const []) as List)
          .map((e) => AdminVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data.length > 1 ? (data[1] as num?)?.toInt() ?? 0 : 0,
    );
  }

  static Future<void> updateVideoStatus(
    int id,
    String status, {
    String? rejectReason,
  }) async {
    await ApiClient.instance.patch(
      '/admin/videos/$id/status',
      data: {
        'status': status,
        if (rejectReason != null && rejectReason.isNotEmpty)
          'rejectReason': rejectReason,
      },
    );
  }

  /// 下架（软删除：状态置为 rejected，理由为“管理员下架”）
  static Future<void> removeVideo(int id) async {
    await ApiClient.instance.patch('/admin/videos/$id/remove');
  }

  /// 物理删除（连同点赞/评论/浏览历史）
  static Future<void> hardDeleteVideo(int id) async {
    await ApiClient.instance.delete('/admin/videos/$id');
  }

  // ─── 活动管理 ───

  static Future<List<AdminActivity>> fetchActivities() async {
    final resp = await ApiClient.instance.get('/admin/activities');
    return (resp.data as List)
        .map((e) => AdminActivity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<AdminActivity> createActivity(Map<String, dynamic> data) async {
    final resp = await ApiClient.instance.post('/admin/activities', data: data);
    return AdminActivity.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<AdminActivity> updateActivity(
    int id,
    Map<String, dynamic> data,
  ) async {
    final resp = await ApiClient.instance.patch(
      '/admin/activities/$id',
      data: data,
    );
    return AdminActivity.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<void> toggleActivity(int id, bool enabled) async {
    await ApiClient.instance.patch(
      '/admin/activities/$id/enabled',
      data: {'enabled': enabled},
    );
  }

  /// 新增活动场次
  static Future<AdminActivitySession> addActivitySession(
    int activityId,
    Map<String, dynamic> data,
  ) async {
    final resp = await ApiClient.instance.post(
      '/admin/activities/$activityId/sessions',
      data: data,
    );
    return AdminActivitySession.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 删除活动场次
  static Future<void> removeActivitySession(int sessionId) async {
    await ApiClient.instance.delete('/admin/activities/sessions/$sessionId');
  }
}

// ─── 活动管理 ───

class AdminActivity {
  const AdminActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.desc,
    required this.tag,
    required this.address,
    required this.price,
    required this.bookable,
    required this.membersOnly,
    required this.enabled,
    required this.sort,
    this.memberPrice,
    this.lat,
    this.lng,
    this.sessions = const [],
  });

  final int id;
  final String title;
  final String date;
  final String desc;
  final String tag;
  final String address;
  final double price;
  final double? memberPrice;
  final bool bookable;
  final bool membersOnly;
  final bool enabled;
  final int sort;
  final double? lat;
  final double? lng;
  final List<AdminActivitySession> sessions;

  factory AdminActivity.fromJson(Map<String, dynamic> json) => AdminActivity(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        date: (json['date'] ?? '') as String,
        desc: (json['desc'] ?? '') as String,
        tag: (json['tag'] ?? '') as String,
        address: (json['address'] ?? '') as String,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        memberPrice: (json['memberPrice'] as num?)?.toDouble(),
        bookable: json['bookable'] == true,
        membersOnly: json['membersOnly'] == true,
        enabled: json['enabled'] != false,
        sort: (json['sort'] as num?)?.toInt() ?? 0,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        sessions: ((json['sessions'] ?? []) as List)
            .map((e) => AdminActivitySession.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AdminActivitySession {
  const AdminActivitySession({
    required this.id,
    required this.activityId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.enabled,
  });

  final int id;
  final int activityId;
  final String date;
  final String startTime;
  final String endTime;
  final int capacity;
  final bool enabled;

  factory AdminActivitySession.fromJson(Map<String, dynamic> json) =>
      AdminActivitySession(
        id: json['id'] as int,
        activityId: (json['activityId'] as num?)?.toInt() ?? 0,
        date: (json['date'] ?? '') as String,
        startTime: (json['startTime'] ?? '') as String,
        endTime: (json['endTime'] ?? '') as String,
        capacity: (json['capacity'] as num?)?.toInt() ?? 1,
        enabled: json['enabled'] != false,
      );
}
