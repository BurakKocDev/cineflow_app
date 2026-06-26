import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cineflow_app/models/movie_response_model.dart';
import 'package:cineflow_app/models/tv_show_response_model.dart';
import 'package:cineflow_app/models/video_model.dart';
import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/tv_show_model.dart';
import 'package:cineflow_app/models/person_model.dart';
import 'package:cineflow_app/models/genre_model.dart';
import 'package:cineflow_app/screens/filter_screen.dart';
import 'package:cineflow_app/config/env_config.dart';
import 'package:get/get.dart';

class ApiService extends GetxService {
  String get _apiKey => EnvConfig.tmdbApiKey;
  final String _baseUrl = 'https://api.themoviedb.org/3';

  /// Uygulamada seçili dile göre TMDB `language` parametresini döndürür.
  /// - Uygulama dili İngilizce ise: `en-US`
  /// - Diğer tüm durumlarda varsayılan: `tr-TR`
  String get _currentLanguageParam {
    final code = Get.locale?.languageCode;
    if (code == 'en') return 'en-US';
    return 'tr-TR';
  }

  // Movie Methods
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final url =
        '$_baseUrl/movie/popular?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieResponse movieResponse = MovieResponse.fromJson(data);
      return movieResponse.movies;
    } else {
      throw Exception('Popüler filmler alınamadı: ${response.statusCode}');
    }
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final url =
        '$_baseUrl/movie/top_rated?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieResponse movieResponse = MovieResponse.fromJson(data);
      return movieResponse.movies;
    } else {
      throw Exception('En iyi filmler alınamadı: ${response.statusCode}');
    }
  }

  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    final url =
        '$_baseUrl/movie/upcoming?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieResponse movieResponse = MovieResponse.fromJson(data);
      return movieResponse.movies;
    } else {
      throw Exception(
          'Yakında çıkacak filmler alınamadı: ${response.statusCode}');
    }
  }

  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    final url =
        '$_baseUrl/movie/now_playing?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieResponse movieResponse = MovieResponse.fromJson(data);
      return movieResponse.movies;
    } else {
      throw Exception(
          'Şimdi oynatılan filmler alınamadı: ${response.statusCode}');
    }
  }

  // Discover Movies with filters
  Future<List<Movie>> discoverMovies({
    int page = 1,
    String? withGenres,
    String? withPeople,
    String? withKeywords,
    String? withOriginalLanguage,
    double? voteAverageGte,
    double? voteAverageLte,
    int? voteCountGte,
    int? withRuntimeGte,
    int? withRuntimeLte,
    int? yearGte,
    int? yearLte,
    String sortBy = 'popularity.desc',
    String language = 'tr-TR',
  }) async {
    final params = <String, String>{
      'api_key': _apiKey,
      'language': language,
      'page': '$page',
      'sort_by': sortBy,
      'include_adult': 'false',
    };
    if (withGenres != null && withGenres.isNotEmpty) params['with_genres'] = withGenres;
    if (withPeople != null && withPeople.isNotEmpty) params['with_people'] = withPeople;
    if (withKeywords != null && withKeywords.isNotEmpty) params['with_keywords'] = withKeywords;
    if (withOriginalLanguage != null && withOriginalLanguage.isNotEmpty) params['with_original_language'] = withOriginalLanguage;
    if (voteAverageGte != null) params['vote_average.gte'] = voteAverageGte.toString();
    if (voteAverageLte != null) params['vote_average.lte'] = voteAverageLte.toString();
    if (voteCountGte != null) params['vote_count.gte'] = voteCountGte.toString();
    if (withRuntimeGte != null) params['with_runtime.gte'] = withRuntimeGte.toString();
    if (withRuntimeLte != null) params['with_runtime.lte'] = withRuntimeLte.toString();
    if (yearGte != null) params['primary_release_date.gte'] = '$yearGte-01-01';
    if (yearLte != null) params['primary_release_date.lte'] = '$yearLte-12-31';

    final query = params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    final url = '$_baseUrl/discover/movie?$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieResponse movieResponse = MovieResponse.fromJson(data);
      return movieResponse.movies;
    } else {
      throw Exception('Discover filmleri alınamadı: ${response.statusCode}');
    }
  }

  /// ✅ Refactor edilmiş Search + Filter
  Future<List<Movie>> searchMovies(String query,
      {MovieFilters? filters, int page = 1}) async {
    String url;

    if (filters == null) {
      // Normal search
      url =
          '$_baseUrl/search/movie?api_key=$_apiKey&language=$_currentLanguageParam&query=${Uri.encodeQueryComponent(query)}&page=$page';
    } else {
      // Discover with filters
      String sortBy = '';
      switch (filters.sortOption) {
        case SortOption.newest:
          sortBy = 'primary_release_date.desc';
          break;
        case SortOption.oldest:
          sortBy = 'primary_release_date.asc';
          break;
        case SortOption.highestRated:
          sortBy = 'vote_average.desc';
          break;
        case SortOption.lowestRated:
          sortBy = 'vote_average.asc';
          break;
        default:
          sortBy = 'popularity.desc';
      }

      String yearFilter = '';
      if (filters.yearRange.start > 1900 ||
          filters.yearRange.end < DateTime.now().year + 5) {
        yearFilter =
            '&primary_release_date.gte=${filters.yearRange.start.toInt()}-01-01&primary_release_date.lte=${filters.yearRange.end.toInt()}-12-31';
      }

      String ratingFilter = '';
      if (filters.ratingRange.start > 0 || filters.ratingRange.end < 10) {
        ratingFilter =
            '&vote_average.gte=${filters.ratingRange.start.toStringAsFixed(1)}&vote_average.lte=${filters.ratingRange.end.toStringAsFixed(1)}';
      }

      url =
          '$_baseUrl/discover/movie?api_key=$_apiKey&language=$_currentLanguageParam&sort_by=$sortBy$yearFilter$ratingFilter&page=$page';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieResponse movieResponse = MovieResponse.fromJson(data);
      return movieResponse.movies;
    } else {
      throw Exception('Film arama/veri alınamadı: ${response.statusCode}');
    }
  }

  Future<List<Video>> fetchMovieVideos(int movieId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'] as List<dynamic>;

      List<Video> videos = results
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList();

      // En uygun fragmanı bulma mantığı
      Video? bestVideo = videos.firstWhereOrNull((video) =>
          video.site == 'YouTube' &&
          video.type == 'Trailer' &&
          video.official == true &&
          video.name.toLowerCase().contains('official trailer'));

      bestVideo ??= videos.firstWhereOrNull((video) =>
          video.site == 'YouTube' &&
          video.type == 'Trailer' &&
          video.official == true);

      bestVideo ??= videos.firstWhereOrNull(
          (video) => video.site == 'YouTube' && video.type == 'Trailer');

      if (bestVideo != null) {
        return [bestVideo];
      }

      return [];
    } else {
      throw Exception('Video verisi alınamadı: ${response.statusCode}');
    }
  }

  /// TV dizileri için fragman / video bilgisi
  Future<List<Video>> fetchTvShowVideos(int tvId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/tv/$tvId/videos?api_key=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'] as List<dynamic>;

      final videos = results
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList();

      // En uygun fragmanı bulma mantığı (film ile aynı)
      Video? bestVideo = videos.firstWhereOrNull((video) =>
          video.site == 'YouTube' &&
          video.type == 'Trailer' &&
          video.official == true &&
          video.name.toLowerCase().contains('official trailer'));

      bestVideo ??= videos.firstWhereOrNull((video) =>
          video.site == 'YouTube' &&
          video.type == 'Trailer' &&
          video.official == true);

      bestVideo ??= videos.firstWhereOrNull(
          (video) => video.site == 'YouTube' && video.type == 'Trailer');

      if (bestVideo != null) {
        return [bestVideo];
      }

      return [];
    } else {
      throw Exception('TV videosu verisi alınamadı: ${response.statusCode}');
    }
  }

  // TV Show Methods
  Future<List<TvShow>> getPopularTvShows({int page = 1}) async {
    final url =
        '$_baseUrl/tv/popular?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final TvShowResponse tvShowResponse = TvShowResponse.fromJson(data);
      return tvShowResponse.tvShows;
    } else {
      throw Exception('Popüler TV dizileri alınamadı: ${response.statusCode}');
    }
  }

  // People / Actors Methods
  Future<List<Person>> getPopularPeople({int page = 1}) async {
    final url =
        '$_baseUrl/person/popular?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'] as List<dynamic>;
      return results.map((json) => Person.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Popüler kişiler alınamadı: ${response.statusCode}');
    }
  }

  Future<Person> getPersonDetails(int personId) async {
    final url =
        '$_baseUrl/person/$personId?api_key=$_apiKey&language=$_currentLanguageParam';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Person.fromJson(data);
    } else {
      throw Exception('Kişi detayları alınamadı: ${response.statusCode}');
    }
  }

  Future<Map<String, List<dynamic>>> getPersonCombinedCredits(int personId) async {
    final url =
        '$_baseUrl/person/$personId/combined_credits?api_key=$_apiKey&language=$_currentLanguageParam';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final cast = (data['cast'] as List<dynamic>?) ?? [];
      final crew = (data['crew'] as List<dynamic>?) ?? [];
      return {
        'cast': cast,
        'crew': crew,
      };
    } else {
      throw Exception('Kişi kredileri alınamadı: ${response.statusCode}');
    }
  }

  Future<List<Person>> searchPeople(String query, {int page = 1}) async {
    final url =
        '$_baseUrl/search/person?api_key=$_apiKey&language=$_currentLanguageParam&query=${Uri.encodeQueryComponent(query)}&page=$page&include_adult=false';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'] as List<dynamic>;
      return results.map((json) => Person.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Kişi araması başarısız: ${response.statusCode}');
    }
  }

  /// Keyword arama - tema/konu için
  Future<List<Map<String, dynamic>>> searchKeywords(String query, {int page = 1}) async {
    final url =
        '$_baseUrl/search/keyword?api_key=$_apiKey&query=${Uri.encodeQueryComponent(query)}&page=$page';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'] as List<dynamic>;
      return results.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Keyword araması başarısız: ${response.statusCode}');
    }
  }

  Future<List<TvShow>> getTopRatedTvShows({int page = 1}) async {
    final url =
        '$_baseUrl/tv/top_rated?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final TvShowResponse tvShowResponse = TvShowResponse.fromJson(data);
      return tvShowResponse.tvShows;
    } else {
      throw Exception('En iyi TV dizileri alınamadı: ${response.statusCode}');
    }
  }

  Future<List<TvShow>> getOnTheAirTvShows({int page = 1}) async {
    final url =
        '$_baseUrl/tv/on_the_air?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final TvShowResponse tvShowResponse = TvShowResponse.fromJson(data);
      return tvShowResponse.tvShows;
    } else {
      throw Exception(
          'Yayında olan TV dizileri alınamadı: ${response.statusCode}');
    }
  }

  Future<List<TvShow>> getAiringTodayTvShows({int page = 1}) async {
    final url =
        '$_baseUrl/tv/airing_today?api_key=$_apiKey&language=$_currentLanguageParam&page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final TvShowResponse tvShowResponse = TvShowResponse.fromJson(data);
      return tvShowResponse.tvShows;
    } else {
      throw Exception(
          'Bugün yayınlanan TV dizileri alınamadı: ${response.statusCode}');
    }
  }

  Future<List<TvShow>> searchTvShows(String query) async {
    final url =
        '$_baseUrl/search/tv?api_key=$_apiKey&language=$_currentLanguageParam&query=${Uri.encodeQueryComponent(query)}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final TvShowResponse tvShowResponse = TvShowResponse.fromJson(data);
      return tvShowResponse.tvShows;
    } else {
      throw Exception(
          'TV dizisi arama verisi alınamadı: ${response.statusCode}');
    }
  }

  /// TV dizisi detaylarını ID ile getirir (tüm detaylı bilgileri içerir)
  Future<TvShow> getTvShowDetails(int tvShowId) async {
    final url =
        '$_baseUrl/tv/$tvShowId?api_key=$_apiKey&language=$_currentLanguageParam';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return TvShow.fromJson(data);
    } else {
      throw Exception(
          'TV dizisi detayları alınamadı: ${response.statusCode}');
    }
  }

  // Genre Methods
  Future<List<Genre>> getMovieGenres() async {
    final url =
        '$_baseUrl/genre/movie/list?api_key=$_apiKey&language=$_currentLanguageParam';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> genres = data['genres'] as List<dynamic>;
      return genres
          .map((json) => Genre.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Film türleri alınamadı: ${response.statusCode}');
    }
  }

  Future<List<Genre>> getTvShowGenres() async {
    final url =
        '$_baseUrl/genre/tv/list?api_key=$_apiKey&language=$_currentLanguageParam';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> genres = data['genres'] as List<dynamic>;
      return genres
          .map((json) => Genre.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('TV dizisi türleri alınamadı: ${response.statusCode}');
    }
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final url =
        '$_baseUrl/discover/movie?api_key=$_apiKey&language=$_currentLanguageParam&with_genres=$genreId&page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieResponse movieResponse = MovieResponse.fromJson(data);
      return movieResponse.movies;
    } else {
      throw Exception('Türe göre filmler alınamadı: ${response.statusCode}');
    }
  }

  Future<List<TvShow>> getTvShowsByGenre(int genreId, {int page = 1}) async {
    final url =
        '$_baseUrl/discover/tv?api_key=$_apiKey&language=$_currentLanguageParam&with_genres=$genreId&page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final TvShowResponse tvShowResponse = TvShowResponse.fromJson(data);
      return tvShowResponse.tvShows;
    } else {
      throw Exception('Türe göre TV dizileri alınamadı: ${response.statusCode}');
    }
  }
}
