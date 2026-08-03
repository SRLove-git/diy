import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/auth_service.dart';
import 'set_password_page.dart';

/// 登录 / 注册（验证码 + 密码双模式）：未注册手机号登录时自动注册。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _sendingCode = false;
  bool _loggingIn = false;
  bool _passwordLoggingIn = false;
  bool _obscurePassword = true;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _sendCode() async {
    // 只校验手机号：获取验证码时验证码框为空是正常的，不能全表单校验
    final phoneValid = RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneCtrl.text);
    if (!phoneValid) {
      // 触发手机号字段的错误显示
      _codeFormKey.currentState!.validate();
      return;
    }
    setState(() => _sendingCode = true);
    try {
      final code = await AuthService.instance.sendCode(_phoneCtrl.text);
      if (!mounted) return;
      _startCountdown();
      // 开发环境：自动填入验证码
      if (code != null) {
        _codeCtrl.text = code;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('验证码已填入：$code'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } on DioException catch (e) {
      _showError(_message(e));
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _login() async {
    if (!_codeFormKey.currentState!.validate()) return;
    setState(() => _loggingIn = true);
    try {
      await AuthService.instance.login(_phoneCtrl.text, _codeCtrl.text);
      // 登录成功后 AuthGate 自动切换到主界面
    } on DioException catch (e) {
      _showError(_message(e));
    } finally {
      if (mounted) setState(() => _loggingIn = false);
    }
  }

  Future<void> _passwordLogin() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _passwordLoggingIn = true);
    try {
      await AuthService.instance
          .passwordLogin(_phoneCtrl.text, _passwordCtrl.text);
      // 登录成功后 AuthGate 自动切换到主界面
    } on DioException catch (e) {
      _showError(_message(e));
    } finally {
      if (mounted) setState(() => _passwordLoggingIn = false);
    }
  }

  void _goSetPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SetPasswordPage()),
    );
  }

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join('，') : m.toString();
    }
    return '网络异常，请稍后再试';
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Icon(Icons.handyman, size: 64, color: Color(0xFFE8633A)),
                const SizedBox(height: 12),
                Text(
                  'DIY 手作工坊',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                const Text(
                  '未注册手机号将自动创建账号',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8A8A8A)),
                ),
                const SizedBox(height: 24),
                TabBar(
                  labelColor: const Color(0xFFE8633A),
                  unselectedLabelColor: const Color(0xFF8A8A8A),
                  indicatorColor: const Color(0xFFE8633A),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: '验证码登录'),
                    Tab(text: '密码登录'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 320,
                  child: TabBarView(
                    children: [_buildCodeTab(), _buildPasswordTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 验证码登录表单
  Widget _buildCodeTab() {
    return Form(
      key: _codeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            decoration: const InputDecoration(
              labelText: '手机号',
              counterText: '',
              prefixIcon: Icon(Icons.phone_iphone),
            ),
            validator: (v) =>
                (v == null || !RegExp(r'^1[3-9]\d{9}$').hasMatch(v))
                    ? '请输入正确的手机号'
                    : null,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: '验证码',
                    counterText: '',
                    prefixIcon: Icon(Icons.sms_outlined),
                  ),
                  validator: (v) =>
                      (v == null || !RegExp(r'^\d{6}$').hasMatch(v))
                          ? '请输入 6 位验证码'
                          : null,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  onPressed: (_countdown > 0 || _sendingCode)
                      ? null
                      : _sendCode,
                  child: Text(
                    _countdown > 0 ? '$_countdown 秒后重发' : '获取验证码',
                    style: const TextStyle(color: Color(0xFFE8633A)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _loggingIn ? null : _login,
            child: _loggingIn
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('登录'),
          ),
        ],
      ),
    );
  }

  /// 密码登录表单
  Widget _buildPasswordTab() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            decoration: const InputDecoration(
              labelText: '手机号',
              counterText: '',
              prefixIcon: Icon(Icons.phone_iphone),
            ),
            validator: (v) =>
                (v == null || !RegExp(r'^1[3-9]\d{9}$').hasMatch(v))
                    ? '请输入正确的手机号'
                    : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            maxLength: 32,
            decoration: InputDecoration(
              labelText: '密码',
              counterText: '',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? '密码至少 6 位' : null,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goSetPassword,
              child: const Text(
                '忘记密码？',
                style: TextStyle(color: Color(0xFFE8633A)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _passwordLoggingIn ? null : _passwordLogin,
            child: _passwordLoggingIn
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('登录'),
          ),
        ],
      ),
    );
  }
}
