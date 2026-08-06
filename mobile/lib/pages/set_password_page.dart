import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import '../widgets/agreement_checkbox.dart';

/// 密码操作场景：找回密码（未登录） / 修改密码（已登录）
enum PasswordMode { forgot, change }

/// 设置 / 重置密码：微信式短信验证码校验后写入新密码。
/// - 找回密码：手机号可编辑，需勾选协议；
/// - 修改密码：自动带入当前账号手机号，只发验证码不重输手机号。
class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({
    super.key,
    this.mode = PasswordMode.forgot,
    this.initialPhone,
  });

  final PasswordMode mode;
  final String? initialPhone;

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  late final bool _isChange = widget.mode == PasswordMode.change;
  late final TextEditingController _phoneCtrl = TextEditingController(
    text: _isChange
        ? (widget.initialPhone ?? AuthService.instance.user?.phone ?? '')
        : (widget.initialPhone ?? ''),
  );
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _sendingCode = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreed = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 已登录的修改密码场景无需再勾选协议
    _agreed = _isChange;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
    if (!_isChange && !_agreed) {
      _showError('请先阅读并同意《用户协议》和《隐私政策》');
      return;
    }
    final phoneValid = RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneCtrl.text);
    if (!phoneValid) {
      _formKey.currentState!.validate();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isChange && !_agreed) {
      _showError('请先阅读并同意《用户协议》和《隐私政策》');
      return;
    }
    setState(() => _submitting = true);
    try {
      await AuthService.instance.setPassword(
        _phoneCtrl.text,
        _codeCtrl.text,
        _passwordCtrl.text,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(_isChange ? '密码修改成功' : '密码重置成功，请使用新密码登录')),
      );
    } on DioException catch (e) {
      _showError(_message(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isChange ? '修改密码' : '找回密码')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  _isChange ? '验证码将发送到当前绑定手机号，通过后设置新密码' : '通过短信验证码验证身份后设置新密码',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneCtrl,
                  enabled: !_isChange,
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
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  maxLength: 32,
                  decoration: InputDecoration(
                    labelText: '新密码（至少 6 位）',
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  maxLength: 32,
                  decoration: InputDecoration(
                    labelText: '确认新密码',
                    counterText: '',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) =>
                      v != _passwordCtrl.text ? '两次输入的密码不一致' : null,
                ),
                if (!_isChange) ...[
                  const SizedBox(height: 20),
                  AgreementCheckbox(
                    checked: _agreed,
                    onChanged: (v) => setState(() => _agreed = v),
                    notice: '通过验证码重置密码即代表您已同意',
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isChange ? '确认修改' : '确认重置'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
