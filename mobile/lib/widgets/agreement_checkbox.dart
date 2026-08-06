import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../pages/agreement_page.dart';

/// 微信式协议勾选行：未勾选时点击登录/获取验证码会被拦截。
/// 文案按场景可定制，链接固定指向《用户协议》与《隐私政策》。
class AgreementCheckbox extends StatelessWidget {
  const AgreementCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.notice = '未注册手机号登录时将自动注册，且代表您已同意',
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String notice;

  void _open(BuildContext context, AgreementType type) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AgreementPage(type: type)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                checked ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 18,
                color: checked ? colors.primary : colors.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 0,
                children: [
                  Text(
                    notice,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => _open(context, AgreementType.user),
                    child: Text(
                      '《用户协议》',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '和',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => _open(context, AgreementType.privacy),
                    child: Text(
                      '《隐私政策》',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
