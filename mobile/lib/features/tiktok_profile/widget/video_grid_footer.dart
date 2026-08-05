import 'package:flutter/material.dart';

/// 作品墙列表尾部状态（widget 组件层）
///
/// 三种状态：
/// - [loading]：上拉分页加载中，展示转圈；
/// - 没有更多：展示「没有更多了」；
/// - [error]：加载更多失败，展示重试按钮。
class VideoGridFooter extends StatelessWidget {
  const VideoGridFooter({
    super.key,
    required this.loading,
    required this.hasMore,
    this.error,
    this.onRetry,
  });

  final bool loading;
  final bool hasMore;

  /// 加载更多失败信息（非空时展示重试）
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // 出错时优先展示重试
    if (error != null && onRetry != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '加载失败，点击重试',
                style: TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
            ),
          ),
        ),
      );
    }
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white54,
            ),
          ),
        ),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '— 没有更多了 —',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.32),
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 16);
  }
}
