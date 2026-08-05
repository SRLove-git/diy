import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diy_mobile/features/tiktok_profile/model/tiktok_video_model.dart';
import 'package:diy_mobile/features/tiktok_profile/page/video_profile_page.dart';
import 'package:diy_mobile/features/tiktok_profile/widget/music_marquee.dart';
import 'package:diy_mobile/features/tiktok_profile/widget/video_action_rail.dart';
import 'package:diy_mobile/features/tiktok_profile/widget/video_grid_card.dart';
import 'package:diy_mobile/features/tiktok_profile/widget/video_grid_footer.dart';
import 'package:diy_mobile/features/tiktok_profile/widget/video_info_panel.dart';
import 'package:diy_mobile/pages/short_video_models.dart';

TiktokVideoModel _model({
  int id = 1,
  String title = '手作视频',
  String music = '测试音乐',
  int viewCount = 123,
  int likeCount = 10,
}) =>
    TiktokVideoModel(
      video: ShortVideo(
        id: id,
        authorId: 1,
        user: 'srlovice',
        avatar: '',
        title: title,
        cover: '',
        duration: const Duration(seconds: 12),
        likeCount: likeCount,
        commentCount: 2,
        shareCount: 3,
        viewCount: viewCount,
        followCount: 10,
        tags: const ['手作'],
        music: music,
        videoUrl: 'http://example.com/video.mp4',
      ),
    );

void main() {
  testWidgets('作品墙页面渲染顶部区域（返回/昵称/更多）与骨架屏', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VideoProfilePage(nickname: 'srlovice')),
    );
    // 首帧：顶栏 + 骨架屏
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('srlovice'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsWidgets);
    // 等待网络失败后的错误态（测试环境无后端，展示错误重试）
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('作品加载失败'), findsOneWidget);
  });

  testWidgets('网格卡片展示播放量浮标并响应双击', (tester) async {
    var doubled = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 260,
            child: VideoGridCard(
              item: _model(),
              onTap: () {},
              onDoubleTap: () => doubled++,
            ),
          ),
        ),
      ),
    );
    expect(find.text('123'), findsOneWidget);
    expect(find.text('0:12'), findsOneWidget);
    await tester.tap(find.byType(VideoGridCard));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(VideoGridCard));
    await tester.pump(const Duration(milliseconds: 50));
    expect(doubled, 1);
  });

  testWidgets('右侧操作栏展示五个动作且回调可触发', (tester) async {
    var liked = 0;
    var commented = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VideoActionRail(
            item: _model(),
            onLike: () => liked++,
            onComment: () => commented++,
            onShare: () {},
            onFavorite: () {},
            onMore: () {},
          ),
        ),
      ),
    );
    expect(find.text('10'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('更多'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_outline_rounded));
    expect(liked, 1);
    await tester.tap(find.byIcon(Icons.chat_bubble_rounded));
    expect(commented, 1);
  });

  testWidgets('音乐跑马灯与底部信息面板渲染', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Column(
              children: [
                const MusicMarquee(text: '一首很长的背景音乐名称'),
                VideoInfoPanel(item: _model(), nickname: 'srlovice'),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('@srlovice'), findsOneWidget);
    expect(find.text('手作视频'), findsOneWidget);
    expect(find.text('#手作'), findsOneWidget);
    expect(find.text('一首很长的背景音乐名称'), findsOneWidget);
  });

  testWidgets('列表尾部加载/没有更多状态', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              VideoGridFooter(loading: true, hasMore: true),
              VideoGridFooter(loading: false, hasMore: false),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('没有更多了'), findsOneWidget);
  });
}
