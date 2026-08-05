import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:diy_mobile/core/auth_service.dart';
import 'package:diy_mobile/core/chat_service.dart';
import 'package:diy_mobile/pages/chat/chat_page.dart';
import 'package:diy_mobile/pages/chat/conversation_list_page.dart';
import 'package:diy_mobile/pages/community/user_profile_page.dart';

/// 回归测试：聊天页点击对方头像应跳转到用户主页。
/// 依赖本机开发后端（localhost:3000）与测试账号 13800000002。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// 复用已保存的登录态；没有或失效时才走验证码登录（兼容 60 秒限频）
  Future<void> ensureLoggedIn() async {
    await AuthService.instance.init();
    if (AuthService.instance.isLoggedIn) return;
    String? code;
    for (var i = 0; i < 3; i++) {
      try {
        code = await AuthService.instance.sendCode('13800000002');
        break;
      } catch (_) {
        await Future<void>.delayed(const Duration(seconds: 65));
      }
    }
    expect(code, isNotNull, reason: '开发环境应返回验证码');
    await AuthService.instance.login('13800000002', code!);
  }

  testWidgets('聊天页点击头像跳转用户主页', (tester) async {
    // 加载 .env，使 API 基址与真机运行一致
    await dotenv.load(fileName: '.env');

    // 1. 用开发环境短信验证码登录测试账号（13800000002，对应后端用户 33）
    await ensureLoggedIn();
    expect(AuthService.instance.isLoggedIn, isTrue);

    // 2. 找到与用户 32（13800000001）的会话
    ChatService.instance.ensureConnected();
    await ChatService.instance.refreshConversations();
    final conv = ChatService.instance.conversations
        .where((c) => c.peerId == 32)
        .first;
    expect(conv.peerNickname, isNotEmpty);

    // 3. 进入聊天页
    await tester.pumpWidget(
      MaterialApp(home: ChatPage(conversation: conv)),
    );
    // 等待消息加载完成（本地缓存 + 服务端同步）
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byType(ChatPage), findsOneWidget);

    // 4. 找到对方头像（文字消息行内唯一的网络头像）并点击
    final avatarFinder = find.descendant(
      of: find.byType(ChatPage),
      matching: find.byType(Image),
    );
    expect(avatarFinder, findsWidgets, reason: '消息行应渲染对方头像');
    await tester.tap(avatarFinder.first);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // 5. 断言已进入用户主页
    expect(find.byType(UserProfilePage), findsOneWidget);
  });

  testWidgets('聊天列表点击会话头像跳转用户主页', (tester) async {
    await dotenv.load(fileName: '.env');

    // 登录并加载会话列表
    await ensureLoggedIn();
    ChatService.instance.ensureConnected();
    await ChatService.instance.refreshConversations();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ConversationListPage()),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // 点击「测试用户32」所在行左侧的圆形头像（行内 52x52，昵称从约 x=80 开始）
    final nameRect = tester.getRect(find.text('测试用户32'));
    await tester.tapAt(Offset(nameRect.left - 60, nameRect.center.dy));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byType(UserProfilePage), findsOneWidget);
  });
}
