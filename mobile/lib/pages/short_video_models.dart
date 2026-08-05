import '../core/chat_api.dart';
import '../features/community/domain/community_models.dart';

/// 短视频领域模型（信息流单条）
///
/// 与 UI / 数据源解耦，模型保持稳定；评论复用社区通用
/// [CommunityComment] / [CommunityUser]。
class ShortVideo {
  const ShortVideo({
    required this.id,
    required this.authorId,
    required this.user,
    required this.avatar,
    required this.title,
    required this.cover,
    required this.duration,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    this.viewCount = 0,
    required this.followCount,
    required this.tags,
    required this.music,
    this.comments = const [],
    this.liked = false,
    this.videoUrl = '',
    this.isPhoto = false,
    this.photos = const [],
    this.filterId = '',
    this.trimStart = 0,
    this.trimEnd = 0,
    this.speed = 1.0,
    this.rotation = 0,
    this.aspectRatio = 0,
  });

  final int id;

  /// 作者的后端用户 ID（关注用）
  final int authorId;

  /// 作者昵称
  final String user;

  /// 作者头像 URL
  final String avatar;

  /// 视频标题 / 文案
  final String title;

  /// 视频封面 URL（Mock 播放：封面静态图 + AnimationController 模拟进度）
  final String cover;

  /// 视频时长
  final Duration duration;

  final int likeCount;
  final int commentCount;
  final int shareCount;

  /// 浏览数（服务端 videos 模块返回；个人主页网格封面浮标展示）
  final int viewCount;

  /// 作者粉丝数
  final int followCount;

  /// 话题标签，如 `#拼豆`
  final List<String> tags;

  /// 配乐名称
  final String music;

  /// 评论列表（评论弹层内展示，本地追加）
  final List<CommunityComment> comments;

  final bool liked;

  /// 视频文件 URL（已解析为绝对地址；照片作品为空）
  final String videoUrl;

  /// 照片作品（无视频流，仅封面照片配背景音乐）
  final bool isPhoto;

  /// 照片作品图片列表（已解析为绝对地址；单图/视频作品为空）
  final List<String> photos;

  /// 编辑滤镜 ID（'' 原图），见 PhotoFilter
  final String filterId;

  /// 视频裁剪起点（秒，0 表示未裁剪）
  final double trimStart;

  /// 视频裁剪终点（秒，0 表示未裁剪）
  final double trimEnd;

  /// 播放倍速（0.5 ~ 2）
  final double speed;

  /// 照片顺时针旋转 90° 次数（0/1/2/3）
  final int rotation;

  /// 视频展示画幅（width / height）；0 表示使用视频文件原始画幅。
  final double aspectRatio;

  /// 从服务端信息流条目解析（对应 videos 模块 VideoItem 响应）。
  /// 头像/封面兼容 http(s) 与 /uploads/ 相对路径，统一解析为绝对地址。
  factory ShortVideo.fromServerJson(Map<String, dynamic> json) {
    final author = (json['author'] as Map<String, dynamic>?) ?? const {};
    final avatar = (author['avatar'] ?? '') as String;
    final cover = (json['cover'] ?? '') as String;
    final rawVideo = (json['videoUrl'] ?? '') as String;
    return ShortVideo(
      id: json['id'] as int,
      authorId: ((json['userId'] ?? author['id']) as num).toInt(),
      user: (author['nickname'] ?? '') as String,
      avatar: avatar.isEmpty ? '' : ChatApi.resolveUrl(avatar),
      title: (json['title'] ?? '') as String,
      cover: cover.isEmpty ? '' : ChatApi.resolveUrl(cover),
      videoUrl: rawVideo.isEmpty ? '' : ChatApi.resolveUrl(rawVideo),
      duration: Duration(seconds: ((json['duration'] ?? 0) as num).toInt()),
      likeCount: ((json['likeCount'] ?? 0) as num).toInt(),
      commentCount: ((json['commentCount'] ?? 0) as num).toInt(),
      shareCount: ((json['shareCount'] ?? 0) as num).toInt(),
      viewCount: ((json['viewCount'] ?? 0) as num).toInt(),
      followCount: ((author['followCount'] ?? 0) as num).toInt(),
      tags: ((json['tags'] ?? []) as List).map((e) => e.toString()).toList(),
      music: (json['music'] ?? '') as String,
      liked: (json['liked'] ?? false) as bool,
      isPhoto: ((json['videoUrl'] ?? '') as String).isEmpty,
      photos: ((json['photos'] ?? []) as List)
          .map((e) => ChatApi.resolveUrl(e.toString()))
          .toList(),
      filterId: (json['filter'] ?? '') as String,
      trimStart: ((json['trimStart'] ?? 0) as num).toDouble(),
      trimEnd: ((json['trimEnd'] ?? 0) as num).toDouble(),
      speed: ((json['speed'] ?? 1) as num).toDouble(),
      rotation: ((json['rotation'] ?? 0) as num).toInt(),
      aspectRatio: ((json['aspectRatio'] ?? 0) as num).toDouble(),
    );
  }

  ShortVideo copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? viewCount,
    List<CommunityComment>? comments,
    bool? liked,
  }) => ShortVideo(
    id: id,
    authorId: authorId,
    user: user,
    avatar: avatar,
    title: title,
    cover: cover,
    duration: duration,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    shareCount: shareCount ?? this.shareCount,
    viewCount: viewCount ?? this.viewCount,
    followCount: followCount,
    tags: tags,
    music: music,
    comments: comments ?? this.comments,
    liked: liked ?? this.liked,
    videoUrl: videoUrl,
    isPhoto: isPhoto,
    photos: photos,
    filterId: filterId,
    trimStart: trimStart,
    trimEnd: trimEnd,
    speed: speed,
    rotation: rotation,
    aspectRatio: aspectRatio,
  );
}
