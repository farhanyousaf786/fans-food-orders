

import 'app_translations.dart';
import 'language_service.dart';

class Translate {
  static String get(String key) {
    final languageCode = LanguageService.getCurrentLanguage();
    return AppTranslations.getText(key, languageCode);
  }

  static String withLanguage(String key, String languageCode) {
    return AppTranslations.getText(key, languageCode);
  }
}
