import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LanguageProvider with ChangeNotifier {
  static const String _boxName = 'myBox';
  static const String _languageKey = 'language';
  static const String _languageMigrationKey = 'language_migrated_to_en';

  Locale _appLocale = Locale(_getInitialLanguage());

  static String _getInitialLanguage() {
    final box = Hive.box(_boxName);

    // Check if migration has been done
    final migrated = box.get(_languageMigrationKey, defaultValue: false);

    if (!migrated) {
      // First time or not migrated yet - set to English and mark as migrated
      box.put(_languageKey, 'en');
      box.put(_languageMigrationKey, true);
      return 'en';
    }

    // Already migrated, use saved preference
    return box.get(_languageKey, defaultValue: 'en');
  }

  Locale get appLocale => _appLocale;

  void changeLanguage(Locale newLocale) {
    if (_appLocale == newLocale) {
      return;
    }
    _appLocale = newLocale;
    Hive.box(_boxName).put(_languageKey, newLocale.languageCode);
    notifyListeners();
  }
}
