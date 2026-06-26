import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/services/api_service.dart';
import 'package:cineflow_app/services/database_service.dart';
import 'package:cineflow_app/models/tv_show_model.dart';
import 'package:cineflow_app/controllers/favorite_controller.dart';
import 'package:cineflow_app/utils/haptic_feedback_helper.dart';

class TvShowController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Search controllers
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  // Observable variables
  final RxList<TvShow> tvShows = <TvShow>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentCategory = 0.obs;
  final RxSet<int> favoriteTvShowIds = <int>{}.obs;
  final RxInt currentPage = 1.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString currentQuery = ''.obs;

  // Categories
  final List<String> categories = [
    'popular',
    'top_rated',
    'on_the_air',
    'airing_today',
  ];

  @override
  void onInit() {
    super.onInit();
    // Load favorite IDs first
    // ignore: unawaited_futures
    loadFavoriteIds();
    loadTvShowsByCategory(0); // Load popular TV shows by default
  }

  @override
  void onClose() {
    // Cleanup
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  Future<void> loadFavoriteIds() async {
    try {
      final favoriteTvShows = await _databaseService.getFavoriteTvShows();
      favoriteTvShowIds.assignAll(favoriteTvShows.map((t) => t.id));
      // ignore: avoid_print
      print('Loaded ${favoriteTvShowIds.length} favorite TV shows');
    } catch (e) {
      // ignore: avoid_print
      print('Error loading favorite TV show IDs: $e');
      favoriteTvShowIds.clear();
    }
  }

  Future<void> loadTvShowsByCategory(int categoryIndex) async {
    if (isLoading.value) return; // Prevent multiple simultaneous loads
    
    currentCategory.value = categoryIndex;
    isLoading.value = true;
    currentPage.value = 1;

    try {
      List<TvShow> shows;
      final category = categories[categoryIndex];

      switch (category) {
        case 'popular':
          shows = await _apiService.getPopularTvShows();
          break;
        case 'top_rated':
          shows = await _apiService.getTopRatedTvShows();
          break;
        case 'on_the_air':
          shows = await _apiService.getOnTheAirTvShows();
          break;
        case 'airing_today':
          shows = await _apiService.getAiringTodayTvShows();
          break;
        default:
          shows = await _apiService.getPopularTvShows();
      }

      tvShows.assignAll(shows);
    } catch (e) {
      _showError('network_error'.tr, 'try_again_later'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> refreshTvShows() async {
    await loadTvShowsByCategory(currentCategory.value);
  }

  Future<void> searchTvShows(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      currentQuery.value = '';
      await loadTvShowsByCategory(currentCategory.value);
      return;
    }

    if (isLoading.value) return; // Prevent multiple simultaneous searches

    currentQuery.value = trimmed;
    isLoading.value = true;
    try {
      final searchResults = await _apiService.searchTvShows(trimmed);
      tvShows.assignAll(searchResults);
    } catch (e) {
      _showError('network_error'.tr, 'try_again_later'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(TvShow tvShow) async {
    HapticFeedbackHelper.mediumImpact();
    try {
      await _databaseService.toggleFavoriteTvShow(tvShow);

      if (favoriteTvShowIds.contains(tvShow.id)) {
        favoriteTvShowIds.remove(tvShow.id);
        Get.snackbar(
          'favorites'.tr,
          'removed_from_favorites'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        favoriteTvShowIds.add(tvShow.id);
        Get.snackbar(
          'favorites'.tr,
          'added_to_favorites'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      // Keep Favorites screen in sync
      if (Get.isRegistered<FavoriteController>()) {
        final fav = Get.find<FavoriteController>();
        // Fire and forget is fine here; UI will react when done
        // ignore: unawaited_futures
        fav.loadAllFavorites();
      }
    } catch (e) {
      _showError('unknown_error'.tr, 'try_again_later'.tr);
    }
  }

  bool isFavorite(int tvShowId) {
    return favoriteTvShowIds.contains(tvShowId);
  }

  Future<void> loadMoreTvShows() async {
    if (isLoadingMore.value || isLoading.value) return;
    isLoadingMore.value = true;
    try {
      final next = currentPage.value + 1;
      List<TvShow> shows;
      final category = categories[currentCategory.value];
      switch (category) {
        case 'popular':
          shows = await _apiService.getPopularTvShows(page: next);
          break;
        case 'top_rated':
          shows = await _apiService.getTopRatedTvShows(page: next);
          break;
        case 'on_the_air':
          shows = await _apiService.getOnTheAirTvShows(page: next);
          break;
        case 'airing_today':
          shows = await _apiService.getAiringTodayTvShows(page: next);
          break;
        default:
          shows = await _apiService.getPopularTvShows(page: next);
      }
      if (shows.isNotEmpty) {
        currentPage.value = next;
        tvShows.addAll(shows);
      }
    } catch (e) {
      // Silently fail for pagination - user can retry by scrolling
      // ignore: avoid_print
      print('loadMoreTvShows error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

}
