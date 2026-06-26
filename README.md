# CineFlow

Film ve dizi keşfi, favoriler, oyuncular ve Gemini destekli film asistanı içeren Flutter uygulaması.

## Kurulum

1. Flutter SDK kurulu olmalı.
2. Bağımlılıkları yükle:
   ```bash
   flutter pub get
   ```
3. API anahtarlarını ayarla:
   ```bash
   cp .env.example .env
   ```
   `.env` dosyasına kendi anahtarlarını yaz:
   - `GEMINI_API_KEY` → [Google AI Studio](https://aistudio.google.com/apikey)
   - `TMDB_API_KEY` → [TMDB API](https://www.themoviedb.org/settings/api)
4. Uygulamayı çalıştır:
   ```bash
   flutter run
   ```

## Notlar

- `.env` dosyası Git'e eklenmez; sadece `.env.example` şablonu repoda bulunur.
- Gemini kurulum detayları için `GEMINI_KURULUM.md` dosyasına bakabilirsin.

## Özellikler

- Popüler / en iyi filmler ve diziler
- Arama ve filtreleme
- Favoriler
- Oyuncu keşfi
- AI film asistanı (Gemini)
