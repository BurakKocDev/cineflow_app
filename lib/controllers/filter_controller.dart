import 'package:cineflow_app/screens/filter_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FilterController extends GetxController {
  late final MovieFilters initialFilters;

  var sortOption = SortOption.none.obs;
  var yearRange = const RangeValues(1900, 2025).obs;
  var ratingRange = const RangeValues(0, 10).obs;

  MovieFilters get appliedFilters => MovieFilters(
    sortOption: sortOption.value,
    yearRange: yearRange.value,
    ratingRange: ratingRange.value,
  );

  @override
  void onInit() {
    super.onInit();

    initialFilters =
        Get.arguments as MovieFilters? ??
        MovieFilters(
          sortOption: SortOption.none,

          yearRange: RangeValues(1900, DateTime.now().year.toDouble() + 5),
          ratingRange: const RangeValues(0, 10),
        );

    sortOption.value = initialFilters.sortOption;
    yearRange.value = initialFilters.yearRange;
    ratingRange.value = initialFilters.ratingRange;
  }

  void updateSortOption(SortOption? newOption) {
    if (newOption != null) {
      sortOption.value = newOption;
    }
  }

  void updateYearRange(RangeValues newRange) {
    yearRange.value = newRange;
  }

  void updateRatingRange(RangeValues newRange) {
    ratingRange.value = newRange;
  }

  void resetFilters() {
    sortOption.value = SortOption.none;
    yearRange.value = RangeValues(1900, DateTime.now().year.toDouble() + 5);
    ratingRange.value = const RangeValues(0, 10);
    Get.snackbar(
      'filters_reset'.tr,
      'filters_reset_desc'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueGrey.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
