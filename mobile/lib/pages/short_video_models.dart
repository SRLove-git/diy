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
    required this.followCount,
    required this.tags,
    required this.music,
    this.comments = const [],
    this.liked = false,
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

  /// 作者粉丝数
  final int followCount;

  /// 话题标签，如 `#拼豆`
  final List<String> tags;

  /// 配乐名称
  final String music;

  /// 评论列表（评论弹层内展示，本地追加）
  final List<CommunityComment> comments;

  final bool liked;

  ShortVideo copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    List<CommunityComment>? comments,
    bool? liked,
  }) =>
      ShortVideo(
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
        followCount: followCount,
        tags: tags,
        music: music,
        comments: comments ?? this.comments,
        liked: liked ?? this.liked,
      );
}
