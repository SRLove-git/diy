import '../../../pages/short_video_models.dart';

/// 个人主页视频页的数据模型（model 层）
///
/// 在 [ShortVideo]（短视频领域模型，含播放地址 / 点赞 / 评论 / 分享数据）
/// 基础上，补充个人主页作品墙需要的展示字段：
///
/// - 浏览量 [viewCount]：服务端已返回，网格封面「▶ xx」浮标展示；
/// - 收藏状态 [favorited] / 收藏数 [favoriteCount]：视频收藏接口暂未提供，
///   当前先做本地交互状态，后续接入后端时在 Provider 层上报即可。
///
/// 模型保持不可变：所有交互变化都通过 [copyWith] 生成新实例，
/// 由 Provider 统一广播给页面与组件，避免组件各自持有过期状态。
class TiktokVideoModel {
  const TiktokVideoModel({
    required this.video,
    this.favorited = false,
    this.favoriteCount = 0,
  });

  /// 底层短视频领域模型（播放地址、点赞/评论/分享计数、评论列表等）
  final ShortVideo video;

  /// 当前用户是否已收藏（本地交互状态）
  final bool favorited;

  /// 收藏数（本地交互计数）
  final int favoriteCount;

  // ──── 便捷读取：把常用字段直接透传给 UI，组件层无需解包 video ────

  /// 作品 ID（唯一标识，用于列表局部更新）
  int get id => video.id;

  /// 封面图 URL
  String get cover => video.cover;

  /// 作品简介文案
  String get title => video.title;

  /// 话题标签，如 `#拼豆`
  List<String> get tags => video.tags;

  /// 背景音乐名称
  String get music => video.music;

  /// 视频文件 URL（照片作品为空）
  String get videoUrl => video.videoUrl;

  /// 照片作品图片列表（笔记多图轮播；单图/视频作品为空）
  List<String> get photos => video.photos;

  /// 是否照片作品（无视频流，仅封面图）
  bool get isPhoto => video.isPhoto || video.videoUrl.isEmpty;

  /// 视频时长
  Duration get duration => video.duration;

  /// 浏览量（网格封面浮标）
  int get viewCount => video.viewCount;

  /// 点赞数
  int get likeCount => video.likeCount;

  /// 评论数
  int get commentCount => video.commentCount;

  /// 分享数
  int get shareCount => video.shareCount;

  /// 当前用户是否已点赞
  bool get liked => video.liked;

  /// 生成新实例；任一参数为 null 时沿用当前值。
  TiktokVideoModel copyWith({
    ShortVideo? video,
    bool? favorited,
    int? favoriteCount,
    int? viewCount,
  }) =>
      TiktokVideoModel(
        video:
            video ??
            this.video.copyWith(viewCount: viewCount ?? this.viewCount),
        favorited: favorited ?? this.favorited,
        favoriteCount: favoriteCount ?? this.favoriteCount,
      );
}
