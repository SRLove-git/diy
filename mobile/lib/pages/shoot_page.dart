import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/media_composer.dart';
import '../core/music_api.dart';
import '../core/video_layout.dart';
import 'douyin_publish_page.dart';
import 'media_picker_page.dart';
import 'music_picker_sheet.dart';
import 'post_edit_page.dart';
import 'short_video_models.dart';

/// 抖音风格作品拍摄页面
///
/// 布局（Stack + Column + Row，纯 Flutter 组件）：
/// - 顶部：左上白色 X 关闭按钮 + 居中「选择音乐」胶囊按钮（接入后端曲库）
/// - 背景：真实相机预览（无相机设备如模拟器时降级为暗色渐变占位）
/// - 右侧：垂直按钮栏（翻转/闪光灯/设置）
/// - 底部：拍摄模式（照片/视频）+ 快门区（快门/相册）+ Tab 栏（相机/敬请期待）
///
/// 功能：视频模式真实录制 → 发布页上传发布；照片模式拍照 → 社区发帖；
/// 相册模式支持图片/视频混选：纯图片发布笔记，含视频则按选择顺序合成后发布；
/// 翻转/闪光灯实时控制相机。
class ShootPage extends StatefulWidget {
  const ShootPage({super.key});

  @override
  State<ShootPage> createState() => _ShootPageState();
}

class _ShootPageState extends State<ShootPage> with WidgetsBindingObserver {
  /// 拍摄模式：0=照片(默认选中) 1=视频
  int _modeIndex = 0;

  /// 底部 Tab：0=相机(默认选中) 1=敬请期待
  int _tabIndex = 0;

  // ── 相机状态 ──
  CameraController? _camera;
  bool _cameraReady = false;
  bool _switchingCamera = false;
  bool _recording = false;
  final Stopwatch _recTimer = Stopwatch();

  /// 录制计时刷新器（每秒触发 setState 让顶部计时走起来）
  Timer? _recTicker;

  bool _useFront = false;
  FlashMode _flash = FlashMode.auto;
  VideoAspectPreset _aspectPreset = VideoAspectPreset.portrait;

  /// 已选配乐（拍摄页顶部展示，发布时写入视频）
  MusicItem? _music;

  static const _white = Colors.white;
  static const _gray = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    // 拍摄页整套布局（预览画幅、右侧按钮栏、底部操作区）按竖屏设计：
    // 无论系统是否开启竖屏锁定，进入页面都强制竖屏，避免横屏时画幅与控件错乱。
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    // 离开拍摄页后恢复系统默认支持的其它方向
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    WidgetsBinding.instance.removeObserver(this);
    _recTicker?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 相机在后台必须释放，回前台重新初始化
    if (state == AppLifecycleState.inactive) {
      _recTicker?.cancel();
      _recTicker = null;
      _camera?.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  /// 初始化相机（按当前镜头方向）；无可用相机时降级为占位背景
  Future<void> _initCamera() async {
    // 防止快速连续点击翻转导致多个初始化并发、状态错乱
    if (_switchingCamera) return;
    _switchingCamera = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() => _cameraReady = false);
        return;
      }
      final target = _useFront
          ? cameras.indexWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
            )
          : cameras.indexWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
            );

      // 先释放旧相机，避免新旧两个 CaptureSession 同时占用摄像头，
      // 否则新控制器 initialize() 会挂起或失败，表现为“翻转后卡住”。
      final old = _camera;
      if (old != null) {
        if (mounted) {
          setState(() {
            _camera = null;
            _cameraReady = false;
          });
        }
        try {
          await old.dispose();
        } catch (_) {
          // 旧相机释放失败不阻塞新相机初始化
        }
      }
      if (!mounted) return;

      final controller = CameraController(
        cameras[target >= 0 ? target : 0],
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _cameraReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cameraReady = false);
    } finally {
      _switchingCamera = false;
    }
  }

  /// 翻转前后摄像头
  Future<void> _switchCamera() async {
    if (_recording) {
      _toast('录制中无法切换镜头');
      return;
    }
    if (_switchingCamera) return;
    setState(() => _useFront = !_useFront);
    await _initCamera();
  }

  /// 循环切换闪光灯：关 → 自动 → 常亮
  Future<void> _cycleFlash() async {
    final c = _camera;
    if (c == null || !c.value.isInitialized) {
      _toast('当前设备无相机');
      return;
    }
    const modes = [FlashMode.off, FlashMode.auto, FlashMode.torch];
    final next = modes[(modes.indexOf(_flash) + 1) % modes.length];
    try {
      await c.setFlashMode(next);
    } catch (_) {
      // 部分机型不支持指定闪光模式，静默
    }
    if (mounted) setState(() => _flash = next);
  }

  // ===================== 拍摄动作 =====================

  Future<void> _onShutter() async {
    if (_modeIndex == 0) {
      await _takePhoto();
    } else if (_recording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final c = _camera;
    if (c == null || !c.value.isInitialized) {
      // 无相机设备（模拟器）：改从相册选素材进入发布
      await _pickFromAlbum();
      return;
    }
    try {
      await c.startVideoRecording();
      _recTimer.start();
      // 每秒刷新顶部录制计时（否则一直停在 00:00）
      _recTicker?.cancel();
      _recTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      if (mounted) setState(() => _recording = true);
    } catch (_) {
      _toast('无法开始录制，请检查相机权限');
    }
  }

  Future<void> _stopRecording() async {
    final c = _camera;
    if (c == null) return;
    _recTicker?.cancel();
    _recTicker = null;
    try {
      final file = await c.stopVideoRecording();
      _recTimer.stop();
      final seconds = _recTimer.elapsed.inSeconds;
      _recTimer.reset();
      if (!mounted) return;
      setState(() => _recording = false);
      // 先进入拍摄后编辑页，再进发布页
      final edit = await _openEditor(
        video: file,
        durationSeconds: seconds,
        aspectRatio: _aspectPreset.ratio,
      );
      if (edit == null || !mounted) return;
      await _openPublishPage(
        initialVideo: file,
        durationSeconds: seconds,
        music: edit.music ?? _music,
        edit: edit,
        aspectRatio: edit.aspectRatio,
      );
    } catch (_) {
      _recTimer.stop();
      _recTimer.reset();
      if (mounted) setState(() => _recording = false);
      _toast('录制失败');
    }
  }

  Future<void> _takePhoto() async {
    final c = _camera;
    if (c == null || !c.value.isInitialized) {
      _toast('当前设备无相机');
      return;
    }
    try {
      final shot = await c.takePicture();
      if (!mounted) return;
      // 先进入拍摄后编辑页，再进发布页
      final edit = await _openEditor(photo: shot);
      if (edit == null || !mounted) return;
      await _openPublishPage(
        initialImage: shot,
        music: edit.music ?? _music,
        edit: edit,
      );
    } catch (_) {
      _toast('拍照失败');
    }
  }

  /// 相册按钮：打开应用内图片/视频混选页，并按选择顺序处理。
  Future<void> _pickFromAlbum() async {
    final selected = await Navigator.push<List<SelectedMediaFile>>(
      context,
      MaterialPageRoute(builder: (_) => const MediaPickerPage(maxSelection: 9)),
    );
    if (selected == null || selected.isEmpty || !mounted) return;

    final onlyPhotos = selected.every(
      (item) => item.type == SelectedMediaType.image,
    );
    if (onlyPhotos) {
      await _openPublishPage(
        initialImages: selected.map((item) => XFile(item.path)).toList(),
        music: _music,
      );
      return;
    }

    File? videoFile;
    if (selected.length == 1) {
      videoFile = File(selected.single.path);
    } else {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(child: Text('正在按选择顺序拼接素材…')),
              ],
            ),
          ),
        ),
      );
      try {
        videoFile = await MediaComposer.compose(selected);
      } catch (_) {
        if (mounted) _toast('素材拼接失败，请更换素材后重试');
      } finally {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (videoFile == null || !mounted) return;

    final video = XFile(videoFile.path);
    final edit = await _openEditor(
      video: video,
      aspectRatio: selected.length > 1 ? 9 / 16 : null,
    );
    if (edit == null || !mounted) return;
    await _openPublishPage(
      initialVideo: video,
      music: edit.music ?? _music,
      edit: edit,
      aspectRatio: edit.aspectRatio,
    );
  }

  /// 进入拍摄后编辑页（滤镜/裁剪/倍速/音乐）；取消返回 null
  Future<PostEditResult?> _openEditor({
    XFile? video,
    XFile? photo,
    int? durationSeconds,
    double? aspectRatio,
  }) {
    return Navigator.push<PostEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PostEditPage(
          video: video,
          photo: photo,
          initialMusic: _music,
          durationSeconds: durationSeconds,
          aspectRatio: aspectRatio,
        ),
      ),
    );
  }

  /// 进入作品发布页；若发布成功则携带结果关闭拍摄页
  Future<void> _openPublishPage({
    XFile? initialVideo,
    XFile? initialImage,
    List<XFile>? initialImages,
    int? durationSeconds,
    MusicItem? music,
    PostEditResult? edit,
    double? aspectRatio,
  }) async {
    final result = await Navigator.push<ShortVideo>(
      context,
      MaterialPageRoute(
        builder: (_) => DouyinPublishPage(
          initialVideo: initialVideo,
          initialImage: initialImage,
          initialImages: initialImages,
          initialMusic: music,
          durationSeconds: durationSeconds,
          initialEdit: edit,
          initialAspectRatio: aspectRatio,
        ),
      ),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  /// 打开曲库选择配乐
  Future<void> _openMusicPicker() async {
    final result = await showMusicPicker(context, current: _music);
    if (result == null || !mounted) return; // 取消
    setState(() => _music = result.music);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 背景：真实相机预览 / 暗色渐变占位 ──
          if (_cameraReady)
            _buildCameraPreview()
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E1E26), Color(0xFF000000)],
                ),
              ),
            ),

          // 录制中红点 + 计时
          if (_recording) _buildRecordingBadge(),

          // ── 顶部：关闭按钮 + 选择音乐 ──
          _buildTopBar(),

          // ── 右侧垂直按钮栏 ──
          _buildRightRail(),

          if (!_recording && _modeIndex == 1) _buildAspectPicker(),

          // ── 底部拍摄操作区 + Tab 栏 ──
          _buildBottomArea(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final camera = _camera;
    if (camera == null) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E26), Color(0xFF000000)],
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = _modeIndex == 1 ? _aspectPreset.ratio : 3 / 4;
        final previewBounds = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final previewRatio = orientedCameraAspectRatio(
          camera.value.aspectRatio,
          previewBounds: previewBounds,
        );
        final frame = containAspectSize(
          previewBounds,
          ratio,
        );
        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: SizedBox(
              width: frame.width,
              height: frame.height,
              child: coverVideoFrame(
                sourceAspectRatio: previewRatio,
                child: CameraPreview(camera),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAspectPicker() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 228,
      child: SafeArea(
        top: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final preset in VideoAspectPreset.values)
                  GestureDetector(
                    onTap: () => setState(() => _aspectPreset = preset),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: preset == _aspectPreset
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        preset.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: preset == _aspectPreset
                              ? Colors.black
                              : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== 录制指示 =====================
  Widget _buildRecordingBadge() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 70),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fiber_manual_record,
                color: Palette.primary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _formatSeconds(_recTimer.elapsed.inSeconds),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatSeconds(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
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
            // 居中：「选择音乐」/ 已选音乐名
            GestureDetector(
              onTap: _openMusicPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      color: _white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        _music == null ? '选择音乐' : _music!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _railItem(Icons.cameraswitch_rounded, '翻转', onTap: _switchCamera),
          const SizedBox(height: 22),
          _railItem(_flashIcon, _flashLabel, onTap: _cycleFlash),
          const SizedBox(height: 22),
          _railItem(
            Icons.settings_rounded,
            '设置',
            onTap: () => _toast('设置（演示）'),
          ),
        ],
      ),
    );
  }

  IconData get _flashIcon => switch (_flash) {
    FlashMode.off => Icons.flash_off_rounded,
    FlashMode.torch => Icons.flash_on_rounded,
    _ => Icons.flash_auto_rounded,
  };

  String get _flashLabel => switch (_flash) {
    FlashMode.off => '闪光灯',
    FlashMode.torch => '常亮',
    _ => '自动',
  };

  Widget _railItem(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _white, size: 26),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: _white, fontSize: 11)),
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
            // 拍摄模式：照片(选中) / 视频
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _modeLabel('照片', 0),
                const SizedBox(width: 30),
                _modeLabel('视频', 1),
              ],
            ),
            const SizedBox(height: 22),
            // 快门 | 相册（左侧留空占位保证快门居中）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 102),
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

  /// 大圆形快门按钮：外圈粗白圆环 + 内部白色快门；录制中变为红色方框（停止）。
  /// 视频模式录制结束后进入发布页，发布成功后回传 [ShortVideo]。
  Widget _buildShutter() {
    return GestureDetector(
      onTap: _recording ? _stopRecording : _onShutter,
      child: Container(
        width: 78,
        height: 78,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _white, width: 6),
        ),
        child: _recording
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.accent,
                ),
                child: const Center(
                  child: Icon(
                    Icons.stop_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _white,
                ),
              ),
      ),
    );
  }

  /// 快门左侧按钮：方形占位 + 下方文字
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
          Text(label, style: const TextStyle(color: _white, fontSize: 12)),
        ],
      ),
    );
  }
}
