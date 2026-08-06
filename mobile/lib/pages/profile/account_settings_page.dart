import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../login_page.dart';
import '../set_password_page.dart';
import 'edit_profile_page.dart';

/// 账号设置：编辑资料 / 修改密码 / 切换账号 / 退出登录。
class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final user = AuthService.instance.user;
    final display = user?.nickname.isNotEmpty == true ? user!.nickname : '手作新人';
    return Scaffold(
      appBar: AppBar(title: const Text('账号设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前账号
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.placeholder,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _Avatar(user: user),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          display,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '已登录账号',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _openEditProfile(),
                  child: const Text('编辑资料'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // 账号操作
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.placeholder,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  label: '编辑个人资料',
                  onTap: _openEditProfile,
                ),
                _SettingsTile(
                  icon: Icons.key_rounded,
                  label: '修改密码',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const SetPasswordPage(mode: PasswordMode.change),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.swap_horiz_rounded,
                  label: '切换账号',
                  onTap: _openSwitchAccount,
                ),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: '退出登录',
                  danger: true,
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const EditProfilePage()));
    if (mounted) setState(() {});
  }

  void _openSwitchAccount() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SwitchAccountSheet(),
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AuthService.instance.logout();
      // AuthGate 监听到登录态变化后自动切回登录页
    }
  }
}

/// 切换账号弹层：当前账号 + 已保存会话列表 + 添加账号。
/// 从「账号设置」或个人主页下拉菜单进入。
class SwitchAccountSheet extends StatefulWidget {
  const SwitchAccountSheet({super.key});

  @override
  State<SwitchAccountSheet> createState() => _SwitchAccountSheetState();
}

class _SwitchAccountSheetState extends State<SwitchAccountSheet> {
  bool _switching = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final user = AuthService.instance.user;
    final sessions = AuthService.instance.savedSessions;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '切换账号',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            if (user != null) _accountRow(user, active: true),
            for (final s in sessions) _savedRow(s, colors),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline_rounded,
                color: colors.primary,
              ),
              title: Text(
                '添加账号',
                style: TextStyle(color: colors.primary, fontSize: 15),
              ),
              onTap: _switching ? null : _addAccount,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _accountRow(User user, {required bool active}) {
    final colors = AppColors.of(context);
    return ListTile(
      leading: _Avatar(user: user, size: 38),
      title: Text(
        user.nickname.isNotEmpty ? user.nickname : '手作新人',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        active ? '当前账号' : '${user.id}',
        style: TextStyle(fontSize: 12, color: colors.textSecondary),
      ),
      trailing: active
          ? Icon(Icons.check_circle_rounded, color: colors.primary, size: 20)
          : IconButton(
              icon: Icon(Icons.close_rounded, color: colors.textSecondary),
              onPressed: () => AuthService.instance.removeSession(user.id),
            ),
      onTap: null,
    );
  }

  Widget _savedRow(SavedSession s, AppColors colors) {
    return ListTile(
      leading: _Avatar(userId: s.userId, avatar: s.avatar, size: 38),
      title: Text(
        s.nickname.isNotEmpty ? s.nickname : '用户 ${s.userId}',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '已保存',
        style: TextStyle(fontSize: 12, color: colors.textSecondary),
      ),
      trailing: _switching
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: Icon(Icons.close_rounded, color: colors.textSecondary),
              onPressed: () => AuthService.instance.removeSession(s.userId),
            ),
      onTap: _switching ? null : () => _switchTo(s),
    );
  }

  Future<void> _switchTo(SavedSession session) async {
    setState(() => _switching = true);
    final ok = await AuthService.instance.switchToSession(session);
    if (!mounted) return;
    setState(() => _switching = false);
    Navigator.of(context).pop();
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('切换失败，请重新登录该账号')));
    }
  }

  Future<void> _addAccount() async {
    Navigator.of(context).pop();
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const LoginPage()));
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = danger ? colors.danger : colors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.user, this.userId = 0, this.avatar = '', this.size = 52});

  /// 当前登录用户（有 user 时优先用其头像）
  final User? user;

  /// 已保存会话的用户 ID（无 user 时的兜底展示）
  final int userId;

  /// 头像 URL（相对 /uploads/ 或 http(s)）
  final String avatar;
  final double size;

  String get _avatarUrl {
    final raw = user?.avatar.isNotEmpty == true ? user!.avatar : avatar;
    return raw.isEmpty ? '' : ChatApi.resolveUrl(raw);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final url = _avatarUrl;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Palette.accentLight,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url.startsWith('http')
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.person,
                color: colors.textSecondary,
                size: size * 0.5,
              ),
            )
          : Icon(Icons.person, color: colors.textSecondary, size: size * 0.5),
    );
  }
}
