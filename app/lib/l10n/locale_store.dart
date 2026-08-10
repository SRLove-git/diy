import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App 内语言选择：null 表示跟随系统，'zh' / 'en' 表示用户手动指定。
class LocaleStore extends ChangeNotifier {
  LocaleStore._();

  static LocaleStore? _instance;
  static LocaleStore get instance => _instance ??= LocaleStore._();

  static const _kLanguage = 'app_language';

  String? _languageCode;
  bool _loaded = false;

  String? get languageCode => _languageCode;
  bool get loaded => _loaded;

  Locale? get locale => switch (_languageCode) {
        'zh' => const Locale('zh'),
        'en' => const Locale('en'),
        _ => null,
      };

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(_kLanguage);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(String? languageCode) async {
    _languageCode = languageCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null) {
      await prefs.remove(_kLanguage);
    } else {
      await prefs.setString(_kLanguage, languageCode);
    }
  }
}
