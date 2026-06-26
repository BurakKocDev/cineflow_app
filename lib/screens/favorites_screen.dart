// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/controllers/favorite_controller.dart';
import 'package:cineflow_app/controllers/detail_controller.dart';
import 'package:cineflow_app/controllers/tv_show_detail_controller.dart';
import 'package:cineflow_app/screens/detail_screen.dart';
import 'package:cineflow_app/screens/TvShowDetailScreen.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/tv_show_model.dart';
import 'package:cineflow_app/widgets/empty_state_widget.dart';
import 'package:cineflow_app/utils/haptic_feedback_helper.dart';
// import removed for actor images

class FavoritesScreen extends GetView<FavoriteController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_favorites'.tr),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.switchTab(0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: controller.currentTab.value == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              'Filmler',
                              style: TextStyle(
                                color: controller.currentTab.value == 0
                                    ? AppColors.onPrimary
                                    : AppColors.onCard,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.switchTab(1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: controller.currentTab.value == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              'TV Dizileri',
                              style: TextStyle(
                                color: controller.currentTab.value == 1
                                    ? AppColors.onPrimary
                                    : AppColors.onCard,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.currentTab.value == 0) {
                  return _buildMovieFavoritesList();
                } else if (controller.currentTab.value == 1) {
                  return _buildTvShowFavoritesList();
                } else {
                  return _buildMovieFavoritesList();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieFavoritesList() {
    final movies = controller.favoriteMovies;
    if (movies.isEmpty) {
      return _buildEmptyListPlaceholder('Favori Film', Icons.movie);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshFavorites,
      child: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _buildFavoriteMovieItem(movie);
        },
      ),
    );
  }

  Widget _buildTvShowFavoritesList() {
    final tvShows = controller.favoriteTvShows;
    if (tvShows.isEmpty) {
      return _buildEmptyListPlaceholder('Favori TV Dizisi', Icons.tv);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshFavorites,
      child: ListView.builder(
        itemCount: tvShows.length,
        itemBuilder: (context, index) {
          final tvShow = tvShows[index];
          return _buildFavoriteTvShowItem(tvShow);
        },
      ),
    );
  }

  // Actor favorites removed per request

  Widget _buildFavoriteMovieItem(Movie movie) {
    final posterUrl = movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
        : null;

    return Dismissible(
      key: Key(movie.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        HapticFeedbackHelper.mediumImpact();
        controller.removeFavoriteMovie(movie.id);
      },
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => const DetailScreen(),
            arguments: movie,
            binding: BindingsBuilder(() {
              Get.lazyPut(() => DetailController());
            }),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
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
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: posterUrl != null
                    ? Image.network(
                        posterUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderPoster(80, 120),
                      )
                    : _buildPlaceholderPoster(80, 120),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: AppColors.onCard,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.releaseDate ?? 'Tarih bilgisi yok',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
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
      ),
    );
  }

  Widget _buildFavoriteTvShowItem(TvShow tvShow) {
    final posterUrl = tvShow.posterPath != null
        ? 'https://image.tmdb.org/t/p/w200${tvShow.posterPath}'
        : null;

    return Dismissible(
      key: Key(tvShow.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        HapticFeedbackHelper.mediumImpact();
        controller.removeFavoriteTvShow(tvShow.id);
      },
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => const TvShowDetailScreen(),
            arguments: tvShow,
            binding: BindingsBuilder(() {
              Get.lazyPut(() => TvShowDetailController());
            }),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
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
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: posterUrl != null
                    ? Image.network(
                        posterUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderPoster(80, 120),
                      )
                    : _buildPlaceholderPoster(80, 120),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tvShow.name,
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: AppColors.onCard,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tvShow.firstAirDate ?? 'Tarih bilgisi yok',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tvShow.overview,
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
      ),
    );
  }

  Widget _buildEmptyListPlaceholder(String itemType, IconData icon) {
    return EmptyStateWidget(
      title: '$itemType Boş',
      subtitle: 'Favorilere ${itemType.toLowerCase()} ekleyin.',
      icon: icon,
    );
  }

  Widget _buildPlaceholderPoster(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: AppColors.cardGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}
