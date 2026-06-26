import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/services/api_service.dart';
import 'package:cineflow_app/services/database_service.dart';
import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/tv_show_model.dart';
import 'package:cineflow_app/screens/filter_screen.dart';
import 'package:cineflow_app/controllers/favorite_controller.dart';
import 'package:cineflow_app/utils/haptic_feedback_helper.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();

  // Observable variables
  final RxList<dynamic> movies = <dynamic>[].obs;
  final RxList<dynamic> tvShows = <dynamic>[].obs;
  final RxString currentQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxSet<int> favoriteMovieIds = <int>{}.obs;
  final RxSet<int> favoriteTvShowIds = <int>{}.obs;
  final RxInt currentMoviePage = 1.obs;
  final RxBool isLoadingMoreMovies = false.obs;
  final RxBool isGridView = false.obs; // Grid/List toggle

  // Filters
  final Rx<MovieFilters> currentFilters = MovieFilters(
    sortOption: SortOption.none,
    yearRange: const RangeValues(1900, 2025),
    ratingRange: const RangeValues(0, 10),
  ).obs;


  // Debounce timer for search
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    // Load favorite IDs first (synchronously if possible, but async won't block)
    // ignore: unawaited_futures
    loadFavoriteIds();
    // Load initial data
    loadInitialData();
    // Setup search listener with debounce
    _setupSearchListener();
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    searchController.dispose();
    searchFocusNode.dispose();
    pageController.dispose();
    scrollController.dispose();
    // Cancel debounce timer
    _searchDebounce?.cancel();
    super.onClose();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      final query = searchController.text.trim();
      // Cancel previous timer
      _searchDebounce?.cancel();
      // Create new timer with 500ms delay
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        if (query != currentQuery.value) {
          _performSearch(query);
        }
      });
    });
  }

  Future<void> loadInitialData() async {
    if (isLoading.value) return; // Prevent multiple simultaneous loads
    isLoading.value = true;
    try {
      currentMoviePage.value = 1;
      // Load favorite IDs in parallel with movies
      final favoriteFuture = loadFavoriteIds();
      final popularMovies = await _apiService.getPopularMovies(page: currentMoviePage.value);
      movies.assignAll(popularMovies);
      final popularTvShows = await _apiService.getPopularTvShows();
      tvShows.assignAll(popularTvShows);
      // Wait for favorites to load
      await favoriteFuture;
    } catch (e) {
      _showError('network_error'.tr, 'try_again_later'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMovies() async {
    await loadInitialData();
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void onTabTapped(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      currentQuery.value = '';
      await loadInitialData();
      return;
    }

    if (isLoading.value) return; // Prevent multiple simultaneous searches
    
    currentQuery.value = query;
    isLoading.value = true;
    try {
      final searchResults = await _apiService.searchMovies(query);
      movies.assignAll(searchResults);
    } catch (e) {
      _showError('network_error'.tr, 'try_again_later'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // Public method for immediate search (used by buttons)
  Future<void> search(String query) async {
    _searchDebounce?.cancel();
    await _performSearch(query);
  }

  Future<void> loadFavoriteIds() async {
    try {
      final favoriteMovies = await _databaseService.getFavoriteMovies();
      final favoriteTvShows = await _databaseService.getFavoriteTvShows();
      favoriteMovieIds.assignAll(favoriteMovies.map((m) => m.id));
      favoriteTvShowIds.assignAll(favoriteTvShows.map((t) => t.id));
      // ignore: avoid_print
      print('Loaded ${favoriteMovieIds.length} favorite movies and ${favoriteTvShowIds.length} favorite TV shows');
    } catch (e) {
      // ignore: avoid_print
      print('Error loading favorite IDs: $e');
      // Initialize with empty sets if error
      favoriteMovieIds.clear();
      favoriteTvShowIds.clear();
    }
  }

  Future<void> toggleFavoriteFromList(dynamic item) async {
    HapticFeedbackHelper.mediumImpact();
    try {
      if (item is Movie) {
        await _databaseService.toggleFavoriteMovie(item);
        await loadFavoriteIds(); // Refresh favorite IDs
        // Sync with FavoriteController
        if (Get.isRegistered<FavoriteController>()) {
          // ignore: unawaited_futures
          Get.find<FavoriteController>().loadAllFavorites();
        }
      } else if (item is TvShow) {
        await _databaseService.toggleFavoriteTvShow(item);
        await loadFavoriteIds(); // Refresh favorite IDs
        // Sync with FavoriteController
        if (Get.isRegistered<FavoriteController>()) {
          // ignore: unawaited_futures
          Get.find<FavoriteController>().loadAllFavorites();
        }
      }
    } catch (e) {
      _showError('unknown_error'.tr, 'try_again_later'.tr);
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

  /// Surprise me: Rastgele bir film önerisi
  Future<void> applyFilters(MovieFilters filters) async {
    if (isLoading.value) return; // Prevent multiple simultaneous filter applications
    
    currentFilters.value = filters;
    isLoading.value = true;

    try {
      // Apply filters to API call
      final filteredMovies =
          await _apiService.searchMovies(currentQuery.value, filters: filters);
      movies.assignAll(filteredMovies);
    } catch (e) {
      _showError('network_error'.tr, 'try_again_later'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // home_screen.dart'ta kullanılan bu metodlar eklendi
  void clearSearch() {
    searchController.clear();
    loadInitialData();
  }

  Future<void> loadMoreMovies() async {
    if (isLoadingMoreMovies.value || currentQuery.isNotEmpty || isLoading.value) return;
    isLoadingMoreMovies.value = true;
    try {
      final nextPage = currentMoviePage.value + 1;
      final more = await _apiService.getPopularMovies(page: nextPage);
      if (more.isNotEmpty) {
        currentMoviePage.value = nextPage;
        movies.addAll(more);
      }
    } catch (e) {
      // Silently fail for pagination - user can retry by scrolling
      // ignore: avoid_print
      print('loadMoreMovies error: $e');
    } finally {
      isLoadingMoreMovies.value = false;
    }
  }

}
