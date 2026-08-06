import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';

/// 登录页（验证码登录 + 密码登录双 Tab）
///
/// 对应新版 UI 的「01-登录 / 65-密码登录」屏，接 [AuthService] 真实接口。
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _agreed = true;
  bool _loading = false;
  bool _sendingCode = false;
  int _countdown = 0;

  @override
  void dispose() {
    _tab.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 11) {
      _toast('请输入 11 位手机号');
      return;
    }
    setState(() => _sendingCode = true);
    try {
      final code = await AuthService.instance.sendCode(phone);
      setState(() => _countdown = 60);
      _tick();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              code == null ? '验证码已发送' : '开发环境验证码：$code',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on Exception catch (e) {
      _toast(_errorText(e));
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  void _tick() {
    if (!mounted || _countdown <= 0) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _countdown = _countdown - 1);
      if (_countdown > 0) _tick();
    });
  }

  Future<void> _login() async {
    if (!_agreed) {
      _toast('请先同意《用户协议》和《隐私政策》');
      return;
    }
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 11) {
      _toast('请输入 11 位手机号');
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = AuthService.instance;
      if (_tab.index == 0) {
        final code = _codeCtrl.text.trim();
        if (code.isEmpty) {
          _toast('请输入验证码');
          return;
        }
        final isNew = await auth.login(phone, code);
        if (mounted && isNew) _toast('注册成功，欢迎加入手作星球！');
      } else {
        final password = _passwordCtrl.text;
        if (password.isEmpty) {
          _toast('请输入密码');
          return;
        }
        await auth.passwordLogin(phone, password);
      }
    } on Exception catch (e) {
      if (mounted) _toast(_errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _errorText(Exception e) {
    final s = e.toString();
    if (s.contains('401')) return '手机号或验证码不正确';
    if (s.contains('DioException')) {
      final msg = s.split('message: ').lastOrNull ?? '';
      return msg.isEmpty ? '网络异常，请稍后再试' : msg;
    }
    return '网络异常，请稍后再试';
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const _BrandGradientMark(),
                const SizedBox(height: 18),
                const Text(
                  'IDOL BEADS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '手作星球 · 预约到店 / 社区 / 短视频',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF737373)),
                ),
                const SizedBox(height: 40),
                TabBar(
                  controller: _tab,
                  labelColor: const Color(0xFF111111),
                  unselectedLabelColor: const Color(0xFFA8A8A8),
                  indicatorColor: const Color(0xFFED4956),
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
                const SizedBox(height: 28),
                _PhoneField(controller: _phoneCtrl),
                const SizedBox(height: 12),
                if (_tab.index == 0)
                  _CodeField(
                    controller: _codeCtrl,
                    countdown: _countdown,
                    sending: _sendingCode,
                    onSend: _sendCode,
                  )
                else
                  _PasswordField(controller: _passwordCtrl),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _loading ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: const Color(0xFFD9D9D9),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('登录', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _agreed = !_agreed),
                      child: Icon(
                        _agreed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: _agreed
                            ? const Color(0xFFED4956)
                            : const Color(0xFFA8A8A8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '登录即代表同意《用户协议》和《隐私政策》',
                      style: TextStyle(fontSize: 12, color: Color(0xFFA8A8A8)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandGradientMark extends StatelessWidget {
  const _BrandGradientMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFEDA75),
              Color(0xFFFA7E1E),
              Color(0xFFD62976),
              Color(0xFF962FBF),
              Color(0xFF4F5BD5),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 40),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
      decoration: _decoration(hint: '请输入手机号', prefix: Icons.phone_iphone),
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.countdown,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final int countdown;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: _decoration(
        hint: '请输入验证码',
        prefix: Icons.sms_outlined,
        suffix: TextButton(
          onPressed: sending || countdown > 0 ? null : onSend,
          child: Text(
            countdown > 0 ? '${countdown}s' : '获取验证码',
            style: const TextStyle(fontSize: 13, color: Color(0xFFED4956)),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: _decoration(hint: '请输入密码', prefix: Icons.lock_outline),
    );
  }
}

InputDecoration _decoration({
  required String hint,
  required IconData prefix,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFA8A8A8), fontSize: 14),
    prefixIcon: Icon(prefix, size: 20, color: const Color(0xFF737373)),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFED4956), width: 1.2),
    ),
  );
}
