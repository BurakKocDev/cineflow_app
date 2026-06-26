// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/controllers/home_controller.dart';
import 'package:cineflow_app/screens/detail_screen.dart';
import 'package:cineflow_app/screens/favorites_screen.dart';
import 'package:cineflow_app/screens/filter_screen.dart' as filter;
import 'package:cineflow_app/screens/profile_screen.dart';
import 'package:cineflow_app/screens/TvShowsScreen.dart';
import 'package:cineflow_app/controllers/detail_controller.dart';
import 'package:cineflow_app/controllers/filter_controller.dart';
import 'package:cineflow_app/controllers/favorite_controller.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineflow_app/screens/actors_screen.dart';
import 'package:cineflow_app/controllers/people_controller.dart';
import 'package:cineflow_app/screens/assistant_screen.dart';
import 'package:cineflow_app/controllers/assistant_controller.dart';
import 'package:cineflow_app/widgets/shimmer_loading.dart';
import 'package:cineflow_app/widgets/poster_carousel.dart';
import 'package:cineflow_app/widgets/turkish_text_field.dart';
import 'package:cineflow_app/widgets/view_toggle_button.dart';
import 'package:cineflow_app/widgets/animated_rating_stars.dart';
import 'package:cineflow_app/widgets/animated_icon_button.dart';
import 'package:cineflow_app/widgets/empty_state_widget.dart';
import 'package:cineflow_app/widgets/custom_refresh_indicator.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          _buildMoviesPage(),
          _buildTvShowsPage(),
          _buildFavoritesPage(),
          _buildActorsPage(),
          _buildAssistantPage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMoviesPage() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(Get.context!).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('movies'.tr),
          actions: [
            AnimatedIconButton(
              icon: Icons.favorite,
              onPressed: () {
                Get.to(
                  () => const FavoritesScreen(),
                  binding: BindingsBuilder(() {
                    Get.put(FavoriteController());
                  }),
                );
              },
            ),
            AnimatedIconButton(
              icon: Icons.filter_list,
              onPressed: () async {
                controller.searchFocusNode.unfocus();

                final filter.MovieFilters? resultFilters = await Get.to<filter.MovieFilters>(
                  () => const filter.FilterScreen(),
                  arguments: controller.currentFilters.value,
                  binding: BindingsBuilder(() {
                    Get.put(FilterController());
                  }),
                );

                if (resultFilters != null) {
                  controller.applyFilters(resultFilters);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildMoviesContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTvShowsPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('tv_shows'.tr),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: const TvShowsScreen(),
    );
  }

  Widget _buildFavoritesPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr),
      ),
      body: const FavoritesScreen(),
    );
  }

  Widget _buildActorsPage() {
    return GetBuilder<PeopleController>(
      init: Get.find<PeopleController>(),
      builder: (_) => const ActorsScreen(),
    );
  }

  Widget _buildAssistantPage() {
    return GetBuilder<AssistantController>(
      init: Get.find<AssistantController>(),
      builder: (_) => const AssistantScreen(),
    );
  }

  Widget _buildProfilePage() {
    return const ProfileScreen();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          hintText: 'search_movies'.tr,
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
                    onPressed: () => controller.clearSearch(),
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
        onChanged: (query) => controller.search(query),
        onSubmitted: (query) {
          controller.search(query);
          controller.searchFocusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildMoviesContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.movies.isEmpty) {
        return _buildShimmerLoading();
      } else if (controller.movies.isEmpty && !controller.isLoading.value) {
        return _buildEmptyState();
      } else {
        // Show trending carousel at top if we have movies
        if (controller.movies.isNotEmpty && !controller.isLoading.value) {
          return Column(
            children: [
              // Trending Carousel
              PosterCarousel(
                items: controller.movies.take(10).toList(),
                onTap: (movie) {
                  Get.to(
                    () => const DetailScreen(),
                    arguments: movie,
                    binding: BindingsBuilder(() {
                      Get.put(DetailController());
                    }),
                    transition: Transition.cupertino,
                  );
                },
                title: 'Trending Now',
              ),
              const SizedBox(height: 16),
              // View Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'movies'.tr,
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ViewToggleButton(
                      currentMode: controller.isGridView.value
                          ? ViewMode.grid
                          : ViewMode.list,
                      onModeChanged: (mode) {
                        controller.isGridView.value = mode == ViewMode.grid;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Movies List/Grid
              Expanded(
                child: controller.isGridView.value
                    ? _buildMoviesGrid()
                    : _buildMoviesList(),
              ),
            ],
          );
        }
        return _buildMoviesList();
      }
    });
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const ShimmerMovieCard(),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: controller.currentQuery.isNotEmpty 
          ? 'Sonuç bulunamadı'
          : 'Film bulunamadı',
      subtitle: controller.currentQuery.isNotEmpty
          ? 'Arama teriminizi değiştirmeyi deneyin'
          : 'Popüler filmler yükleniyor...',
      icon: Icons.movie_outlined,
    );
  }

  Widget _buildMoviesList() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        await controller.refreshMovies();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 300) {
            controller.loadMoreMovies();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.movies.length,
          itemBuilder: (context, index) {
            final movie = controller.movies[index];
            return _buildMovieCard(movie, index);
          },
        ),
      ),
    );
  }

  Widget _buildMoviesGrid() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        await controller.refreshMovies();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 300) {
            controller.loadMoreMovies();
          }
          return false;
        },
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.movies.length,
          itemBuilder: (context, index) {
            final movie = controller.movies[index];
            return _buildMovieGridCard(movie, index);
          },
        ),
      ),
    );
  }

  Widget _buildMovieCard(dynamic movie, int index) {
    final heroTag = 'movie_list_${movie.id}_$index';
    final isFavorite = controller.favoriteMovieIds.contains(movie.id);
    
    final animIndex = index.clamp(0, 8); // animasyon süresini sınırlı tut

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 220 + (animIndex * 20)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key('movie_${movie.id}_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isFavorite ? AppColors.error : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
            size: 32,
          ),
        ),
        onDismissed: (direction) {
          controller.toggleFavoriteFromList(movie);
        },
        child: Container(
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
              () => const DetailScreen(),
              arguments: movie,
              binding: BindingsBuilder(() {
                Get.put(DetailController());
              }),
              transition: Transition.cupertino,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster with Hero
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.cardGradient,
                          ),
                          child: movie.posterPath != null
                              ? CachedNetworkImage(
                                  imageUrl:
                                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _buildPlaceholderPoster(),
                                  errorWidget: (context, url, error) =>
                                      _buildPlaceholderPoster(),
                                  fadeInDuration:
                                      const Duration(milliseconds: 250),
                                )
                              : _buildPlaceholderPoster(),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Movie Info
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
                          movie.title ?? movie.name ?? 'Unknown',
                          style: Get.textTheme.titleLarge?.copyWith(
                            color: AppColors.onCard,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Animated Rating Stars
                      AnimatedRatingStars(
                        rating: movie.voteAverage?.toDouble() ?? 0.0,
                        maxRating: 10.0,
                        starSize: 16,
                        showRatingText: true,
                      ),
                      const SizedBox(width: 8),
                      Obx(() => IconButton(
                        icon: Icon(
                          controller.favoriteMovieIds.contains(movie.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: controller.favoriteMovieIds.contains(movie.id)
                              ? AppColors.secondary
                              : AppColors.grey400,
                        ),
                        onPressed: () => controller.toggleFavoriteFromList(movie),
                      )),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Release Date
                  Text(
                    _formatDate(movie.releaseDate ?? movie.firstAirDate),
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey400,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Overview
                  Text(
                    movie.overview ?? 'No overview available.',
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
      ),
    );
  }

  Widget _buildMovieGridCard(dynamic movie, int index) {
    final heroTag = 'movie_grid_${movie.id}_$index';
    
    final animIndex = index.clamp(0, 8);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 260 + (animIndex * 25)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform(
          transform: Matrix4.identity()
            ..scale(0.9 + (value * 0.1))
            ..translate(0.0, 18.0 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          Get.to(
            () => const DetailScreen(),
            arguments: movie,
            binding: BindingsBuilder(() {
              Get.put(DetailController());
            }),
            transition: Transition.cupertino,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.cardGradient,
                          ),
                          child: movie.posterPath != null
                              ? CachedNetworkImage(
                                  imageUrl:
                                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _buildPlaceholderPoster(),
                                  errorWidget: (context, url, error) =>
                                      _buildPlaceholderPoster(),
                                )
                              : _buildPlaceholderPoster(),
                        ),
                        // Rating overlay
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.onPrimary,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${(movie.voteAverage ?? 0).toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title ?? movie.name ?? 'Unknown',
                      style: Get.textTheme.titleSmall?.copyWith(
                        color: AppColors.onCard,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(movie.releaseDate ?? movie.firstAirDate),
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey400,
                      ),
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

  Widget _buildPlaceholderPoster() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.cardGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 60,
          color: AppColors.grey400,
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Tarih bilgisi yok';
    if (raw.length >= 10) return raw; // YYYY-MM-DD
    return raw;
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.movie),
            label: 'movies'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.tv),
            label: 'tv_shows'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: 'favorites'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: 'actors'.tr,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Asistan',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr,
          ),
        ],
      )),
    );
  }
}
