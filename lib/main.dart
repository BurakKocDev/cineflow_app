// lib/main.dart
import 'package:cineflow_app/bindings/app_bindings.dart';
import 'package:cineflow_app/screens/landing_screen.dart';
import 'package:cineflow_app/constants/app_themes.dart';
import 'package:cineflow_app/localization/app_localizations.dart';
import 'package:cineflow_app/localization/locale_service.dart';
import 'package:cineflow_app/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // `.env` yoksa uygulama açılır; API anahtarları boş kalır.
  }

  await NotificationService().initialize();

  final savedLocale = await LocaleService.loadSavedLocale();

  runApp(MyMainApp(initialLocale: savedLocale));
}

// Uygulamayı Getx ile saran bir widget oluşturalım
class MyMainApp extends StatelessWidget {
  const MyMainApp({super.key, this.initialLocale});

  final Locale? initialLocale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBindings(), // Burası en önemli kısım
      debugShowCheckedModeBanner: false,
      title: 'CineFlow',
      theme: AppThemes.darkTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.dark,
      // Sayfalar arası modern ve ince bir geçiş animasyonu
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 320),
      locale: initialLocale ?? AppLocalizations.turkish,
      fallbackLocale: AppLocalizations.turkish,
      translations: AppLocalizations(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LandingScreen(), // Başlangıç ekranı
    );
  }
}
