import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thinkorigin/l10n/locale_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('设置页语言选择写入本地并驱动 App locale', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocaleStore.instance;
    await store.setLanguage('en');

    expect(store.languageCode, 'en');
    expect(store.locale?.languageCode, 'en');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), 'en');

    await store.setLanguage(null);
    expect(store.languageCode, null);
    expect(store.locale, null);
    expect(prefs.getString('app_language'), null);
  });
}
