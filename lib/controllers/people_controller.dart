import 'package:get/get.dart';
import 'package:cineflow_app/services/api_service.dart';
import 'package:cineflow_app/models/person_model.dart';
import 'package:cineflow_app/utils/turkish_text.dart';

enum ActorSortMode { popularity, nameAZ, nameZA }

class PeopleController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<Person> people = <Person>[] .obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxString query = ''.obs;
  final Rx<ActorSortMode> sortMode = ActorSortMode.popularity.obs;

  @override
  void onInit() {
    super.onInit();
    loadPopularPeople();
  }

  Future<void> loadPopularPeople({int page = 1}) async {
    isLoading.value = true;
    try {
      List<Person> result;
      if (query.isNotEmpty) {
        result = await _apiService.searchPeople(query.value, page: page);
      } else {
        result = await _apiService.getPopularPeople(page: page);
      }
      if (page == 1) {
        people.assignAll(result);
      } else {
        people.addAll(result);
      }
      _applySort();
      currentPage.value = page;
    } catch (e) {
      Get.snackbar('Error', 'Aktörler alınamadı: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value) return;
    await loadPopularPeople(page: currentPage.value + 1);
  }

  void setQuery(String q) {
    query.value = q.trim();
    loadPopularPeople(page: 1);
  }

  void setSortMode(ActorSortMode mode) {
    sortMode.value = mode;
    _applySort();
  }

  void _applySort() {
    final list = [...people];
    switch (sortMode.value) {
      case ActorSortMode.popularity:
        list.sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));
        break;
      case ActorSortMode.nameAZ:
        list.sort((a, b) => a.name.compareTurkish(b.name));
        break;
      case ActorSortMode.nameZA:
        list.sort((a, b) => b.name.compareTurkish(a.name));
        break;
    }
    people.assignAll(list);
  }

}


