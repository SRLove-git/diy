import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_colors.dart';
import 'core/auth_service.dart';
import 'core/chat_service.dart';
import 'features/community/presentation/community_page.dart';
import 'pages/chat/conversation_list_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'widgets/glass_bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 加载 .env（后端 IP 配置），需在首次请求 API 前完成
  await dotenv.load(fileName: '.env');
  runApp(const DiyApp());
  // 冷启动延时 300ms，等原生插件（Keychain）就绪后再恢复登录态
  Future.delayed(const Duration(milliseconds: 300), () {
    AuthService.instance.init();
  });
}

/// 全局主题：对齐《第一阶段UI设计指导》§3 视觉规范
class DiyApp extends StatelessWidget {
  const DiyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIY 手作工坊',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }

  /// 按亮/暗模式构建主题，配色对齐《个人页面设计初稿》颜色规范
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF465FFF),
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF465FFF),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      extensions: [isDark ? AppColors.dark : AppColors.light],
    );
  }
}

/// 登录态门卫：未登录进登录页，已登录进主界面
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) =>
          AuthService.instance.isLoggedIn ? const MainShell() : const LoginPage(),
    );
  }
}

/// 底部 4 Tab：首页 / 发现 / 消息 / 个人主页（玻璃拟态胶囊样式）
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// 页面索引：0 首页 / 1 发现(社区) / 2 消息 / 3 个人主页
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 登录后建立聊天 WebSocket 连接
    ChatService.instance.ensureConnected();
    // 消息 Tab 常驻；导航栏头像点击切到"个人主页"
    _pages = [
      const HomePage(),
      CommunityPage(
        onSwitchTab: (navIndex) => setState(() => _index = navIndex),
      ),
      ConversationListPage(onTapAvatar: () => setState(() => _index = 3)),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: ListenableBuilder(
        listenable: ChatService.instance,
        builder: (context, _) => GlassBottomNav(
          currentIndex: _index,
          onSelect: (i) => setState(() => _index = i),
          chatUnread: ChatService.instance.totalUnread,
        ),
      ),
    );
  }
}
