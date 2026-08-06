import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import '../widgets/agreement_checkbox.dart';
import 'set_password_page.dart';

/// 登录方式：验证码登录/注册为主流程，密码登录与用户名登录为次级入口。
enum _LoginMode { code, password, username }

/// 登录 / 注册（微信式）：验证码登录未注册自动注册；无独立注册页，
/// 登录前必须勾选协议；忘记密码走短信验证重设。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _namePasswordCtrl = TextEditingController();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();

  _LoginMode _mode = _LoginMode.code;
  bool _agreed = false;
  bool _sendingCode = false;
  bool _loggingIn = false;
  bool _passwordLoggingIn = false;
  bool _usernameLoggingIn = false;
  bool _obscurePassword = true;
  bool _obscureNamePassword = true;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _namePasswordCtrl.dispose();
    super.dispose();
  }

  void _switchMode(_LoginMode mode) {
    setState(() => _mode = mode);
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
    if (!_ensureAgreed()) return;
    // 只校验手机号：获取验证码时验证码框为空是正常的，不能全表单校验
    final phoneValid = RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneCtrl.text);
    if (!phoneValid) {
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
    if (!_ensureAgreed()) return;
    if (!_codeFormKey.currentState!.validate()) return;
    setState(() => _loggingIn = true);
    try {
      final isNewUser = await AuthService.instance.login(
        _phoneCtrl.text,
        _codeCtrl.text,
      );
      // 登录成功后 AuthGate 自动切换到主界面
      if (isNewUser && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('注册成功，欢迎加入 IDOL BEADS')));
      }
    } on DioException catch (e) {
      _showError(_message(e));
    } finally {
      if (mounted) setState(() => _loggingIn = false);
    }
  }

  Future<void> _passwordLogin() async {
    if (!_ensureAgreed()) return;
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _passwordLoggingIn = true);
    try {
      await AuthService.instance.passwordLogin(
        _phoneCtrl.text,
        _passwordCtrl.text,
      );
      // 登录成功后 AuthGate 自动切换到主界面
    } on DioException catch (e) {
      _showError(_message(e));
    } finally {
      if (mounted) setState(() => _passwordLoggingIn = false);
    }
  }

  Future<void> _usernameLogin() async {
    if (!_ensureAgreed()) return;
    if (!_usernameFormKey.currentState!.validate()) return;
    setState(() => _usernameLoggingIn = true);
    try {
      await AuthService.instance.usernameLogin(
        _usernameCtrl.text,
        _namePasswordCtrl.text,
      );
      // 登录成功后 AuthGate 自动切换到主界面
    } on DioException catch (e) {
      _showError(_message(e));
    } finally {
      if (mounted) setState(() => _usernameLoggingIn = false);
    }
  }

  void _goSetPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SetPasswordPage(mode: PasswordMode.forgot),
      ),
    );
  }

  bool _ensureAgreed() {
    if (_agreed) return true;
    _showError('请先阅读并同意《用户协议》和《隐私政策》');
    return false;
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: Palette.gradientPink,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Palette.accentTint,
                        blurRadius: 18,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'IDOL BEADS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '拼出美好 · 豆住快乐',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(key: ValueKey(_mode), child: _buildForm()),
              ),
              const SizedBox(height: 8),
              _buildModeSwitcher(),
              const SizedBox(height: 16),
              AgreementCheckbox(
                checked: _agreed,
                onChanged: (v) => setState(() => _agreed = v),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (_mode) {
      case _LoginMode.code:
        return _buildCodeTab();
      case _LoginMode.password:
        return _buildPasswordTab();
      case _LoginMode.username:
        return _buildUsernameTab();
    }
  }

  /// 验证码登录 / 注册表单（主流程）
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
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                    ),
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
                : const Text('登录 / 注册'),
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
            validator: (v) => (v == null || v.length < 6) ? '密码至少 6 位' : null,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goSetPassword,
              child: Text(
                '忘记密码？',
                style: TextStyle(color: AppColors.of(context).textSecondary),
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

  /// 用户名登录表单
  Widget _buildUsernameTab() {
    return Form(
      key: _usernameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameCtrl,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: '用户名',
              counterText: '',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v == null || v.trim().length < 2) ? '用户名至少 2 位' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _namePasswordCtrl,
            obscureText: _obscureNamePassword,
            maxLength: 32,
            decoration: InputDecoration(
              labelText: '密码',
              counterText: '',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNamePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(
                  () => _obscureNamePassword = !_obscureNamePassword,
                ),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? '密码至少 6 位' : null,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goSetPassword,
              child: Text(
                '忘记密码？',
                style: TextStyle(color: AppColors.of(context).textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _usernameLoggingIn ? null : _usernameLogin,
            child: _usernameLoggingIn
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

  /// 次级登录入口切换：验证码登录是主流程，密码/用户名登录为链接入口
  Widget _buildModeSwitcher() {
    final colors = AppColors.of(context);
    final links = <Widget>[
      if (_mode != _LoginMode.code)
        _ModeLink(label: '验证码登录', onTap: () => _switchMode(_LoginMode.code)),
      if (_mode != _LoginMode.password)
        _ModeLink(label: '密码登录', onTap: () => _switchMode(_LoginMode.password)),
      if (_mode != _LoginMode.username)
        _ModeLink(
          label: '用户名登录',
          onTap: () => _switchMode(_LoginMode.username),
        ),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: [
        for (var i = 0; i < links.length; i++) ...[
          if (i > 0)
            Text(
              '·',
              style: TextStyle(color: colors.textTertiary, fontSize: 13),
            ),
          links[i],
        ],
      ],
    );
  }
}

class _ModeLink extends StatelessWidget {
  const _ModeLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.of(context).textSecondary,
        ),
      ),
    );
  }
}
