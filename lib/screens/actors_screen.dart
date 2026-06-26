import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/controllers/people_controller.dart';
import 'package:cineflow_app/models/person_model.dart';
import 'package:cineflow_app/screens/actor_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineflow_app/widgets/shimmer_actor_card.dart';
import 'package:cineflow_app/widgets/turkish_text_field.dart';
// Removed favorite actor button integration

class ActorsScreen extends GetView<PeopleController> {
  const ActorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchFocusNode = FocusNode();
    
    return GestureDetector(
      onTap: () => searchFocusNode.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('actors'.tr),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          actions: [
            Obx(() {
              final mode = controller.sortMode.value;
              String label;
              if (mode == ActorSortMode.nameAZ) {
                label = 'A-Z';
              } else if (mode == ActorSortMode.nameZA) {
                label = 'Z-A';
              } else {
                label = 'TMDB';
              }
              return PopupMenuButton<ActorSortMode>(
                onSelected: controller.setSortMode,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ActorSortMode.popularity,
                    child: Text('TMDB Popülerlik'),
                  ),
                  const PopupMenuItem(
                    value: ActorSortMode.nameAZ,
                    child: Text('İsim A-Z'),
                  ),
                  const PopupMenuItem(
                    value: ActorSortMode.nameZA,
                    child: Text('İsim Z-A'),
                  ),
                ],
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilterBar(searchFocusNode),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.people.isEmpty) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.66,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const ShimmerActorCard(),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => controller.loadPopularPeople(page: 1),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 300) {
                        if (!controller.isLoading.value) {
                          controller.loadMore();
                        }
                      }
                      return false;
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: controller.people.length,
                      itemBuilder: (context, index) {
                        final person = controller.people[index];
                        return _buildPersonCardWithAnimation(person, index);
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar(FocusNode searchFocusNode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TurkishTextField(
              focusNode: searchFocusNode,
              decoration: InputDecoration(
                hintText: 'search_actors'.tr,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: controller.setQuery,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                if (value.isEmpty) {
                  controller.setQuery('');
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => controller.query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.setQuery(''),
                )
              : const SizedBox.shrink())
        ],
      ),
    );
  }

  Widget _buildPersonCard(Person person, int index) {
    final photoUrl = person.profilePath != null
        ? 'https://image.tmdb.org/t/p/w300${person.profilePath}'
        : null;
    final heroTag = 'actor_${person.id}_$index';

    return InkWell(
        onTap: () {
          Get.to(
            () => const ActorDetailScreen(),
            arguments: person,
            transition: Transition.cupertino,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
          child: Column(
            children: [
              // Profile Photo with Hero
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        photoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: photoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _placeholder(),
                                errorWidget: (context, url, error) => _placeholder(),
                                fadeInDuration: const Duration(milliseconds: 250),
                              )
                            : _placeholder(),
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
                        // Popularity badge
                        if (person.popularity != null && person.popularity! > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
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
                                    Icons.trending_up,
                                    color: AppColors.onPrimary,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    person.popularity!.toStringAsFixed(0),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: AppColors.onCard,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getDepartmentIcon(person.knownForDepartment),
                          size: 12,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            person.knownForDepartment ?? 'Oyuncu',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: AppColors.grey400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
  
  Widget _buildPersonCardWithAnimation(Person person, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 30)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _buildPersonCard(person, index),
    );
  }

  IconData _getDepartmentIcon(String? department) {
    switch (department?.toLowerCase()) {
      case 'acting':
        return Icons.mic;
      case 'directing':
        return Icons.videocam;
      case 'writing':
        return Icons.create;
      case 'producing':
        return Icons.production_quantity_limits;
      default:
        return Icons.person;
    }
  }

  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cardGradient),
      child: const Center(
        child: Icon(Icons.person, color: AppColors.grey400, size: 40),
      ),
    );
  }
}

// Favorite button removed per request


