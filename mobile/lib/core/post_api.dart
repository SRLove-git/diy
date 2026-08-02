import 'package:dio/dio.dart';

import 'api_client.dart';

/// 评论数据模型
class Comment {
  const Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final int postId;
  final String content;
  final String createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as int,
        userId: json['userId'] as int,
        postId: json['postId'] as int,
        content: (json['content'] ?? '') as String,
        createdAt: (json['createdAt'] ?? '') as String,
      );
}

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

  // --- Like ---

  /// 切换点赞状态
  static Future<bool> toggleLike(int postId) async {
    final resp = await ApiClient.instance.post('/posts/$postId/like');
    return resp.data['liked'] as bool;
  }

  /// 查询当前用户是否已点赞
  static Future<bool> isLiked(int postId) async {
    final resp = await ApiClient.instance.get('/posts/$postId/like');
    return resp.data['liked'] as bool;
  }

  /// 批量查询点赞状态
  static Future<Map<int, bool>> batchLiked(List<int> postIds) async {
    final ids = postIds.join(',');
    final resp = await ApiClient.instance.get('/posts/liked', queryParameters: {'ids': ids});
    final map = <int, bool>{};
    for (final e in (resp.data as Map<String, dynamic>).entries) {
      map[int.parse(e.key)] = e.value as bool;
    }
    return map;
  }

  // --- Collect ---

  /// 切换收藏状态
  static Future<bool> toggleCollect(int postId) async {
    final resp = await ApiClient.instance.post('/posts/$postId/collect');
    return resp.data['collected'] as bool;
  }

  /// 查询当前用户是否已收藏
  static Future<bool> isCollected(int postId) async {
    final resp = await ApiClient.instance.get('/posts/$postId/collect');
    return resp.data['collected'] as bool;
  }

  // --- Comments ---

  /// 获取评论列表
  static Future<({List<Comment> items, int total})> fetchComments(int postId, {int page = 1}) async {
    final resp = await ApiClient.instance.get('/posts/$postId/comments', queryParameters: {'page': page});
    final data = resp.data;
    final items = ((data[0] ?? []) as List)
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: data[1] as int);
  }

  /// 添加评论
  static Future<Comment> addComment(int postId, String content) async {
    final resp = await ApiClient.instance.post(
      '/posts/$postId/comments',
      data: {'content': content},
    );
    return Comment.fromJson(resp.data as Map<String, dynamic>);
  }

  // --- Author profile ---

  /// 获取指定用户的作品列表
  static Future<({List<Post> items, int total})> fetchByUser(int userId, {int page = 1}) async {
    final resp = await ApiClient.instance.get('/posts/users/$userId/posts', queryParameters: {'page': page});
    final items = ((resp.data[0] ?? []) as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: resp.data[1] as int);
  }

  // --- My favorites ---

  /// 获取我的收藏列表
  static Future<({List<Post> items, int total})> fetchFavorites({int page = 1}) async {
    final resp = await ApiClient.instance.get('/posts/favorites', queryParameters: {'page': page});
    final items = ((resp.data[0] ?? []) as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: resp.data[1] as int);
  }

  // --- History ---

  /// 记录浏览历史
  static Future<void> addHistory(int postId) async {
    await ApiClient.instance.post('/posts/$postId/history');
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
