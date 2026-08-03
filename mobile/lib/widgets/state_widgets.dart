import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// 通用状态控件库
/// 对齐《第一阶段UI设计指导》§八：加载/空态/错误状态规范

/// 加载中组件
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: TextStyle(color: colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// 空态组件
class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(fontSize: 15, color: colors.textSecondary)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// 错误态组件
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.message = '加载失败',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 48, color: colors.textSecondary),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: colors.textSecondary)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 通用列表状态构建器：根据 loading / error / items 返回对应状态控件
class StateListBuilder extends StatelessWidget {
  const StateListBuilder({
    super.key,
    required this.loading,
    this.error,
    required this.isEmpty,
    required this.emptyIcon,
    required this.emptyMessage,
    this.emptyActionLabel,
    this.onRefresh,
    this.onRetry,
    required this.builder,
  });

  final bool loading;
  final String? error;
  final bool isEmpty;
  final IconData emptyIcon;
  final String emptyMessage;
  final String? emptyActionLabel;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (loading) {
      body = const LoadingWidget();
    } else if (error != null) {
      body = AppErrorWidget(message: error!, onRetry: onRetry);
    } else if (isEmpty) {
      body = EmptyWidget(
        icon: emptyIcon,
        message: emptyMessage,
        actionLabel: emptyActionLabel,
        onAction: onRetry,
      );
    } else {
      body = builder();
    }

    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: body is ListView ? body : ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.7, child: body)]));
    }

    return body;
  }
}
