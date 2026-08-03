import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/api_client.dart';
import '../../core/appointment_api.dart';
import 'service_timer_page.dart';

/// 到店核销页：Tab1 展示最近待核销预约的二维码（店员扫码核销），
/// Tab2 保留手动输码核销（6 位数字）。
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  // 二维码 Tab 状态
  Appointment? _latest;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 拉取我的预约，取最近一条「待核销」状态的展示二维码
  Future<void> _loadLatest() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final list = await AppointmentApi.fetchMyList();
      Appointment? latest;
      for (final a in list) {
        if (a.status == 'pending' || a.status == 'booked') {
          latest = a;
          break;
        }
      }
      if (!mounted) return;
      setState(() {
        _latest = latest ?? (list.isNotEmpty ? list.first : null);
        _loading = false;
        if (latest == null && list.isNotEmpty) {
          _loadError = '当前没有待核销的预约';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = '预约列表加载失败';
      });
    }
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

  /// 用二维码上的预约码核销（与输码同一接口）
  Future<void> _checkinCode(String code) async {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('到店核销'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '二维码'),
              Tab(text: '输码核销'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQrTab(context),
            _buildCodeTab(context),
          ],
        ),
      ),
    );
  }

  // ──── Tab 1：二维码 ────
  Widget _buildQrTab(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null && _latest == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_2,
                size: 56,
                color: Color(0xFFD8D5CF),
              ),
              const SizedBox(height: 16),
              Text(
                _loadError!,
                style: const TextStyle(color: Color(0xFF8A8A8A)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadLatest,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('刷新'),
              ),
            ],
          ),
        ),
      );
    }
    final a = _latest!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 28,
            color: Color(0xFFE8633A),
          ),
          const SizedBox(height: 6),
          Text(
            a.storeName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${a.date} ${a.startTime}-${a.endTime} · ${a.tableName} · ${a.peopleCount}人',
            style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
          ),
          const SizedBox(height: 24),
          // 二维码：内容为预约码
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEAE6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: a.code,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '预约码 ${a.code}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '到店后请店员扫码核销',
            style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 240,
            height: 48,
            child: FilledButton(
              onPressed: _submitting ? null : () => _checkinCode(a.code),
              child: Text(_submitting ? '核销中…' : '自助核销'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFD9453E), fontSize: 14),
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadLatest,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('刷新预约'),
          ),
        ],
      ),
    );
  }

  // ──── Tab 2：输码核销 ────
  Widget _buildCodeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
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
            '手动输入 6 位预约码核销',
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
    );
  }
}
