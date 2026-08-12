import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// 便捷访问：`context.l10n.xxx` 等价于 `AppLocalizations.of(context)!.xxx`。
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// 服务端返回的中文业务名称（会员等级 / 套餐名 / 徽标）在英文模式下的映射；
/// 中文模式或未收录的名称原样返回。
extension MemberNameX on BuildContext {
  String memberName(String zh) {
    if (Localizations.localeOf(this).languageCode != 'en') return zh;
    return switch (zh) {
      '手作会员' => 'Handmade Member',
      '月卡' => 'Monthly Card',
      '季卡' => 'Quarterly Card',
      '年卡' => 'Annual Card',
      '推荐' => 'Recommended',
      '最划算' => 'Best Value',
      _ => zh,
    };
  }
}

/// 服务端返回的中文会员权益文案在英文模式下的映射；
/// 中文模式或未收录的权益原样返回。
extension MemberBenefitX on BuildContext {
  String memberBenefit(String zh) {
    if (Localizations.localeOf(this).languageCode != 'en') return zh;
    return switch (zh) {
      '全场消费8折专属优惠' => 'Exclusive 20% off on all purchases',
      _ => zh,
    };
  }
}
