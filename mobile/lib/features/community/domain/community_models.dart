/// 社区领域模型（频道信息流）
///
/// 与 UI / 数据源解耦：后续接入 API 时仅需替换 data 层实现，
/// 领域模型保持稳定，见 [CommunityRepository]。
library;

/// 媒体类型
enum MediaType {
  image,
  video;

  static MediaType fromName(String? name) =>
      name == 'video' ? MediaType.video : MediaType.image;
}

/// 帖子内单个媒体（图片 / 视频封面）
class MediaItem {
  const MediaItem({
    required this.type,
    required this.url,
    this.aspectRatio = 1,
    this.duration,
  });

  final MediaType type;

  /// 图片 URL 或视频封面 URL
  final String url;

  /// 宽高比（宽/高）。视频按 `> 1.3` 判横屏
  final double aspectRatio;

  /// 视频时长（仅视频有效）
  final Duration? duration;

  /// 是否为横屏视频（宽高比 > 1.3）
  bool get isLandscapeVideo => type == MediaType.video && aspectRatio > 1.3;
}

/// 信息流帖子（频道动态）
class FeedPost {
  const FeedPost({
    required this.id,
    required this.authorId,
    required this.avatar,
    required this.username,
    required this.channelTag,
    required this.content,
    required this.medias,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.viewCount,
    required this.reactions,
    this.previewComments = const [],
    this.liked = false,
  });

  final int id;

  /// 作者的后端用户 ID（关注/私信用）
  final int authorId;

  /// 作者头像 URL（为空时展示渐变首字头像）
  final String avatar;

  /// 作者昵称
  final String username;

  /// 频道标签，如 `#芙宁娜的后花园`
  final String channelTag;

  /// 文案
  final String content;

  /// 媒体列表（图片 / 视频按顺序混排）
  final List<MediaItem> medias;

  final int likeCount;
  final int commentCount;
  final int shareCount;

  /// 浏览数
  final int viewCount;

  /// 互动表情标签，如 `❤️ 爱了 4.4万`
  final List<String> reactions;

  /// 评论预览（评论弹层内展示）
  final List<CommunityComment> previewComments;

  final bool liked;

  FeedPost copyWith({int? likeCount, bool? liked}) => FeedPost(
        id: id,
        authorId: authorId,
        avatar: avatar,
        username: username,
        channelTag: channelTag,
        content: content,
        medias: medias,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount,
        shareCount: shareCount,
        viewCount: viewCount,
        reactions: reactions,
        previewComments: previewComments,
        liked: liked ?? this.liked,
      );
}

/// 社区用户
class CommunityUser {
  const CommunityUser({
    required this.id,
    required this.nickname,
    this.avatarUrl = '',
  });

  final int id;
  final String nickname;

  /// 头像地址；为空时展示渐变首字头像
  final String avatarUrl;

  /// 头像首字符（无头像时的兜底文案），按 Unicode 码点截取以兼容 emoji
  String get initial =>
      nickname.isEmpty ? '?' : String.fromCharCode(nickname.runes.first);
}

/// 评论（信息流卡片内展示 / 评论弹层）
class CommunityComment {
  const CommunityComment({
    required this.user,
    required this.content,
    required this.createdAt,
  });

  final CommunityUser user;
  final String content;
  final String createdAt;
}

/// 相对时间：刚刚 / x分钟前 / x小时前 / x天前 / 日期
String timeAgo(String isoTime, {DateTime? now}) {
  final nowLocal = now ?? DateTime.now();
  DateTime? time;
  try {
    time = DateTime.parse(isoTime).toLocal();
  } catch (_) {
    return isoTime;
  }
  final diff = nowLocal.difference(time);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
  if (diff.inDays < 1) return '${diff.inHours}小时前';
  if (diff.inDays < 7) return '${diff.inDays}天前';
  final m = '${time.month}月${time.day}日';
  return time.year == nowLocal.year ? m : '${time.year}年$m';
}

/// 数量格式化：5.2万 / 462 / 1.2千
String formatCount(int n) {
  if (n >= 10000) {
    final v = n / 10000;
    final s = v >= 100 ? v.round().toString() : v.toStringAsFixed(1);
    return '$s万';
  }
  if (n >= 1000) {
    final v = n / 1000;
    final s = v >= 100 ? v.round().toString() : v.toStringAsFixed(1);
    return '$s千';
  }
  return '$n';
}
