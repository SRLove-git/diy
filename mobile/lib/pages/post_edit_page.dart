import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../core/app_colors.dart';
import '../core/music_api.dart';
import '../core/photo_filters.dart';
import '../core/video_layout.dart';
import 'music_picker_sheet.dart';

/// 拍摄后编辑结果（滤镜/裁剪/倍速/旋转/配乐）。
///
/// 由 [PostEditPage] 返回，拍摄页携带进入发布页，发布时写入作品元数据。
class PostEditResult {
  const PostEditResult({
    this.filterId = '',
    this.trimStart = 0,
    this.trimEnd = 0,
    this.speed = 1.0,
    this.rotation = 0,
    this.music,
    this.aspectRatio = 0,
  });

  /// 滤镜 ID（'' 原图），见 [PhotoFilter]
  final String filterId;

  /// 视频裁剪起点（秒，0 表示不裁剪）
  final double trimStart;

  /// 视频裁剪终点（秒，0 表示不裁剪）
  final double trimEnd;

  /// 播放倍速（0.5x ~ 2x，默认 1）
  final double speed;

  /// 照片顺时针旋转次数（每次 90°，0/1/2/3）
  final int rotation;

  /// 编辑页选择的配乐（可空）
  final MusicItem? music;

  /// 最终展示画幅（width / height）。
  final double aspectRatio;

  bool get hasTrim => trimEnd > trimStart && trimStart > 0;
}

/// 抖音风格「拍摄后编辑」页面。
///
/// 拍完视频/照片先进入本页：可加滤镜、裁剪（视频时长/照片旋转）、
/// 倍速（视频）、切换配乐；点「下一步」携带 [PostEditResult] 返回，
/// 由调用方打开发布页。
class PostEditPage extends StatefulWidget {
  const PostEditPage({
    super.key,
    this.video,
    this.photo,
    this.initialMusic,
    this.durationSeconds,
    this.aspectRatio,
  });

  /// 已录制的视频素材（与 [photo] 二选一）
  final XFile? video;

  /// 拍下的照片素材（与 [video] 二选一）
  final XFile? photo;

  /// 拍摄页已选配乐名（可空）
  final String? initialMusic;

  /// 视频实测时长（秒，相册视频可能为空）
  final int? durationSeconds;

  final double? aspectRatio;

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  /// 底部功能 Tab：0=滤镜 1=裁剪 2=倍速 3=音乐
  int _tab = 0;

  String _filterId = '';
  double _trimStart = 0;
  double _trimEnd = 0;
  double _speed = 1.0;
  int _rotation = 0;
  MusicItem? _music;

  /// 视频真实播放器（本地文件预览；播放失败时回退占位）
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _videoPlaying = false;

  /// 素材是否为视频
  bool get _isVideo => widget.video != null;

  /// 视频总时长（秒）；未知时裁剪不可用
  double get _videoLength {
    final supplied = widget.durationSeconds;
    if (supplied != null && supplied > 0) {
      return supplied.toDouble().clamp(0, 600);
    }
    final ctrl = _videoCtrl;
    if (ctrl != null && ctrl.value.isInitialized) {
      return (ctrl.value.duration.inMilliseconds / 1000).clamp(0, 600);
    }
    return 0;
  }

  /// 是否已设置裁剪区间（起点 > 0，或结尾已短于视频总长）
  bool get _hasTrim {
    if (_trimEnd <= _trimStart) return false;
    if (_trimStart > 0) return true;
    return _videoLength > 0 && _trimEnd < _videoLength;
  }

  static const _white = Colors.white;
  static const _hint = Color(0xFF999999);
  static const _primary = Palette.accent;
  static const _btnBg = Color(0xFF2C2C2C);
  static const _bg = Color(0xFF121212);
  static const _border = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    if (widget.initialMusic != null && widget.initialMusic!.isNotEmpty) {
      _music = MusicItem(
        id: 0,
        title: widget.initialMusic!,
        artist: '',
        cover: '',
        musicUrl: '',
        duration: 0,
      );
    }
    // 默认裁剪区间 = 完整视频
    _trimEnd = _videoLength;
    // 视频素材：初始化真实播放器用于预览
    final file = widget.video;
    if (file != null) {
      final ctrl = VideoPlayerController.file(File(file.path));
      _videoCtrl = ctrl;
      _initVideo(ctrl);
    }
  }

  /// 初始化视频播放器：循环播放，应用倍速，按裁剪区间循环
  Future<void> _initVideo(VideoPlayerController ctrl) async {
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.setPlaybackSpeed(_speed);
      ctrl.addListener(_onVideoTick);
      if (!mounted) return;
      setState(() {
        _videoReady = true;
        if (_trimEnd <= 0) _trimEnd = _videoLength;
      });
    } catch (_) {
      // 播放失败保留占位（_videoReady 保持 false）
    }
  }

  /// 播放状态/裁剪区间同步
  void _onVideoTick() {
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    // 超出裁剪终点时跳回起点（预览裁剪效果）
    if (_hasTrim) {
      final end = Duration(milliseconds: (_trimEnd * 1000).round());
      if (ctrl.value.position >= end) {
        ctrl.seekTo(Duration(milliseconds: (_trimStart * 1000).round()));
      }
    }
    final playing = ctrl.value.isPlaying;
    if (playing != _videoPlaying && mounted) {
      setState(() => _videoPlaying = playing);
    }
  }

  /// 播放/暂停切换
  void _toggleVideoPlay() {
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      ctrl.play();
    }
    if (mounted) setState(() => _videoPlaying = ctrl.value.isPlaying);
  }

  @override
  void dispose() {
    _videoCtrl?.removeListener(_onVideoTick);
    _videoCtrl?.dispose();
    super.dispose();
  }

  /// 打开曲库选择/清除配乐
  Future<void> _openMusicPicker() async {
    final result = await showMusicPicker(context, current: _music);
    if (result == null || !mounted) return;
    setState(() => _music = result.music);
  }

  /// 照片旋转（每次 90° 顺时针）
  void _rotate(int step) {
    setState(() => _rotation = (_rotation + step) % 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildPreview()),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  // ===================== 顶部栏 =====================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: _white, size: 26),
          ),
          const Spacer(),
          const Text('编辑', style: TextStyle(color: _white, fontSize: 16)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(
              context,
              PostEditResult(
                filterId: _filterId,
                trimStart: _trimStart,
                trimEnd: _trimEnd,
                speed: _speed,
                rotation: _rotation,
                music: _music,
                aspectRatio: _isVideo && _videoReady
                    ? normalizeVideoAspectRatio(
                        widget.aspectRatio,
                        fallback: _videoCtrl!.value.aspectRatio,
                      )
                    : 0,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                '下一步',
                style: TextStyle(color: _white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 预览区 =====================
  Widget _buildPreview() {
    final filter = filterOf(_filterId).colorFilter;
    final angle = _rotation * 90 * 3.141592653589793 / 180;
    final mediaRatio = _isVideo && _videoReady
        ? normalizeVideoAspectRatio(
            widget.aspectRatio,
            fallback: _videoCtrl!.value.aspectRatio,
          )
        : 9 / 16;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final frame = containAspectSize(
            Size(constraints.maxWidth, constraints.maxHeight),
            mediaRatio,
          );
          return Center(
            child: Transform.rotate(
              angle: angle,
              child: SizedBox(
                width: frame.width,
                height: frame.height,
                child: Container(
                  decoration: BoxDecoration(
                    color: _btnBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: ColorFiltered(
                      colorFilter: filter,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 背景：照片 / 视频真实预览 / 占位
                          if (!_isVideo)
                            Image.file(
                              File(widget.photo!.path),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholder(),
                            )
                          else if (_videoReady)
                            _videoPreview()
                          else
                            _placeholder(video: true),
                          // 滤镜名称角标
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                filterOf(_filterId).name,
                                style: const TextStyle(
                                  color: _white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          // 裁剪区间角标（视频）
                          if (_isVideo && _hasTrim)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_fmt(_trimStart)} - ${_fmt(_trimEnd)}',
                                  style: const TextStyle(
                                    color: _white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          // 倍速角标（视频）
                          if (_isVideo && _speed != 1)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_speed}x',
                                  style: const TextStyle(
                                    color: _white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 视频真实预览：播放画面 + 中央播放/暂停 + 底部进度
  Widget _videoPreview() {
    final ctrl = _videoCtrl!;
    return Stack(
      fit: StackFit.expand,
      children: [
        // 播放画面（按原始宽高比居中展示）
        coverVideoFrame(
          sourceAspectRatio: ctrl.value.aspectRatio,
          child: VideoPlayer(ctrl),
        ),
        // 中央播放/暂停按钮（点击切换）
        Center(
          child: GestureDetector(
            onTap: _toggleVideoPlay,
            child: Icon(
              _videoPlaying
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              color: _white.withValues(alpha: 0.92),
              size: 58,
            ),
          ),
        ),
        // 底部进度（当前 / 总时长）
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: ctrl,
            builder: (context, value, _) {
              return Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  '${_fmtPos(value.position)} / ${_fmtPos(value.duration)}',
                  style: const TextStyle(color: _white, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Duration → mm:ss
  static String _fmtPos(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _placeholder({bool video = false}) {
    return Container(
      color: _btnBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            video ? Icons.movie_outlined : Icons.photo_outlined,
            color: _hint,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            video ? '视频预览' : '照片素材',
            style: const TextStyle(color: _hint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static String _fmt(double sec) {
    final s = sec.round();
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  // ===================== 底部工具栏 =====================
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab 栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _tabBtn(0, Icons.auto_awesome, '滤镜'),
              if (_isVideo) _tabBtn(1, Icons.content_cut, '裁剪'),
              if (_isVideo) _tabBtn(2, Icons.speed, '倍速'),
              _tabBtn(3, Icons.music_note, '音乐'),
            ],
          ),
          const SizedBox(height: 4),
          // 面板（固定高度）
          SizedBox(height: 108, child: _buildPanel()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _tabBtn(int index, IconData icon, String label) {
    final selected = index == _tab;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? _primary : _hint, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(color: selected ? _primary : _hint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ===================== 功能面板 =====================
  Widget _buildPanel() {
    return switch (_tab) {
      0 => _buildFilterPanel(),
      1 => _buildTrimPanel(),
      2 => _buildSpeedPanel(),
      _ => _buildMusicPanel(),
    };
  }

  /// 滤镜面板：横向缩略图，点选应用
  Widget _buildFilterPanel() {
    final source = _isVideo ? null : widget.photo;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: kPhotoFilters.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final f = kPhotoFilters[i];
        final selected = f.id == _filterId;
        return GestureDetector(
          onTap: () => setState(() => _filterId = f.id),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? _primary : _border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: ColorFiltered(
                    colorFilter: f.colorFilter,
                    child: source != null
                        ? Image.file(
                            File(source.path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const ColoredBox(color: _btnBg),
                          )
                        : const ColoredBox(
                            color: Color(0xFF1E1E28),
                            child: Center(
                              child: Icon(
                                Icons.movie_outlined,
                                color: _hint,
                                size: 20,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                f.name,
                style: TextStyle(
                  color: selected ? _white : _hint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 裁剪面板：视频选择起止区间；照片旋转 90°
  Widget _buildTrimPanel() {
    if (_isVideo) {
      if (_videoLength <= 0) {
        return const Center(
          child: Text('无法读取视频时长', style: TextStyle(color: _hint, fontSize: 12)),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RangeSlider(
              values: RangeValues(_trimStart, _trimEnd),
              max: _videoLength,
              min: 0,
              divisions: _videoLength.round(),
              activeColor: _primary,
              inactiveColor: _btnBg,
              labels: RangeLabels(_fmt(_trimStart), _fmt(_trimEnd)),
              onChanged: (v) => setState(() {
                _trimStart = v.start;
                _trimEnd = v.end;
              }),
            ),
            Text(
              '裁剪区间 ${_fmt(_trimStart)} - ${_fmt(_trimEnd)}'
              '${_hasTrim ? '（已裁剪）' : ''}',
              style: const TextStyle(color: _hint, fontSize: 12),
            ),
          ],
        ),
      );
    }
    // 照片：旋转
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _rotBtn(Icons.rotate_left, '左转', -1),
        const SizedBox(width: 40),
        _rotBtn(Icons.rotate_right, '右转', 1),
      ],
    );
  }

  Widget _rotBtn(IconData icon, String label, int step) {
    return GestureDetector(
      onTap: () => _rotate(step),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _btnBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: _white, fontSize: 11)),
        ],
      ),
    );
  }

  /// 倍速面板（仅视频）
  Widget _buildSpeedPanel() {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: speeds.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final s = speeds[i];
        final selected = s == _speed;
        return GestureDetector(
          onTap: () {
            setState(() => _speed = s);
            // 预览实时生效
            _videoCtrl?.setPlaybackSpeed(s);
          },
          child: Container(
            width: 56,
            height: 72,
            decoration: BoxDecoration(
              color: _btnBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? _primary : _border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '${s}x',
                style: TextStyle(
                  color: selected ? _white : _hint,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 音乐面板：展示当前配乐，点按打开曲库
  Widget _buildMusicPanel() {
    return GestureDetector(
      onTap: _openMusicPicker,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _btnBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(
              _music == null ? Icons.music_note_rounded : Icons.music_note,
              color: _music == null ? _hint : _primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _music == null ? '选择配乐（原声）' : _music!.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _white, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right, color: _hint, size: 20),
          ],
        ),
      ),
    );
  }
}
