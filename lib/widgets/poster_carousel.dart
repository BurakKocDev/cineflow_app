import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineflow_app/constants/app_colors.dart';

class PosterCarousel extends StatelessWidget {
  final List<dynamic> items;
  final Function(dynamic) onTap;
  final String title;
  final double height;

  const PosterCarousel({
    super.key,
    required this.items,
    required this.onTap,
    required this.title,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: Get.textTheme.headlineSmall?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final posterPath = item.posterPath ?? item.backdropPath;
              
              return _PosterCard(
                posterPath: posterPath,
                title: item.title ?? item.name ?? 'Unknown',
                rating: item.voteAverage?.toDouble() ?? 0.0,
                onTap: () => onTap(item),
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PosterCard extends StatefulWidget {
  final String? posterPath;
  final String title;
  final double rating;
  final VoidCallback onTap;
  final int index;

  const _PosterCard({
    required this.posterPath,
    required this.title,
    required this.rating,
    required this.onTap,
    required this.index,
  });

  @override
  State<_PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<_PosterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (widget.index * 50)),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Poster Image
                      widget.posterPath != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  'https://image.tmdb.org/t/p/w500${widget.posterPath}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.cardGradient,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                      // Gradient Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Rating Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.onPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Title
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.cardGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 50,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}

