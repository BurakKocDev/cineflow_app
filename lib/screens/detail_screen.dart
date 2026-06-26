import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cineflow_app/controllers/detail_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineflow_app/constants/app_colors.dart';

class DetailScreen extends GetView<DetailController> {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movie = controller.movie;
    final posterUrl = movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
        : null;

    return Obx(() {
      if (controller.ytController != null) {
        return YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: controller.ytController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.amber,
            progressColors: const ProgressBarColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
          ),
          builder: (context, player) {
            return Scaffold(
              appBar: controller.ytController!.value.isFullScreen
                  ? null
                  : AppBar(
                      title: Text(movie.title),
                      actions: [
                        Obx(
                          () => IconButton(
                            icon: Icon(
                              controller.isFavorite.value
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: controller.isFavorite.value
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              controller.toggleFavorite();
                            },
                          ),
                        ),
                      ],
                    ),
              body: SingleChildScrollView(
                padding: controller.ytController!.value.isFullScreen
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Film Afişi with Hero Animation
                    if (!controller.ytController!.value.isFullScreen)
                      Center(
                        child: Hero(
                          tag: 'movie_list_${movie.id}_0', // Fallback tag, will need dynamic from navigation
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: posterUrl != null
                                ? Image.network(
                                    posterUrl,
                                    width: 200,
                                    height: 300,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          width: 200,
                                          height: 300,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF16213E),
                                                Color(0xFF1E293B),
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  )
                                : Container(
                                    width: 200,
                                    height: 300,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF16213E),
                                          Color(0xFF1E293B),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (!controller.ytController!.value.isFullScreen)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 30),
                          Text(
                            movie.overview.isNotEmpty
                                ? movie.overview
                                : 'Açıklama mevcut değil.',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Fragman Oynatıcı
                    if (controller.isLoadingTrailers.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (controller.trailers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            'Bu film için fragman bulunamadı.',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!controller.ytController!.value.isFullScreen)
                            const Text(
                              'Fragman:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (!controller.ytController!.value.isFullScreen)
                            const SizedBox(height: 10),
                          player,
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        final backdropUrl = movie.backdropPath != null
            ? 'https://image.tmdb.org/t/p/w1280${movie.backdropPath}'
            : null;
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Parallax AppBar with backdrop
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                  centerTitle: false,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (backdropUrl != null)
                        CachedNetworkImage(
                          imageUrl: backdropUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.secondary,
                              ],
                            ),
                          ),
                        ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        controller.isFavorite.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: controller.isFavorite.value
                            ? Colors.red
                            : Colors.white,
                      ),
                      onPressed: () {
                        controller.toggleFavorite();
                      },
                    ),
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      Center(
                        child: Hero(
                          tag: 'movie_list_${movie.id}_0',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: posterUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: posterUrl,
                                    width: 200,
                                    height: 300,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 200,
                                      height: 300,
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          width: 200,
                                          height: 300,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                AppColors.secondary,
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  )
                                : Container(
                                    width: 200,
                                    height: 300,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.secondary,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        movie.title,
                        style: Get.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.voteAverage.toStringAsFixed(1)}/10',
                            style: Get.textTheme.bodyLarge?.copyWith(
                              color: AppColors.onBackground,
                            ),
                          ),
                          if (movie.releaseDate != null) ...[
                            const SizedBox(width: 16),
                            Text(
                              movie.releaseDate!,
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: AppColors.grey400,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      // Overview
                      Text(
                        'Özet',
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        movie.overview.isNotEmpty
                            ? movie.overview
                            : 'Açıklama mevcut değil.',
                        style: Get.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onBackground,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Trailers
                      if (controller.isLoadingTrailers.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (controller.trailers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'Bu film için fragman bulunamadı.',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}
