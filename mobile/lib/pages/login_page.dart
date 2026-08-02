import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/auth_service.dart';

/// 登录 / 注册（手机号验证码）：未注册手机号登录时自动注册。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _sendingCode = false;
  bool _loggingIn = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sendingCode = true);
    try {
      await AuthService.instance.sendCode(_phoneCtrl.text);
      if (!mounted) return;
      _startCountdown();
    } on DioException catch (e) {
      _showError(_message(e));
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                const SizedBox(height: 32),
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
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: '验证码',
                    counterText: '',
                    prefixIcon: const Icon(Icons.sms_outlined),
                    suffixIcon: TextButton(
                      onPressed: (_countdown > 0 || _sendingCode)
                          ? null
                          : _sendCode,
                      child: Text(
                        _countdown > 0 ? '$_countdown 秒后重发' : '获取验证码',
                        style: const TextStyle(color: Color(0xFFE8633A)),
                      ),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || !RegExp(r'^\d{6}$').hasMatch(v))
                          ? '请输入 6 位验证码'
                          : null,
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
          ),
        ),
      ),
    );
  }
}
