import 'dart:async';

/// 个人主页数据变更事件：作品发布成功后广播，
/// 供个人主页自动刷新作品列表，无需用户手动下拉刷新。
class ProfileEvents {
  ProfileEvents._();

  static final StreamController<void> _worksChanged =
      StreamController<void>.broadcast();

  /// 作品数据已变化（新发布/删除）事件流
  static Stream<void> get worksChanged => _worksChanged.stream;

  /// 广播作品已变化，触发个人主页刷新
  static void notifyWorksChanged() {
    if (!_worksChanged.isClosed) _worksChanged.add(null);
  }
}
