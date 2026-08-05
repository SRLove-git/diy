import 'package:flutter/material.dart';

/// 全局路由观察者。
///
/// 用于感知当前页面被新路由覆盖 / 恢复：例如视频页被发布页盖住时暂停播放，
/// 返回视频页后再按进入前的播放状态恢复。
final RouteObserver<ModalRoute<dynamic>> appRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();
