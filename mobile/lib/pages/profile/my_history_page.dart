import 'package:flutter/material.dart';

/// 观看历史（占位页）
class MyHistoryPage extends StatelessWidget {
  const MyHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('观看历史')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Color(0xFFD0D0D0)),
            const SizedBox(height: 16),
            const Text(
              '浏览历史功能开发中',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8A8A8A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '敬请期待',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
