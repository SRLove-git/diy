import 'package:dio/dio.dart';

import 'api_client.dart';

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.businessHours,
    required this.images,
  });

  final int id;
  final String name;
  final String address;
  final double rating;
  final String businessHours;
  final List<String> images;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String,
        rating: (json['rating'] as num?)?.toDouble() ?? 5,
        businessHours: (json['businessHours'] ?? '') as String,
        images: ((json['images'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
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
    required int storeId,
    required int tableId,
    required int slotId,
    required String date,
    required int peopleCount,
  }) async {
    final resp = await ApiClient.instance.post(
      '/appointments',
      data: {
        'storeId': storeId,
        'tableId': tableId,
        'slotId': slotId,
        'date': date,
        'peopleCount': peopleCount,
      },
    );
    return Appointment.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 我的预约列表
  static Future<List<Appointment>> fetchMyList() async {
    final resp = await ApiClient.instance.get('/appointments');
    return (resp.data as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
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
