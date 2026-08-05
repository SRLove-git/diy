import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:diy_mobile/features/community/data/mock_community_repository.dart';
import 'package:diy_mobile/features/community/presentation/community_page.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    // 测试环境无 .env 资源，直接注入 API 基址（AppConfig/AuthService 依赖）
    dotenv.testLoad(mergeWith: {'API_BASE_URL': 'http://localhost:3000/api'});

    // 模拟手机竖屏视口（360x780 逻辑像素）
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: CommunityPage(
          onSwitchTab: (_) {},
          repository: MockCommunityRepository(),
        ),
      ),
    );
    // 等 Mock 仓库延迟(450ms) + 入场动画完成
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('频道页渲染：Header / 搜索栏 / 信息流', (WidgetTester tester) async {
    await pumpPage(tester);

    // 顶部 Header：社区标题 + 发布 icon
    expect(find.text('社区'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

    // 搜索栏
    expect(find.text('找频道/找内容'), findsOneWidget);

    // 信息流（首屏可见内容）：首条帖子作者 / 频道标签 / Reaction / 浏览数
    expect(find.text('matthew'), findsWidgets);
    expect(find.textContaining('#芙宁娜的后花园'), findsWidgets);
    expect(find.textContaining('❤️ 爱了 4.4万'), findsWidgets);
    expect(find.textContaining('浏览 5.2万'), findsWidgets);
    // 首条帖子初始为已点赞，显示实心爱心
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
  });

  testWidgets('频道页交互：点赞后图标切换', (WidgetTester tester) async {
    await pumpPage(tester);

    // 第一条帖子初始为已点赞（实心爱心），点击取消点赞
    final likedHeart = find.byIcon(Icons.favorite_rounded).first;
    expect(likedHeart, findsWidgets);
    // 用 alignment 0.5 把卡片滚到视口中间，避免滚到顶部被 AppBar 遮挡
    await Scrollable.ensureVisible(likedHeart.evaluate().single, alignment: 0.5);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(likedHeart);
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
  });
}
