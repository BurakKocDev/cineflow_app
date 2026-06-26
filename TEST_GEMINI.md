# 🧪 Gemini API Test Rehberi

## ✅ Entegrasyon Tamamlandı!

Gemini API başarıyla entegre edildi. Şimdi test edebilirsin.

---

## 🚀 Nasıl Test Edilir?

### 1. Uygulamayı Çalıştır
```bash
flutter run
```

### 2. Film Asistanı Ekranına Git
- Uygulamada "Film Asistanı" veya chat ikonuna tıkla

### 3. Test Sorguları Dene

#### ✅ Basit Sorgu (Regex ile işlenecek - Hızlı)
```
"2010 aksiyon filmleri"
```
**Beklenen:** Hızlı yanıt, regex parsing kullanılacak

#### ✅ Karmaşık Sorgu (AI ile işlenecek - Detaylı)
```
"2010'larda çıkmış, Leonardo DiCaprio'nun oynadığı psikolojik gerilim filmleri öner"
```
**Beklenen:** Gemini AI kullanılacak, detaylı ve doğal yanıt

#### ✅ Çok Karmaşık Sorgu (AI ile işlenecek)
```
"Bana 2015-2020 arası çıkmış, IMDB puanı 8 üzeri olan, bilim kurgu ve aksiyon türünde filmler öner. Ayrıca bu filmlerin neden önerildiğini açıkla."
```
**Beklenen:** Gemini AI kullanılacak, çok detaylı yanıt

---

## 🔍 Kontrol Listesi

### API Key Kontrolü
- [ ] `lib/services/gemini_service.dart` dosyasında API key doğru eklendi mi?
- [ ] API key boş değil mi? (`_apiKey.isNotEmpty`)

### Servis Kontrolü
- [ ] GeminiService uygulama başlangıcında yüklendi mi?
- [ ] AssistantController GeminiService'i bulabiliyor mu?

### Test Sonuçları
- [ ] Basit sorgular hızlı yanıt veriyor mu?
- [ ] Karmaşık sorgular AI ile işleniyor mu?
- [ ] Film önerileri gösteriliyor mu?
- [ ] Hata mesajı görünmüyor mu?

---

## 🐛 Sorun Giderme

### ❌ "Gemini API key not configured" Hatası
**Çözüm:**
1. `lib/services/gemini_service.dart` dosyasını kontrol et
2. API key'in doğru eklendiğinden emin ol
3. Uygulamayı yeniden başlat

### ❌ "API error: 403" veya "401" Hatası
**Çözüm:**
1. API key'in geçerli olduğunu kontrol et
2. Google AI Studio'da API'nin aktif olduğunu kontrol et
3. Billing hesabının aktif olduğundan emin ol

### ❌ "API error: 429" (Rate Limit)
**Çözüm:**
1. Çok fazla istek gönderiyorsun, biraz bekle
2. Ücretsiz tier limitini kontrol et (60 istek/ay)

### ❌ AI Yanıt Vermiyor, Regex'e Düşüyor
**Kontrol Et:**
1. Konsol loglarını kontrol et (`print` mesajları)
2. API key'in doğru çalıştığını kontrol et
3. İnternet bağlantını kontrol et

---

## 📊 Beklenen Davranış

### Basit Sorgular
- **Hız:** Çok hızlı (< 1 saniye)
- **Yöntem:** Regex parsing
- **Yanıt:** Kısa ve öz

### Karmaşık Sorgular
- **Hız:** Orta (2-5 saniye)
- **Yöntem:** Gemini AI
- **Yanıt:** Detaylı ve doğal

---

## ✅ Başarı Kriterleri

Eğer şunlar oluyorsa her şey çalışıyor demektir:

✅ Basit sorgular hızlı işleniyor
✅ Karmaşık sorgular AI ile işleniyor
✅ Yanıtlar doğal ve açıklayıcı
✅ Film önerileri gösteriliyor
✅ Hata mesajı görünmüyor
✅ Konsol'da "✅ Gemini AI aktif ve kullanıma hazır!" mesajı var

---

## 🎉 Başarılar!

Artık Gemini AI entegre edildi ve çalışıyor! Karmaşık sorgular için çok daha iyi sonuçlar alacaksın.

