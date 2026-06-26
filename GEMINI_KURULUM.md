# 🚀 Gemini API Entegrasyonu - Adım Adım Rehber

## 📋 ADIM 1: API Key Alma

1. **Google AI Studio'ya Git**
   ```
   https://makersuite.google.com/app/apikey
   ```

2. **Google Hesabınla Giriş Yap**

3. **"Create API Key" Butonuna Tıkla**
   - Yeni bir proje oluştur veya mevcut projeyi seç
   - API key otomatik oluşturulacak

4. **API Key'i Kopyala**
   - Örnek format: `AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567`
   - ⚠️ Bu key'i güvenli tut!

---

## 📋 ADIM 2: API Key'i Koda Ekleme

### Yöntem 1: Doğrudan Ekleme (Hızlı Test)

1. **Dosyayı Aç**
   ```
   lib/services/gemini_service.dart
   ```

2. **13. Satırı Bul ve Değiştir**
   
   **ÖNCE (Şu anki durum):**
   ```dart
   static const String _apiKey = ''; // TODO: Gemini API key ekle
   ```
   
   **SONRA (API key ekledikten sonra):**
   ```dart
   static const String _apiKey = 'AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567'; // API key'in buraya
   ```

3. **Dosyayı Kaydet**

### Yöntem 2: Environment Variable (Güvenli - Önerilen)

Eğer API key'i kodda tutmak istemiyorsan (güvenlik için):

1. **`pubspec.yaml` dosyasına ekle:**
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

2. **Terminal'de çalıştır:**
   ```bash
   flutter pub get
   ```

3. **Proje kök dizininde `.env` dosyası oluştur:**
   ```
   GEMINI_API_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567
   ```

4. **`.gitignore` dosyasına ekle:**
   ```
   .env
   ```

5. **`lib/services/gemini_service.dart` dosyasını güncelle:**
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   class GeminiService extends GetxService {
     String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
     // ...
   }
   ```

6. **`lib/main.dart` dosyasını güncelle:**
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await dotenv.load(fileName: ".env");
     // ... geri kalan kod
   }
   ```

---

## 📋 ADIM 3: Test Etme

1. **Uygulamayı Çalıştır**
   ```bash
   flutter run
   ```

2. **Asistan Ekranına Git**
   - Uygulamada "Film Asistanı" sekmesine git

3. **Basit Sorgu Dene (Regex ile işlenecek)**
   ```
   "2010 aksiyon filmleri"
   ```

4. **Karmaşık Sorgu Dene (AI ile işlenecek)**
   ```
   "2010'larda çıkmış, Leonardo DiCaprio'nun oynadığı psikolojik gerilim filmleri öner"
   ```

---

## ✅ Başarı Kontrolü

Eğer her şey çalışıyorsa:

✅ **Basit sorgular** → Hızlı yanıt (regex parsing)
✅ **Karmaşık sorgular** → Detaylı, doğal yanıt (Gemini AI)
✅ **Hata mesajı yok** → "Gemini API key not configured" görünmüyor

---

## 🔍 Sorun Giderme

### ❌ "Gemini API key not configured" Hatası
- **Çözüm:** API key'in doğru eklendiğinden emin ol
- Dosyayı kaydettiğinden emin ol
- Uygulamayı yeniden başlat

### ❌ "API error: 403" veya "401" Hatası
- **Çözüm:** 
  - API key'in geçerli olduğunu kontrol et
  - Google Cloud Console'da API'nin aktif olduğunu kontrol et
  - Billing hesabının aktif olduğundan emin ol

### ❌ "API error: 429" (Rate Limit)
- **Çözüm:** 
  - Çok fazla istek gönderiyorsun, biraz bekle
  - Ücretsiz tier limitini kontrol et (60 istek/ay)

---

## 💰 Maliyet Bilgisi

- **Ücretsiz Tier:** Ayda 60 istek ücretsiz
- **Paid Tier:** İlk 15 istek/ay ücretsiz, sonrası ücretli
- Detaylar: https://ai.google.dev/pricing

---

## 📚 Ek Kaynaklar

- Gemini API Dokümantasyonu: https://ai.google.dev/docs
- Google AI Studio: https://makersuite.google.com
- Flutter HTTP Paketi: https://pub.dev/packages/http

---

## 🎉 Tamamlandı!

Artık Gemini API entegre edildi! Karmaşık sorgular AI ile işlenecek ve daha iyi sonuçlar alacaksın.

