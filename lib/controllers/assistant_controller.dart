import 'package:get/get.dart';
import 'package:cineflow_app/services/gemini_service.dart';
import 'package:cineflow_app/services/api_service.dart';
import 'package:cineflow_app/models/movie_model.dart';

class AssistantMessage {
  final String role; // user or assistant
  final String content;
  final DateTime timestamp;
  AssistantMessage(this.role, this.content, {DateTime? timestamp}) 
      : timestamp = timestamp ?? DateTime.now();
}

class AssistantController extends GetxController {
  GeminiService? _geminiService;
  late final ApiService _apiService;

  final RxList<AssistantMessage> messages = <AssistantMessage>[].obs;
  final RxList<Movie> recommendations = <Movie>[].obs;
  final RxBool isThinking = false.obs;
  final RxBool useAI = false.obs; // AI kullanımını kontrol et

  @override
  void onInit() {
    super.onInit();
    // Gemini servisini kontrol et ve aktifleştir
    try {
      if (Get.isRegistered<GeminiService>()) {
        _geminiService = Get.find<GeminiService>();
        useAI.value = _geminiService?.isAvailable ?? false;
        if (Get.isRegistered<ApiService>()) {
          _apiService = Get.find<ApiService>();
        } else {
          _apiService = Get.put(ApiService());
        }
        
        if (useAI.value) {
          // AI aktifse kullanıcıya bildir
          // ignore: avoid_print
          print('✅ Gemini AI aktif ve kullanıma hazır!');
        }
      } else {
        // Servis henüz kayıtlı değilse bekle ve tekrar dene
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.isRegistered<GeminiService>()) {
            _geminiService = Get.find<GeminiService>();
            useAI.value = _geminiService?.isAvailable ?? false;
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Gemini servisi yüklenemedi: $e');
      useAI.value = false;
    }
    
    // Hoş geldin mesajı ekle
    messages.add(AssistantMessage('assistant', 
      'Merhaba! Size film ve dizi önerileri sunabilirim. Ne tür içerikler izlemek istersiniz?'));
  }

  Future<void> handlePrompt(String prompt) async {
    if (prompt.trim().isEmpty) return;

    // Öneri kartlarını temizle (sadece sohbet kullanıyoruz)
    recommendations.clear();

    messages.add(AssistantMessage('user', prompt));
    isThinking.value = true;

    try {
      if (_geminiService != null && _geminiService!.isAvailable) {
        // Tüm geçmiş sohbeti Gemini'ye gönder
        final history = messages
            .map((m) => {
                  'role': m.role,
                  'content': m.content,
                })
            .toList();

        final reply = await _geminiService!.getChatReply(history: history);
        messages.add(AssistantMessage('assistant', reply));
        // Öneri içeren yanıtları kartlara dönüştür
        // ignore: unawaited_futures
        _updateRecommendationsFromReply(reply);
      } else {
        messages.add(AssistantMessage(
          'assistant',
          'Yapay zeka şu anda kullanılamıyor. Lütfen Gemini API anahtarını kontrol edin.',
        ));
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Hata: $e');
      messages.add(AssistantMessage('assistant', 
        'Üzgünüm, Gemini isteği sırasında bir hata oluştu: ${e.toString()}'));
    } finally {
      isThinking.value = false;
    }
  }

  Future<void> _updateRecommendationsFromReply(String reply) async {
    recommendations.clear();
    try {
      final regex = RegExp(
        r'^\s*\d+\.\s*(.+?)(?:\s*\((\d{4})\))?\s*[–-]\s*(.+)$',
        multiLine: true,
      );
      final matches = regex.allMatches(reply).toList();
      if (matches.isEmpty) return;

      final List<Movie> result = [];

      for (final m in matches) {
        final title = m.group(1)?.trim();
        final yearStr = m.group(2)?.trim();
        if (title == null || title.isEmpty) continue;
        try {
          final movies = await _apiService.searchMovies(title);
          if (movies.isEmpty) continue;
          Movie best = movies.first;
          if (yearStr != null) {
            final year = int.tryParse(yearStr);
            if (year != null) {
              final byYear = movies.where((mv) {
                if (mv.releaseDate == null || mv.releaseDate!.length < 4) {
                  return false;
                }
                final y = int.tryParse(mv.releaseDate!.substring(0, 4));
                return y == year;
              });
              if (byYear.isNotEmpty) {
                best = byYear.first;
              }
            }
          }
          if (!result.any((mv) => mv.id == best.id)) {
            result.add(best);
          }
          if (result.length >= 8) break;
        } catch (_) {
          // Tek film araması hata verirse o satırı atla
        }
      }

      if (result.isNotEmpty) {
        recommendations.assignAll(result);
      }
    } catch (e) {
      // ignore: avoid_print
      print('assistant _updateRecommendationsFromReply error: $e');
    }
  }
  /// Mesajları temizle
  void clearMessages() {
    messages.clear();
    recommendations.clear();
    messages.add(AssistantMessage('assistant', 
      'Merhaba! Size film ve dizi önerileri sunabilirim. Ne tür içerikler izlemek istersiniz?'));
  }
}


