import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/api_client.dart';
import '../../core/appointment_api.dart';

/// 到店二维码核销页：展示待核销（booked）预约的二维码，到店出示由店员扫码核销
class MyCheckInQrPage extends StatefulWidget {
  const MyCheckInQrPage({super.key});

  @override
  State<MyCheckInQrPage> createState() => _MyCheckInQrPageState();
}

class _MyCheckInQrPageState extends State<MyCheckInQrPage> {
  List<Appointment> _booked = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await ApiClient.instance.get('/appointments');
      final list = resp.data as List;
      if (!mounted) return;
      setState(() {
        _booked = list
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .where((a) => a.status == 'booked')
            .toList();
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppointmentApi.messageOf(e);
      });
    }
  }

  void _showQrDetail(Appointment appt) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appt.storeName,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${appt.date} ${appt.startTime}-${appt.endTime} · 桌位 ${appt.tableName}',
                style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _QrCode(code: appt.code, size: 240),
              const SizedBox(height: 16),
              const Text(
                '到店出示此二维码，由店员扫码核销',
                style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('到店核销')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFF8A8A8A)),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _booked.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 64,
                            color: Color(0xFFD0D0D0),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '暂无待核销的预约',
                            style: TextStyle(color: Color(0xFF8A8A8A)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _booked.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final appt = _booked[i];
                          return InkWell(
                            onTap: () => _showQrDetail(appt),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _QrCode(code: appt.code, size: 96),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appt.storeName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        _InfoLine(
                                          icon: Icons.calendar_today,
                                          text:
                                              '${appt.date} ${appt.startTime}-${appt.endTime}',
                                        ),
                                        const SizedBox(height: 4),
                                        _InfoLine(
                                          icon: Icons.table_bar,
                                          text:
                                              '桌位 ${appt.tableName} · ${appt.peopleCount} 人',
                                        ),
                                        const SizedBox(height: 4),
                                        _InfoLine(
                                          icon: Icons.confirmation_number,
                                          text: '预约码 ${appt.code}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF8A8A8A),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _QrCode extends StatelessWidget {
  const _QrCode({required this.code, required this.size});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: QrImageView(
        data: code,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8A8A8A)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
          ),
        ),
      ],
    );
  }
}
