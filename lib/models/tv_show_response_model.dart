// lib/models/tv_show_response_model.dart

import 'tv_show_model.dart';

class TvShowResponse {
  final int page;
  final List<TvShow> tvShows;
  final int totalPages;
  final int totalResults;

  TvShowResponse({
    required this.page,
    required this.tvShows,
    required this.totalPages,
    required this.totalResults,
  });

  factory TvShowResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<TvShow> tvShowsList = list.map((i) => TvShow.fromJson(i)).toList();

    return TvShowResponse(
      page: json['page'],
      tvShows: tvShowsList,
      totalPages: json['total_pages'],
      totalResults: json['total_results'],
    );
  }
}
