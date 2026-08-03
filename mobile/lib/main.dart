import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'core/auth_service.dart';
import 'pages/community_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

/// 底部 3 Tab：首页 / 社区 / 我的（悬浮胶囊样式，对齐《个人页面设计初稿》§7）
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = [HomePage(), CommunityPage(), ProfilePage()];

  static const _icons = [
    (outline: Icons.home_outlined, filled: Icons.home),
    (outline: Icons.grid_view_outlined, filled: Icons.grid_view),
    (outline: Icons.person_outline, filled: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(3, (i) {
              final active = _index == i;
              return Expanded(
                child: IconButton(
                  icon: Icon(
                    active ? _icons[i].filled : _icons[i].outline,
                    size: 26,
                  ),
                  color: active ? colors.textPrimary : colors.textSecondary,
                  onPressed: () => setState(() => _index = i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
