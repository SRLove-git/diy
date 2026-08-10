import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api_config.dart';
import 'live_theme.dart';

/// 实时页面共享组件

/// 价格显示：整数不带小数（68 → 68），非整数保留 1 位小数（9.9 → 9.9）。
String fmtPrice(double value) {
  final v = value.isFinite ? value : 0;
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

class LivePage extends StatelessWidget {
  const LivePage({
    super.key,
    required this.child,
    this.bottomBar,
    this.fullBleed = false,
    this.backgroundColor = LiveColors.bg,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final Widget? bottomBar;
  /// 深色全屏页（Reels / 播放页）：顶部铺满、状态栏图标用浅色。
  final bool fullBleed;
  final Color backgroundColor;
  /// 键盘弹出时是否压缩页面高度。默认 true（Scaffold 默认行为）；
  /// 登录等页面设为 false，键盘直接覆盖在页面之上，避免页面被压缩变小。
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Expanded(child: child),
        ?bottomBar,
      ],
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
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
      // 顶部导航强制白底（去掉 Material 3 的灰色 surfaceTint），
      // 对齐设计稿的白底极简体系。
      backgroundColor: LiveColors.bg,
      surfaceTintColor: Colors.transparent,
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

/// 底部悬浮 Tab（主页/我的），对齐原设计稿的悬浮胶囊样式。
/// 社区 / Reels / 聊天前期暂不开放，已隐藏（保留 5 Tab 设计资源，后续恢复时切回）。
class LiveTabBar extends StatelessWidget {
  const LiveTabBar({super.key, required this.current, this.onTap});

  final int current;
  final ValueChanged<int>? onTap;

  static const _tabs = [
    (Icons.home_outlined, Icons.home, '主页'),
    (Icons.person_outline, Icons.person, '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: 88 + bottomInset,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 62,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 4 + bottomInset),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: LiveColors.bg,
            borderRadius: BorderRadius.circular(31),
            border: Border.all(color: LiveColors.divider, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (i != current) onTap?.call(i);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == current ? _tabs[i].$2 : _tabs[i].$1,
                          size: 22,
                          color: i == current
                              ? LiveColors.textPrimary
                              : LiveColors.textTertiary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tabs[i].$3,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                                i == current ? FontWeight.w700 : FontWeight.w400,
                            color: i == current
                                ? LiveColors.textPrimary
                                : LiveColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
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
          side: BorderSide(color: color.withValues(alpha: 0.35)),
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
              errorBuilder: (_, _, _) => Container(
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
        errorBuilder: (_, _, _) => Container(
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
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.1),
        border: outlined ? Border.all(color: color.withValues(alpha: 0.5)) : null,
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

/// 顶部消息提示：用 Overlay 在页面顶部显示，避免被底部键盘遮挡。
void showLiveSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  final overlay = Overlay.of(context, rootOverlay: false);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TopToast(
      message: message,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  // 延迟一帧再插入：避免在同一帧内既移除旧 route 的 overlay entry、
  // 又插入新的 toast entry。Overlay 的 entry 使用 GlobalKey 管理元素，
  // 同一帧内增删会让退场中的 route 子树与新 entry 争用元素，触发
  // InheritedElement 依赖残留断言（_dependents.isEmpty）。
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!overlay.mounted || entry.mounted) return;
    overlay.insert(entry);
  });
}

/// 顶部浮层提示（自动 2.2s 后消失，带淡入淡出）。
class _TopToast extends StatefulWidget {
  const _TopToast({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      _ctrl.reverse().whenComplete(widget.onDismiss);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _opacity,
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xE6141414),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  // 显式去掉下划线，避免继承到祖先的 underline 装饰
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
