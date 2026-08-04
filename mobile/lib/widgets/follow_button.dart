import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// 关注/已关注 胶囊按钮。
/// 状态由外部持有（onChanged 传 `!following`），busy 时禁用并显示加载圈。
class FollowButton extends StatelessWidget {
  const FollowButton({
    super.key,
    required this.following,
    required this.onChanged,
    this.enabled = true,
    this.compact = false,
  });

  /// 当前是否已关注
  final bool following;

  /// 切换回调（参数为目标状态）
  final Future<void> Function(bool following) onChanged;

  /// 切换中禁用，避免重复请求
  final bool enabled;

  /// 紧凑模式：用于作者信息行等空间有限的场景
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final height = compact ? 28.0 : 34.0;
    final busy = !enabled;
    return GestureDetector(
      onTap: busy ? null : () => onChanged(!following),
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: following ? Colors.transparent : colors.primary,
          borderRadius: BorderRadius.circular(height / 2),
          border: following ? Border.all(color: colors.textSecondary) : null,
        ),
        child: busy
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: following ? colors.textSecondary : Colors.white,
                ),
              )
            : Text(
                following ? '已关注' : '关注',
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                  color: following ? colors.textSecondary : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
