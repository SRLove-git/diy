import '../../../core/chat_api.dart';
import '../../../core/post_api.dart';
import '../domain/community_models.dart';
import '../domain/community_repository.dart';

/// 基于真实 API 的社区仓库实现
///
/// 将后端 [PostApi] 返回的 [Post] 映射为领域模型 [FeedPost]，
/// 实现 [CommunityRepository] 接口，可直接注入 [CommunityPage]。
class ApiCommunityRepository implements CommunityRepository {
  @override
  Future<List<FeedPost>> fetchFeed({int page = 1, int pageSize = 10}) async {
    final result = await PostApi.fetchLatest(page: page);
    final items = result.items;
    final postIds = items.map((p) => p.id).toList();

    // 批量拉取点赞状态（自动忽略未登录错误）
    Map<int, bool> likedMap = {};
    try {
      likedMap = await PostApi.batchLiked(postIds);
    } catch (_) {
      // 未登录或网络异常时忽略
    }

    return items.map((p) => _toFeedPost(p, likedMap[p.id] ?? false)).toList();
  }

  @override
  Future<List<CommunityComment>> fetchComments(int postId) async {
    try {
      final result = await PostApi.fetchComments(postId, page: 1);
      return result.items.map(_toCommunityComment).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> toggleLike(int postId) async {
    return PostApi.toggleLike(postId);
  }

  // ──── 模型映射 ────

  /// 将后端 [Post] 映射为领域模型 [FeedPost]
  static FeedPost _toFeedPost(Post p, bool liked) {
    // 优先使用 medias（新格式），回退到 images（旧格式）
    final List<MediaItem> medias = p.medias.isNotEmpty
        ? p.medias
            .map((m) => MediaItem(
                  type: m.type == 'video' ? MediaType.video : MediaType.image,
                  url: ChatApi.resolveUrl(m.url),
                  aspectRatio: m.aspectRatio ?? 1,
                  duration: m.duration != null
                      ? Duration(seconds: m.duration!.round())
                      : null,
                ))
            .toList()
        : p.images
            .map((url) => MediaItem(
                  type: MediaType.image,
                  url: ChatApi.resolveUrl(url),
                  aspectRatio: 4 / 5,
                ))
            .toList();

    return FeedPost(
      id: p.id,
      authorId: p.userId,
      avatar: p.author?.avatar ?? '',
      username: p.author?.nickname ?? '用户 #${p.userId}',
      channelTag: p.channelTag.isNotEmpty ? p.channelTag : '#社区',
      content: p.content,
      medias: medias,
      likeCount: p.likeCount,
      commentCount: p.commentCount,
      shareCount: p.shareCount,
      viewCount: p.viewCount,
      reactions: _buildReactions(p),
      liked: liked,
    );
  }

  /// 将后端 [Comment] 映射为领域模型 [CommunityComment]
  static CommunityComment _toCommunityComment(Comment c) {
    return CommunityComment(
      user: CommunityUser(
        id: c.userId,
        nickname: c.author?.nickname ?? '用户 #${c.userId}',
        avatarUrl: c.author?.avatar ?? '',
      ),
      content: c.content,
      createdAt: c.createdAt,
    );
  }

  /// 根据互动数据生成 Reaction 标签（模拟）
  static List<String> _buildReactions(Post p) {
    final list = <String>[];
    if (p.likeCount > 0) {
      list.add('❤️ 爱了 ${formatCount(p.likeCount)}');
    }
    if (p.commentCount > 10) {
      list.add('🔥 热门');
    }
    return list;
  }
}
