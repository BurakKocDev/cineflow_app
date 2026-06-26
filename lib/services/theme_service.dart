import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'app_theme_mode';

  /// Kaydedilmiş tema modunu yükler. Kayıt yoksa [ThemeMode.system] döner.
  static Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_themeKey);

      if (value == 'light') {
        return ThemeMode.light;
      }
      if (value == 'dark') {
        return ThemeMode.dark;
      }
      if (value == 'system') {
        return ThemeMode.system;
      }
    } catch (_) {
      // prefs erişiminde sorun olsa bile uygulama çökmemeli
    }
    // Her durumda güvenli varsayılan
    return ThemeMode.system;
  }

  /// Seçilen tema modunu kaydeder.
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    late final String value;

    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }

    await prefs.setString(_themeKey, value);
  }
}

