import 'package:dio/dio.dart';

import 'api_client.dart';

/// 我的通知数据模型
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.read = false,
  });

  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool read;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        content: (json['content'] ?? '') as String,
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
            DateTime.now(),
        read: json['read'] == true,
      );
}

/// 我的通知 API（列表 / 未读数 / 已读）
class NotificationApi {
  NotificationApi._();

  /// 我的通知分页列表
  static Future<({List<AppNotification> items, int total, int unread})>
      fetchMine({int page = 1, int pageSize = 20}) async {
    final resp = await ApiClient.instance.get(
      '/notifications',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final json = resp.data as Map<String, dynamic>;
    return (
      items: ((json['items'] ?? []) as List)
          .map(
            (e) => AppNotification.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      total: (json['total'] ?? 0) as int,
      unread: (json['unread'] ?? 0) as int,
    );
  }

  /// 未读通知数
  static Future<int> fetchUnreadCount() async {
    final resp = await ApiClient.instance.get('/notifications/unread-count');
    return ((resp.data as Map<String, dynamic>)['count'] ?? 0) as int;
  }

  /// 标记单条已读
  static Future<void> markRead(int id) async {
    await ApiClient.instance.post('/notifications/$id/read');
  }

  /// 全部标记已读
  static Future<void> markAllRead() async {
    await ApiClient.instance.post('/notifications/read-all');
  }

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
