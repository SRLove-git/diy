import 'package:dio/dio.dart';

import 'api_client.dart';

// ─── 数据看板 ───

class DashboardOverview {
  const DashboardOverview({
    required this.users,
    required this.appointments,
    required this.community,
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

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    final u = json['users'] as Map<String, dynamic>? ?? const {};
    final a = json['appointments'] as Map<String, dynamic>? ?? const {};
    final c = json['community'] as Map<String, dynamic>? ?? const {};
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
  });

  final String date;
  final int users;
  final int appointments;
  final int posts;
  final int likes;
  final int comments;

  factory TrendItem.fromJson(Map<String, dynamic> json) => TrendItem(
        date: (json['date'] ?? '') as String,
        users: (json['users'] as num?)?.toInt() ?? 0,
        appointments: (json['appointments'] as num?)?.toInt() ?? 0,
        posts: (json['posts'] as num?)?.toInt() ?? 0,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        comments: (json['comments'] as num?)?.toInt() ?? 0,
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
    required this.lat,
    required this.lng,
    required this.rating,
    required this.businessHours,
    required this.phone,
    required this.enabled,
    required this.tables,
    required this.slots,
  });

  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double rating;
  final String businessHours;
  final String phone;
  final bool enabled;
  final List<AdminStoreTable> tables;
  final List<AdminTimeSlot> slots;

  factory AdminStore.fromJson(Map<String, dynamic> json) => AdminStore(
        id: json['id'] as int,
        name: (json['name'] ?? '') as String,
        address: (json['address'] ?? '') as String,
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 5,
        businessHours: (json['businessHours'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
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
    required this.storeName,
    required this.tableName,
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
  final String storeName;
  final String tableName;
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
        storeName: (json['storeName'] ?? '') as String,
        tableName: (json['tableName'] ?? '') as String,
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

// ─── 举报 ───

class AdminReport {
  const AdminReport({
    required this.id,
    required this.reporterId,
    required this.postId,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int reporterId;
  final int postId;
  final String reason;
  final String status;
  final String createdAt;
  final String updatedAt;

  factory AdminReport.fromJson(Map<String, dynamic> json) => AdminReport(
        id: json['id'] as int,
        reporterId: (json['reporterId'] as num?)?.toInt() ?? 0,
        postId: (json['postId'] as num?)?.toInt() ?? 0,
        reason: (json['reason'] ?? '') as String,
        status: (json['status'] ?? '') as String,
        createdAt: (json['createdAt'] ?? '') as String,
        updatedAt: (json['updatedAt'] ?? '') as String,
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
    return (resp.data as List)
        .map((e) => AdminOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clockIn(int id) async {
    await ApiClient.instance.post('/admin/appointments/$id/clockin');
  }

  static Future<void> clockOut(int id) async {
    await ApiClient.instance.post('/admin/appointments/$id/clockout');
  }

  // ─── 作品审核 ───

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

  // ─── 举报处理 ───

  static Future<Paged<AdminReport>> fetchReports({String? status, int page = 1}) async {
    final resp = await ApiClient.instance.get(
      '/admin/reports',
      queryParameters: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final data = resp.data as List;
    return Paged(
      items: ((data.isNotEmpty ? data[0] : const []) as List)
          .map((e) => AdminReport.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data.length > 1 ? (data[1] as num?)?.toInt() ?? 0 : 0,
    );
  }

  static Future<void> resolveReport(int id) async {
    await ApiClient.instance.post('/admin/reports/$id/resolve');
  }

  static Future<void> dismissReport(int id) async {
    await ApiClient.instance.post('/admin/reports/$id/dismiss');
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
}
