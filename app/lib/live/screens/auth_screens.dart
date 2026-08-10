import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/api_client.dart';
import '../../api/auth_store.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

final _emailReg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _usernameReg = RegExp(r'^[a-zA-Z0-9_]{2,30}$');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _accountCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _accountCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final account = _accountCtrl.text.trim();
    if (account.isEmpty) {
      showLiveSnack(context, '请输入用户名或邮箱');
      return;
    }
    if (_pwdCtrl.text.length < 6) {
      showLiveSnack(context, '密码至少 6 位');
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await AuthService.instance.login(account, _pwdCtrl.text);
      await AuthStore.instance.save(
        accessToken: r.accessToken,
        refreshToken: r.refreshToken,
        userId: r.userId,
      );
      if (!mounted) return;
      showLiveSnack(context, '登录成功');
      // save() 触发 AuthStore notifyListeners -> 路由 redirect 自动跳转首页；
      // 这里不再显式 goHome，避免与 redirect 竞态导致重复 page key 断言。
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      // 键盘弹出时不压缩页面高度，键盘直接覆盖在页面之上，
      // 避免出现“登录页变小、键盘在下方”的上下分层效果。
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 90),
                  const Center(
                    child: Text(
                      'Think Origin',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: LiveColors.textPrimary,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      '发现手作 · 遇见同好',
                      style: TextStyle(fontSize: 13, color: LiveColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 46),
                  TextField(
                    controller: _accountCtrl,
                    maxLength: 255,
                    decoration: const InputDecoration(
                      hintText: '用户名 / 邮箱',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pwdCtrl,
                    obscureText: _obscure,
                    maxLength: 32,
                    decoration: InputDecoration(
                      hintText: '请输入密码',
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: LiveColors.textTertiary,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => LiveRoutes.push(context, RoutePaths.loginForgot),
                      child: const Text(
                        '忘记密码？',
                        style: TextStyle(fontSize: 13, color: LiveColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: '登录',
                    color: Colors.black,
                    textColor: Colors.white,
                    borderRadius: 16,
                    onTap: _loading ? null : _login,
                    loading: _loading,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => LiveRoutes.push(
                            context,
                            RoutePaths.loginRegister,
                          ),
                          child: const Text(
                            '注册新账号',
                            style: TextStyle(color: LiveColors.textSecondary, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // 协议文字固定在页面底部略上位置，不随内容滚动。
          Padding(
            padding: const EdgeInsets.only(bottom: 28, top: 8),
            child: const Center(
              child: Text(
                '注册即代表同意《用户协议》和《隐私政策》',
                style: TextStyle(fontSize: 11, color: LiveColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 注册：用户名 + 密码 + 邮箱绑定（邮箱验证码校验）。
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _sending = false;
  bool _obscure = true;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [
      _usernameCtrl,
      _emailCtrl,
      _codeCtrl,
      _pwdCtrl,
      _confirmCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _emailOk => _emailReg.hasMatch(_emailCtrl.text.trim());

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _sendCode() async {
    if (!_emailOk) {
      showLiveSnack(context, '请输入正确的邮箱');
      return;
    }
    setState(() => _sending = true);
    try {
      final code =
          await AuthService.instance.sendEmailCode(_emailCtrl.text.trim());
      if (!mounted) return;
      if (code != null) {
        showLiveSnack(context, '验证码已发送（开发环境：$code）');
      } else {
        showLiveSnack(context, '验证码已发送');
      }
      _startCountdown();
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _register() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (!_usernameReg.hasMatch(username)) {
      showLiveSnack(context, '用户名需为 2-30 位字母、数字或下划线');
      return;
    }
    if (!_emailOk) {
      showLiveSnack(context, '请输入正确的邮箱');
      return;
    }
    if (_codeCtrl.text.trim().length != 6) {
      showLiveSnack(context, '请输入 6 位验证码');
      return;
    }
    if (_pwdCtrl.text.length < 6) {
      showLiveSnack(context, '密码至少 6 位');
      return;
    }
    if (_pwdCtrl.text != _confirmCtrl.text) {
      showLiveSnack(context, '两次输入的密码不一致');
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await AuthService.instance.register(
        username: username,
        email: email,
        password: _pwdCtrl.text,
        emailCode: _codeCtrl.text.trim(),
      );
      await AuthStore.instance.save(
        accessToken: r.accessToken,
        refreshToken: r.refreshToken,
        userId: r.userId,
      );
      if (!mounted) return;
      showLiveSnack(context, '注册成功，欢迎加入 Think Origin');
      // save() 触发 AuthStore notifyListeners -> 路由 redirect 自动跳转首页
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      resizeToAvoidBottomInset: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '注册新账号',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: LiveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '用用户名和密码注册，绑定邮箱用于找回密码',
              style: TextStyle(fontSize: 13, color: LiveColors.textSecondary),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _usernameCtrl,
              maxLength: 30,
              decoration: const InputDecoration(
                hintText: '用户名（2-30 位字母/数字/下划线）',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              maxLength: 255,
              decoration: const InputDecoration(hintText: '邮箱（用于绑定和找回密码）', counterText: ''),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(hintText: '邮箱验证码', counterText: ''),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 118,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: (_countdown > 0 || _sending) ? null : _sendCode,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LiveColors.brand,
                      side: const BorderSide(color: LiveColors.brand, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _countdown > 0 ? '${_countdown}s 后重发' : '获取验证码',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwdCtrl,
              obscureText: _obscure,
              maxLength: 32,
              decoration: InputDecoration(
                hintText: '设置密码（6-32 位）',
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: LiveColors.textTertiary,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              maxLength: 32,
              decoration: const InputDecoration(hintText: '确认密码', counterText: ''),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: '注册',
              onTap: _loading ? null : _register,
              loading: _loading,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => LiveRoutes.replace(context, RoutePaths.login),
                  child: const Text(
                    '已有账号？去登录',
                    style: TextStyle(color: LiveColors.textSecondary, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 忘记密码：邮箱验证码校验 + 设置新密码。
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _sending = false;
  bool _obscure = true;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_emailCtrl, _codeCtrl, _pwdCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _emailOk => _emailReg.hasMatch(_emailCtrl.text.trim());

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _sendCode() async {
    if (!_emailOk) {
      showLiveSnack(context, '请输入正确的邮箱');
      return;
    }
    setState(() => _sending = true);
    try {
      final code =
          await AuthService.instance.sendEmailCode(_emailCtrl.text.trim());
      if (!mounted) return;
      if (code != null) {
        showLiveSnack(context, '验证码已发送（开发环境：$code）');
      } else {
        showLiveSnack(context, '验证码已发送');
      }
      _startCountdown();
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    if (!_emailOk) {
      showLiveSnack(context, '请输入正确的邮箱');
      return;
    }
    if (_codeCtrl.text.trim().length != 6) {
      showLiveSnack(context, '请输入 6 位验证码');
      return;
    }
    if (_pwdCtrl.text.length < 6) {
      showLiveSnack(context, '密码至少 6 位');
      return;
    }
    if (_pwdCtrl.text != _confirmCtrl.text) {
      showLiveSnack(context, '两次输入的密码不一致');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.resetPassword(
        email: email,
        emailCode: _codeCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
      if (!mounted) return;
      showLiveSnack(context, '密码重置成功，请重新登录');
      LiveRoutes.replace(context, RoutePaths.login);
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      resizeToAvoidBottomInset: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '忘记密码',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: LiveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '通过绑定邮箱验证后设置新密码',
              style: TextStyle(fontSize: 13, color: LiveColors.textSecondary),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              maxLength: 255,
              decoration: const InputDecoration(hintText: '绑定邮箱', counterText: ''),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(hintText: '邮箱验证码', counterText: ''),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 118,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: (_countdown > 0 || _sending) ? null : _sendCode,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LiveColors.brand,
                      side: const BorderSide(color: LiveColors.brand),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _countdown > 0 ? '${_countdown}s' : '获取验证码',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwdCtrl,
              obscureText: _obscure,
              maxLength: 32,
              decoration: InputDecoration(
                hintText: '设置新密码（6-32 位）',
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: LiveColors.textTertiary,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              maxLength: 32,
              decoration: const InputDecoration(hintText: '确认新密码', counterText: ''),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: '重置密码',
              onTap: _loading ? null : _submit,
              loading: _loading,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => LiveRoutes.replace(context, RoutePaths.login),
                  child: const Text(
                    '返回登录',
                    style: TextStyle(color: LiveColors.textSecondary, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 修改登录密码（设置-账号与安全）：原密码 + 新密码 + 确认新密码。
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    for (final c in [_oldCtrl, _newCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final old = _oldCtrl.text;
    final next = _newCtrl.text;
    if (old.isEmpty) {
      showLiveSnack(context, '请输入原密码');
      return;
    }
    if (next.length < 6) {
      showLiveSnack(context, '新密码至少 6 位');
      return;
    }
    if (next != _confirmCtrl.text) {
      showLiveSnack(context, '两次输入的新密码不一致');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance
          .changePassword(oldPassword: old, newPassword: next);
      if (!mounted) return;
      showLiveSnack(context, '密码修改成功');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          const LiveAppBar(title: '修改密码'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '修改登录密码',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: LiveColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '验证原密码后设置新密码，下次登录请使用新密码',
                    style: TextStyle(
                      fontSize: 13,
                      color: LiveColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _oldCtrl,
                    obscureText: _obscureOld,
                    maxLength: 32,
                    decoration: InputDecoration(
                      hintText: '原密码',
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureOld
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: LiveColors.textTertiary,
                        ),
                        onPressed: () =>
                            setState(() => _obscureOld = !_obscureOld),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newCtrl,
                    obscureText: _obscureNew,
                    maxLength: 32,
                    decoration: InputDecoration(
                      hintText: '新密码（6-32 位）',
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: LiveColors.textTertiary,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    maxLength: 32,
                    decoration: const InputDecoration(
                      hintText: '确认新密码',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: '确认修改',
                    onTap: _loading ? null : _submit,
                    loading: _loading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
