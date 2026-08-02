import 'package:dio/dio.dart';

import 'api_client.dart';

/// 社区作品数据模型
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
    required this.tags,
    required this.status,
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
  final int likeCount;
  final int collectCount;
  final int commentCount;
  final String createdAt;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        userId: json['userId'] as int,
        content: (json['content'] ?? '') as String,
        images: ((json['images'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
        tags: ((json['tags'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
        status: (json['status'] ?? 'pending') as String,
        likeCount: (json['likeCount'] ?? 0) as int,
        collectCount: (json['collectCount'] ?? 0) as int,
        commentCount: (json['commentCount'] ?? 0) as int,
        createdAt: (json['createdAt'] ?? '') as String,
      );
}

/// 社区 API
class PostApi {
  PostApi._();

  /// 最新信息流
  static Future<({List<Post> items, int total})> fetchLatest({int page = 1}) async {
    final resp = await ApiClient.instance.get('/posts', queryParameters: {'page': page});
    final items = ((resp.data[0] ?? []) as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: resp.data[1] as int);
  }

  /// 热门信息流（按点赞数排序）
  static Future<({List<Post> items, int total})> fetchHot({int page = 1}) async {
    final resp = await ApiClient.instance.get('/posts/hot', queryParameters: {'page': page});
    final items = ((resp.data[0] ?? []) as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: resp.data[1] as int);
  }

  /// 作品详情
  static Future<Post> fetchDetail(int id) async {
    final resp = await ApiClient.instance.get('/posts/$id');
    return Post.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 我的作品
  static Future<({List<Post> items, int total})> fetchMine({int page = 1}) async {
    final resp = await ApiClient.instance.get('/posts/mine', queryParameters: {'page': page});
    final items = ((resp.data[0] ?? []) as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: resp.data[1] as int);
  }

  /// 发布作品
  static Future<Post> create({
    required String content,
    required List<String> images,
    required List<String> tags,
  }) async {
    final resp = await ApiClient.instance.post(
      '/posts',
      data: {'content': content, 'images': images, 'tags': tags},
    );
    return Post.fromJson(resp.data as Map<String, dynamic>);
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
