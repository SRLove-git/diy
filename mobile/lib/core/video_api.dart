import 'package:dio/dio.dart';

import '../features/community/domain/community_models.dart';
import '../pages/short_video_models.dart';
import 'api_client.dart';
import 'chat_api.dart';
import 'upload_media_type.dart';

/// 短视频 REST API（对应服务端 videos 模块）。
///
/// 覆盖：推荐/关注/我的信息流、发布、上传视频与封面、点赞、评论、浏览、分享。
/// 与 [PostApi] 同风格：静态方法 + 服务端响应直接映射为领域模型。
class VideoApi {
  VideoApi._();

  // ──── 信息流 ────

  /// 推荐信息流（全部已通过视频，按创建时间倒序）
  static Future<({List<ShortVideo> items, int total})> fetchRecommend({
    int page = 1,
    String? q,
  }) async {
    final resp = await ApiClient.instance.get(
      '/videos',
      queryParameters: {
        'page': page,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      },
    );
    return _parseList(resp.data);
  }

  /// 按关键词搜索视频（标题 / 文案 / 配乐 / 地点 / 标签）
  static Future<({List<ShortVideo> items, int total})> search(
    String keyword, {
    int page = 1,
  }) =>
      fetchRecommend(page: page, q: keyword);

  /// 关注信息流（已关注作者的视频，需登录）
  static Future<({List<ShortVideo> items, int total})> fetchFollowing({
    int page = 1,
  }) async {
    final resp = await ApiClient.instance.get(
      '/videos/following',
      queryParameters: {'page': page},
    );
    return _parseList(resp.data);
  }

  /// 我的发布列表
  static Future<({List<ShortVideo> items, int total})> fetchMine({
    int page = 1,
  }) async {
    final resp = await ApiClient.instance.get(
      '/videos/mine',
      queryParameters: {'page': page},
    );
    return _parseList(resp.data);
  }

  /// 我点赞过的视频列表
  static Future<({List<ShortVideo> items, int total})> fetchMyLikedVideos({
    int page = 1,
  }) async {
    final resp = await ApiClient.instance.get(
      '/videos/my-likes',
      queryParameters: {'page': page},
    );
    return _parseList(resp.data);
  }

  /// 指定作者的视频列表
  static Future<({List<ShortVideo> items, int total})> fetchByUser(
    int userId, {
    int page = 1,
  }) async {
    final resp = await ApiClient.instance.get(
      '/videos/users/$userId/videos',
      queryParameters: {'page': page},
    );
    return _parseList(resp.data);
  }

  /// 视频详情
  static Future<ShortVideo> fetchDetail(int id) async {
    final resp = await ApiClient.instance.get('/videos/$id');
    return ShortVideo.fromServerJson(resp.data as Map<String, dynamic>);
  }

  // ──── 上传 ────

  /// 上传视频文件，返回可访问的相对路径（/uploads/video/...）
  static Future<String> uploadVideo(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        contentType: uploadMediaTypeFor(filePath),
      ),
    });
    final resp = await ApiClient.instance.post(
      '/uploads/videos',
      data: form,
      options: ApiClient.uploadOptions(
        headers: {'Content-Type': Headers.multipartFormDataContentType},
      ),
    );
    return (resp.data as Map<String, dynamic>)['url'] as String;
  }

  /// 上传视频封面图，返回可访问的相对路径（/uploads/post/...）
  static Future<String> uploadCover(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        contentType: uploadMediaTypeFor(filePath),
      ),
    });
    final resp = await ApiClient.instance.post(
      '/uploads/images',
      data: form,
      queryParameters: {'folder': 'post'},
      options: ApiClient.uploadOptions(
        headers: {'Content-Type': Headers.multipartFormDataContentType},
      ),
    );
    return (resp.data as Map<String, dynamic>)['url'] as String;
  }

  // ──── 发布 ────

  /// 发布短视频/照片作品（videoUrl 已由 [uploadVideo] 上传取得）
  static Future<ShortVideo> create({
    String title = '',
    String content = '',
    String cover = '',
    String videoUrl = '',
    int? duration,
    String music = '',
    int? musicId,
    List<String> tags = const [],
    String location = '',
    List<String> photos = const [],
    String filter = '',
    double trimStart = 0,
    double trimEnd = 0,
    double speed = 1,
    int rotation = 0,
    double aspectRatio = 0,
  }) async {
    final data = <String, dynamic>{};
    if (title.isNotEmpty) data['title'] = title;
    if (content.isNotEmpty) data['content'] = content;
    if (cover.isNotEmpty) data['cover'] = cover;
    if (videoUrl.isNotEmpty) data['videoUrl'] = videoUrl;
    if (duration != null && duration > 0) data['duration'] = duration;
    if (music.isNotEmpty) data['music'] = music;
    if (musicId != null && musicId > 0) data['musicId'] = musicId;
    if (tags.isNotEmpty) data['tags'] = tags;
    if (location.isNotEmpty) data['location'] = location;
    if (photos.isNotEmpty) data['photos'] = photos;
    if (filter.isNotEmpty) data['filter'] = filter;
    if (trimStart > 0) data['trimStart'] = trimStart;
    if (trimEnd > 0) data['trimEnd'] = trimEnd;
    if (speed != 1) data['speed'] = speed;
    if (rotation != 0) data['rotation'] = rotation;
    if (aspectRatio > 0) data['aspectRatio'] = aspectRatio;
    final resp = await ApiClient.instance.post('/videos', data: data);
    return ShortVideo.fromServerJson(resp.data as Map<String, dynamic>);
  }

  /// 删除自己的视频/照片作品
  static Future<void> deleteVideo(int videoId) async {
    await ApiClient.instance.delete('/videos/$videoId');
  }

  // ──── 点赞 ────

  /// 切换点赞状态，返回最新是否已点赞
  static Future<bool> toggleLike(int videoId) async {
    final resp = await ApiClient.instance.post('/videos/$videoId/like');
    return (resp.data as Map<String, dynamic>)['liked'] as bool;
  }

  /// 查询当前用户是否已点赞
  static Future<bool> isLiked(int videoId) async {
    final resp = await ApiClient.instance.get('/videos/$videoId/like');
    return (resp.data as Map<String, dynamic>)['liked'] as bool;
  }

  /// 批量查询点赞状态
  static Future<Map<int, bool>> batchLiked(List<int> videoIds) async {
    final ids = videoIds.join(',');
    final resp = await ApiClient.instance.get(
      '/videos/liked',
      queryParameters: {'ids': ids},
    );
    final map = <int, bool>{};
    for (final e in (resp.data as Map<String, dynamic>).entries) {
      map[int.parse(e.key)] = e.value as bool;
    }
    return map;
  }

  // ──── 评论 ────

  /// 获取评论列表
  static Future<({List<CommunityComment> items, int total})> fetchComments(
    int videoId, {
    int page = 1,
  }) async {
    final resp = await ApiClient.instance.get(
      '/videos/$videoId/comments',
      queryParameters: {'page': page},
    );
    final items = ((resp.data[0] ?? []) as List)
        .map((e) => _commentFromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: resp.data[1] as int);
  }

  /// 添加评论，返回最新评论
  static Future<CommunityComment> addComment(
    int videoId,
    String content, {
    int? parentId,
    int? replyToId,
  }) async {
    final resp = await ApiClient.instance.post(
      '/videos/$videoId/comments',
      data: {
        'content': content,
        'parentId': ?parentId,
        'replyToId': ?replyToId,
      },
    );
    return _commentFromJson(resp.data as Map<String, dynamic>);
  }

  /// 切换评论点赞，返回最新是否已点赞
  static Future<bool> toggleCommentLike(int videoId, int commentId) async {
    final resp = await ApiClient.instance
        .post('/videos/$videoId/comments/$commentId/like');
    return resp.data['liked'] as bool;
  }

  // ──── 浏览 / 分享 ────

  /// 记录浏览（浏览量 +1）
  static Future<void> recordView(int videoId) async {
    await ApiClient.instance.post('/videos/$videoId/view');
  }

  /// 记录视频浏览历史（需登录，未登录时服务端返回 401 由调用方静默忽略）
  static Future<void> addHistory(int videoId) async {
    await ApiClient.instance.post('/videos/$videoId/history');
  }

  /// 获取我的视频浏览历史（按浏览时间倒序）
  static Future<({List<ShortVideo> items, int total})> fetchHistory({
    int page = 1,
  }) async {
    final resp = await ApiClient.instance.get(
      '/videos/history',
      queryParameters: {'page': page},
    );
    return _parseList(resp.data);
  }

  /// 记录分享（分享数 +1）
  static Future<void> recordShare(int videoId) async {
    await ApiClient.instance.post('/videos/$videoId/share');
  }

  // ──── Helpers ────

  static ({List<ShortVideo> items, int total}) _parseList(dynamic data) {
    final items = ((data[0] ?? []) as List)
        .map((e) => ShortVideo.fromServerJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: data[1] as int);
  }

  /// 服务端评论 → 社区评论模型（author 内嵌作者信息）
  static CommunityComment _commentFromJson(Map<String, dynamic> json) {
    final author = (json['author'] as Map<String, dynamic>?) ?? const {};
    final avatar = (author['avatar'] ?? '') as String;
    final replyToJson = json['replyTo'] as Map<String, dynamic>?;
    return CommunityComment(
      id: (json['id'] as num).toInt(),
      user: CommunityUser(
        id: ((author['id'] ?? json['userId'] ?? 0) as num).toInt(),
        nickname: (author['nickname'] ?? '') as String,
        avatarUrl: avatar.isEmpty ? '' : ChatApi.resolveUrl(avatar),
      ),
      content: (json['content'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      likeCount: (json['likeCount'] ?? 0) as int,
      liked: (json['liked'] ?? false) as bool,
      parentId: (json['parentId'] as num?)?.toInt(),
      replyTo: replyToJson == null
          ? null
          : CommunityUser(
              id: ((replyToJson['id'] ?? json['replyToId'] ?? 0) as num)
                  .toInt(),
              nickname: (replyToJson['nickname'] ?? '') as String,
              avatarUrl: (replyToJson['avatar'] ?? '') as String,
            ),
      replies: ((json['replies'] ?? []) as List)
          .map((e) => _commentFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 提取后端错误信息
  static String messageOf(DioException e) {
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return '请求超时，请检查网络后重试';
    }
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join('，') : m.toString();
    }
    return '网络异常，请稍后再试';
  }
}
