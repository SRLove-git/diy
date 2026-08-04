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
      // 素材选择功能待实现，当前提交无图帖子
      final post = await PostApi.create(
        content: desc.isEmpty ? title : '$title\n$desc',
        images: const [],
        tags: const [],
        title: title,
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
        // 手机样式视频预览卡片（素材选择功能待实现，先显示空态）
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
                  Container(
                    color: _btnBg,
                    child: const Center(
                      child: Icon(Icons.videocam, color: _hint, size: 48),
                    ),
                  ),
                  // 播放按钮叠加
                  const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: _white,
                      size: 56,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 添加素材按钮
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
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
              ),
            ],
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
