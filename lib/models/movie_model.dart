import 'package:cineflow_app/models/genre_model.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final List<int>? genreIds;
  final List<Genre>? genres;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    this.genreIds,
    this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>(),
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      posterPath: map['posterPath'] as String?,
      releaseDate: map['releaseDate'] as String?,
      voteAverage: 0.0, // Veritabanında saklanmıyor, varsayılan değer
      backdropPath: null,
      genreIds: null,
      genres: null,
    );
  }
}
