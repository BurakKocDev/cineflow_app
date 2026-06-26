# 🚀 Gemini API Entegrasyonu - Adım Adım Rehber

## 📋 ADIM 1: API Key Alma

1. **Google AI Studio'ya Git**
   ```
   https://aistudio.google.com/apikey
   ```

2. **Google Hesabınla Giriş Yap**

3. **"Create API Key" Butonuna Tıkla**
   - Yeni bir proje oluştur veya mevcut projeyi seç
   - API key otomatik oluşturulacak

4. **API Key'i Kopyala**
   - Google AI Studio'dan oluşturulan anahtarı kopyala
   - ⚠️ Bu key'i asla GitHub'a yükleme!

---

## 📋 ADIM 2: API Key'i Projeye Ekleme (`.env`)

Bu projede anahtarlar kodda değil, `.env` dosyasında tutulur.

1. **Şablonu kopyala**
   ```bash
   cp .env.example .env
   ```

2. **`.env` dosyasını düzenle**
   ```env
   GEMINI_API_KEY=buraya_kendi_anahtarini_yaz
   TMDB_API_KEY=buraya_tmdb_anahtarini_yaz
   ```

3. **`.env` dosyası Git'e eklenmez** (`.gitignore` içinde)

4. **Anahtar okuma yeri**
   - `lib/config/env_config.dart`
   - `lib/services/gemini_service.dart`

5. **Uygulama başlangıcı**
   - `lib/main.dart` içinde `dotenv.load(fileName: '.env')` çağrılır

---

## 📋 ADIM 3: Test Etme

1. **Uygulamayı Çalıştır**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Asistan Ekranına Git**
   - Uygulamada "Film Asistanı" sekmesine git

3. **Örnek sorgular**
   ```
   Üzgünken izleyebileceğim filmler öner
   ```
   ```
   2010'larda çıkmış psikolojik gerilim filmleri öner
   ```

---

## ✅ Başarı Kontrolü

Eğer her şey çalışıyorsa:

✅ Asistan ekranı yanıt veriyor  
✅ **"Gemini API key not configured"** hatası yok  
✅ **"Yapay zeka şu anda kullanılamıyor"** mesajı yok  

---

## 🔍 Sorun Giderme

### ❌ "Gemini API key not configured" Hatası
- `.env` dosyasının proje kökünde olduğundan emin ol
- `GEMINI_API_KEY=` satırının boş olmadığını kontrol et
- Uygulamayı tamamen kapatıp yeniden çalıştır

### ❌ "API error: 403" veya "401" Hatası
- API key'in geçerli olduğunu kontrol et
- Google AI Studio'da key'in aktif olduğunu kontrol et

### ❌ "API error: 429" (Rate Limit)
- Çok fazla istek gönderiyorsun, biraz bekle
- Ücretsiz tier limitini kontrol et

---

## 💰 Maliyet Bilgisi

- **Ücretsiz Tier:** Sınırlı ücretsiz kullanım
- Detaylar: https://ai.google.dev/pricing

---

## 📚 Ek Kaynaklar

- Gemini API Dokümantasyonu: https://ai.google.dev/docs
- Google AI Studio: https://aistudio.google.com
- Flutter dotenv: https://pub.dev/packages/flutter_dotenv

---

## 🎉 Tamamlandı!

Artık Gemini API `.env` üzerinden güvenli şekilde kullanılıyor.
