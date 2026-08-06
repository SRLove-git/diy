import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_colors.dart';
import '../../../core/chat_api.dart';
import '../../../core/post_api.dart';
import '../../../core/profile_events.dart';
import '../../../core/video_api.dart';

/// 社区作品发布编辑页面
///
/// 结构：
/// - AppBar：左侧返回箭头，中间标题"发新帖"，右上角蓝色圆角"发表"按钮
/// - 内容输入区：多行文本输入，hint "分享新鲜事…"
/// - 图片选择区：横向滚动，已选缩略图 + 添加按钮
/// - 功能列表项：标记位置 / 自主声明 / 高级设置
/// - 底部工具栏：表情图标、文本T图标
class PublishPostPage extends StatefulWidget {
  const PublishPostPage({super.key, this.initialImage});

  /// 拍摄页照片模式拍下的图片（本地路径），进入后直接带入
  final String? initialImage;

  @override
  State<PublishPostPage> createState() => _PublishPostPageState();
}

class _PublishPostPageState extends State<PublishPostPage> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  /// 已选图片的本地文件路径列表
  late final List<String> _selectedImages = widget.initialImage == null
      ? []
      : [widget.initialImage!];

  /// 已选视频素材（单个，可选）
  XFile? _video;

  /// 最大可选图片数
  static const int _maxImages = 9;

  /// 是否正在发布中
  bool _publishing = false;

  /// 标记位置（发布时写入 post.location）
  String _location = '';

  /// 高级设置：频道标签（发布时写入 post.channelTag，进入对应频道流）
  String _channelTag = '';

  /// 自主声明：是否声明原创（发布时写入 tags）
  bool _originalDeclared = false;

  /// 从相册选图
  Future<void> _pickImage() async {
    if (_selectedImages.length >= _maxImages) return;
    final images = await _picker.pickMultiImage(
      imageQuality: 80,
      limit: _maxImages - _selectedImages.length,
    );
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images.map((e) => e.path)));
    }
  }

  /// 从相册选视频（单个）
  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _video = file);
  }

  /// 移除已选图片
  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  /// 移除已选视频
  void _removeVideo() {
    setState(() => _video = null);
  }

  /// 上传图片/视频并发布帖子
  Future<void> _onPublish() async {
    final content = _textController.text.trim();
    if (content.isEmpty && _selectedImages.isEmpty && _video == null) {
      _showError('请输入内容或选择素材');
      return;
    }

    setState(() => _publishing = true);
    try {
      // 1. 先上传所有图片
      final uploadedUrls = <String>[];
      final medias = <Map<String, dynamic>>[];
      for (final path in _selectedImages) {
        final url = await ChatApi.uploadImage(path, folder: 'post');
        uploadedUrls.add(url);
        medias.add({'type': 'image', 'url': url});
      }
      // 2. 上传视频（如有）
      if (_video != null) {
        final videoUrl = await VideoApi.uploadVideo(_video!.path);
        medias.add({'type': 'video', 'url': videoUrl});
      }

      // 3. 创建帖子
      await PostApi.create(
        content: content,
        images: uploadedUrls,
        tags: _originalDeclared ? const ['原创'] : const [],
        medias: medias,
        location: _location.isEmpty ? null : _location,
        channelTag: _channelTag.isEmpty ? null : _channelTag,
      );

      if (!mounted) return;
      // 通知个人主页刷新作品列表，无需手动下拉
      ProfileEvents.notifyWorksChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('发表成功'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: _buildAppBar(colors),
      body: Stack(
        children: [
          Column(
            children: [
              // 内容输入区
              _buildContentInput(colors),
              // 图片/视频选择区域
              _buildMediaPicker(colors),
              // 分割线
              Divider(height: 1, color: colors.divider),
              // 功能列表项
              _buildSettingsList(colors),
              // 弹性空间
              const Expanded(child: SizedBox()),
              // 分割线
              Divider(height: 1, color: colors.divider),
              // 底部工具栏
              _buildBottomToolbar(colors),
            ],
          ),
          // 发布中遮罩
          if (_publishing) _buildPublishingOverlay(),
        ],
      ),
    );
  }

  /// 发布中遮罩层
  Widget _buildPublishingOverlay() {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('发布中…', style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  /// 自定义 AppBar：左侧返回箭头 + 中间标题 + 右侧品牌色发表按钮
  PreferredSizeWidget _buildAppBar(AppColors colors) {
    return AppBar(
      backgroundColor: Palette.background,
      elevation: 0.5,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: colors.textPrimary,
        onPressed: _publishing ? null : () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '发新帖',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton(
            onPressed: _publishing ? null : _onPublish,
            style: TextButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('发表', style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  /// 内容输入区：多行文本输入框，hint "分享新鲜事…"
  Widget _buildContentInput(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _textController,
        maxLines: 5,
        minLines: 3,
        enabled: !_publishing,
        style: TextStyle(fontSize: 16, color: colors.textPrimary, height: 1.5),
        decoration: InputDecoration(
          hintText: '分享新鲜事…',
          hintStyle: TextStyle(color: colors.textSecondary, fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        textInputAction: TextInputAction.newline,
      ),
    );
  }

  /// 图片/视频选择区域：横向滚动
  /// 顺序：照片缩略图 → 已选视频预览 → 「添加照片」→「添加视频」（两个添加按钮始终相邻且可见）
  Widget _buildMediaPicker(AppColors colors) {
    final hasMedia = _selectedImages.isNotEmpty || _video != null;
    final hasVideo = _video != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, hasMedia ? 12 : 0),
      child: SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedImages.length + (hasVideo ? 1 : 0) + 2,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            // 照片缩略图
            if (i < _selectedImages.length) {
              return _buildImageThumb(i);
            }
            // 已选视频预览（紧跟照片，位于添加按钮左侧）
            if (hasVideo && i == _selectedImages.length) {
              return _buildVideoPreview();
            }
            // 添加照片按钮
            if (i == _selectedImages.length + (hasVideo ? 1 : 0)) {
              return _buildAddButton(colors);
            }
            // 添加视频按钮（始终显示，不被视频预览覆盖）
            return _buildVideoAddButton(colors);
          },
        ),
      ),
    );
  }

  /// 图片缩略图（圆角矩形，显示本地文件，带删除按钮）
  Widget _buildImageThumb(int index) {
    return Stack(
      children: [
        // 圆角矩形缩略图，显示本地图片
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(_selectedImages[index]),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
        // 右上角删除按钮
        Positioned(
          top: -2,
          right: -2,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  /// 添加照片按钮：白色方形 + 灰色加号 + 「添加照片」文字
  Widget _buildAddButton(AppColors colors) {
    final isFull = _selectedImages.length >= _maxImages;
    return GestureDetector(
      onTap: isFull ? null : _pickImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isFull ? colors.divider : colors.placeholder,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 32,
              color: isFull
                  ? colors.textSecondary.withValues(alpha: 0.4)
                  : colors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              '添加照片',
              style: TextStyle(
                fontSize: 11,
                color: isFull
                    ? colors.textSecondary.withValues(alpha: 0.4)
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加视频按钮：白色方形 + 播放图标 + 「添加视频」文字（始终显示）
  Widget _buildVideoAddButton(AppColors colors) {
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colors.placeholder,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 30,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              '添加视频',
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// 已选视频预览块：黑色方形 + 播放图标 + 文件名 + 移除按钮
  Widget _buildVideoPreview() {
    final video = _video!;
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF1B1B22),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _videoName(video.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: GestureDetector(
            onTap: _removeVideo,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  String _videoName(String name) =>
      name.length > 8 ? '${name.substring(0, 7)}…' : name;

  /// 功能列表项：标记位置 / 自主声明 / 高级设置
  Widget _buildSettingsList(AppColors colors) {
    return Column(
      children: [
        _buildSettingItem(
          Icons.location_on_outlined,
          '标记位置',
          _location.isEmpty ? '' : _location,
          colors,
          true,
          _pickLocation,
        ),
        _buildSettingItem(
          Icons.verified_outlined,
          '自主声明',
          _originalDeclared ? '已声明原创' : '未声明',
          colors,
          true,
          _toggleOriginal,
        ),
        _buildSettingItem(
          Icons.tune,
          '高级设置',
          _channelTag.isEmpty ? '' : _channelTag,
          colors,
          false,
          _editChannel,
        ),
      ],
    );
  }

  /// 单个设置列表项
  Widget _buildSettingItem(
    IconData icon,
    String title,
    String value,
    AppColors colors,
    bool showDivider,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: Colors.black87),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value.isEmpty ? title : '$title：$value',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: value.isEmpty
                            ? Colors.black87
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Divider(height: 1, color: colors.divider),
          ),
      ],
    );
  }

  /// 标记位置：从常用地点中选择（写入 post.location）
  Future<void> _pickLocation() async {
    const locations = [
      '手作市集',
      '工作室',
      '家里',
      '咖啡店',
      '学校',
      '公园',
    ];
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              '标记位置',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            for (final l in locations)
              ListTile(
                dense: true,
                title: Text(l),
                trailing: _location == l
                    ? Icon(Icons.check_rounded,
                        color: AppColors.light.primary, size: 20)
                    : null,
                onTap: () => Navigator.pop(sheetContext, l),
              ),
            if (_location.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pop(sheetContext, ''),
                child: const Text('不显示位置'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _location = picked);
  }

  /// 自主声明：原创声明开关
  Future<void> _toggleOriginal() async {
    final value = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('自主声明'),
        content: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('声明为原创作品'),
          value: _originalDeclared,
          onChanged: (v) => Navigator.pop(dialogContext, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (value != null) setState(() => _originalDeclared = value);
  }

  /// 高级设置：频道标签（进入对应频道信息流）
  Future<void> _editChannel() async {
    final controller = TextEditingController(text: _channelTag);
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '频道标签',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: '如：#手作日常 / #陶艺研究所',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(sheetContext, controller.text.trim()),
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null) return;
    var tag = value;
    if (tag.isNotEmpty && !tag.startsWith('#')) tag = '#$tag';
    setState(() => _channelTag = tag);
  }

  /// 底部工具栏：表情图标 + 文本T图标
  Widget _buildBottomToolbar(AppColors colors) {
    return Container(
      height: 48,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, size: 24),
            color: colors.textSecondary,
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40),
          ),
          IconButton(
            icon: Icon(Icons.text_fields, size: 24),
            color: colors.textSecondary,
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40),
          ),
        ],
      ),
    );
  }
}
