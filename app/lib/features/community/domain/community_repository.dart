import 'community_models.dart';

/// 社区数据仓库抽象接口
///
/// 页面只依赖该抽象，不感知数据来源：
/// 当前接入真实后端实现 [ApiCommunityRepository]；
/// 本地联调时可临时替换为 [MockCommunityRepository]。
abstract interface class CommunityRepository {
  /// 信息流分页拉取
  Future<List<FeedPost>> fetchFeed({int page = 1, int pageSize = 10});

  /// 帖子评论列表
  Future<List<CommunityComment>> fetchComments(int postId);

  /// 切换点赞状态，返回最新是否已点赞
  Future<bool> toggleLike(int postId);
}
