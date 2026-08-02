import 'package:flutter/material.dart';

/// 社区：标题「社区」+ 右侧发布入口 + 信息流占位
/// 对齐《第一阶段UI设计指导》§六
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE8633A)),
            onPressed: () {
              // 二期接入发布页
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.brush_outlined, size: 64, color: Color(0xFF8A8A8A)),
            SizedBox(height: 12),
            Text('还没有作品，来发布第一个吧', style: TextStyle(color: Color(0xFF8A8A8A))),
          ],
        ),
      ),
    );
  }
}
