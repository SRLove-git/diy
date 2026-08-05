import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/post_api.dart';
import '../../widgets/image_viewer.dart';

/// 编辑主页：修改头像 + 名字 / 用户名 / 简介 / 性别 / 生日 / 所在地。
/// 保存成功后返回 true，供个人主页刷新。
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  late String _nickname;
  late String _username;
  late String _bio;
  late String _gender;
  late String? _birthday;
  late String _location;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.user;
    _nickname = user?.nickname ?? '';
    _username = user?.username ?? '';
    _bio = user?.bio ?? '';
    _gender = user?.gender ?? 'secret';
    _birthday = user?.birthday;
    _location = user?.location ?? '';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── 保存 ───
  Future<void> _save() async {
    final nickname = _nickname.trim();
    final username = _username.trim();
    if (nickname.isEmpty) {
      _toast('请填写名字');
      return;
    }
    if (username.isNotEmpty &&
        !RegExp(r'^[a-zA-Z0-9_]{2,30}$').hasMatch(username)) {
      _toast('用户名需为 2-30 位字母、数字或下划线');
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateProfile(
        nickname: nickname,
        username: username, // 空串交给服务端清空
        bio: _bio.trim(),
        gender: _gender,
        birthday: _birthday ?? '', // 空串交给服务端清空
        location: _location.trim(),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(const SnackBar(content: Text('资料已保存')));
    } on DioException catch (e) {
      if (mounted) _toast(PostApi.messageOf(e));
    } catch (_) {
      if (mounted) _toast('保存失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── 头像 ───
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
  }

  void _openAvatarMenu() {
    final user = AuthService.instance.user;
    final hasAvatar = _isValidImageUrl(user?.avatar);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('查看头像'),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewAvatar(user!.avatar);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('取消'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _viewAvatar(String avatar) {
    showImageViewer(
      context,
      image: networkViewerImage(ChatApi.resolveUrl(avatar)),
      heroTag: 'edit-profile-avatar',
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (_) {
      _toast('无法打开相机/相册');
      return;
    }
    if (picked == null) return;
    try {
      await AuthService.instance.updateAvatar(picked.path);
      if (mounted) _toast('头像已更新');
    } on DioException catch (e) {
      if (mounted) _toast(PostApi.messageOf(e));
    } catch (_) {
      if (mounted) _toast('头像上传失败，请稍后再试');
    }
  }

  // ─── 文本输入 ───
  Future<String?> _promptText({
    required String title,
    required String hint,
    required int maxLength,
    required String initial,
    bool multiline = false,
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: maxLength,
          minLines: multiline ? 3 : 1,
          maxLines: multiline ? 6 : 1,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _editGender() async {
    const options = [
      (value: 'male', label: '男'),
      (value: 'female', label: '女'),
      (value: 'secret', label: '保密'),
    ];
    final colors = AppColors.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '性别',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(option.label, textAlign: TextAlign.center),
                trailing: _gender == option.value
                    ? Icon(Icons.check_rounded, color: colors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, option.value),
              ),
            ListTile(
              title: const Text('取消', textAlign: TextAlign.center),
              textColor: colors.textSecondary,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _gender = selected);
    }
  }

  Future<void> _editBirthday() async {
    final colors = AppColors.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '生日',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('选择生日'),
              onTap: () => Navigator.pop(ctx, 'pick'),
            ),
            if (_birthday != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.danger),
                title: Text(
                  '清除生日',
                  style: TextStyle(color: colors.danger),
                ),
                onTap: () => Navigator.pop(ctx, 'clear'),
              ),
            ListTile(
              title: const Text('取消', textAlign: TextAlign.center),
              textColor: colors.textSecondary,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'clear') {
      setState(() => _birthday = null);
      return;
    }
    final initial = DateTime.tryParse(_birthday ?? '') ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: '选择生日',
    );
    if (picked != null && mounted) {
      setState(() => _birthday = _dateFormat.format(picked));
    }
  }

  // ─── UI ───
  static const _genderLabels = {
    'male': '男',
    'female': '女',
    'secret': '保密',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          '编辑主页',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '保存',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) {
            final user = AuthService.instance.user;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _buildAvatarSection(user),
                const SizedBox(height: 24),
                _buildFormCard(colors),
                const SizedBox(height: 16),
                Text(
                  '用户名可用于用户名 + 密码登录，仅支持字母、数字和下划线',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarSection(User? user) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: _openAvatarMenu,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFDCE5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _isValidImageUrl(user?.avatar)
                    ? Image.network(
                        ChatApi.resolveUrl(user!.avatar),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          size: 44,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person, size: 44, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.divider),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 15,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '点击更换头像',
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFormCard(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.placeholder,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _ProfileRow(
            label: '名字',
            value: _nickname,
            placeholder: '未填写',
            onTap: () async {
              final v = await _promptText(
                title: '修改名字',
                hint: '请输入名字',
                maxLength: 30,
                initial: _nickname,
              );
              if (v != null && mounted) setState(() => _nickname = v);
            },
          ),
          _ProfileRow(
            label: '用户名',
            value: _username,
            placeholder: '未设置',
            onTap: () async {
              final v = await _promptText(
                title: '修改用户名',
                hint: '2-30 位字母、数字或下划线',
                maxLength: 30,
                initial: _username,
              );
              if (v != null && mounted) setState(() => _username = v);
            },
          ),
          _ProfileRow(
            label: '简介',
            value: _bio,
            placeholder: '未填写',
            isMultiline: true,
            onTap: () async {
              final v = await _promptText(
                title: '修改简介',
                hint: '介绍一下自己吧',
                maxLength: 200,
                initial: _bio,
                multiline: true,
              );
              if (v != null && mounted) setState(() => _bio = v);
            },
          ),
          _ProfileRow(
            label: '性别',
            value: _genderLabels[_gender] ?? '保密',
            onTap: _editGender,
          ),
          _ProfileRow(
            label: '生日',
            value: _birthday ?? '',
            placeholder: '未设置',
            onTap: _editBirthday,
          ),
          _ProfileRow(
            label: '所在地',
            value: _location,
            placeholder: '未填写',
            isLast: true,
            onTap: () async {
              final v = await _promptText(
                title: '修改所在地',
                hint: '例如：上海',
                maxLength: 60,
                initial: _location,
              );
              if (v != null && mounted) setState(() => _location = v);
            },
          ),
        ],
      ),
    );
  }
}

/// 表单行：左侧标签 + 右侧当前值 + 右侧箭头
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder,
    this.isMultiline = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? placeholder;
  final bool isMultiline;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasValue = value.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? const Radius.circular(18) : Radius.zero,
          top: isLast ? Radius.zero : const Radius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            crossAxisAlignment: isMultiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasValue ? value : (placeholder ?? ''),
                  maxLines: isMultiline ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: isMultiline ? 1.4 : null,
                    color: hasValue ? colors.textPrimary : colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
