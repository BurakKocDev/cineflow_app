# Gemini API Entegrasyon Rehberi

Bu rehber, CineFlow uygulamasında Google Gemini API'yi `.env` dosyası ile kullanmak için adımları içerir.

## 📋 Adım 1: Google AI Studio'dan API Key Alma

1. **Google AI Studio'ya Git**
   - https://aistudio.google.com/apikey
   - Google hesabınla giriş yap

2. **Yeni API Key Oluştur**
   - "Create API Key" butonuna tıkla
   - Yeni proje oluştur veya mevcut projeyi seç

3. **API Key'i Kopyala**
   - Oluşturulan anahtarı güvenli bir yere kaydet
   - ⚠️ **ÖNEMLİ:** Anahtarı repoya commit etme

## 📋 Adım 2: API Key'i Projeye Ekleme

1. **Şablon dosyayı kopyala**
   ```bash
   cp .env.example .env
   ```

2. **`.env` dosyasını düzenle**
   ```env
   GEMINI_API_KEY=buraya_kendi_anahtarini_yaz
   TMDB_API_KEY=buraya_tmdb_anahtarini_yaz
   ```

3. **Bağımlılıkları yükle**
   ```bash
   flutter pub get
   ```

4. **Kod tarafı (zaten hazır)**
   - `lib/config/env_config.dart` → anahtarları okur
   - `lib/services/gemini_service.dart` → Gemini isteklerini yapar
   - `lib/main.dart` → uygulama açılırken `.env` yüklenir

## 📋 Adım 3: Test Etme

1. **Uygulamayı çalıştır**
   ```bash
   flutter run
   ```

2. **Film Asistanı sekmesine git**

3. **Örnek sorgu gönder**
   ```
   Komedi filmi öner
   ```

## 🔍 Sorun Giderme

### "Gemini API key not configured"
- `.env` dosyası var mı?
- `GEMINI_API_KEY` dolu mu?
- Uygulamayı yeniden başlat

### "API error: 403" veya "401"
- Anahtar doğru kopyalandı mı?
- Google AI Studio'da key aktif mi?

### "API error: 429"
- Rate limit aşıldı, biraz bekle

## 💰 Maliyet

- Detaylar: https://ai.google.dev/pricing

## ✅ Başarı Kontrolü

- ✅ Asistan yanıt veriyor
- ✅ API key hatası yok
- ✅ `.env` GitHub'da görünmüyor

Başarılar! 🎉
