import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LanguageProvider with ChangeNotifier {
  static const String _boxName = 'myBox';
  static const String _languageKey = 'language';

  Locale _appLocale = Locale(Hive.box(_boxName).get(_languageKey, defaultValue: 'he'));

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
