# Gemini API Entegrasyon Rehberi

Bu rehber, CineFlow uygulamasına Google Gemini API'yi entegre etmek için adım adım talimatlar içerir.

## 📋 Adım 1: Google AI Studio'dan API Key Alma

1. **Google AI Studio'ya Git**
   - Tarayıcında şu adrese git: https://makersuite.google.com/app/apikey
   - Google hesabınla giriş yap

2. **Yeni API Key Oluştur**
   - Sayfada "Create API Key" veya "Get API Key" butonuna tıkla
   - İstersen yeni bir Google Cloud projesi oluştur veya mevcut birini seç
   - API key otomatik olarak oluşturulacak ve gösterilecek

3. **API Key'i Kopyala**
   - Oluşturulan API key'i kopyala (örnek: `AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567`)
   - ⚠️ **ÖNEMLİ**: Bu key'i güvenli bir yerde sakla, kimseyle paylaşma!

## 📋 Adım 2: API Key'i Projeye Ekleme

### Seçenek A: Doğrudan Kod İçine Ekleme (Hızlı Test İçin)

1. `lib/services/gemini_service.dart` dosyasını aç
2. 7. satırdaki `_apiKey` değişkenini bul:
   ```dart
   static const String _apiKey = ''; // TODO: Gemini API key ekle
   ```
3. API key'i ekle:
   ```dart
   static const String _apiKey = 'AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567'; // API key'in buraya
   ```

### Seçenek B: Environment Variable Kullanma (Önerilen - Güvenli)

1. `pubspec.yaml` dosyasına `flutter_dotenv` paketini ekle:
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

2. Terminal'de paketi yükle:
   ```bash
   flutter pub get
   ```

3. Proje kök dizininde `.env` dosyası oluştur:
   ```
   GEMINI_API_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567
   ```

4. `.env` dosyasını `.gitignore`'a ekle (güvenlik için)

5. `lib/services/gemini_service.dart` dosyasını güncelle:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   class GeminiService extends GetxService {
     String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
     // ...
   }
   ```

6. `lib/main.dart` dosyasında `.env` dosyasını yükle:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await dotenv.load(fileName: ".env"); // .env dosyasını yükle
     // ...
   }
   ```

## 📋 Adım 3: Servisi Aktifleştirme

Servis zaten hazır! API key eklediğin anda otomatik olarak aktif olacak.

`lib/services/gemini_service.dart` dosyasında `isAvailable` getter'ı kontrol ediyor:
```dart
bool get isAvailable => _apiKey.isNotEmpty;
```

## 📋 Adım 4: Test Etme

1. **Uygulamayı Çalıştır**
   ```bash
   flutter run
   ```

2. **Asistan Ekranına Git**
   - Uygulamada "Film Asistanı" veya chat ikonuna tıkla

3. **Karmaşık Bir Sorgu Dene**
   - Basit sorgu (regex ile işlenecek): "2010 aksiyon filmleri"
   - Karmaşık sorgu (AI ile işlenecek): "2010'larda çıkmış, Leonardo DiCaprio'nun oynadığı psikolojik gerilim filmleri öner"

4. **Kontrol Et**
   - Eğer AI aktifse, karmaşık sorgular için daha detaylı ve doğal yanıtlar alacaksın
   - Basit sorgular hala regex ile hızlı işlenecek

## 🔍 Sorun Giderme

### API Key Çalışmıyor
- API key'in doğru kopyalandığından emin ol (boşluk yok)
- Google AI Studio'da API key'in aktif olduğunu kontrol et
- Kotu kullanım limiti olup olmadığını kontrol et

### "Gemini API key not configured" Hatası
- `_apiKey` değişkeninin boş olmadığından emin ol
- Uygulamayı yeniden başlat

### "API error: 403" veya "API error: 401"
- API key'in geçerli olduğundan emin ol
- Google Cloud Console'da API'nin aktif olduğunu kontrol et
- Billing hesabının aktif olduğundan emin ol (ücretsiz tier için bile gerekli)

### "API error: 429" (Rate Limit)
- Çok fazla istek gönderiyorsun, biraz bekle
- Google AI Studio'da kullanım limitlerini kontrol et

## 💰 Maliyet Bilgisi

- **Ücretsiz Tier**: Ayda 60 istek (ücretsiz)
- **Paid Tier**: İlk 15 istek/ay ücretsiz, sonrası ücretli
- Detaylar: https://ai.google.dev/pricing

## 📚 Ek Kaynaklar

- Gemini API Dokümantasyonu: https://ai.google.dev/docs
- Google AI Studio: https://makersuite.google.com
- Flutter HTTP Paketi: https://pub.dev/packages/http

## ✅ Başarı Kontrolü

Eğer her şey doğru çalışıyorsa:
- ✅ Basit sorgular hızlı işleniyor (regex)
- ✅ Karmaşık sorgular AI ile işleniyor
- ✅ Yanıtlar daha doğal ve açıklayıcı
- ✅ Hata mesajları görünmüyor

Başarılar! 🎉

