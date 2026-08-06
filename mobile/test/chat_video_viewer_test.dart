import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'package:diy_mobile/pages/chat/chat_video_viewer.dart';

/// 假视频平台：不依赖真实视频，驱动 ChatVideoViewer 的初始化/播放/暂停/seek。
class _FakeVideoPlatform extends VideoPlayerPlatform {
  final StreamController<VideoEvent> _events =
      StreamController<VideoEvent>.broadcast();

  final Duration duration = const Duration(seconds: 4);
  Duration position = Duration.zero;
  final List<Duration> seekCalls = [];
  int _nextId = 0;

  @override
  Future<void> init() async {
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _nextId++;
    Future<void>.delayed(Duration.zero, () {
      _events.add(VideoEvent(
        eventType: VideoEventType.initialized,
        duration: duration,
        size: const Size(640, 360),
      ));
    });
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _events.stream;
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> seekTo(int playerId, Duration target) async {
    seekCalls.add(target);
    position = target;
  }

  @override
  Future<Duration> getPosition(int playerId) async => position;

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.black);
}

void main() {
  testWidgets('暂停显示播放图标，进度条可拖动 seek', (tester) async {
    final fake = _FakeVideoPlatform();
    VideoPlayerPlatform.instance = fake;

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatVideoViewer(url: 'http://fake/video.mp4'),
      ),
    );

    // 等待初始化完成（进度条出现）
    final sliderFinder = find.byType(Slider);
    for (var i = 0; i < 20 && sliderFinder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(sliderFinder, findsOneWidget, reason: '视频初始化后应出现进度条');

    // 自动播放中：不显示播放图标
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);

    // 点击视频暂停 -> 显示居中播放图标
    await tester.tapAt(const Offset(200, 300));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // 拖动进度条 -> 触发 seek（进度从 0:00 变为 0:01+）
    await tester.drag(sliderFinder, const Offset(120, 0));
    await tester.pump();
    expect(fake.seekCalls, isNotEmpty, reason: '拖动进度条应触发 seekTo');
    expect(fake.seekCalls.last, greaterThan(Duration.zero));
    final timeText =
        tester.widget<Text>(find.textContaining('0:0')).data!;
    expect(timeText, isNot('0:00 / 0:04'));

    // 再次点击 -> 继续播放，图标消失
    await tester.tapAt(const Offset(200, 300));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
  });
}
