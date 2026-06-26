import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/controllers/watch_history_controller.dart';
import 'package:cineflow_app/screens/detail_screen.dart';
import 'package:cineflow_app/screens/TvShowDetailScreen.dart';
import 'package:cineflow_app/controllers/detail_controller.dart';
import 'package:cineflow_app/controllers/tv_show_detail_controller.dart';

class WatchHistoryScreen extends GetView<WatchHistoryController> {
  const WatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('watch_history'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildFilterTab('all', 'Tümü'),
          const SizedBox(width: 12),
          _buildFilterTab('movie', 'Filmler'),
          const SizedBox(width: 12),
          _buildFilterTab('tv', 'Diziler'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String type, String label) {
    return Obx(() => GestureDetector(
          onTap: () => controller.filterByType(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: controller.selectedType.value == type
                  ? AppColors.primaryGradient
                  : null,
              color: controller.selectedType.value == type
                  ? null
                  : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: controller.selectedType.value != type
                  ? Border.all(color: AppColors.grey700)
                  : null,
            ),
            child: Text(
              label,
              style: Get.textTheme.labelLarge?.copyWith(
                color: controller.selectedType.value == type
                    ? AppColors.onPrimary
                    : AppColors.onBackground,
                fontWeight: controller.selectedType.value == type
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ));
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.watchHistory.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadWatchHistory(),
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.watchHistory.length,
          itemBuilder: (context, index) {
            final item = controller.watchHistory[index];
            return _buildHistoryItem(item, index);
          },
        ),
      );
    });
  }

  Widget _buildHistoryItem(WatchHistoryItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (item.itemType == 'movie') {
            // Movie detail - need to fetch movie details
            Get.to(
              () => const DetailScreen(),
              arguments: item.itemId,
              binding: BindingsBuilder(() {
                Get.put(DetailController());
              }),
            );
          } else {
            // TV show detail
            Get.to(
              () => const TvShowDetailScreen(),
              arguments: item.itemId,
              binding: BindingsBuilder(() {
                Get.put(TvShowDetailController());
              }),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: item.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w200${item.posterPath}',
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: AppColors.onCard,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'İlerleme: ${item.progress.toStringAsFixed(0)}%',
                              style: Get.textTheme.bodySmall?.copyWith(
                                color: AppColors.grey400,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.status == 'completed'
                                    ? AppColors.success
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.status == 'completed'
                                    ? 'Tamamlandı'
                                    : 'İzleniyor',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.progress / 100,
                            backgroundColor: AppColors.grey800,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              item.status == 'completed'
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Son izlenme: ${_formatDate(item.lastWatchedAt)}',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                _showDeleteDialog(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 150,
      decoration: const BoxDecoration(
        gradient: AppColors.cardGradient,
      ),
      child: const Icon(
        Icons.movie,
        size: 40,
        color: AppColors.grey400,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.history,
              size: 60,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'İzleme Geçmişi Boş',
            style: Get.textTheme.headlineMedium?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İzlediğin filmler ve diziler burada görünecek',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(WatchHistoryItem item) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Kaldır',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: Text(
          '${item.title} izleme geçmişinden kaldırılsın mı?',
          style: const TextStyle(color: AppColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppColors.grey400),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.removeFromHistory(item.itemId, item.itemType);
              Get.back();
            },
            child: const Text(
              'Kaldır',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
