import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/models/person_model.dart';
import 'package:cineflow_app/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineflow_app/screens/detail_screen.dart';
import 'package:cineflow_app/screens/TvShowDetailScreen.dart';
import 'package:cineflow_app/controllers/detail_controller.dart';
import 'package:cineflow_app/controllers/tv_show_detail_controller.dart';
import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/tv_show_model.dart';

class ActorDetailScreen extends StatefulWidget {
  const ActorDetailScreen({super.key});

  @override
  State<ActorDetailScreen> createState() => _ActorDetailScreenState();
}

class _ActorDetailScreenState extends State<ActorDetailScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  late final Person person;
  bool isLoading = true;
  Map<String, List<dynamic>> credits = const {'cast': [], 'crew': []};

  @override
  void initState() {
    super.initState();
    person = Get.arguments as Person;
    _load();
  }

  void _openCredit(Map<String, dynamic> item) {
    final mediaType = item['media_type'] as String?;
    if (mediaType == 'movie') {
      // Navigate to movie detail
      final movie = Movie(
        id: item['id'] as int,
        title: (item['title'] ?? '') as String,
        overview: (item['overview'] ?? '') as String,
        posterPath: item['poster_path'] as String?,
        backdropPath: null,
        releaseDate: item['release_date'] as String?,
        voteAverage: ((item['vote_average'] ?? 0) as num).toDouble(),
        genreIds: (item['genre_ids'] as List<dynamic>?)?.cast<int>(),
        genres: null,
      );
      Get.to(() => const DetailScreen(), arguments: movie, binding: BindingsBuilder((){
        Get.lazyPut(() => DetailController());
      }));
    } else if (mediaType == 'tv') {
      final tv = TvShow(
        id: item['id'] as int,
        name: (item['name'] ?? '') as String,
        overview: (item['overview'] ?? '') as String,
        posterPath: item['poster_path'] as String?,
        firstAirDate: item['first_air_date'] as String?,
        voteAverage: ((item['vote_average'] ?? 0) as num).toDouble(),
      );
      Get.to(() => const TvShowDetailScreen(), arguments: tv, binding: BindingsBuilder((){
        Get.lazyPut(() => TvShowDetailController());
      }));
    }
  }

  Widget _posterPlaceholder() {
    return const Center(
      child: Icon(Icons.image, color: AppColors.grey400, size: 32),
    );
  }

  // Removed short info chip helper

  Future<void> _load() async {
    try {
      final c = await _apiService.getPersonCombinedCredits(person.id);
      setState(() {
        credits = c;
      });
    } catch (_) {
      Get.snackbar('Error', 'Aktör bilgileri alınamadı', snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = person.profilePath != null
        ? 'https://image.tmdb.org/t/p/w500${person.profilePath}'
        : null;
    final heroTag = 'actor_${person.id}_0';

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: const [],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    decoration: const BoxDecoration(gradient: AppColors.cardGradient),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            width: 120,
                            height: 180,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: photoUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: photoUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (c, u) => Container(color: AppColors.card),
                                      errorWidget: (c, u, e) => Container(color: AppColors.card),
                                      fadeInDuration: const Duration(milliseconds: 250),
                                    )
                                  : Container(
                                      color: AppColors.card,
                                      child: const Icon(Icons.person, size: 48, color: AppColors.grey400),
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24, right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person.name,
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                    color: AppColors.onBackground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  person.knownForDepartment ?? 'Oyuncu',
                                  style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.grey400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Kısa Bilgiler kaldırıldı
                  // Özgeçmiş
                  if ((person.biography ?? '').isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Biyografi', style: Get.textTheme.titleLarge?.copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(person.biography!, style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.onBackground)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Film/Dizi Listesi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Oynadığı Yapımlar', style: Get.textTheme.titleLarge?.copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  _buildCreditsTabs(),
                ],
              ),
            ),
    );
  }

  Widget _buildCreditsTabs() {
    final cast = credits['cast'] ?? [];
    final movies = cast.where((e) => (e as Map<String, dynamic>)['media_type'] == 'movie').toList();
    final tv = cast.where((e) => (e as Map<String, dynamic>)['media_type'] == 'tv').toList();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.onBackground,
            tabs: [Tab(text: 'Filmler'), Tab(text: 'Diziler')],
          ),
          SizedBox(
            height: 260,
            child: TabBarView(
              children: [
                _buildCreditsListCore(movies),
                _buildCreditsListCore(tv),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsListCore(List<dynamic> items) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index] as Map<String, dynamic>;
          final title = (item['title'] ?? item['name'] ?? 'Unknown') as String;
          final poster = item['poster_path'] as String?;
          final posterUrl = poster != null ? 'https://image.tmdb.org/t/p/w300$poster' : null;
          return GestureDetector(
            onTap: () => _openCredit(item),
            child: Container(
            width: 140,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 2/3,
                    child: posterUrl != null
                        ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                              placeholder: (c, u) => _posterPlaceholder(),
                              errorWidget: (c, u, e) => _posterPlaceholder(),
                            fadeInDuration: const Duration(milliseconds: 250),
                          )
                        : Container(
                            color: AppColors.card,
                            child: _posterPlaceholder(),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.onCard, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }

  
}


