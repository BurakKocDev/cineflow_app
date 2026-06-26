import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Uygulama sırları `.env` dosyasından okunur (Git'e eklenmez).
class EnvConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY']?.trim() ?? '';

  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY']?.trim() ?? '';

  static bool get hasGeminiApiKey => geminiApiKey.isNotEmpty;

  static bool get hasTmdbApiKey => tmdbApiKey.isNotEmpty;
}
