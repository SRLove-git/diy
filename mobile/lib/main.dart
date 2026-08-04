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
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

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
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }

  /// 按亮/暗模式构建统一的拾染爱恋视觉系统。
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final palette = isDark ? AppColors.dark : AppColors.light;
    final background = isDark
        ? const Color(0xFF131113)
        : const Color(0xFFFFFBFC);
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: brightness,
      primary: palette.primary,
      onPrimary: Colors.white,
      surface: palette.surface,
      error: palette.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary, size: 23),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          minimumSize: const Size.fromHeight(44),
          side: BorderSide(color: palette.primary.withValues(alpha: 0.45)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.placeholder,
        hintStyle: TextStyle(color: palette.textSecondary),
        labelStyle: TextStyle(color: palette.textSecondary),
        prefixIconColor: palette.textSecondary,
        suffixIconColor: palette.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.danger, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.divider.withValues(alpha: 0.65)),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.divider, thickness: 0.8),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: palette.textSecondary,
        indicatorColor: palette.primary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.placeholder,
        selectedColor: palette.primary.withValues(alpha: 0.14),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: TextStyle(color: palette.textPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3D3539),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
      ),
      extensions: [palette],
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
      builder: (context, _) => AuthService.instance.isLoggedIn
          ? const MainShell()
          : const LoginPage(),
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
    DiscoverPage(onSwitchTab: (navIndex) => setState(() => _index = navIndex)),
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
    const barHeight = 60.0;
    final totalHeight = barHeight + bottom + 0.5; // +0.5 for top border

    return Container(
      height: totalHeight,
      decoration: const BoxDecoration(
        color: Color(0xFAFFFFFF),
        border: Border(top: BorderSide(color: Color(0x14FF718D), width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Color(0x147A4754),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: barHeight,
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded, '首页'),
                _navItem(
                  1,
                  Icons.explore_outlined,
                  Icons.explore_rounded,
                  '社区',
                ),
                _navItem(
                  2,
                  Icons.videocam_outlined,
                  Icons.videocam_rounded,
                  '视频',
                ),
                _navItemWithBadge(
                  3,
                  Icons.chat_bubble_outline_rounded,
                  Icons.chat_bubble_rounded,
                  '消息',
                  unread,
                ),
                _navItem(
                  4,
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  '我的',
                ),
              ],
            ),
          ),
          SizedBox(height: bottom),
        ],
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
    int i,
    IconData outline,
    IconData filled,
    String label,
    int unread,
  ) {
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF718D),
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
