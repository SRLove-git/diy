import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_colors.dart';
import '../../core/appointment_api.dart';

/// 我的订单列表：全部 / 待核销 / 进行中 / 已完成 / 已取消
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Appointment> _orders = [];
  bool _loading = true;
  String? _error;

  static const _tabs = ['全部', '待核销', '进行中', '已完成', '已取消'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await ApiClient.instance.get('/appointments');
      final list = resp.data as List;
      if (!mounted) return;
      setState(() {
        _orders = list
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
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

  Future<void> _cancel(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('取消预约'),
        content: const Text('确认取消该预约吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(ctx).textPrimary,
            ),
            child: const Text('返回'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(ctx).textPrimary,
              foregroundColor: AppColors.of(ctx).surface,
            ),
            child: const Text('确认取消'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ApiClient.instance.post('/appointments/$id/cancel');
      if (!mounted) return;
      _loadOrders();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppointmentApi.messageOf(e))),
      );
    }
  }

  List<Appointment> get _filtered {
    switch (_tabController.index) {
      case 1:
        return _orders.where((o) => o.status == 'booked').toList();
      case 2:
        return _orders
            .where((o) => o.status == 'checked_in' || o.status == 'in_service')
            .toList();
      case 3:
        return _orders.where((o) => o.status == 'completed').toList();
      case 4:
        return _orders.where((o) => o.status == 'cancelled').toList();
      default:
        return _orders;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'booked':
        return '待核销';
      case 'checked_in':
        return '已核销';
      case 'in_service':
        return '服务中';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    final colors = AppColors.of(context);
    switch (status) {
      case 'booked':
        return colors.textPrimary;
      case 'checked_in':
        return const Color(0xFFE6A23C);
      case 'in_service':
        return const Color(0xFF2E9E5B);
      case 'completed':
        return colors.textSecondary;
      case 'cancelled':
        return colors.danger;
      default:
        return colors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订单'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colors.textPrimary,
          unselectedLabelColor: colors.textSecondary,
          dividerColor: Colors.transparent,
          indicatorColor: colors.textPrimary,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadOrders,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.textPrimary),
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Color(0xFFD0D0D0),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '暂无订单',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final o = _filtered[i];
                          return _OrderCard(
                            order: o,
                            statusLabel: _statusLabel(o.status),
                            statusColor: _statusColor(o.status),
                            onCancel: o.status == 'booked'
                                ? () => _cancel(o.id)
                                : null,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.statusLabel,
    required this.statusColor,
    this.onCancel,
  });

  final Appointment order;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
              Expanded(
                child: Text(
                  order.storeName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${order.date}  ${order.startTime}-${order.endTime}',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.table_bar, size: 14, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '桌位 ${order.tableName} · ${order.peopleCount} 人',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            ],
          ),
          if (order.code.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.qr_code, size: 14, color: colors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '预约码 ${order.code}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.danger,
                  side: BorderSide(color: colors.danger),
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('取消预约', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
