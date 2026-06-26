import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/controllers/TvShowController.dart';
import 'package:cineflow_app/controllers/tv_show_detail_controller.dart';
import 'package:cineflow_app/screens/TvShowDetailScreen.dart';
import 'package:cineflow_app/widgets/horizontal_category_list.dart';
import 'package:cineflow_app/widgets/empty_state_widget.dart';
import 'package:cineflow_app/widgets/turkish_text_field.dart';

class TvShowsScreen extends GetView<TvShowController> {
  const TvShowsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Column(
        children: [
          _buildCategories(),
          _buildSearchBar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TurkishTextField(
        controller: controller.searchController,
        focusNode: controller.searchFocusNode,
        decoration: InputDecoration(
          hintText: 'search_tv_shows'.tr,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search,
              color: AppColors.primary,
            ),
          ),
          suffixIcon: Obx(
            () => controller.currentQuery.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.clear,
                        color: AppColors.error,
                      ),
                    ),
                    onPressed: () async {
                      controller.searchController.clear();
                      controller.currentQuery.value = '';
                      await controller.loadTvShowsByCategory(
                          controller.currentCategory.value);
                      controller.searchFocusNode.unfocus();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.card,
        ),
        textInputAction: TextInputAction.search,
        onChanged: (query) => controller.searchTvShows(query),
        onSubmitted: (query) {
          controller.searchTvShows(query);
          controller.searchFocusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildCategories() {
    final categoryLabels = [
      'popular_tv_shows'.tr,
      'top_rated_tv_shows'.tr,
      'on_the_air'.tr,
      'airing_today'.tr,
    ];

    return Obx(() => HorizontalCategoryList(
          categories: categoryLabels,
          selectedIndex: controller.currentCategory.value,
          onCategorySelected: (index) {
            controller.loadTvShowsByCategory(index);
          },
        ));
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.tvShows.isEmpty) {
        return _buildLoadingState();
      } else if (controller.tvShows.isEmpty && !controller.isLoading.value) {
        return _buildEmptyState();
      } else {
        return _buildTvShowsList();
      }
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'loading'.tr,
            style: Get.textTheme.titleLarge?.copyWith(
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: controller.currentQuery.isNotEmpty
          ? 'TV Dizi bulunamadı'
          : 'TV Dizi bulunamadı',
      subtitle: controller.currentQuery.isNotEmpty
          ? 'Arama teriminizi değiştirmeyi deneyin'
          : 'Yukarıdaki kategorilerden birini seçin',
      icon: Icons.tv_outlined,
    );
  }

  Widget _buildTvShowsList() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshTvShows();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 300) {
            controller.loadMoreTvShows();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.tvShows.length,
          itemBuilder: (context, index) {
            final tvShow = controller.tvShows[index];
            return _buildTvShowCard(tvShow, index);
          },
        ),
      ),
    );
  }

  Widget _buildTvShowCard(dynamic tvShow, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.to(
            () => const TvShowDetailScreen(),
            arguments: tvShow,
            binding: BindingsBuilder(() {
              Get.put(TvShowDetailController());
            }),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TV Show Poster
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.cardGradient,
                  ),
                  child: tvShow.posterPath != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500${tvShow.posterPath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderPoster();
                          },
                        )
                      : _buildPlaceholderPoster(),
                ),
              ),
            ),
            
            // TV Show Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title, Rating and Favorite Button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tvShow.name ?? 'Unknown',
                          style: Get.textTheme.titleLarge?.copyWith(
                            color: AppColors.onCard,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.secondaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.onPrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(tvShow.voteAverage ?? 0).toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => IconButton(
                        icon: Icon(
                          controller.favoriteTvShowIds.contains(tvShow.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: controller.favoriteTvShowIds.contains(tvShow.id)
                              ? AppColors.secondary
                              : AppColors.grey400,
                        ),
                        onPressed: () => controller.toggleFavorite(tvShow),
                      )),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Air Date and Status
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tvShow.firstAirDate ?? 'Tarih bilgisi yok',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.info,
                        size: 16,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tvShow.status ?? 'Unknown Status',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Overview
                  Text(
                    tvShow.overview ?? 'No overview available.',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onCard,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPoster() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.cardGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.tv,
          size: 60,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}
