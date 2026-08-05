import 'package:dio/dio.dart';

import 'api_client.dart';

/// 作者简要信息（嵌入列表响应）
class AuthorInfo {
  const AuthorInfo({
    required this.nickname,
    required this.avatar,
  });

  final String nickname;
  final String avatar;

  factory AuthorInfo.fromJson(Map<String, dynamic> json) => AuthorInfo(
        nickname: (json['nickname'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
      );
}

/// 评论数据模型
class Comment {
  const Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    this.author,
  });

  final int id;
  final int userId;
  final int postId;
  final String content;
  final String createdAt;
  final AuthorInfo? author;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as int,
        userId: json['userId'] as int,
        postId: json['postId'] as int,
        content: (json['content'] ?? '') as String,
        createdAt: (json['createdAt'] ?? '') as String,
        author: json['author'] != null
            ? AuthorInfo.fromJson(json['author'] as Map<String, dynamic>)
            : null,
      );
}

/// 媒体项
class PostMedia {
  const PostMedia({
    required this.type,
    required this.url,
    this.aspectRatio,
    this.duration,
  });

  final String type; // image | video
  final String url;
  final double? aspectRatio;
  final double? duration; // 秒

  factory PostMedia.fromJson(Map<String, dynamic> json) => PostMedia(
        type: (json['type'] ?? 'image') as String,
        url: (json['url'] ?? '') as String,
        aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
        duration: (json['duration'] as num?)?.toDouble(),
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
    this.title = '',
    this.location = '',
    this.medias = const [],
    this.channelTag = '',
    this.viewCount = 0,
    this.shareCount = 0,
    this.author,
  });

  final int id;
  final int userId;
  final String title;
  final String content;
  final String location;
  final List<String> images;
  final List<String> tags;
  final String status;
  final int likeCount;
  final int collectCount;
  final int commentCount;
  final String createdAt;
  final List<PostMedia> medias;
  final String channelTag;
  final int viewCount;
  final int shareCount;
  final AuthorInfo? author;

  Post copyWith({
    int? likeCount,
    int? collectCount,
    int? commentCount,
    int? viewCount,
    int? shareCount,
  }) =>
      Post(
        id: id,
        userId: userId,
        title: title,
        content: content,
        location: location,
        images: images,
        tags: tags,
        status: status,
        likeCount: likeCount ?? this.likeCount,
        collectCount: collectCount ?? this.collectCount,
        commentCount: commentCount ?? this.commentCount,
        createdAt: createdAt,
        medias: medias,
        channelTag: channelTag,
        viewCount: viewCount ?? this.viewCount,
        shareCount: shareCount ?? this.shareCount,
        author: author,
      );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: (json['title'] ?? '') as String,
        content: (json['content'] ?? '') as String,
        location: (json['location'] ?? '') as String,
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
        medias: ((json['medias'] ?? []) as List)
            .map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
            .toList(),
        channelTag: (json['channelTag'] ?? '') as String,
        viewCount: (json['viewCount'] ?? 0) as int,
        shareCount: (json['shareCount'] ?? 0) as int,
        author: json['author'] != null
            ? AuthorInfo.fromJson(json['author'] as Map<String, dynamic>)
            : null,
      );
}

/// 社区 API
class PostApi {
  PostApi._();

  /// 最新信息流（可按关键词 / 频道筛选）
  static Future<({List<Post> items, int total})> fetchLatest({
    int page = 1,
    String? q,
    String? channel,
  }) async {
    final resp = await ApiClient.instance.get('/posts', queryParameters: {
      'page': page,
      if (q != null && q.isNotEmpty) 'q': q,
      if (channel != null && channel.isNotEmpty) 'channel': channel,
    });
    final items = ((resp.data[0] ?? []) as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: resp.data[1] as int);
  }

  /// 热门信息流（按点赞数排序，可按关键词 / 频道筛选）
  static Future<({List<Post> items, int total})> fetchHot({
    int page = 1,
    String? q,
    String? channel,
  }) async {
    final resp = await ApiClient.instance.get('/posts/hot', queryParameters: {
      'page': page,
      if (q != null && q.isNotEmpty) 'q': q,
      if (channel != null && channel.isNotEmpty) 'channel': channel,
    });
    final items = ((resp.data[0] ?? []) as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: resp.data[1] as int);
  }

  /// 关注流：我关注的人的作品
  static Future<({List<Post> items, int total})> fetchFollowing({int page = 1}) async {
    final resp = await ApiClient.instance.get(
      '/posts/following',
      queryParameters: {'page': page},
    );
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
    String? title,
    String? location,
    List<Map<String, dynamic>>? medias,
    String? channelTag,
  }) async {
    final data = <String, dynamic>{
      'content': content,
      'images': images,
      'tags': tags,
    };
    if (title != null && title.isNotEmpty) data['title'] = title;
    if (location != null && location.isNotEmpty) data['location'] = location;
    if (medias != null && medias.isNotEmpty) data['medias'] = medias;
    if (channelTag != null && channelTag.isNotEmpty) data['channelTag'] = channelTag;
    final resp = await ApiClient.instance.post('/posts', data: data);
    return Post.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 删除自己的作品
  static Future<void> deletePost(int postId) async {
    await ApiClient.instance.delete('/posts/$postId');
  }

  // --- View ---

  /// 记录浏览（浏览量 +1）
  static Future<void> recordView(int postId) async {
    await ApiClient.instance.post('/posts/$postId/view');
  }

  // --- Share ---

  /// 记录分享（分享数 +1）
  static Future<void> recordShare(int postId) async {
    await ApiClient.instance.post('/posts/$postId/share');
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

  // --- Report ---

  /// 举报作品
  static Future<void> report(int postId, String reason) async {
    await ApiClient.instance.post(
      '/posts/$postId/report',
      data: {'reason': reason},
    );
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

  /// 获取我点赞过的作品
  static Future<({List<Post> items, int total})> fetchLikedPosts({int page = 1}) async {
    final resp = await ApiClient.instance.get('/posts/my-likes', queryParameters: {'page': page});
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

  /// 获取我的浏览历史
  static Future<({List<Post> items, int total})> fetchHistory({int page = 1}) async {
    final resp = await ApiClient.instance.get('/posts/history', queryParameters: {'page': page});
    final data = resp.data;
    final items = ((data[0] ?? []) as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: data[1] as int);
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
