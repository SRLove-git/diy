import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// 便捷访问：`context.l10n.xxx` 等价于 `AppLocalizations.of(context)!.xxx`。
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
