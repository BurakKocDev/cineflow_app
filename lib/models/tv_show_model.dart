// lib/models/tv_show_model.dart

class TvShow {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? firstAirDate;
  final String? lastAirDate;
  final String? status;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? originalLanguage;
  final String? type;
  final double voteAverage;

  TvShow({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.firstAirDate,
    this.lastAirDate,
    this.status,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.originalLanguage,
    this.type,
    required this.voteAverage,
  });

  // API'den gelen JSON verisini TvShow objesine dönüştürür
  factory TvShow.fromJson(Map<String, dynamic> json) {
    // Güvenli tip dönüşümleri için helper fonksiyonlar
    String? safeString(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      return value.toString();
    }

    int? safeInt(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed;
      }
      return null;
    }

    return TvShow(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      firstAirDate: safeString('first_air_date'),
      lastAirDate: safeString('last_air_date'),
      status: safeString('status'),
      numberOfSeasons: safeInt('number_of_seasons'),
      numberOfEpisodes: safeInt('number_of_episodes'),
      originalLanguage: safeString('original_language'),
      type: safeString('type'),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // TvShow objesini veritabanına kaydetmek için Map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'posterPath': posterPath,
      'firstAirDate': firstAirDate,
    };
  }

  // Veritabanından okunan Map verisini TvShow objesine dönüştürür
  factory TvShow.fromMap(Map<String, dynamic> map) {
    return TvShow(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      posterPath: map['posterPath'] as String?,
      firstAirDate: map['firstAirDate'] as String?,
      // Diğer alanlar veritabanında olmadığı için boş geçilebilir
      voteAverage: 0.0,
      lastAirDate: null,
      status: null,
      numberOfSeasons: null,
      numberOfEpisodes: null,
      originalLanguage: null,
      type: null,
    );
  }
}
