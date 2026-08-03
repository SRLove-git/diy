import 'package:flutter/material.dart';

/// 卡包页（占位）
///
/// 后端暂无卡包/会员券模块，先提供入口页面避免死按钮；
/// 后续接入会员套餐/优惠券后在此展示。
class CardPackPage extends StatelessWidget {
  const CardPackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('卡包')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: Color(0xFFD8D5CF),
            ),
            const SizedBox(height: 16),
            const Text(
              '卡包功能建设中',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '会员套餐 / 优惠券即将上线，敬请期待',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
