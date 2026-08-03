import 'community_models.dart';

/// 社区数据仓库抽象接口
///
/// 页面只依赖该抽象，不感知数据来源：
/// 当前接入 [MockCommunityRepository] 演示，后续接入后端时
/// 新建 `ApiCommunityRepository` 实现同一接口即可无缝替换。
abstract interface class CommunityRepository {
  /// 信息流分页拉取
  Future<List<FeedPost>> fetchFeed({int page = 1, int pageSize = 10});

  /// 帖子评论列表
  Future<List<CommunityComment>> fetchComments(int postId);

  /// 切换点赞状态，返回最新是否已点赞
  Future<bool> toggleLike(int postId);
}
