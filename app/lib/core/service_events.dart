import 'dart:async';

/// 服务状态事件：下钟成功后广播预约单 id，
/// 供首页等页面乐观移除「服务中」卡片，无需等待下一次轮询/重新拉取。
class ServiceEvents {
  ServiceEvents._();

  static final StreamController<int> _ended = StreamController<int>.broadcast();

  /// 服务已结束（已下钟）事件流，事件值为预约单 id
  static Stream<int> get ended => _ended.stream;

  /// 广播服务结束，触发首页乐观更新
  static void notifyEnded(int appointmentId) {
    if (!_ended.isClosed) _ended.add(appointmentId);
  }
}
