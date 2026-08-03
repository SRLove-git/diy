import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'core/app_colors.dart';
import 'core/auth_service.dart';
import 'core/chat_service.dart';
import 'features/community/presentation/community_page.dart';
import 'pages/chat/conversation_list_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await LiquidGlassWidgets.initialize();

  // 透明状态栏
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(LiquidGlassWidgets.wrap(
    child: const DiyApp(),
  ));
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

  /// 按亮/暗模式构建主题，配色对齐首页年轻化风格
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FC);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF6B6B),
        brightness: brightness,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: isDark ? const Color(0xFFF0F0F5) : const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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

/// 底部 4 Tab：首页 / 发现 / 消息 / 个人主页（液态玻璃样式）
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    ChatService.instance.ensureConnected();
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
    final colors = AppColors.of(context);

    return GlassScaffold(
      extendBody: true,
      statusBarStyle: GlassStatusBarStyle.none,
      backgroundColor: colors.surface,
      body: IndexedStack(index: _index, children: _pages),
      bottomBar: ListenableBuilder(
        listenable: ChatService.instance,
        builder: (context, _) {
          final unread = ChatService.instance.totalUnread;
          return GlassTabBar.bottom(
            selectedIndex: _index,
            onTabSelected: (i) => setState(() => _index = i),
            unselectedLabelColor: const Color(0xFF9A9AA4),
            selectedLabelColor: colors.primary,
            tabs: [
              GlassTab(
                icon: _icon(0, Icons.home_outlined, Icons.home_rounded),
                label: '首页',
              ),
              GlassTab(
                icon: _icon(1, Icons.explore_outlined, Icons.explore_rounded),
                label: '发现',
              ),
              GlassTab(
                icon: unread > 0
                    ? GlassBadge(
                        count: unread,
                        child: _icon(
                            2, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
                      )
                    : _icon(2, Icons.chat_bubble_outline_rounded,
                        Icons.chat_bubble_rounded),
                label: '消息',
              ),
              GlassTab(
                icon: _icon(
                    3, Icons.person_outline_rounded, Icons.person_rounded),
                label: '个人',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _icon(int i, IconData outline, IconData filled) {
    return Icon(_index == i ? filled : outline, size: 22);
  }
}
