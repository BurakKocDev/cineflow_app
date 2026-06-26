import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/controllers/tv_show_detail_controller.dart';
import 'package:cineflow_app/screens/tv_show_trailer_screen.dart';

class TvShowDetailScreen extends GetView<TvShowDetailController> {
  const TvShowDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final tvShow = controller.tvShow.value;
        if (tvShow == null) {
          return Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(tvShow),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(tvShow),
                      const SizedBox(height: 24),
                      _buildOverview(tvShow),
                      const SizedBox(height: 24),
                      _buildDetails(tvShow),
                      const SizedBox(height: 24),
                      _buildActions(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSliverAppBar(dynamic tvShow) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            tvShow.posterPath != null
                ? Image.network(
                    'https://image.tmdb.org/t/p/w500${tvShow.posterPath}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderBackground(),
                  )
                : _buildPlaceholderBackground(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    // ignore: deprecated_member_use
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: _buildIconButton(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() => IconButton(
              icon: _buildIconButton(
                controller.isFavorite.value
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: controller.isFavorite.value
                    ? AppColors.secondary
                    : AppColors.onSurface,
              ),
              onPressed: () => controller.toggleFavorite(),
            )),
      ],
    );
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.cardGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.tv,
          size: 80,
          color: AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic tvShow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tvShow.name ?? 'Unknown TV Show',
          style: Get.textTheme.displaySmall?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRatingChip(tvShow.voteAverage ?? 0),
            const SizedBox(width: 16),
            Text(
              tvShow.firstAirDate?.substring(0, 4) ?? 'Unknown',
              style: Get.textTheme.titleLarge?.copyWith(
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.onPrimary, size: 20),
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(dynamic tvShow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'overview'.tr,
          style: Get.textTheme.headlineMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          tvShow.overview ?? 'No overview available.',
          style: Get.textTheme.bodyLarge?.copyWith(
            color: AppColors.onBackground,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(dynamic tvShow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Get.textTheme.headlineMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow('Status', tvShow.status ?? 'Unknown'),
        _buildDetailRow('First Air Date', tvShow.firstAirDate ?? 'Unknown'),
        _buildDetailRow('Last Air Date', tvShow.lastAirDate ?? 'Unknown'),
        _buildDetailRow('Number of Seasons', '${tvShow.numberOfSeasons ?? 0}'),
        _buildDetailRow(
            'Number of Episodes', '${tvShow.numberOfEpisodes ?? 0}'),
        _buildDetailRow(
            'Original Language', tvShow.originalLanguage ?? 'Unknown'),
        _buildDetailRow('Type', tvShow.type ?? 'Unknown'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Obx(() {
      final hasTrailer = !controller.isLoadingTrailers.value &&
          controller.trailers.isNotEmpty &&
          controller.ytController != null;

      if (!hasTrailer) {
        // Trailer yoksa butonu hiç gösterme
        return const SizedBox.shrink();
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Get.to(() => const TvShowTrailerScreen());
          },
          icon: const Icon(Icons.play_circle),
          label: const Text('Watch Trailer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildIconButton(IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: color ?? AppColors.onSurface),
    );
  }
}
