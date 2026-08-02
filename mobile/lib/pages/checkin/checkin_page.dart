import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api_client.dart';
import '../../core/appointment_api.dart';
import 'service_timer_page.dart';

/// 输码核销页：大号验证码输入（6 位数字），核销成功自动进入上钟/计时
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.length != 6) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final resp = await ApiClient.instance.post(
        '/appointments/checkin',
        data: {'code': code},
      );
      if (!mounted) return;

      final appt = resp.data as Map<String, dynamic>;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ServiceTimerPage(appointmentId: appt['id'] as int),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = AppointmentApi.messageOf(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('到店核销')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: Color(0xFFE8633A),
            ),
            const SizedBox(height: 24),
            Text(
              '请输入预约码',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              '到店出示预约码即可核销',
              style: TextStyle(color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 240,
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: const TextStyle(
                    color: Color(0xFFD0D0D0),
                    letterSpacing: 12,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFF0E8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _submit(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFD9453E), fontSize: 14),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: 240,
              height: 48,
              child: FilledButton(
                onPressed: _submitting || _controller.text.trim().length != 6
                    ? null
                    : _submit,
                child: Text(_submitting ? '核销中…' : '确认核销'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
