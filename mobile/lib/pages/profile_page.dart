import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/auth_service.dart';

/// 我的：资料区 + 功能列表（卡包/点赞收藏/作品/历史/订单）
/// 对齐《第一阶段UI设计指导》§七
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _editNickname(BuildContext context) async {
    final controller = TextEditingController(
      text: AuthService.instance.user?.nickname ?? '',
    );
    final nickname = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑昵称'),
        content: TextField(
          controller: controller,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '请输入昵称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (nickname != null && nickname.isNotEmpty && context.mounted) {
      try {
        await AuthService.instance.updateNickname(nickname);
      } on DioException catch (e) {
        final data = e.response?.data;
        final msg = data is Map && data['message'] != null
            ? data['message'].toString()
            : '保存失败';
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) {
          final user = AuthService.instance.user;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InkWell(
                onTap: () => _editNickname(context),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFFE8633A),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nickname.isNotEmpty == true
                                ? user!.nickname
                                : '手作新人',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.phone ?? '',
                            style:
                                const TextStyle(color: Color(0xFF8A8A8A)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, color: Color(0xFF8A8A8A)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _MenuTile(icon: Icons.confirmation_number_outlined, label: '卡包'),
              const _MenuTile(icon: Icons.favorite_border, label: '点赞与收藏'),
              const _MenuTile(icon: Icons.photo_library_outlined, label: '个人作品'),
              const _MenuTile(icon: Icons.history, label: '观看历史'),
              const _MenuTile(icon: Icons.receipt_long_outlined, label: '我的订单'),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => AuthService.instance.logout(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD9453E),
                  side: const BorderSide(color: Color(0xFFD9453E)),
                ),
                child: const Text('退出登录'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF2B2B2B)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          const Icon(Icons.chevron_right, color: Color(0xFF8A8A8A)),
        ],
      ),
    );
  }
}
