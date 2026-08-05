import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../core/follow_api.dart';
import '../../widgets/state_widgets.dart';
import 'group_chat_page.dart';

/// 发起群聊：输入群名 + 从已关注用户中多选成员
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _nameCtrl = TextEditingController();
  List<FollowUser> _candidates = [];
  final Set<int> _selected = {};
  bool _loading = true;
  String? _error;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await FollowApi.fetchFollowing();
      if (mounted) {
        setState(() {
          _candidates = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败，请重试';
        });
      }
    }
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _toast('请输入群聊名称');
      return;
    }
    if (_selected.isEmpty) {
      _toast('请至少选择一名成员');
      return;
    }
    setState(() => _creating = true);
    try {
      final group = await GroupApi.createGroup(
        name: name,
        memberIds: _selected.toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GroupChatPage(group: group)),
      );
    } catch (e) {
      if (mounted) {
        _toast(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
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
      appBar: AppBar(title: const Text('发起群聊')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _nameCtrl,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: '输入群聊名称',
                prefixIcon: const Icon(Icons.groups_outlined, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Text(
                  '选择成员',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '已选 ${_selected.length} 人',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(child: _buildMemberList(colors)),
          _buildCreateBar(colors),
        ],
      ),
    );
  }

  Widget _buildMemberList(AppColors colors) {
    if (_loading) return const LoadingWidget(message: '加载关注列表…');
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    if (_candidates.isEmpty) {
      return const EmptyWidget(
        icon: Icons.person_search_outlined,
        message: '还没有关注的人\n先去社区关注感兴趣的作者吧',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _candidates.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: colors.divider),
      itemBuilder: (context, index) {
        final user = _candidates[index];
        final checked = _selected.contains(user.id);
        return InkWell(
          onTap: () {
            setState(() {
              checked ? _selected.remove(user.id) : _selected.add(user.id);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _avatar(user, colors),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.nickname.isEmpty ? '用户 #${user.id}' : user.nickname,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Icon(
                  checked
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: checked ? colors.primary : colors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _avatar(FollowUser user, AppColors colors) {
    final avatar = user.resolvedAvatar;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.placeholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatar.isEmpty
          ? Center(
              child: Text(
                user.nickname.isEmpty ? '#' : user.nickname.characters.first,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildCreateBar(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: FilledButton(
            onPressed: _creating ? null : _create,
            child: Text(_creating ? '创建中…' : '创建群聊'),
          ),
        ),
      ),
    );
  }
}
