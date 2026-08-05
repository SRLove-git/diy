import 'package:flutter/foundation.dart';

import '../../../core/video_api.dart';
import '../../../pages/short_video_models.dart';
import '../model/tiktok_video_model.dart';

/// 个人主页视频列表的 Provider（状态管理层）
///
/// 负责作品墙数据的加载 / 下拉刷新 / 上拉分页，以及点赞、收藏、浏览
/// 等交互状态的管理。页面通过 `Provider` / `Consumer` 订阅，
/// 播放页通过传入的同一个实例把互动结果同步回作品墙。
///
/// 数据源：
/// - [userId] 为空 → 拉取当前登录用户自己的作品（`VideoApi.fetchMine`）；
/// - [userId] 非空 → 拉取指定作者的作品（`VideoApi.fetchByUser`）。
class ProfileVideosController extends ChangeNotifier {
  ProfileVideosController({this.userId});

  /// 作者用户 ID；空表示当前登录用户
  final int? userId;

  /// 作品列表（首页数据；加载/刷新后整体替换，分页时追加）
  List<TiktokVideoModel> videos = [];

  bool _loading = false;

  /// 首页加载中（展示骨架屏）
  bool get loading => _loading;

  bool _loadingMore = false;

  /// 上拉分页加载中（列表尾部展示转圈）
  bool get loadingMore => _loadingMore;

  bool _hasMore = true;

  /// 是否还有下一页
  bool get hasMore => _hasMore;

  String? _error;

  /// 首页加载失败原因（列表为空时展示错误态）
  String? get error => _error;

  int _page = 1;

  /// 首次加载 / 下拉刷新
  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _fetch(page: 1);
      videos = [
        for (final v in r.items) TiktokVideoModel(video: v),
      ];
      _page = 1;
      _hasMore = r.total > videos.length;
    } catch (e) {
      _error = '加载失败，请稍后重试';
      debugPrint('ProfileVideosController.refresh: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 上拉分页加载更多（尾帧触发，见 VideoProfilePage 的滚动监听）
  Future<void> loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final r = await _fetch(page: _page + 1);
      videos = [
        ...videos,
        for (final v in r.items) TiktokVideoModel(video: v),
      ];
      _page += 1;
      _hasMore = r.total > videos.length;
    } catch (e) {
      debugPrint('ProfileVideosController.loadMore: $e');
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<({List<ShortVideo> items, int total})> _fetch({required int page}) {
    final id = userId;
    return id == null
        ? VideoApi.fetchMine(page: page)
        : VideoApi.fetchByUser(id, page: page);
  }

  // ──── 交互状态 ────

  /// 按 ID 查找当前列表中的作品
  TiktokVideoModel? byId(int id) {
    for (final v in videos) {
      if (v.id == id) return v;
    }
    return null;
  }

  void _replace(int id, TiktokVideoModel next) {
    final idx = videos.indexWhere((v) => v.id == id);
    if (idx < 0) return;
    videos = [
      for (var i = 0; i < videos.length; i++)
        if (i == idx) next else videos[i],
    ];
    notifyListeners();
  }

  /// 点赞/取消点赞：先乐观更新 UI，再同步服务端，失败回滚。
  Future<void> toggleLike(TiktokVideoModel item) async {
    final target = !item.liked;
    _replace(
      item.id,
      item.copyWith(
        video: item.video.copyWith(
          liked: target,
          likeCount: item.likeCount + (target ? 1 : -1),
        ),
      ),
    );
    try {
      final serverLiked = await VideoApi.toggleLike(item.id);
      final latest = byId(item.id);
      if (latest == null || serverLiked == latest.liked) return;
      // 服务端结果与本地不一致时，以服务端为准修正
      _replace(
        latest.id,
        latest.copyWith(
          video: latest.video.copyWith(
            liked: serverLiked,
            likeCount: latest.likeCount + (serverLiked ? 1 : -1),
          ),
        ),
      );
    } catch (e) {
      debugPrint('ProfileVideosController.toggleLike: $e');
      // 请求失败回滚到初始状态
      final latest = byId(item.id);
      if (latest != null) _replace(latest.id, item);
    }
  }

  /// 收藏/取消收藏：视频收藏接口暂未提供，先维护本地状态；
  /// 接入后端后在此处上报即可。
  Future<void> toggleFavorite(TiktokVideoModel item) async {
    final target = !item.favorited;
    _replace(
      item.id,
      item.copyWith(
        favorited: target,
        favoriteCount: item.favoriteCount + (target ? 1 : -1),
      ),
    );
  }

  /// 记录一次浏览：本地浏览量 +1 并上报服务端（失败静默）。
  /// 由播放页在切换到当前页时调用。
  void recordView(TiktokVideoModel item) {
    final latest = byId(item.id) ?? item;
    _replace(latest.id, latest.copyWith(viewCount: latest.viewCount + 1));
    VideoApi.recordView(item.id).catchError((_) {});
  }

  /// 播放页回调：把播放页内更新的作品同步回作品墙（点赞/评论/收藏等）
  void syncItem(TiktokVideoModel updated) {
    if (byId(updated.id) == null) return;
    _replace(updated.id, updated);
  }
}
