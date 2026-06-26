import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cineflow_app/constants/app_colors.dart';

class ShimmerActorCard extends StatelessWidget {
  const ShimmerActorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.grey800,
            highlightColor: AppColors.grey700,
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.grey800,
                  highlightColor: AppColors.grey700,
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: AppColors.grey800,
                  highlightColor: AppColors.grey700,
                  child: Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
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

