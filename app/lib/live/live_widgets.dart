import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api_config.dart';
import 'live_theme.dart';
import 'live_routes.dart';

/// 实时页面共享组件

class LivePage extends StatelessWidget {
  const LivePage({
    super.key,
    required this.child,
    this.bottomBar,
    this.fullBleed = false,
    this.backgroundColor = LiveColors.bg,
  });

  final Widget child;
  final Widget? bottomBar;
  /// 深色全屏页（Reels / 播放页）：顶部铺满、状态栏图标用浅色。
  final bool fullBleed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Expanded(child: child),
        if (bottomBar != null) bottomBar!,
      ],
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      body: fullBleed
          ? AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              child: content,
            )
          : SafeArea(bottom: false, child: content),
    );
  }
}

class LiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LiveAppBar({
    super.key,
    this.title,
    this.actions = const [],
    this.leading,
    this.bottom,
  });

  final String? title;
  final List<Widget> actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(bottom == null ? 52 : 52 + bottom!.preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title == null ? null : Text(title!),
      leading: leading ??
          (Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }
}

/// 底部 5 Tab（主页/社区/Reels/聊天/我的），使用设计稿高亮资源图。
class LiveTabBar extends StatelessWidget {
  const LiveTabBar({super.key, required this.current});

  final int current;

  static const _assets = [
    'assets/divtabwrap-home.png',
    'assets/divtabwrap-community.png',
    'assets/divtabwrap-reels.png',
    'assets/divtabwrap-chat.png',
    'assets/divtabwrap-profile.png',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 88 + bottomInset,
      // Reels 深色导航图底部透明，补成不透明深色整块，与其他页面导航尺寸观感一致
      color: current == 2 ? const Color(0xFF141414) : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_assets[current], fit: BoxFit.fill),
          Row(
            children: List.generate(5, (i) {
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i != current) LiveRoutes.switchTab(context, i);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.height = 52,
    this.color,
    this.textColor = LiveColors.textPrimary,
    this.borderRadius = 14,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final double height;
  final Color? color;
  final Color textColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    // 设计稿按钮为浅色底 + 深色文字；禁用态浅灰
    final bg = color ?? (onTap == null ? LiveColors.card : Colors.white);
    final side = color == null
        ? const BorderSide(color: LiveColors.cardBorder, width: 1)
        : BorderSide.none;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          side: side,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: LiveColors.brand),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  const OutlineButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 52,
    this.color = LiveColors.textPrimary,
  });

  final String label;
  final VoidCallback? onTap;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.35)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.moreLabel,
    this.onMore,
  });

  final String title;
  final String? moreLabel;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: LiveColors.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
          ),
          const Spacer(),
          if (moreLabel != null)
            InkWell(
              onTap: onMore,
              child: Row(
                children: [
                  Text(moreLabel!, style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                  const Icon(Icons.chevron_right, size: 16, color: LiveColors.textSecondary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.url = '',
    this.name = '',
    this.size = 40,
  });

  final String url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.characters.first : '手';
    return ClipOval(
      child: url.isEmpty
          ? Container(
              width: size,
              height: size,
              color: LiveColors.brandLight,
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(color: LiveColors.brand, fontSize: size * 0.42, fontWeight: FontWeight.w600),
              ),
            )
          : Image.network(
              ApiConfig.resolve(url),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                color: LiveColors.brandLight,
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(color: LiveColors.brand, fontSize: size * 0.42, fontWeight: FontWeight.w600),
                ),
              ),
            ),
    );
  }
}

class NetImage extends StatelessWidget {
  const NetImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.radius,
    this.placeholderColor = LiveColors.card,
  });

  final String url;
  final BoxFit fit;
  final double? radius;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (url.isEmpty) {
      inner = Container(
        color: placeholderColor,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: LiveColors.textTertiary, size: 28),
      );
    } else {
      inner = Image.network(
        ApiConfig.resolve(url),
        fit: fit,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : Container(color: placeholderColor),
        errorBuilder: (_, __, ___) => Container(
          color: placeholderColor,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: LiveColors.textTertiary, size: 28),
        ),
      );
    }
    if (radius != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(radius!), child: inner);
    }
    return inner;
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.text = '加载中…'});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: LiveColors.brand),
          ),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: LiveColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 40, color: LiveColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: LiveColors.textSecondary, fontSize: 13),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlineButton(label: '重试', onTap: onRetry, height: 40),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.text = '暂无数据', this.icon = Icons.inbox_outlined});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: LiveColors.textTertiary),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: LiveColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.color = LiveColors.brand, this.outlined = false});

  final String label;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.1),
        border: outlined ? Border.all(color: color.withOpacity(0.5)) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: LiveColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: LiveColors.textSecondary)),
        ],
      ),
    );
  }
}

void showLiveSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// 全屏图片查看（55-作品全屏 / 57-聊天图片）。
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return LivePage(
      backgroundColor: Colors.black,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: InteractiveViewer(
                maxScale: 4,
                child: SizedBox(
                  width: 440,
                  child: NetImage(url: url, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 18, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      if (title != null)
                        Flexible(
                          child: Text(
                            title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
