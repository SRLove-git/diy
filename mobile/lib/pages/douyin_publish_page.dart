import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/video_api.dart';
import 'short_video_models.dart';

/// 抖音风格作品发布编辑页面
///
/// 深色暗黑主题，模仿抖音发布作品页面 UI。
/// 支持从相册选择视频素材（可带封面图），上传后通过 [VideoApi] 发布为短视频，
/// 发布成功后以 [ShortVideo] 回传给上一页（拍摄页/信息流）。
class DouyinPublishPage extends StatefulWidget {
  const DouyinPublishPage({super.key, this.initialVideo});

  /// 拍摄页选中的视频文件（可为空，进入后在页内再选）
  final XFile? initialVideo;

  @override
  State<DouyinPublishPage> createState() => _DouyinPublishPageState();
}

class _DouyinPublishPageState extends State<DouyinPublishPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();

  /// 已选视频素材
  XFile? _video;

  /// 已选封面图（可选，不选则信息流展示占位封面）
  XFile? _cover;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _video = widget.initialVideo;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// 从相册选择视频素材
  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _video = file);
  }

  /// 从相册选择封面图
  Future<void> _pickCover() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _cover = file);
  }

  /// 上传视频 + 封面并发布，成功后回传创建的 [ShortVideo]
  Future<void> _submit() async {
    final video = _video;
    if (video == null) {
      _toast('请先选择视频素材');
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
      final videoUrl = await VideoApi.uploadVideo(video.path);
      var cover = '';
      if (_cover != null) {
        cover = await VideoApi.uploadCover(_cover!.path);
      }
      final created = await VideoApi.create(
        title: title,
        content: desc.isEmpty ? title : '$title\n$desc',
        cover: cover,
        videoUrl: videoUrl,
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
  static const _primary = Color(0xFFFE2C55);
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
            onTap: () => _toast(_video == null ? '请先选择视频素材' : '预览（演示）'),
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
    return Column(
      children: [
        // 手机样式视频预览卡片
        Center(
          child: GestureDetector(
            onTap: _pickVideo,
            child: Container(
              width: 200,
              height: 340,
              decoration: BoxDecoration(
                color: _btnBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 背景：封面图 / 占位
                    if (_cover != null)
                      Image.file(
                        File(_cover!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    else
                      _placeholder(),
                    // 播放按钮叠加
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: _white,
                        size: 56,
                      ),
                    ),
                    // 底部素材名称
                    if (_video != null)
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
                            _fileName(_video!.name),
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

        const SizedBox(height: 12),

        // 素材操作按钮
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _assetBtn(
                icon: _video == null ? Icons.add : Icons.swap_horiz,
                label: _video == null ? '添加视频' : '更换视频',
                onTap: _pickVideo,
              ),
              if (_video != null) ...[
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: _btnBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _video == null ? Icons.videocam : Icons.movie_outlined,
            color: _hint,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            _video == null ? '点击添加视频素材' : '已选择视频',
            style: const TextStyle(color: _hint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _assetBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
        _optionRow(
          icon: Icons.label_outline,
          title: '添加标签',
          onTap: () {},
        ),
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
              child: Text(title, style: const TextStyle(color: _white, fontSize: 15)),
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
