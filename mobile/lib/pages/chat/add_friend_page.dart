import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../core/follow_api.dart';
import '../../core/user_api.dart';
import '../../widgets/state_widgets.dart';
import 'chat_page.dart';

/// 添加好友：按手机号搜索 → 关注 / 发消息
class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _phoneCtrl = TextEditingController();
  bool _searching = false;
  bool _searched = false;
  String? _error;
  SearchedUser? _result;
  bool? _following;
  bool _followBusy = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _toast('请输入对方手机号');
      return;
    }
    setState(() {
      _searching = true;
      _searched = true;
      _error = null;
      _result = null;
      _following = null;
    });
    try {
      final items = await UserApi.searchByPhone(phone);
      if (!mounted) return;
      setState(() {
        _result = items.isEmpty ? null : items.first;
        _searching = false;
      });
      if (_result != null) _loadFollowStatus(_result!.id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _searching = false;
          _error = '搜索失败，请重试';
        });
      }
    }
  }

  Future<void> _loadFollowStatus(int userId) async {
    try {
      final status = await FollowApi.status(userId);
      if (mounted && _result?.id == userId) {
        setState(() => _following = status.following);
      }
    } catch (_) {
      // 关注状态加载失败时按钮回退为「加好友」
    }
  }

  Future<void> _toggleFollow() async {
    final user = _result;
    if (user == null || _followBusy) return;
    final target = !(_following ?? false);
    setState(() => _followBusy = true);
    try {
      final status = await FollowApi.setFollow(user.id, following: target);
      if (mounted) {
        setState(() => _following = status.following);
        _toast(status.following ? '已关注 ${user.nickname}' : '已取消关注');
      }
    } catch (_) {
      if (mounted) _toast('操作失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  Future<void> _openChat() async {
    final user = _result;
    if (user == null) return;
    try {
      final conv = await ChatApi.createConversation(user.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatPage(conversation: conv)),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) _toast('发起会话失败，请稍后再试');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('添加好友')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    decoration: InputDecoration(
                      hintText: '输入对方手机号',
                      prefixIcon: const Icon(Icons.phone_iphone, size: 20),
                      counterText: '',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: _searching ? null : _search,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(76, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      _searching ? '搜索中' : '搜索',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildResult(colors)),
        ],
      ),
    );
  }

  Widget _buildResult(AppColors colors) {
    if (_searching) return const LoadingWidget(message: '搜索中…');
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _search);
    }
    if (!_searched) {
      return const EmptyWidget(
        icon: Icons.person_search_outlined,
        message: '输入手机号搜索用户',
      );
    }
    if (_result == null) {
      return const EmptyWidget(
        icon: Icons.search_off,
        message: '未找到该用户\n请确认手机号是否正确',
      );
    }
    final user = _result!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.divider),
          ),
          child: Row(
            children: [
              _avatar(user, colors),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phoneMasked,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: (_following ?? false) ? null : _toggleFollow,
          style: FilledButton.styleFrom(
            backgroundColor: (_following ?? false)
                ? colors.placeholder
                : colors.primary,
            foregroundColor:
                (_following ?? false) ? colors.textSecondary : Colors.white,
          ),
          child: Text(
            _followBusy
                ? '处理中…'
                : (_following ?? false)
                    ? '已关注'
                    : '加好友',
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _openChat,
          child: const Text('发消息'),
        ),
      ],
    );
  }

  Widget _avatar(SearchedUser user, AppColors colors) {
    final avatar = user.resolvedAvatar;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.placeholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatar.isEmpty
          ? Center(
              child: Text(
                user.nickname.isEmpty ? '#' : user.nickname.characters.first,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            )
          : Image.network(
              avatar,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.person,
                color: colors.textSecondary,
              ),
            ),
    );
  }
}
