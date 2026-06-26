// lib/controllers/favorite_controller.dart
import 'package:get/get.dart';
import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/tv_show_model.dart';
import 'package:cineflow_app/services/database_service.dart';

class FavoriteController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  var favoriteMovies = <Movie>[].obs;
  var favoriteTvShows = <TvShow>[].obs;
  var isLoading = true.obs;
  var currentTab = 0.obs; // 0 for movies, 1 for TV shows

  @override
  void onInit() {
    super.onInit();
    loadAllFavorites();
  }

  Future<void> loadAllFavorites() async {
    isLoading.value = true;
    try {
      final fetchedMovies = await _databaseService.getFavoriteMovies();
      final fetchedTvShows = await _databaseService.getFavoriteTvShows();

      favoriteMovies.assignAll(fetchedMovies);
      favoriteTvShows.assignAll(fetchedTvShows);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Favoriler yüklenemedi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Bu metot, sekmeler arasında geçiş yapmak için kullanılır
  void switchTab(int index) {
    currentTab.value = index;
  }

  Future<void> refreshFavorites() async {
    await loadAllFavorites();
  }

  Future<void> removeFavoriteMovie(int id) async {
    await _databaseService.removeFavorite(id);
    favoriteMovies.removeWhere((movie) => movie.id == id);
    Get.snackbar(
      'Favoriler',
      'Film favorilerden çıkarıldı.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> removeFavoriteTvShow(int id) async {
    await _databaseService.removeFavoriteTvShow(id);
    favoriteTvShows.removeWhere((tvShow) => tvShow.id == id);
    Get.snackbar(
      'Favoriler',
      'TV dizisi favorilerden çıkarıldı.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  
}
