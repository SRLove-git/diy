import 'package:flutter/material.dart';

import '../core/post_api.dart';

/// 抖音风格作品发布编辑页面
///
/// 深色暗黑主题，模仿抖音发布作品页面 UI。
/// 包含：视频预览区、图片缩略图选择、文本输入、话题标签、功能选项、底部操作栏。
class DouyinPublishPage extends StatefulWidget {
  const DouyinPublishPage({super.key});

  @override
  State<DouyinPublishPage> createState() => _DouyinPublishPageState();
}

class _DouyinPublishPageState extends State<DouyinPublishPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // 缩略图列表（占位图片 URL）
  final _thumbnails = <String>[
    'https://picsum.photos/200/300?random=1',
    'https://picsum.photos/200/300?random=2',
    'https://picsum.photos/200/300?random=3',
    'https://picsum.photos/200/300?random=4',
    'https://picsum.photos/200/300?random=5',
  ];
  int _selectedThumbIndex = 0;

  // 话题标签数据（用于展示和发布）
  final _topics = ['少女时代', '叶子', '虚拟主播', '日常', 'vlog'];

  // 地点标签数据
  final _locations = ['北京·朝阳区', '三里屯太古里', '国贸CBD'];
  int _selectedLocationIndex = 0;

  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// 提交发布作品
  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (title.isEmpty && desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写标题或描述')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      // 选中的缩略图排在最前，作为短视频封面
      final selected = _thumbnails[_selectedThumbIndex];
      final images = [selected, ..._thumbnails.where((u) => u != selected)];
      final post = await PostApi.create(
        content: desc.isEmpty ? title : '$title\n$desc',
        images: images,
        tags: _topics,
        title: title,
        location: _locations[_selectedLocationIndex],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布成功，等待审核')),
        );
        Navigator.pop(context, post);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                    _buildTopicChips(),
                    const SizedBox(height: 20),
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
            onTap: () {
              // TODO: 预览功能
            },
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
                  // 占位预览图
                  Image.network(
                    _thumbnails[_selectedThumbIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => Container(
                      color: _btnBg,
                      child: const Center(
                        child: Icon(Icons.videocam, color: _hint, size: 48),
                      ),
                    ),
                  ),
                  // 播放按钮叠加
                  const Center(
                    child: Icon(Icons.play_circle_outline, color: _white, size: 56),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 横向图片缩略图列表
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _thumbnails.length + 1, // +1 为添加按钮
            itemBuilder: (context, index) {
              // 末尾 + 号按钮
              if (index == _thumbnails.length) {
                return GestureDetector(
                  onTap: () {
                    // TODO: 添加素材
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: _btnBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _border),
                    ),
                    child: const Icon(Icons.add, color: _white, size: 24),
                  ),
                );
              }

              // 缩略图
              final isSelected = index == _selectedThumbIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedThumbIndex = index),
                child: Container(
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? _primary : _border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      _thumbnails[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => Container(color: _btnBg),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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

  // ===================== 话题标签横向滚动列表 =====================
  Widget _buildTopicChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _topics.length,
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _btnBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '#${_topics[index]}',
              style: const TextStyle(color: _white, fontSize: 13),
            ),
          );
        },
      ),
    );
  }

  // ===================== 列表式功能选项组 =====================
  Widget _buildOptionsList() {
    return Column(
      children: [
        // 1. 选择地点
        _optionRow(
          icon: Icons.location_on_outlined,
          title: '选择地点',
          onTap: () {},
        ),
        _buildLocationChips(),
        const Divider(color: _border, height: 1),

        // 2. 添加标签
        _optionRow(
          icon: Icons.label_outline,
          title: '添加标签',
          onTap: () {},
        ),
        const Divider(color: _border, height: 1),

        // 3. 添加自主声明
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

  // 地点标签横向滚动
  Widget _buildLocationChips() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 12),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _locations.length,
          separatorBuilder: (_, i) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = index == _selectedLocationIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedLocationIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? _primary.withAlpha(51) : _btnBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? _primary : _border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on,
                        color: isSelected ? _primary : _hint, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _locations[index],
                      style: TextStyle(
                        color: isSelected ? _primary : _white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
              '发布成功后将保存内容至本地',
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
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              'https://picsum.photos/100/100?random=99',
                            ),
                          ),
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
