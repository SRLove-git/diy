import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/api_client.dart';
import '../../api/auth_store.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _sending = false;
  bool _loading = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  bool get _phoneOk => RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneCtrl.text.trim());

  Future<void> _sendCode() async {
    if (!_phoneOk) {
      showLiveSnack(context, '请输入正确的手机号');
      return;
    }
    setState(() => _sending = true);
    try {
      final code = await AuthService.instance.sendSmsCode(_phoneCtrl.text.trim());
      if (!mounted) return;
      if (code != null) {
        showLiveSnack(context, '验证码已发送（开发环境：$code）');
      } else {
        showLiveSnack(context, '验证码已发送');
      }
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
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _login() async {
    if (!_phoneOk) {
      showLiveSnack(context, '请输入正确的手机号');
      return;
    }
    if (_codeCtrl.text.trim().length != 6) {
      showLiveSnack(context, '请输入 6 位验证码');
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await AuthService.instance.login(
        _phoneCtrl.text.trim(),
        _codeCtrl.text.trim(),
      );
      await AuthStore.instance.save(
        accessToken: r.accessToken,
        refreshToken: r.refreshToken,
        userId: r.userId,
      );
      if (!mounted) return;
      if (r.isNewUser) {
        showLiveSnack(context, '欢迎新用户，登录成功');
      }
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
                      '手作星球',
                      style: TextStyle(
                        fontSize: 36,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: LiveColors.inputBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          '+86',
                          style: TextStyle(fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          decoration: const InputDecoration(
                            hintText: '请输入手机号',
                            counterText: '',
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            hintText: '请输入验证码',
                            counterText: '',
                          ),
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
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: '登录 / 注册',
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
                            RoutePaths.loginPassword,
                          ),
                          child: const Text(
                            '密码登录',
                            style: TextStyle(color: LiveColors.textSecondary, fontSize: 14),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => LiveRoutes.push(
                            context,
                            RoutePaths.loginSetPassword,
                          ),
                          child: const Text(
                            '忘记密码',
                            textAlign: TextAlign.center,
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
                '登录即代表同意《用户协议》和《隐私政策》',
                style: TextStyle(fontSize: 11, color: LiveColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordLoginScreen extends StatefulWidget {
  const PasswordLoginScreen({super.key});

  @override
  State<PasswordLoginScreen> createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final account = _phoneCtrl.text.trim();
    if (account.isEmpty) {
      showLiveSnack(context, '请输入手机号或用户名');
      return;
    }
    if (_pwdCtrl.text.length < 6) {
      showLiveSnack(context, '密码至少 6 位');
      return;
    }
    setState(() => _loading = true);
    try {
      final isPhone = RegExp(r'^1[3-9]\d{9}$').hasMatch(account);
      final r = isPhone
          ? await AuthService.instance.passwordLogin(account, _pwdCtrl.text)
          : await AuthService.instance.usernameLogin(account, _pwdCtrl.text);
      await AuthStore.instance.save(
        accessToken: r.accessToken,
        refreshToken: r.refreshToken,
        userId: r.userId,
      );
      // save() 触发 AuthStore notifyListeners -> 路由 redirect 自动跳转首页，
      // 无需再显式 goHome（显式导航会与 redirect 竞态导致重复 page key）。
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
              '使用密码登录',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
            ),
            const SizedBox(height: 34),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(hintText: '请输入手机号 / 用户名'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwdCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: '请输入密码',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: LiveColors.textTertiary),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => LiveRoutes.push(context, RoutePaths.loginSetPassword),
                child: const Text('忘记密码？', style: TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(label: '登录', onTap: _loading ? null : _login, loading: _loading),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => LiveRoutes.replace(context, RoutePaths.login),
                  child: const Text('验证码登录', style: TextStyle(color: LiveColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () => LiveRoutes.replace(context, RoutePaths.login),
                  child: const Text('注册新账号', style: TextStyle(color: LiveColors.textSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 忘记密码 / 设置密码（验证码校验 + 新密码 + 可选用户名）。
class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  bool _sending = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_phoneCtrl, _codeCtrl, _pwdCtrl, _confirmCtrl, _usernameCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneCtrl.text.trim())) {
      showLiveSnack(context, '请输入正确的手机号');
      return;
    }
    setState(() => _sending = true);
    try {
      final code = await AuthService.instance.sendSmsCode(_phoneCtrl.text.trim());
      if (!mounted) return;
      if (code != null) showLiveSnack(context, '验证码已发送（开发环境：$code）');
      else showLiveSnack(context, '验证码已发送');
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
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _submit() async {
    if (_phoneCtrl.text.trim().isEmpty ||
        _codeCtrl.text.trim().length != 6 ||
        _pwdCtrl.text.length < 6) {
      showLiveSnack(context, '请填写手机号、验证码和至少 6 位的新密码');
      return;
    }
    if (_pwdCtrl.text != _confirmCtrl.text) {
      showLiveSnack(context, '两次输入的密码不一致');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.setPassword(
        phone: _phoneCtrl.text.trim(),
        code: _codeCtrl.text.trim(),
        password: _pwdCtrl.text,
        username: _usernameCtrl.text.trim().isEmpty ? null : _usernameCtrl.text.trim(),
      );
      if (!mounted) return;
      showLiveSnack(context, '密码设置成功，请登录');
      LiveRoutes.replace(context, RoutePaths.loginPassword);
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
              '设置新密码',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
            ),
            const SizedBox(height: 34),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              decoration: const InputDecoration(hintText: '请输入手机号', counterText: ''),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(hintText: '请输入验证码', counterText: ''),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(_countdown > 0 ? '${_countdown}s' : '获取验证码',
                        style: const TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: '设置新密码（6-32 位）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: '确认新密码'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(hintText: '用户名（选填，用于用户名密码登录）'),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: '重置密码', onTap: _loading ? null : _submit, loading: _loading),
          ],
        ),
      ),
    );
  }
}
