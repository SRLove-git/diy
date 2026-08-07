import 'api_client.dart';
import 'models.dart';

/// 社区作品 / 短视频
class CommunityService {
  CommunityService._();
  static final CommunityService instance = CommunityService._();

  Future<Page<Post>> latest({int page = 1, String q = '', String channel = ''}) async {
    final raw = await ApiClient.instance.get('/posts', query: {
      'page': page,
      if (q.isNotEmpty) 'q': q,
      if (channel.isNotEmpty) 'channel': channel,
    });
    return Page.parse<Post>(raw, Post.fromJson);
  }

  Future<Page<Post>> hot({int page = 1, String q = '', String channel = ''}) async {
    final raw = await ApiClient.instance.get('/posts/hot', query: {
      'page': page,
      if (q.isNotEmpty) 'q': q,
      if (channel.isNotEmpty) 'channel': channel,
    });
    return Page.parse<Post>(raw, Post.fromJson);
  }

  Future<Page<Post>> following({int page = 1}) async {
    final raw = await ApiClient.instance.get('/posts/following', query: {'page': page});
    return Page.parse<Post>(raw, Post.fromJson);
  }

  Future<Page<Post>> mine({int page = 1}) async {
    final raw = await ApiClient.instance.get('/posts/mine', query: {'page': page});
    return Page.parse<Post>(raw, Post.fromJson);
  }

  Future<Page<Post>> favorites({int page = 1}) async {
    final raw = await ApiClient.instance.get('/posts/favorites', query: {'page': page});
    return Page.parse<Post>(raw, Post.fromJson);
  }

  Future<Page<Post>> myLikes({int page = 1}) async {
    final raw = await ApiClient.instance.get('/posts/my-likes', query: {'page': page});
    return Page.parse<Post>(raw, Post.fromJson);
  }

  Future<Page<Post>> history({int page = 1}) async {
    final raw = await ApiClient.instance.get('/posts/history', query: {'page': page});
    return Page.parse<Post>(raw, Post.fromJson);
  }

  Future<Page<Post>> userPosts(int userId, {int page = 1}) async {
    final raw =
        await ApiClient.instance.get('/posts/users/$userId/posts', query: {'page': page});
    return Page.parse<Post>(raw, Post.fromJson);
  }

  Future<Post> detail(int id) async {
    final data = await ApiClient.instance.get('/posts/$id') as Map<String, dynamic>;
    return Post.fromJson(data);
  }

  Future<Post> create(Map<String, dynamic> body) async {
    final data = await ApiClient.instance.post('/posts', body: body) as Map<String, dynamic>;
    return Post.fromJson(data);
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.delete('/posts/$id');
  }

  Future<bool> toggleLike(int id) async {
    final data = await ApiClient.instance.post('/posts/$id/like') as Map<String, dynamic>;
    return data['liked'] as bool? ?? false;
  }

  Future<bool> isLiked(int id) async {
    final data = await ApiClient.instance.get('/posts/$id/like') as Map<String, dynamic>;
    return data['liked'] as bool? ?? false;
  }

  Future<bool> toggleCollect(int id) async {
    final data = await ApiClient.instance.post('/posts/$id/collect') as Map<String, dynamic>;
    return data['collected'] as bool? ?? false;
  }

  Future<bool> isCollected(int id) async {
    final data = await ApiClient.instance.get('/posts/$id/collect') as Map<String, dynamic>;
    return data['collected'] as bool? ?? false;
  }

  Future<Page<Comment>> comments(int id, {int page = 1}) async {
    final raw = await ApiClient.instance.get('/posts/$id/comments', query: {'page': page});
    return Page.parse<Comment>(raw, Comment.fromJson);
  }

  Future<Comment> addComment(int id, String content) async {
    final data = await ApiClient.instance.post('/posts/$id/comments', body: {'content': content})
        as Map<String, dynamic>;
    return Comment.fromJson(data);
  }

  Future<void> recordView(int id) => ApiClient.instance.post('/posts/$id/view');
  Future<void> recordShare(int id) => ApiClient.instance.post('/posts/$id/share');
  Future<void> addHistory(int id) => ApiClient.instance.post('/posts/$id/history');
}

class VideoService {
  VideoService._();
  static final VideoService instance = VideoService._();

  Future<Page<Video>> recommend({int page = 1, String q = ''}) async {
    final raw = await ApiClient.instance.get('/videos', query: {
      'page': page,
      if (q.isNotEmpty) 'q': q,
    });
    return Page.parse<Video>(raw, Video.fromJson);
  }

  Future<Page<Video>> following({int page = 1}) async {
    final raw = await ApiClient.instance.get('/videos/following', query: {'page': page});
    return Page.parse<Video>(raw, Video.fromJson);
  }

  Future<Page<Video>> mine({int page = 1}) async {
    final raw = await ApiClient.instance.get('/videos/mine', query: {'page': page});
    return Page.parse<Video>(raw, Video.fromJson);
  }

  Future<Page<Video>> myLikes({int page = 1}) async {
    final raw = await ApiClient.instance.get('/videos/my-likes', query: {'page': page});
    return Page.parse<Video>(raw, Video.fromJson);
  }

  Future<Page<Video>> history({int page = 1}) async {
    final raw = await ApiClient.instance.get('/videos/history', query: {'page': page});
    return Page.parse<Video>(raw, Video.fromJson);
  }

  Future<Page<Video>> userVideos(int userId, {int page = 1}) async {
    final raw = await ApiClient.instance.get('/videos/users/$userId/videos', query: {'page': page});
    return Page.parse<Video>(raw, Video.fromJson);
  }

  Future<Video> detail(int id) async {
    final data = await ApiClient.instance.get('/videos/$id') as Map<String, dynamic>;
    return Video.fromJson(data);
  }

  Future<Video> create(Map<String, dynamic> body) async {
    final data = await ApiClient.instance.post('/videos', body: body) as Map<String, dynamic>;
    return Video.fromJson(data);
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.delete('/videos/$id');
  }

  Future<bool> toggleLike(int id) async {
    final data = await ApiClient.instance.post('/videos/$id/like') as Map<String, dynamic>;
    return data['liked'] as bool? ?? false;
  }

  Future<bool> isLiked(int id) async {
    final data = await ApiClient.instance.get('/videos/$id/like') as Map<String, dynamic>;
    return data['liked'] as bool? ?? false;
  }

  /// 批量查询当前用户对多个视频的点赞状态：GET /videos/liked?ids=1,2,3
  Future<Map<int, bool>> batchLiked(List<int> ids) async {
    if (ids.isEmpty) return {};
    final data = await ApiClient.instance.get('/videos/liked', query: {'ids': ids})
        as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(int.tryParse(k) ?? 0, v as bool? ?? false));
  }

  Future<Page<Comment>> comments(int id, {int page = 1}) async {
    final raw = await ApiClient.instance.get('/videos/$id/comments', query: {'page': page});
    return Page.parse<Comment>(raw, Comment.fromJson);
  }

  Future<Comment> addComment(int id, String content) async {
    final data = await ApiClient.instance.post('/videos/$id/comments', body: {'content': content})
        as Map<String, dynamic>;
    return Comment.fromJson(data);
  }

  Future<void> recordView(int id) => ApiClient.instance.post('/videos/$id/view');
  Future<void> recordShare(int id) => ApiClient.instance.post('/videos/$id/share');
  Future<void> addHistory(int id) => ApiClient.instance.post('/videos/$id/history');
}
