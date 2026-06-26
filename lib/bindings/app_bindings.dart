// lib/app_bindings.dart
import 'package:get/get.dart';
import 'package:cineflow_app/services/api_service.dart';
import 'package:cineflow_app/services/database_service.dart';
import 'package:cineflow_app/services/gemini_service.dart';
import 'package:cineflow_app/controllers/home_controller.dart';
import 'package:cineflow_app/controllers/favorite_controller.dart';
import 'package:cineflow_app/controllers/filter_controller.dart';
import 'package:cineflow_app/controllers/TvShowController.dart'; // Bu satırı ekleyin
import 'package:cineflow_app/controllers/detail_controller.dart'; // Bu satırı ekleyin
import 'package:cineflow_app/controllers/people_controller.dart';
import 'package:cineflow_app/controllers/assistant_controller.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Servisleri global olarak erişilebilir yap
    Get.put(ApiService());
    Get.put(DatabaseService());
    // Gemini servisi - API key eklendiğinde otomatik aktif olacak
    Get.put(GeminiService());

    // Controller'ları lazyPut ile gerektiğinde oluştur
    // Bu, uygulama başlangıcını daha hızlı yapar
    Get.lazyPut(() => HomeController());
    Get.put(FavoriteController(), permanent: true);
    Get.lazyPut(() => FilterController());
    Get.lazyPut(() => TvShowController()); // Bunu ekleyin
    Get.lazyPut(() => DetailController()); // Bunu ekleyin
    Get.lazyPut(() => PeopleController());
    Get.lazyPut(() => AssistantController());
  }
}
