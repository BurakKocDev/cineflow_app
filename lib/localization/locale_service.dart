import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class LocaleService {
  static const String _localeKey = 'app_locale';

  /// Kayıtlı dili yükler. Hiç kayıt yoksa null döner.
  static Future<Locale?> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    switch (code) {
      case 'en':
        return AppLocalizations.english;
      case 'tr':
        return AppLocalizations.turkish;
      default:
        return null;
    }
  }

  /// Seçilen dili kaydeder.
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}


