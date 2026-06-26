import 'package:get/get.dart';
import 'package:cineflow_app/services/database_service.dart';
import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/tv_show_model.dart';

class WatchHistoryItem {
  final int itemId;
  final String itemType;
  final String title;
  final String? posterPath;
  final double progress;
  final DateTime lastWatchedAt;
  final String status;
  final Movie? movie;
  final TvShow? tvShow;

  WatchHistoryItem({
    required this.itemId,
    required this.itemType,
    required this.title,
    this.posterPath,
    required this.progress,
    required this.lastWatchedAt,
    required this.status,
    this.movie,
    this.tvShow,
  });

  factory WatchHistoryItem.fromMap(Map<String, dynamic> map) {
    return WatchHistoryItem(
      itemId: map['itemId'] as int,
      itemType: map['itemType'] as String,
      title: map['title'] as String,
      posterPath: map['posterPath'] as String?,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      lastWatchedAt: DateTime.fromMillisecondsSinceEpoch(
        map['lastWatchedAt'] as int,
      ),
      status: map['status'] as String? ?? 'watching',
    );
  }
}

class WatchHistoryController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  final RxList<WatchHistoryItem> watchHistory = <WatchHistoryItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedType = 'all'.obs; // 'all', 'movie', 'tv'

  @override
  void onInit() {
    super.onInit();
    loadWatchHistory();
  }

  Future<void> loadWatchHistory() async {
    isLoading.value = true;
    try {
      final maps = await _databaseService.getWatchHistory(
        itemType: selectedType.value == 'all' ? null : selectedType.value,
      );
      
      watchHistory.assignAll(
        maps.map((map) => WatchHistoryItem.fromMap(map)).toList(),
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'İzleme geçmişi yüklenemedi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToHistory({
    required int itemId,
    required String itemType,
    required String title,
    String? posterPath,
    double progress = 0.0,
  }) async {
    try {
      await _databaseService.addToWatchHistory(
        itemId: itemId,
        itemType: itemType,
        title: title,
        posterPath: posterPath,
        progress: progress,
      );
      await loadWatchHistory();
    } catch (e) {
      // ignore: avoid_print
      print('Error adding to watch history: $e');
    }
  }

  Future<void> updateProgress({
    required int itemId,
    required String itemType,
    required double progress,
    String? status,
  }) async {
    try {
      await _databaseService.updateWatchProgress(
        itemId: itemId,
        itemType: itemType,
        progress: progress,
        status: status,
      );
      await loadWatchHistory();
    } catch (e) {
      // ignore: avoid_print
      print('Error updating progress: $e');
    }
  }

  Future<void> removeFromHistory(int itemId, String itemType) async {
    try {
      await _databaseService.removeFromWatchHistory(itemId, itemType);
      await loadWatchHistory();
      Get.snackbar(
        'Başarılı',
        'İzleme geçmişinden kaldırıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Kaldırılamadı: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void filterByType(String type) {
    selectedType.value = type;
    loadWatchHistory();
  }

  Future<void> markAsCompleted(int itemId, String itemType) async {
    await updateProgress(
      itemId: itemId,
      itemType: itemType,
      progress: 100.0,
      status: 'completed',
    );
  }
}

