import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 订单管理：预约订单列表 + 状态筛选 + 上钟/下钟（对齐网页管理端）
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List<AdminOrder> _orders = [];
  bool _loading = true;
  String? _error;
  String _status = '';

  static const _tabs = [
    (value: '', label: '全部'),
    (value: 'booked', label: '待核销'),
    (value: 'checked_in', label: '已核销'),
    (value: 'in_service', label: '服务中'),
    (value: 'completed', label: '已完成'),
    (value: 'cancelled', label: '已取消'),
  ];

  static const _statusLabels = {
    'booked': '待核销',
    'checked_in': '已核销',
    'in_service': '服务中',
    'completed': '已完成',
    'cancelled': '已取消',
  };

  static const _statusColors = {
    'booked': Color(0xFFE8633A),
    'checked_in': Color(0xFFE6A23C),
    'in_service': Color(0xFF2E9E5B),
    'completed': Color(0xFF8A8A8A),
    'cancelled': Color(0xFFD9453E),
  };

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
      final list = await AdminApi.fetchOrders(status: _status);
      if (mounted) setState(() => _orders = list);
    } on DioException catch (e) {
      if (mounted) setState(() => _error = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _switchStatus(String v) {
    if (_status == v) return;
    setState(() => _status = v);
    _load();
  }

  Future<void> _operate(AdminOrder o, String action) async {
    String title;
    String content;
    String success;
    switch (action) {
      case 'checkin':
        title = '核销';
        content = '确认核销该预约？核销后记录核销时间。';
        success = '已核销';
        break;
      case 'clockin':
        title = '上钟';
        content = '确认为该预约上钟（开始服务）？';
        success = '已上钟';
        break;
      case 'clockout':
        title = '下钟';
        content = '确认下钟（结束服务）？';
        success = '已下钟';
        break;
      case 'cancel':
        title = '取消订单';
        content = '确认取消该预约订单？';
        success = '已取消';
        break;
      default:
        return;
    }
    final ok = await _confirm(title, content);
    if (ok != true) return;
    try {
      switch (action) {
        case 'checkin':
          await AdminApi.adminCheckIn(o.id);
          break;
        case 'clockin':
          await AdminApi.clockIn(o.id);
          break;
        case 'clockout':
          await AdminApi.clockOut(o.id);
          break;
        case 'cancel':
          await AdminApi.adminCancel(o.id);
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
        _load();
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AdminApi.messageOf(e))));
      }
    }
  }

  Future<bool?> _confirm(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单管理'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          // 状态筛选
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _FilterChip(
                label: _tabs[i].label,
                active: _status == _tabs[i].value,
                onTap: () => _switchStatus(_tabs[i].value),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingWidget();
    if (_error != null) return AppErrorWidget(message: _error!, onRetry: _load);
    if (_orders.isEmpty) {
      return const EmptyWidget(icon: Icons.receipt_long_outlined, message: '暂无订单数据');
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _buildOrderCard(_orders[i], colors),
      ),
    );
  }

  Widget _buildOrderCard(AdminOrder o, AppColors colors) {
    final statusColor = _statusColors[o.status] ?? colors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.placeholder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  o.code,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: statusColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabels[o.status] ?? o.status,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            o.storeName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _row('日期', '${o.date} ${o.startTime} - ${o.endTime}', colors),
          _row('桌位', '${o.tableName} · ${o.peopleCount} 人', colors),
          _row('核销时间', _fmtTime(o.checkInTime), colors),
          _row('上钟 / 下钟', '${_fmtTime(o.serviceStartTime)} / ${_fmtTime(o.serviceEndTime)}', colors),
          _row('使用时长', _fmtDuration(o.serviceStartTime, o.serviceEndTime), colors),
          if (o.status == 'booked' ||
              o.status == 'checked_in' ||
              o.status == 'in_service') ...[
            const SizedBox(height: 12),
            _buildActions(o, colors),
          ],
        ],
      ),
    );
  }

  /// 操作区：待核销 → 核销 + 取消订单；已核销 → 上钟 + 取消订单；服务中 → 下钟
  Widget _buildActions(AdminOrder o, AppColors colors) {
    if (o.status == 'in_service') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => _operate(o, 'clockout'),
          style: FilledButton.styleFrom(
            backgroundColor: colors.danger,
            minimumSize: const Size.fromHeight(40),
          ),
          child: const Text('下钟'),
        ),
      );
    }
    final isBooked = o.status == 'booked';
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () => _operate(o, isBooked ? 'checkin' : 'clockin'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E9E5B),
              minimumSize: const Size.fromHeight(40),
            ),
            child: Text(isBooked ? '核销' : '上钟'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _operate(o, 'cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.danger,
              side: BorderSide(color: colors.danger),
              minimumSize: const Size.fromHeight(40),
            ),
            child: const Text('取消订单'),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return '-';
    final d = DateTime.tryParse(t);
    if (d == null) return '-';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final s = d.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _fmtDuration(String? s, String? e) {
    if (s == null || e == null) return '-';
    final start = DateTime.tryParse(s);
    final end = DateTime.tryParse(e);
    if (start == null || end == null) return '-';
    final ms = end.difference(start);
    final h = ms.inHours.toString().padLeft(2, '0');
    final m = (ms.inMinutes % 60).toString().padLeft(2, '0');
    final sec = (ms.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? colors.textPrimary : colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: active ? colors.surface : colors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
