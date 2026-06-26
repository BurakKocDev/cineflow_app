import 'package:cineflow_app/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SortOption { none, newest, oldest, highestRated, lowestRated }

class MovieFilters {
  final SortOption sortOption;
  final RangeValues yearRange;
  final RangeValues ratingRange;

  MovieFilters({
    required this.sortOption,
    required this.yearRange,
    required this.ratingRange,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieFilters &&
          runtimeType == other.runtimeType &&
          sortOption == other.sortOption &&
          yearRange == other.yearRange &&
          ratingRange == other.ratingRange;

  @override
  int get hashCode =>
      sortOption.hashCode ^ yearRange.hashCode ^ ratingRange.hashCode;
}

class FilterScreen extends GetView<FilterController> {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrele'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.resetFilters();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sıralama Seçenekleri',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: SortOption.values.map((option) {
                  return RadioListTile<SortOption>(
                    title: Text(_getSortOptionText(option)),
                    value: option,
                    groupValue: controller.sortOption.value,
                    onChanged: controller.updateSortOption,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(
                () => Text(
                  'Yıl Aralığı: ${controller.yearRange.value.start.round()} - ${controller.yearRange.value.end.round()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Obx(
              () => RangeSlider(
                values: controller.yearRange.value,
                min: 1900,
                max: DateTime.now().year.toDouble() + 5,
                divisions: (DateTime.now().year + 5) - 1900,
                labels: RangeLabels(
                  controller.yearRange.value.start.round().toString(),
                  controller.yearRange.value.end.round().toString(),
                ),
                onChanged: controller.updateYearRange,
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(
                () => Text(
                  'Puan Aralığı: ${controller.ratingRange.value.start.toStringAsFixed(1)} - ${controller.ratingRange.value.end.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Obx(
              () => RangeSlider(
                values: controller.ratingRange.value,
                min: 0,
                max: 10,
                divisions: 20,
                labels: RangeLabels(
                  controller.ratingRange.value.start.toStringAsFixed(1),
                  controller.ratingRange.value.end.toStringAsFixed(1),
                ),
                onChanged: controller.updateRatingRange,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Filtreleri Uygula',
            style: TextStyle(fontSize: 18),
          ),
          onPressed: () {
            Get.back(result: controller.appliedFilters);
          },
        ),
      ),
    );
  }

  String _getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.none:
        return 'Popülerliğe Göre';
      case SortOption.newest:
        return 'En Yeni Filmler';
      case SortOption.oldest:
        return 'En Eski Filmler';
      case SortOption.highestRated:
        return 'En Yüksek Puanlı';
      case SortOption.lowestRated:
        return 'En Düşük Puanlı';
    }
  }
}
