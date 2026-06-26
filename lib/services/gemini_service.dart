// lib/services/gemini_service.dart
// Gemini API servisi - şimdilik hazır ama aktif değil
// Kullanmak için API key eklemen gerekecek

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/tv_show_model.dart';
import 'package:cineflow_app/utils/turkish_text.dart';
import 'package:cineflow_app/config/env_config.dart';

class GeminiService extends GetxService {
  static const String _apiBase = 'https://generativelanguage.googleapis.com/v1beta';
  static const Duration _timeout = Duration(seconds: 30);

  String? _resolvedModelName; // örn: "models/gemini-2.5-flash"

  String get _apiKey => EnvConfig.geminiApiKey;

  bool get isAvailable => EnvConfig.hasGeminiApiKey;

  Future<String> _resolveModelName() async {
    if (_resolvedModelName != null) return _resolvedModelName!;

    final uri = Uri.parse('$_apiBase/models?key=$_apiKey');
    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('ListModels failed ${response.statusCode}: ${response.body}');
    }

    final data = json.decode(response.body);
    final models = (data['models'] as List?) ?? const [];
    if (models.isEmpty) {
      throw Exception('No models returned by ListModels');
    }

    bool supportsGenerateContent(dynamic m) {
      final methods = m['supportedGenerationMethods'];
      return methods is List && methods.contains('generateContent');
    }

    String? pick(Iterable<dynamic> source) {
      for (final m in source) {
        if (!supportsGenerateContent(m)) continue;
        final name = m['name'];
        if (name is String && name.startsWith('models/')) return name;
      }
      return null;
    }

    // 1) Öncelik: gemini-2.5 + flash + generateContent
    final m25flash = pick(models.where((m) {
      final name = (m['name'] ?? '').toString();
      return name.contains('gemini-2.5') && name.contains('flash');
    }));
    if (m25flash != null) {
      _resolvedModelName = m25flash;
      return m25flash;
    }

    // 2) Fallback: herhangi bir "flash"
    final anyFlash = pick(models.where((m) => (m['name'] ?? '').toString().contains('flash')));
    if (anyFlash != null) {
      _resolvedModelName = anyFlash;
      return anyFlash;
    }

    // 3) Fallback: herhangi bir gemini
    final anyGemini = pick(models.where((m) => (m['name'] ?? '').toString().contains('gemini')));
    if (anyGemini != null) {
      _resolvedModelName = anyGemini;
      return anyGemini;
    }

    // 4) Son çare: ilk model adı
    final first = models.first;
    final firstName = first['name'];
    if (firstName is String && firstName.startsWith('models/')) {
      _resolvedModelName = firstName;
      return firstName;
    }

    throw Exception('Could not resolve a usable Gemini model');
  }

  Future<Uri> _generateContentUri() async {
    final modelName = await _resolveModelName(); // "models/..."
    return Uri.parse('$_apiBase/$modelName:generateContent?key=$_apiKey');
  }

  /// Genel amaçlı chat cevabı (sohbet ekranı için)
  ///
  /// [history]: Sırasıyla geçmiş mesajlar; role: 'user' veya 'assistant'
  Future<String> getChatReply({
    required List<Map<String, String>> history,
  }) async {
    if (!isAvailable) {
      throw Exception('Gemini API key not configured');
    }
    if (history.isEmpty) {
      throw Exception('History cannot be empty');
    }

    // Sistem talimatı: sadece net, tam listeler döndür
    const systemInstruction =
        'Sen film ve dizi odaklı bir sohbet ve öneri asistanısın. '
        'Kullanıcı üzgün olabilir, soru sorabilir veya sadece muhabbet etmek isteyebilir; '
        'doğal, samimi ve Türkçe cevap ver.\n'
        '$turkishOrthographyInstruction\n\n'
        'Eğer kullanıcı film/dizi ÖNERİSİ istiyorsa:\n'
        '- EN FAZLA 5 adet öneriyi numaralı liste halinde yaz (1., 2., 3. ...).\n'
        '- Her satırda "Film/Dizi Adı (Yıl) – kısa açıklama." formatını kullan.\n'
        '- Cümleleri mutlaka tam bitir; kelime veya cümle yarım kalmasın, sonuna nokta koy.\n\n'
        'Eğer kullanıcı sadece sohbet ediyorsa veya soru soruyorsa:\n'
        '- Normal chat bot gibi doğal ve kısa cevaplar ver (en fazla 3-4 cümle).\n'
        '- Gerektiğinde film ve dizilerden örnekler vermen serbest.';

    // Gemini için içerik listesi oluştur (önce sistem mesajı, sonra geçmiş)
    final contents = <Map<String, dynamic>>[
      {
        'role': 'user',
        'parts': [
          {'text': systemInstruction},
        ],
      },
      ...history.map((m) {
      final role = m['role'] == 'assistant' ? 'model' : 'user';
      final text = m['content'] ?? '';
      return {
        'role': role,
        'parts': [
          {'text': text},
        ],
      };
    }),
    ];

    final requestBody = {
      'contents': contents,
      'generationConfig': {
        'temperature': 0.4,
        'topK': 32,
        'topP': 0.9,
        'maxOutputTokens': 2048,
      },
    };

    final response = await http
        .post(
          await _generateContentUri(),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = json.decode(response.body);
    final candidates = data['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final candidate = candidates[0];
      final content = candidate['content'];
      if (content != null &&
          content['parts'] is List &&
          content['parts'].isNotEmpty) {
        final part = content['parts'][0];
        final text = part['text'];
        if (text is String && text.isNotEmpty) {
          return text;
        }
      }
    }

    throw Exception('Empty response from Gemini API');
  }

  /// Gemini API ile film önerisi al
  /// 
  /// [prompt]: Kullanıcının sorgusu
  /// [contextMovies]: TMDB'den çekilen ilgili filmler (context olarak)
  /// [contextTvShows]: TMDB'den çekilen ilgili diziler (context olarak)
  /// 
  /// Returns: AI'nın önerdiği filmler ve açıklama
  Future<Map<String, dynamic>> getMovieRecommendations({
    required String prompt,
    List<Movie>? contextMovies,
    List<TvShow>? contextTvShows,
  }) async {
    if (!isAvailable) {
      throw Exception('Gemini API key not configured');
    }

    try {
      // Context oluştur - sadece ilgili filmler
      String context = _buildContext(contextMovies, contextTvShows);
      
      // Kullanıcının istediği genre'yi çıkar
      String genreHint = _extractGenreHint(prompt);
      
      // Çok daha spesifik ve katı prompt
      final systemPrompt = '''Sen bir film öneri asistanısın. ÇOK ÖNEMLİ: Sadece kullanıcının istediği kriterlere TAM UYAN filmleri önermelisin.

KULLANICI İSTEĞİ: "$prompt"
${genreHint.isNotEmpty ? 'İSTENEN TÜR: $genreHint' : ''}

${context.isNotEmpty ? 'TMDB\'DEN ÇEKİLEN FİLMLER (SADECE BU FİLMLERDEN SEÇ):\n$context' : ''}

KURALLAR:
1. SADECE yukarıdaki listedeki filmlerden öner yap
2. Eğer kullanıcı belirli bir tür istiyorsa (ör: komedi), SADECE o türe ait filmleri öner
3. Alakasız filmler önerme - eğer uygun film yoksa "Bu kriterlere uygun film bulunamadı" de
4. En fazla 10 film öner
5. Her film için kısa açıklama yap (neden bu filmi önerdiğini belirt)
6. Türkçe yanıt ver ve $turkishOrthographyInstruction
7. Samimi ama profesyonel bir ton kullan

ÖRNEK YANIT FORMATI:
"Size X film önerisi buldum:

1. [Film Adı] - [Kısa açıklama]
2. [Film Adı] - [Kısa açıklama]
..."

Eğer listede uygun film yoksa: "Maalesef bu kriterlere uygun film bulunamadı. Farklı bir tür veya kriter deneyebilirsiniz."''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': systemPrompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3, // Daha düşük temperature = daha tutarlı ve odaklı yanıtlar
          'topK': 20, // Daha az seçenek = daha tutarlı
          'topP': 0.8, // Daha düşük topP = daha odaklı
          'maxOutputTokens': 800, // Daha kısa yanıtlar
        }
      };

      final response = await http.post(
        await _generateContentUri(),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // API yanıtını kontrol et
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate['content'] != null && candidate['content']['parts'] != null) {
            final text = candidate['content']['parts'][0]['text'] ?? '';
            
            if (text.isNotEmpty) {
              return {
                'success': true,
                'response': text,
                'recommendedMovies': contextMovies ?? [],
              };
            }
          }
        }
        
        // Yanıt boşsa hata döndür
        return {
          'success': false,
          'error': 'Gemini API boş yanıt döndü',
        };
      } else {
        // HTTP hatası
        final errorBody = response.body.isNotEmpty 
            ? json.decode(response.body) 
            : {'error': 'Bilinmeyen hata'};
        
        return {
          'success': false,
          'error': 'Gemini API error ${response.statusCode}: ${errorBody.toString()}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Gemini API exception: ${e.toString()}',
      };
    }
  }

  /// Context string'i oluştur - daha detaylı ve genre bilgisiyle
  String _buildContext(List<Movie>? movies, List<TvShow>? tvShows) {
    final buffer = StringBuffer();
    
    if (movies != null && movies.isNotEmpty) {
      buffer.writeln('FİLMLER (SADECE BUNLARDAN SEÇ):');
      buffer.writeln('=' * 50);
      for (var movie in movies.take(15)) {
        final genreInfo = movie.genreIds != null && movie.genreIds!.isNotEmpty
            ? 'Genre ID: ${movie.genreIds!.join(", ")}'
            : 'Genre bilgisi yok';
        buffer.writeln('\n${movie.title}');
        buffer.writeln('  Yıl: ${movie.releaseDate ?? "Bilinmiyor"}');
        buffer.writeln('  Puan: ${movie.voteAverage.toStringAsFixed(1)}/10');
        buffer.writeln('  $genreInfo');
        if (movie.overview.isNotEmpty) {
          final overview = movie.overview.length > 150 
              ? '${movie.overview.substring(0, 150)}...' 
              : movie.overview;
          buffer.writeln('  Özet: $overview');
        }
      }
    }
    
    if (tvShows != null && tvShows.isNotEmpty) {
      buffer.writeln('\n\nDİZİLER (SADECE BUNLARDAN SEÇ):');
      buffer.writeln('=' * 50);
      for (var show in tvShows.take(15)) {
        buffer.writeln('\n${show.name}');
        buffer.writeln('  İlk Yayın: ${show.firstAirDate ?? "Bilinmiyor"}');
        buffer.writeln('  Puan: ${show.voteAverage.toStringAsFixed(1)}/10');
        if (show.overview.isNotEmpty) {
          final overview = show.overview.length > 150 
              ? '${show.overview.substring(0, 150)}...' 
              : show.overview;
          buffer.writeln('  Özet: $overview');
        }
      }
    }
    
    return buffer.toString();
  }

  /// Prompt'tan genre ipucu çıkar
  String _extractGenreHint(String prompt) {
    final lower = prompt.toTurkishLowerCase();
    final genreMap = {
      'komedi': 'Komedi',
      'comedy': 'Komedi',
      'aksiyon': 'Aksiyon',
      'action': 'Aksiyon',
      'dram': 'Dram',
      'drama': 'Dram',
      'korku': 'Korku',
      'horror': 'Korku',
      'gerilim': 'Gerilim',
      'thriller': 'Gerilim',
      'bilim kurgu': 'Bilim Kurgu',
      'science fiction': 'Bilim Kurgu',
      'romantik': 'Romantik',
      'romance': 'Romantik',
      'fantastik': 'Fantastik',
      'fantasy': 'Fantastik',
    };
    
    for (var entry in genreMap.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return '';
  }

  /// Sorgunun karmaşıklığını değerlendir
  /// Returns: true if query should use AI (artık daha fazla sorgu AI ile işlenecek)
  bool isComplexQuery(String query) {
    final lower = query.toTurkishLowerCase();
    
    // Karmaşık sorgu göstergeleri
    final complexPatterns = [
      r'\b(ve|ile|birlikte|ama|ancak|fakat)\b', // Bağlaçlar
      r'\b(örneğin|mesela|gibi|benzer)\b', // Örnekler
      r'\b(neden|niçin|nasıl|neden)\b', // Sorular
      r'\b(öner|tavsiye|öneri|tavsiye et|bul|göster)\b', // Açık istekler
      r'\b(tema|temalı|konu|konulu|hakkında|about)\b', // Tema/konu sorguları
      r'.{60,}', // Uzun sorgular (60+ karakter) - daha düşük eşik
    ];
    
    for (var pattern in complexPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }
    
    // Birden fazla kriter varsa karmaşık sayılır (artık 1+ kriter yeterli - daha agresif)
    int criteriaCount = 0;
    if (RegExp(r'\d{4}').hasMatch(lower)) criteriaCount++; // Yıl
    if (RegExp(r'(aksiyon|komedi|dram|korku|gerilim|bilim kurgu|fantastik|romantik|suç|macera|animasyon|komedi filmi|komedi dizisi)').hasMatch(lower)) criteriaCount++; // Tür
    if (RegExp(r'(oyuncu|aktör|yönetmen|yazar|actor|director|writer)').hasMatch(lower)) criteriaCount++; // Kişi
    if (RegExp(r'\d+\s*(puan|rating|imdb|tmdb|\+|üzeri|üstü)').hasMatch(lower)) criteriaCount++; // Puan
    if (RegExp(r'(tema|temalı|konu|konulu|keyword)').hasMatch(lower)) criteriaCount++; // Tema/konu
    
    // Artık 1 veya daha fazla kriter = AI kullan (daha iyi sonuçlar için)
    return criteriaCount >= 1;
  }
}

