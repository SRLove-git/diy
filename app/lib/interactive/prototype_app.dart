import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../live/live_router.dart';
import '../live/live_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_store.dart';

/// Think Origin App 入口：go_router 声明式路由，启动时由 redirect 处理登录态。
class PrototypeApp extends StatelessWidget {
  const PrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // LiquidGlassWidgets.wrap：液态玻璃全局配置（无障碍桥接 / 主题解析）。
    // MaterialApp 用户必须传 brightnessResolver，玻璃组件才能跟随主题亮度。
    return LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      child: ListenableBuilder(
        listenable: LocaleStore.instance,
        builder: (context, _) => MaterialApp.router(
          title: 'Think Origin',
          debugShowCheckedModeBanner: false,
          theme: LiveTheme.data,
          // 默认跟随系统语言；设置页可手动切换中文 / English
          locale: LocaleStore.instance.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            // 固定设计稿字号：整体界面已按屏幕缩放，
            // 禁止系统字体缩放改变布局导致文字溢出、按钮变形。
            minScaleFactor: 1.0,
            maxScaleFactor: 1.0,
            child: child!,
          ),
        ),
      ),
    );
  }
}
