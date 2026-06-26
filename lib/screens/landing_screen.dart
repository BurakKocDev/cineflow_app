import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/screens/home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _animationController.forward();

    await Future.delayed(const Duration(seconds: 4));
    _navigateToHome();
  }

  void _navigateToHome() {
    Get.off(() => const HomeScreen());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and App Name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.movie,
                              size: 60,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'CineFlow',
                            style: Get.textTheme.displayLarge?.copyWith(
                              color: AppColors.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Film ve TV Dizi Keşif Uygulaması',
                            style: Get.textTheme.titleLarge?.copyWith(
                              color: AppColors.grey400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Animated Features
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            icon: Icons.search,
                            title: 'Film ve Dizi Ara',
                            subtitle:
                                'Milyonlarca içerik arasından seçim yapın',
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureItem(
                            icon: Icons.favorite,
                            title: 'Favorilerinizi Kaydedin',
                            subtitle:
                                'Beğendiğiniz içerikleri favorilere ekleyin',
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureItem(
                            icon: Icons.notifications,
                            title: 'Bildirimler Alın',
                            subtitle:
                                'Yeni çıkan filmler hakkında bilgilendirilin',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Skip Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: TextButton(
                  onPressed: _navigateToHome,
                  child: Text(
                    'Atla',
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: AppColors.onCard,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
