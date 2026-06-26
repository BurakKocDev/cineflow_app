// lib/controllers/detail_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/video_model.dart';
import 'package:cineflow_app/services/api_service.dart';
import 'package:cineflow_app/services/database_service.dart';
import 'package:cineflow_app/controllers/home_controller.dart';
import 'package:cineflow_app/controllers/favorite_controller.dart';
import 'package:cineflow_app/controllers/watch_history_controller.dart';
import 'package:cineflow_app/utils/haptic_feedback_helper.dart';

class DetailController extends GetxController {
  late final Movie movie;

  late final ApiService _apiService;
  late final DatabaseService _databaseService;
  late final HomeController _homeController;
  late final FavoriteController _favoriteController;
  WatchHistoryController? _watchHistoryController;

  var isFavorite = false.obs;
  var isLoadingTrailers = true.obs;
  var trailers = <Video>[].obs;
  YoutubePlayerController? ytController;

  @override
  void onInit() {
    super.onInit();
    movie = Get.arguments as Movie;

    _apiService = Get.find<ApiService>();
    _databaseService = Get.find<DatabaseService>();
    _homeController = Get.find<HomeController>();
    _favoriteController = Get.find<FavoriteController>();
    if (Get.isRegistered<WatchHistoryController>()) {
      _watchHistoryController = Get.find<WatchHistoryController>();
    }

    _checkIfFavorite();
    _fetchMovieTrailers(); // Bu metodun artık tanımlı olduğuna dikkat edin.
  }

  @override
  void onClose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    ytController?.dispose();
    super.onClose();
  }

  Future<void> _checkIfFavorite() async {
    isFavorite.value = await _databaseService.isFavorite(movie.id);
  }

  Future<void> _fetchMovieTrailers() async {
    try {
      final fetchedTrailers = await _apiService.fetchMovieVideos(movie.id);

      final officialTrailers = fetchedTrailers
          .where((video) =>
              video.site == 'YouTube' &&
              video.type == 'Trailer' &&
              video.official)
          .toList();

      if (officialTrailers.isNotEmpty) {
        trailers.assignAll(officialTrailers);
        final firstTrailer = officialTrailers.first;
        ytController = YoutubePlayerController(
          initialVideoId: firstTrailer.key,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      } else {
        trailers.clear();
        ytController = null;
      }
    } catch (e) {
      // Silently fail for trailers - not critical
      trailers.clear();
      ytController = null;
    } finally {
      isLoadingTrailers.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    HapticFeedbackHelper.mediumImpact();
    try {
      if (isFavorite.value) {
        await _databaseService.removeFavorite(movie.id);
        Get.snackbar(
          'favorites'.tr,
          'removed_from_favorites'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        await _databaseService.addFavorite(movie);
        Get.snackbar(
          'favorites'.tr,
          'added_to_favorites'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
      isFavorite.value = !isFavorite.value;

      // Ana ekran ve favoriler ekranını senkronize etmek için
      // ignore: unawaited_futures
      _homeController.loadFavoriteIds();
      // ignore: unawaited_futures
      _favoriteController.loadAllFavorites();
      
      // İzleme geçmişine ekle
      _addToWatchHistory();
    } catch (e) {
      Get.snackbar(
        'unknown_error'.tr,
        'try_again_later'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _addToWatchHistory() async {
    try {
      if (_watchHistoryController != null) {
        await _watchHistoryController!.addToHistory(
          itemId: movie.id,
          itemType: 'movie',
          title: movie.title,
          posterPath: movie.posterPath,
          progress: 0.0,
        );
      } else {
        // Direct database call if controller not available
        await _databaseService.addToWatchHistory(
          itemId: movie.id,
          itemType: 'movie',
          title: movie.title,
          posterPath: movie.posterPath,
          progress: 0.0,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error adding to watch history: $e');
    }
  }

  Future<void> updateWatchProgress(double progress) async {
    try {
      if (_watchHistoryController != null) {
        await _watchHistoryController!.updateProgress(
          itemId: movie.id,
          itemType: 'movie',
          progress: progress,
          status: progress >= 100 ? 'completed' : 'watching',
        );
      } else {
        await _databaseService.updateWatchProgress(
          itemId: movie.id,
          itemType: 'movie',
          progress: progress,
          status: progress >= 100 ? 'completed' : 'watching',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error updating watch progress: $e');
    }
  }
}
