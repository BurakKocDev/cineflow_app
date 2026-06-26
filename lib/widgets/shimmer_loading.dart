import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cineflow_app/constants/app_colors.dart';

class ShimmerMovieCard extends StatelessWidget {
  const ShimmerMovieCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.grey800,
            highlightColor: AppColors.grey700,
            period: const Duration(milliseconds: 1200),
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                Shimmer.fromColors(
                  baseColor: AppColors.grey800,
                  highlightColor: AppColors.grey700,
                  period: const Duration(milliseconds: 1200),
                  child: Container(
                    height: 24,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Rating and date shimmer
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColors.grey800,
                      highlightColor: AppColors.grey700,
                      period: const Duration(milliseconds: 1200),
                      child: Container(
                        height: 20,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Shimmer.fromColors(
                      baseColor: AppColors.grey800,
                      highlightColor: AppColors.grey700,
                      period: const Duration(milliseconds: 1200),
                      child: Container(
                        height: 20,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Overview lines shimmer
                ...List.generate(3, (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < 2 ? 8 : 0),
                      child: Shimmer.fromColors(
                        baseColor: AppColors.grey800,
                        highlightColor: AppColors.grey700,
                        period: const Duration(milliseconds: 1200),
                        child: Container(
                          height: 16,
                          width: index == 2 ? 200 : double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerGridItem extends StatelessWidget {
  const ShimmerGridItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey800,
      highlightColor: AppColors.grey700,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grey800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.grey800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

