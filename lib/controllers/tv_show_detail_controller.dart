import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:cineflow_app/services/api_service.dart';
import 'package:cineflow_app/services/database_service.dart';
import 'package:cineflow_app/models/tv_show_model.dart';
import 'package:cineflow_app/models/video_model.dart';
import 'package:cineflow_app/controllers/home_controller.dart';
import 'package:cineflow_app/controllers/favorite_controller.dart';
import 'package:cineflow_app/utils/haptic_feedback_helper.dart';

class TvShowDetailController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  late final ApiService _apiService;
  late final HomeController _homeController;

  // Observable variables
  final Rx<TvShow?> tvShow = Rx<TvShow?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxList<dynamic> similarTvShows = <dynamic>[].obs;
  final RxList<dynamic> recommendations = <dynamic>[].obs;

  // Trailer state
  final RxBool isLoadingTrailers = false.obs;
  final RxList<Video> trailers = <Video>[].obs;
  YoutubePlayerController? ytController;

  late int _tvShowId;

  @override
  void onInit() {
    super.onInit();
    final initialTvShow = Get.arguments as TvShow;
    _tvShowId = initialTvShow.id;
    _homeController = Get.find<HomeController>();
    _apiService = Get.find<ApiService>();

    // Initialize with basic data, then fetch full details
    tvShow.value = initialTvShow;
    
    checkFavoriteStatus();
    _fetchTvShowTrailers();
    _fetchTvShowDetails();
  }

  @override
  void onClose() {
    ytController?.dispose();
    super.onClose();
  }

  Future<void> _fetchTvShowDetails() async {
    isLoading.value = true;
    try {
      final detailedTvShow = await _apiService.getTvShowDetails(_tvShowId);
      tvShow.value = detailedTvShow;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching TV show details: $e');
      Get.snackbar(
        'Error',
        'Failed to load TV show details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkFavoriteStatus() async {
    try {
      final isFav = await _databaseService.isFavoriteTvShow(_tvShowId);
      isFavorite.value = isFav;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to check favorite status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleFavorite() async {
    HapticFeedbackHelper.mediumImpact();
    try {
      if (tvShow.value != null) {
        await _databaseService.toggleFavoriteTvShow(tvShow.value!);
        isFavorite.value = !isFavorite.value;
        HapticFeedbackHelper.success();

        // Update home controller favorite IDs
        await _homeController.loadFavoriteIds();

        // Update favorites list screen if present
        if (Get.isRegistered<FavoriteController>()) {
          final fav = Get.find<FavoriteController>();
          // ignore: unawaited_futures
          fav.loadAllFavorites();
        }

        Get.snackbar(
          'Success',
          isFavorite.value
              ? '${tvShow.value!.name} favorilere eklendi'
              : '${tvShow.value!.name} favorilerden çıkarıldı',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle favorite: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _fetchTvShowTrailers() async {
    isLoadingTrailers.value = true;
    try {
      final fetchedTrailers = await _apiService.fetchTvShowVideos(_tvShowId);

      if (fetchedTrailers.isNotEmpty) {
        trailers.assignAll(fetchedTrailers);
        final firstTrailer = fetchedTrailers.first;
        ytController = YoutubePlayerController(
          initialVideoId: firstTrailer.key,
          flags: const YoutubePlayerFlags(
            autoPlay: true, // TV dizisi fragmanları otomatik başlasın
            mute: false,
          ),
        );
      } else {
        trailers.clear();
        ytController = null;
      }
    } catch (_) {
      trailers.clear();
      ytController = null;
    } finally {
      isLoadingTrailers.value = false;
    }
  }
}
