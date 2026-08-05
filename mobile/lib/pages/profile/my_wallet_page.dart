import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';
import '../../features/member/data/api_member_repository.dart';
import '../../features/member/domain/member_models.dart';

class MyWalletPage extends StatefulWidget {
  const MyWalletPage({super.key});

  @override
  State<MyWalletPage> createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage>
    with SingleTickerProviderStateMixin {
  final _repo = const ApiMemberRepository();
  final _items = <MemberWalletCoupon>[];
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
      final items = await _repo.fetchWallet();
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '卡包加载失败，请重试';
      });
    }
  }

  List<MemberWalletCoupon> _itemsByStatus(String status) {
    return _items.where((item) => item.status == status).toList();
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('卡包'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '未使用'),
              Tab(text: '已使用'),
              Tab(text: '已过期'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingWidget(message: '加载卡包中…');
    if (_error != null) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AppErrorWidget(message: _error!, onRetry: _load),
          ),
        ],
      );
    }

    return TabBarView(
      children: [
        _buildList(_itemsByStatus('unused'), '还没有可用优惠券'),
        _buildList(_itemsByStatus('used'), '还没有已使用优惠券'),
        _buildList(_itemsByStatus('expired'), '还没有过期优惠券'),
      ],
    );
  }

  Widget _buildList(List<MemberWalletCoupon> items, String emptyText) {
    if (items.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyWidget(
              icon: Icons.wallet_giftcard_outlined,
              message: emptyText,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _WalletCard(
        item: items[index],
        formatDate: _formatDate,
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.item, required this.formatDate});

  final MemberWalletCoupon item;
  final String Function(DateTime date) formatDate;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isInactive = item.status != 'unused';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isInactive
              ? const [Color(0xFFE7E2DC), Color(0xFFD4CDC6)]
              : const [Palette.coral, Palette.accent],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.threshold,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '有效期至 ${formatDate(item.expireAt)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  switch (item.status) {
                    'used' => '已使用',
                    'expired' => '已过期',
                    _ => '可使用',
                  },
                  style: TextStyle(
                    color: colors.surface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
