import '../domain/community_models.dart';
import '../domain/community_repository.dart';
import 'mock_community_datasource.dart';

/// Mock 仓库实现
///
/// 模拟网络延迟与本地交互状态（点赞），用于 UI 联调演示。
/// 后续接入后端：新建 `ApiCommunityRepository implements CommunityRepository`，
/// 将 `CommunityPage` 依赖注入处替换即可，页面代码无需改动。
class MockCommunityRepository implements CommunityRepository {
  /// 模拟网络延迟，让骨架/加载态可见
  static const _latency = Duration(milliseconds: 450);

  /// 帖子级点赞状态，模拟服务端持久化
  final Map<int, bool> _liked = {};

  FeedPost? _byId(int postId) {
    for (final p in MockCommunityDataSource.posts) {
      if (p.id == postId) return p;
    }
    return null;
  }

  Future<T> _delay<T>(T value) => Future.delayed(_latency, () => value);

  @override
  Future<List<FeedPost>> fetchFeed({int page = 1, int pageSize = 10}) {
    final source = MockCommunityDataSource.posts;
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, source.length);
    final slice = source.sublist(start, end).map((p) {
      return p.copyWith(liked: _liked[p.id] ?? p.liked);
    }).toList();
    return _delay(slice);
  }

  @override
  Future<List<CommunityComment>> fetchComments(int postId) =>
      _delay(List.of(_byId(postId)?.previewComments ?? const []));

  @override
  Future<bool> toggleLike(int postId) {
    final current = _liked[postId] ?? _byId(postId)?.liked ?? false;
    final next = !current;
    _liked[postId] = next;
    return _delay(next);
  }
}
