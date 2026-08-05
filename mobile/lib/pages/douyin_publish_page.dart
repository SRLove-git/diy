import 'dart:io';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../core/app_colors.dart';
import '../core/music_api.dart';
import '../core/media_composer.dart';
import '../core/photo_filters.dart';
import '../core/video_api.dart';
import '../core/video_layout.dart';
import 'music_picker_sheet.dart';
import 'post_edit_page.dart';
import 'short_video_models.dart';

/// 抖音风格作品发布编辑页面
///
/// 深色暗黑主题，模仿抖音发布作品页面 UI。
/// 支持两种素材：视频（可带封面图）或照片（配背景音乐），
/// 上传后通过 [VideoApi] 发布为短视频/照片作品，
/// 发布成功后以 [ShortVideo] 回传给上一页（拍摄页/信息流）。
/// 页内可点「配乐」打开曲库重新选择/清除背景音乐。
class DouyinPublishPage extends StatefulWidget {
  const DouyinPublishPage({
    super.key,
    this.initialVideo,
    this.initialImage,
    this.initialImages,
    this.initialMusic,
    this.durationSeconds,
    this.initialEdit,
    this.initialAspectRatio,
  });

  /// 拍摄页选中的视频文件（可为空，进入后在页内再选）
  final XFile? initialVideo;

  /// 拍摄页照片模式拍下的照片（照片作品：以照片为封面，配背景音乐）
  final XFile? initialImage;

  /// 相册页按选择顺序带入的照片笔记素材。
  final List<XFile>? initialImages;

  /// 拍摄页选中的配乐名（可空）
  final String? initialMusic;

  /// 录制视频的实测时长（秒，可空则由服务端默认）
  final int? durationSeconds;

  /// 拍摄后编辑结果（滤镜/裁剪/倍速/旋转/配乐，可空）
  final PostEditResult? initialEdit;

  final double? initialAspectRatio;

  @override
  State<DouyinPublishPage> createState() => _DouyinPublishPageState();
}

class _DouyinPublishPageState extends State<DouyinPublishPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();

  /// 已选视频素材（视频与照片互斥）
  XFile? _video;

  /// 已选照片素材列表（照片作品：最多 9 张，第一张为封面）
  final List<XFile> _photos = [];

  /// 照片作品最多可添加张数（小红书式）
  static const int _maxPhotos = 9;

  /// 已选封面图（仅视频作品可选）
  XFile? _cover;

  /// 已选配乐（发布时写入作品）
  MusicItem? _music;

  /// 拍摄后编辑结果（滤镜/裁剪/倍速/旋转）
  PostEditResult? _edit;

  /// 视频真实播放器（无封面视频预览；播放失败回退占位）
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _videoPlaying = false;
  double? _aspectRatio;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _video = widget.initialVideo;
    _aspectRatio = widget.initialAspectRatio ?? widget.initialEdit?.aspectRatio;
    if (widget.initialImage != null) {
      _photos.add(widget.initialImage!);
    }
    if (widget.initialImages != null) {
      _photos.addAll(widget.initialImages!.take(_maxPhotos));
    }
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
    _edit = widget.initialEdit;
    // 编辑页选择的配乐优先
    final editMusic = _edit?.music;
    if (editMusic != null && editMusic.title.isNotEmpty) {
      _music = editMusic;
    }
    // 视频素材：初始化真实播放器用于预览
    if (_video != null) _initVideoPreview();
  }

  /// 初始化视频播放器：循环播放，失败回退占位
  Future<void> _initVideoPreview() async {
    final file = _video;
    if (file == null) return;
    final ctrl = VideoPlayerController.file(File(file.path));
    _videoCtrl = ctrl;
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      ctrl.addListener(_onVideoTick);
      if (mounted) {
        setState(() {
          _videoReady = true;
          if (_aspectRatio == null || _aspectRatio! <= 0) {
            _aspectRatio = ctrl.value.aspectRatio;
          }
        });
      }
    } catch (_) {
      // 播放失败保留占位（_videoReady 保持 false）
    }
  }

  /// 释放视频播放器（更换视频/切照片模式时调用）
  void _releaseVideo() {
    _videoCtrl?.removeListener(_onVideoTick);
    _videoCtrl?.dispose();
    _videoCtrl = null;
    _videoReady = false;
    _videoPlaying = false;
  }

  void _onVideoTick() {
    final c = _videoCtrl;
    if (c == null || !c.value.isInitialized) return;
    final playing = c.value.isPlaying;
    if (playing != _videoPlaying && mounted) {
      setState(() => _videoPlaying = playing);
    }
  }

  /// 视频预览播放/暂停切换
  void _toggleVideoPreview() {
    final c = _videoCtrl;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    if (mounted) setState(() => _videoPlaying = c.value.isPlaying);
  }

  @override
  void dispose() {
    _releaseVideo();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// 从相册选择视频素材（替换照片素材）
  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    _releaseVideo();
    setState(() {
      _video = file;
      _photos.clear();
      _cover = null;
      _aspectRatio = null;
    });
    _initVideoPreview();
  }

  /// 从相册追加照片素材（小红书式多图，最多 9 张）
  Future<void> _pickPhotos() async {
    if (_photos.length >= _maxPhotos) return;
    final files = await _picker.pickMultiImage(
      imageQuality: 80,
      limit: _maxPhotos - _photos.length,
    );
    if (files.isEmpty) return;
    _releaseVideo();
    setState(() {
      _photos.addAll(files);
      _video = null;
      _cover = null;
    });
  }

  /// 移除指定照片
  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  /// 从相册选择封面图（仅视频作品）
  Future<void> _pickCover() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _cover = file);
  }

  /// 页内打开曲库选择/清除配乐
  Future<void> _openMusicPicker() async {
    final result = await showMusicPicker(context, current: _music);
    if (result == null || !mounted) return;
    setState(() => _music = result.music);
  }

  /// 上传素材并发布，成功后回传创建的 [ShortVideo]。
  /// 视频：上传视频 + 可选封面；照片：逐张上传，第一张为封面（照片作品配背景音乐）。
  Future<void> _submit() async {
    final video = _video;
    if (video == null && _photos.isEmpty) {
      _toast('请先添加视频或照片素材');
      return;
    }
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty && desc.isEmpty) {
      _toast('请填写标题或描述');
      return;
    }

    setState(() => _submitting = true);
    try {
      var videoUrl = '';
      var cover = '';
      var photos = <String>[];
      if (video != null) {
        videoUrl = await VideoApi.uploadVideo(video.path);
        // 封面：手动选择优先；未选择时自动从视频抽一帧，保证主页/信息流有封面
        cover = _cover != null
            ? await VideoApi.uploadCover(_cover!.path)
            : await _autoCover(video.path);
      } else {
        // 照片作品：逐张上传，第一张为封面，无视频流
        for (final p in _photos) {
          final url = await VideoApi.uploadCover(p.path);
          photos.add(url);
          if (cover.isEmpty) cover = url;
        }
      }
      final created = await VideoApi.create(
        title: title,
        content: desc.isEmpty ? title : '$title\n$desc',
        cover: cover,
        videoUrl: videoUrl,
        duration:
            widget.durationSeconds ??
            (_videoCtrl?.value.duration.inSeconds ?? 0),
        music: _music?.title ?? '',
        photos: photos,
        filter: _edit?.filterId ?? '',
        trimStart: _edit?.trimStart ?? 0,
        trimEnd: _edit?.trimEnd ?? 0,
        speed: _edit?.speed ?? 1,
        rotation: _edit?.rotation ?? 0,
        aspectRatio: video == null
            ? 0
            : normalizeVideoAspectRatio(
                _aspectRatio,
                fallback: _videoCtrl?.value.aspectRatio ?? 9 / 16,
              ),
      );
      if (mounted) {
        _toast('发布成功');
        Navigator.pop(context, created);
      }
    } on DioException catch (e) {
      if (mounted) _toast('发布失败：${VideoApi.messageOf(e)}');
    } catch (e) {
      if (mounted) _toast('发布失败：$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// 未手动选封面时，从视频文件中抽取一帧上传为封面；失败不阻塞发布。
  Future<String> _autoCover(String videoPath) async {
    try {
      final durationSec = (widget.durationSeconds ??
              _videoCtrl?.value.duration.inSeconds ??
              0)
          .toDouble();
      // 取视频前 20% 处（0.1s ~ 2s），避开片头黑场
      final at = durationSec > 0
          ? (durationSec * 0.2).clamp(0.1, 2.0).toDouble()
          : 0.5;
      final frame = await MediaComposer.extractCoverFrame(videoPath, seconds: at);
      return await VideoApi.uploadCover(frame.path);
    } catch (_) {
      return '';
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
  }

  // ---------- 配色常量 ----------
  static const _bg = Color(0xFF121212);
  static const _btnBg = Color(0xFF2C2C2C);
  static const _primary = Palette.accent;
  static const _white = Colors.white;
  static const _hint = Color(0xFF888888);
  static const _border = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildPreviewArea(),
                    const SizedBox(height: 16),
                    _buildTextInputs(),
                    const SizedBox(height: 16),
                    _buildFunctionButtons(),
                    const SizedBox(height: 16),
                    _buildOptionsList(),
                    const SizedBox(height: 100), // 底部留白给操作栏
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
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
          // 返回箭头
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: _white, size: 24),
          ),
          const Spacer(),
          // 预览按钮
          GestureDetector(
            onTap: () =>
                _toast(_video == null && _photos.isEmpty ? '请先添加素材' : '预览（演示）'),
            child: const Text(
              '预览',
              style: TextStyle(color: _white, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ===================== 预览区域 =====================
  Widget _buildPreviewArea() {
    final hasAsset = _video != null || _photos.isNotEmpty;
    final filter = filterOf(_edit?.filterId ?? '').colorFilter;
    final angle = (_edit?.rotation ?? 0) * 90 * 3.141592653589793 / 180;
    final summary = _editSummary;
    final previewRatio = _video != null && _videoReady
        ? normalizeVideoAspectRatio(
            _aspectRatio,
            fallback: _videoCtrl!.value.aspectRatio,
          )
        : 9 / 16;
    return Column(
      children: [
        // 手机样式素材预览卡片
        Center(
          child: GestureDetector(
            onTap: () {
              if (!hasAsset) {
                _pickVideo();
                return;
              }
              // 视频就绪时点击卡片播放/暂停
              if (_video != null && _videoReady) {
                _toggleVideoPreview();
                return;
              }
              _toast('预览（演示）');
            },
            child: Transform.rotate(
              angle: angle,
              child: SizedBox(
                width: isLandscapeVideo(previewRatio) ? 320 : 200,
                height: isLandscapeVideo(previewRatio)
                    ? 320 / previewRatio
                    : 200 / previewRatio,
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
                          // 背景：照片素材（第一张）/ 无封面视频真实预览 / 封面图 / 占位
                          if (_photos.isNotEmpty)
                            Image.file(
                              File(_photos.first.path),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholder(),
                            )
                          else if (_video != null && _videoReady)
                            _videoPreviewBox()
                          else if (_cover != null)
                            Image.file(
                              File(_cover!.path),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholder(),
                            )
                          else
                            _placeholder(),
                          // 视频未就绪时叠加播放图标（就绪后由预览框内部管理）
                          if (_video != null && !_videoReady)
                            const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: _white,
                                size: 56,
                              ),
                            ),
                          // 照片作品角标（多图显示张数）
                          if (_photos.isNotEmpty)
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
                                  _photos.length > 1
                                      ? '照片 ${_photos.length} 张'
                                      : '照片',
                                  style: const TextStyle(
                                    color: _white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          // 底部素材名称
                          if (hasAsset)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                color: Colors.black54,
                                child: Text(
                                  _fileName(
                                    _video != null
                                        ? _video!.name
                                        : _photos.first.name,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
          ),
        ),
        // 编辑摘要（滤镜/倍速/裁剪）
        if (summary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              summary,
              style: const TextStyle(color: _hint, fontSize: 11),
            ),
          ),

        const SizedBox(height: 12),

        // 素材操作按钮（无素材 / 视频模式显示；照片模式由图片列表管理）
        if (_video == null && _photos.isEmpty) ...[
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _assetBtn(
                  icon: Icons.videocam_outlined,
                  label: '添加视频',
                  onTap: _pickVideo,
                ),
                _assetBtn(
                  icon: Icons.photo_outlined,
                  label: '添加照片',
                  onTap: _pickPhotos,
                ),
              ],
            ),
          ),
        ] else if (_video != null) ...[
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _assetBtn(
                  icon: Icons.swap_horiz,
                  label: '更换视频',
                  onTap: _pickVideo,
                ),
                _assetBtn(
                  icon: Icons.image_outlined,
                  label: _cover == null ? '选择封面' : '更换封面',
                  onTap: _pickCover,
                ),
                if (_cover != null)
                  _assetBtn(
                    icon: Icons.close,
                    label: '移除封面',
                    onTap: () => setState(() => _cover = null),
                  ),
              ],
            ),
          ),
        ],

        // 照片图片列表（始终显示；长按拖动排序，末尾可继续添加）
        if (_photos.isNotEmpty) _buildPhotoStrip(),

        // 配乐选择行（点按打开曲库，照片作品配背景音乐）
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _openMusicPicker,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _music == null ? Icons.music_note_rounded : Icons.music_note,
                color: _music == null ? _hint : _white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _music == null ? '选择配乐（原声）' : '配乐：${_music!.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _music == null ? _hint : _white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: _hint, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  /// 编辑摘要文案：滤镜 · 倍速 · 裁剪区间
  String get _editSummary {
    final edit = _edit;
    if (edit == null) return '';
    final parts = <String>[
      if (edit.filterId.isNotEmpty) '滤镜 ${filterOf(edit.filterId).name}',
      if (edit.speed != 1) '${edit.speed}x',
      if (edit.trimStart > 0)
        '已裁剪 ${_fmtSec(edit.trimStart)}-${_fmtSec(edit.trimEnd)}',
      if (edit.rotation != 0) '已旋转',
    ];
    return parts.join(' · ');
  }

  static String _fmtSec(double sec) {
    final s = sec.round();
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  /// 照片图片列表：横向排列全部照片，右上角可移除，
  /// 长按拖动可改变顺序（松手插入到目标位置），末尾「+」继续添加。
  Widget _buildPhotoStrip() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _photos.length + (_photos.length >= _maxPhotos ? 0 : 1),
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            if (i == _photos.length) {
              // 末尾添加图块
              return GestureDetector(
                onTap: _pickPhotos,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: _btnBg,
                    border: Border.all(color: _border, width: 1),
                  ),
                  child: const Icon(Icons.add, color: _hint),
                ),
              );
            }
            return _draggablePhoto(i);
          },
        ),
      ),
    );
  }

  /// 单张照片项：可长按拖动排序，右上角移除，左下角显示序号
  Widget _draggablePhoto(int index) {
    final photo = _photos[index];
    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: _btnBg,
                child: const Icon(Icons.broken_image, color: _hint),
              ),
            ),
            // 移除按钮
            Positioned(
              top: -2,
              right: -2,
              child: GestureDetector(
                onTap: () => _removePhoto(index),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                ),
              ),
            ),
            // 序号（随拖动实时变化）
            Positioned(
              left: 4,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return LongPressDraggable<XFile>(
      data: photo,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 72, height: 72, child: thumb),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: thumb),
      child: DragTarget<XFile>(
        onWillAcceptWithDetails: (d) => d.data != photo,
        onAcceptWithDetails: (d) => _movePhoto(d.data, index),
        builder: (_, _, _) => thumb,
      ),
    );
  }

  /// 拖动排序：把 [photo] 移动到目标索引位置
  void _movePhoto(XFile photo, int targetIndex) {
    final from = _photos.indexOf(photo);
    if (from < 0 || from == targetIndex) return;
    setState(() {
      final item = _photos.removeAt(from);
      _photos.insert(targetIndex, item);
    });
  }

  Widget _placeholder() {
    final isPhoto = _photos.isNotEmpty;
    return Container(
      color: _btnBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPhoto
                ? Icons.photo_outlined
                : (_video == null ? Icons.videocam : Icons.movie_outlined),
            color: _hint,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            isPhoto ? '照片素材' : (_video == null ? '点击添加视频或照片素材' : '已选择视频'),
            style: const TextStyle(color: _hint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 视频真实预览框：播放画面 + 播放/暂停 + 底部进度
  Widget _videoPreviewBox() {
    final c = _videoCtrl!;
    return Stack(
      fit: StackFit.expand,
      children: [
        coverVideoFrame(
          sourceAspectRatio: c.value.aspectRatio,
          child: VideoPlayer(c),
        ),
        Center(
          child: Icon(
            _videoPlaying
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
            color: _white.withValues(alpha: 0.85),
            size: 46,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: c,
            builder: (context, value, _) => Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                '${_fmtSec(value.position.inMilliseconds / 1000)}'
                ' / ${_fmtSec(value.duration.inMilliseconds / 1000)}',
                style: const TextStyle(color: _white, fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _assetBtn({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 52,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: _btnBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _white, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: _white, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  String _fileName(String name) =>
      name.length > 18 ? '${name.substring(0, 17)}…' : name;

  // ===================== 文本输入区域 =====================
  Widget _buildTextInputs() {
    return Column(
      children: [
        // 单行标题输入
        TextField(
          controller: _titleCtrl,
          style: const TextStyle(color: _white, fontSize: 16),
          cursorColor: _white,
          decoration: const InputDecoration(
            hintText: '添加标题',
            hintStyle: TextStyle(color: _hint, fontSize: 16),
            filled: true,
            fillColor: _btnBg,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        // 多行描述输入
        TextField(
          controller: _descCtrl,
          style: const TextStyle(color: _white, fontSize: 14),
          cursorColor: _white,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '添加作品描述...',
            hintStyle: TextStyle(color: _hint, fontSize: 14),
            filled: true,
            fillColor: _btnBg,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ],
    );
  }

  // ===================== 功能按钮行 =====================
  Widget _buildFunctionButtons() {
    return Row(
      children: [
        // #话题 按钮
        _funcBtn('#话题'),
        const SizedBox(width: 10),
        // @朋友 按钮
        _funcBtn('@朋友'),
        const Spacer(),
        // 排版布局按钮
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _btnBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.auto_fix_high, color: _white, size: 18),
        ),
      ],
    );
  }

  Widget _funcBtn(String label) {
    return GestureDetector(
      onTap: () {
        // TODO: 对应功能
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _btnBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label, style: const TextStyle(color: _white, fontSize: 13)),
      ),
    );
  }

  // ===================== 列表式功能选项组 =====================
  Widget _buildOptionsList() {
    return Column(
      children: [
        // 1. 添加标签
        _optionRow(icon: Icons.label_outline, title: '添加标签', onTap: () {}),
        const Divider(color: _border, height: 1),

        // 2. 添加自主声明
        _optionRow(
          icon: Icons.campaign_outlined,
          title: '添加自主声明',
          onTap: () {},
        ),
        const Divider(color: _border, height: 1),
      ],
    );
  }

  Widget _optionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: _white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: _white, fontSize: 15),
              ),
            ),
            const Icon(Icons.chevron_right, color: _hint, size: 20),
          ],
        ),
      ),
    );
  }

  // ===================== 底部操作栏 =====================
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 提示文字
            const Text(
              '发布后将同步到短视频信息流',
              style: TextStyle(color: _hint, fontSize: 11),
            ),
            const SizedBox(height: 10),

            // 操作按钮行
            Row(
              children: [
                // 分享图标按钮
                const Icon(Icons.share_outlined, color: _white, size: 22),
                const SizedBox(width: 16),

                // 限时日常 按钮
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: 限时日常
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _btnBg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.more_time, color: _white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            '限时日常',
                            style: TextStyle(color: _white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 发作品 主按钮
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _submitting ? null : _submit,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _submitting ? _btnBg : _primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _white,
                                ),
                              )
                            : const Text(
                                '发作品',
                                style: TextStyle(
                                  color: _white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
