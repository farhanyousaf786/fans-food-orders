import 'package:hive/hive.dart';

class LanguageService {
  static const String _boxName = 'myBox';
  static const String _languageKey = 'language';

  static String getCurrentLanguage() {
    return Hive.box(_boxName).get(_languageKey, defaultValue: 'he');
  }

  static void setLanguage(String language) {
    if (!['en', 'he'].contains(language)) {
      throw ArgumentError('Unsupported language: $language');
    }
    Hive.box(_boxName).put(_languageKey, language);
  }

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'he':
        return 'Hebrew';
      default:
        return code;
    }
  }
}
