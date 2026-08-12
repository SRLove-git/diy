import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'api_config.dart';
import 'auth_store.dart';
import 'chat_services.dart';
import 'models.dart';
import 'services.dart';

/// 实时推送（WebSocket）：预约状态变更（店员核销 / 上钟 / 下钟）即时通知，
/// 平台通知（点赞/评论/关注/系统消息）即时刷新未读角标，
/// 首页无需轮询 / 手动刷新即可更新。
class RealtimeService {
  RealtimeService._();

  static final RealtimeService instance = RealtimeService._();

  WebSocket? _ws;
  Timer? _reconnectTimer;
  bool _manualClose = false;
  int _reconnectDelay = 1;

  void start() {
    _manualClose = false;
    if (_ws != null &&
        (_ws!.readyState == WebSocket.open ||
            _ws!.readyState == WebSocket.connecting)) {
      return;
    }
    _connect();
  }

  void stop() {
    _manualClose = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _ws?.close();
    _ws = null;
  }

  Future<void> _connect() async {
    final token = AuthStore.instance.accessToken;
    if (token == null || token.isEmpty || _manualClose) return;
    try {
      final ws = await WebSocket.connect('${ApiConfig.wsUrl}?token=$token');
      if (_manualClose) {
        ws.close();
        return;
      }
      _ws = ws;
      _reconnectDelay = 1;
      ws.listen(
        _handle,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_manualClose) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), _connect);
    _reconnectDelay = (_reconnectDelay * 2).clamp(1, 30);
  }

  void _handle(dynamic raw) {
    try {
      final map = jsonDecode(raw.toString());
      if (map is! Map<String, dynamic>) return;
      switch (map['type']) {
        case 'appointment':
          final appt = map['appointment'];
          if (appt is Map<String, dynamic>) {
            HomeOrdersRefresh.instance.refresh(Appointment.fromJson(appt));
          }
          break;
        case 'notification':
          // 平台通知已发送：立即刷新首页未读角标（拉取失败静默）
          unawaited(
            NotificationService.instance.unreadCount().catchError((_) => 0),
          );
          break;
      }
    } catch (_) {
      // 解析失败忽略（聊天帧为 msgpack 二进制，非 JSON）
    }
  }
}
