import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_colors.dart';
import 'core/auth_service.dart';
import 'core/chat_service.dart';
import 'features/community/presentation/discover/discover_page.dart';
import 'pages/chat/conversation_list_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/short_video_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // 透明状态栏，图标亮度跟随系统
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(const DiyApp());
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

/// 底部 5 Tab：首页 / 社区 / 视频 / 消息 / 我的（iOS 风格）
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // iOS 风格底部导航主色
  static const _selectedColor = Color(0xFFFF718D);
  static const _unselectedColor = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    ChatService.instance.ensureConnected();
  }

  List<Widget> get _pages => [
        const HomePage(),
        DiscoverPage(
          onSwitchTab: (navIndex) => setState(() => _index = navIndex),
        ),
        ShortVideoPage(active: _index == 2),
        ConversationListPage(onTapAvatar: () => setState(() => _index = 4)),
        const ProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFFBFC),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: ListenableBuilder(
        listenable: ChatService.instance,
        builder: (context, _) {
          final unread = ChatService.instance.totalUnread;
          return _buildBottomBar(unread);
        },
      ),
    );
  }

  Widget _buildBottomBar(int unread) {
    final bottom = MediaQuery.of(context).padding.bottom;
    const barHeight = 56.0;
    final totalHeight = barHeight + bottom + 0.5; // +0.5 for top border

    return Container(
      height: totalHeight,
      decoration: const BoxDecoration(
        color: Color(0xF2FFFBFC),
        border: Border(
          top: BorderSide(color: Color(0x1A333333), width: 0.5),
        ),
      ),
      child: ClipRect(
        child: Column(
        children: [
          SizedBox(
            height: barHeight,
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded, '首页'),
                _navItem(1, Icons.explore_outlined, Icons.explore_rounded, '社区'),
                _navItem(2, Icons.videocam_outlined, Icons.videocam_rounded, '视频'),
                _navItemWithBadge(
                  3,
                  Icons.chat_bubble_outline_rounded,
                  Icons.chat_bubble_rounded,
                  '消息',
                  unread,
                ),
                _navItem(4, Icons.person_outline_rounded, Icons.person_rounded, '我的'),
              ],
            ),
          ),
          SizedBox(height: bottom),
        ],
      ),
      ),
    );
  }

  Widget _navItem(int i, IconData outline, IconData filled, String label) {
    final selected = _index == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? filled : outline,
              size: 22,
              color: selected ? _selectedColor : _unselectedColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? _selectedColor : _unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItemWithBadge(
      int i, IconData outline, IconData filled, String label, int unread) {
    final selected = _index == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? filled : outline,
                  size: 22,
                  color: selected ? _selectedColor : _unselectedColor,
                ),
                if (unread > 0)
                  Positioned(
                    top: -4,
                    right: -12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? _selectedColor : _unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
