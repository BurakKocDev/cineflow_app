import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:get/get.dart';

/// İyileştirilmiş boş durum widget'ı (Lottie animasyonları ile)
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? lottieAsset;
  final Widget? actionButton;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.lottieAsset,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animasyonu varsa onu göster, yoksa icon göster
            if (lottieAsset != null)
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  lottieAsset!,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              )
            else if (icon != null)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 60,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
            // Title
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - value)),
                    child: Text(
                      title,
                      style: Get.textTheme.headlineMedium?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      child: Text(
                        subtitle!,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

