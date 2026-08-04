import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'douyin_publish_page.dart';
import 'short_video_models.dart';

/// 抖音风格作品拍摄页面（仅 UI，不实现真实相机功能）
///
/// 布局（Stack + Column + Row，纯 Flutter 组件）：
/// - 顶部：左上白色 X 关闭按钮 + 居中深色「选择音乐」胶囊按钮
/// - 右侧：垂直按钮栏（翻转/闪光灯/设置/动图/灵感跟拍/倒计时/提词器/更多）
/// - 底部：拍摄模式（分段拍/照片/视频）+ 快门区（特效/快门/相册）+ Tab 栏（相机/敬请期待）
class ShootPage extends StatefulWidget {
  const ShootPage({super.key});

  @override
  State<ShootPage> createState() => _ShootPageState();
}

class _ShootPageState extends State<ShootPage> {
  /// 拍摄模式：0=分段拍 1=照片(默认选中) 2=视频
  int _modeIndex = 1;

  /// 底部 Tab：0=相机(默认选中) 1=敬请期待
  int _tabIndex = 0;

  final _picker = ImagePicker();

  static const _white = Colors.white;
  static const _gray = Color(0xFF999999);

  /// 右侧按钮栏（图标 + 文字）
  static const _railItems = [
    (Icons.cameraswitch_rounded, '翻转'),
    (Icons.flash_on_rounded, '闪光灯'),
    (Icons.settings_rounded, '设置'),
    (Icons.auto_awesome_rounded, '动图'),
    (Icons.lightbulb_outline_rounded, '灵感跟拍'),
    (Icons.timer_outlined, '倒计时'),
    (Icons.menu_book_outlined, '提词器'),
    (Icons.more_vert, '更多'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 背景：相机取景器占位（暗色渐变） ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E1E26), Color(0xFF000000)],
              ),
            ),
          ),

          // ── 顶部：关闭按钮 + 选择音乐 ──
          _buildTopBar(),

          // ── 右侧垂直按钮栏 ──
          _buildRightRail(),

          // ── 底部拍摄操作区 + Tab 栏 ──
          _buildBottomArea(),
        ],
      ),
    );
  }

  // ===================== 顶部区域 =====================
  Widget _buildTopBar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 居中：深色圆角「选择音乐」按钮
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_note_rounded, color: _white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '选择音乐',
                    style: TextStyle(color: _white, fontSize: 14),
                  ),
                ],
              ),
            ),
            // 左上角：关闭按钮
            Positioned(
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: _white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== 右侧按钮栏 =====================
  Widget _buildRightRail() {
    return Positioned(
      right: 12,
      top: 110,
      bottom: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final item in _railItems) _railItem(item.$1, item.$2),
        ],
      ),
    );
  }

  Widget _railItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {}, // 仅 UI，功能后续接入
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _white, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: _white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ===================== 底部拍摄操作区 =====================
  Widget _buildBottomArea() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拍摄模式：分段拍 / 照片(选中) / 视频
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _modeLabel('分段拍', 0),
                const SizedBox(width: 30),
                _modeLabel('照片', 1),
                const SizedBox(width: 30),
                _modeLabel('视频', 2),
              ],
            ),
            const SizedBox(height: 22),
            // 特效 | 快门 | 相册
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _sideButton(Icons.auto_awesome, '特效'),
                const SizedBox(width: 46),
                _buildShutter(),
                const SizedBox(width: 46),
                _sideButton(Icons.image_outlined, '相册', onTap: _pickFromAlbum),
              ],
            ),
            const SizedBox(height: 22),
            // 底部 Tab 栏：相机(选中) / 敬请期待
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabLabel('相机', 0),
                const SizedBox(width: 24),
                _tabLabel('敬请期待', 1),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// 拍摄模式文字选项：选中高亮白色，未选中浅灰色
  Widget _modeLabel(String label, int index) {
    final selected = index == _modeIndex;
    return GestureDetector(
      onTap: () => setState(() => _modeIndex = index),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? _white : _gray,
          fontSize: selected ? 16 : 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  /// 底部 Tab 文字选项：选中高亮白色，未选中浅灰色
  Widget _tabLabel(String label, int index) {
    final selected = index == _tabIndex;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? _white : _gray,
          fontSize: selected ? 15 : 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  /// 大圆形快门按钮：外圈粗白圆环 + 内部白色快门；进入作品发布页。
  /// 发布成功后把 [ShortVideo] 结果回传给上一页（短视频信息流）。
  Widget _buildShutter() {
    return GestureDetector(
      onTap: () => _openPublishPage(),
      child: Container(
        width: 78,
        height: 78,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _white, width: 6),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _white,
          ),
        ),
      ),
    );
  }

  /// 相册按钮：从系统相册选择视频后直接进入发布流程
  Future<void> _pickFromAlbum() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    if (!mounted) return;
    await _openPublishPage(initialVideo: file);
  }

  /// 进入作品发布页；若发布成功则携带结果关闭拍摄页
  Future<void> _openPublishPage({XFile? initialVideo}) async {
    final result = await Navigator.push<ShortVideo>(
      context,
      MaterialPageRoute(
        builder: (_) => DouyinPublishPage(initialVideo: initialVideo),
      ),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  /// 快门两侧按钮：方形占位 + 下方文字
  Widget _sideButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(icon, color: _white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: _white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
