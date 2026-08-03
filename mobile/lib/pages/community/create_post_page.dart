import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/post_api.dart';

/// 作品发布页：图文 ≤9 图、文案、标签
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _images = <String>[]; // 图片 URL 列表
  final _tags = <String>[];
  bool _submitting = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isEmpty) return;
    if (_tags.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标签已存在')),
      );
      return;
    }
    setState(() => _tags.add(tag));
    _tagCtrl.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _addImage() {
    // 一期：使用占位图片 URL（后续接入 OSS 上传）
    if (_images.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多上传 9 张图片')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) {
        final urlCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('添加图片'),
          content: TextField(
            controller: urlCtrl,
            decoration: const InputDecoration(
              hintText: '粘贴图片 URL（一期占位，后续接入 OSS 上传）',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final url = urlCtrl.text.trim();
                if (url.isNotEmpty) {
                  setState(() => _images.add(url));
                }
                Navigator.pop(ctx);
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写文案或添加图片')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await PostApi.create(
        content: content,
        images: _images,
        tags: _tags,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布成功，等待审核')),
        );
        Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布作品'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('发布', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            const Text('添加图片（最多 9 张）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._images.map(
                  (url) => Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.remove(url)),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_images.length < 9)
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.divider, width: 1.5),
                        color: colors.surface,
                      ),
                      child: Icon(Icons.add_photo_alternate_outlined, color: colors.textSecondary),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // 文案区域
            const Text('文案', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              maxLines: 5,
              maxLength: 5000,
              decoration: const InputDecoration(
                hintText: '分享你的手作体验…',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 20),

            // 标签区域
            const Text('标签', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(
                      hintText: '输入标签名',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addTag,
                  style: FilledButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('添加'),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tags.map(
                  (t) => Chip(
                    label: Text(t, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => _removeTag(t),
                    backgroundColor: const Color(0x1AE8633A),
                    side: BorderSide.none,
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
