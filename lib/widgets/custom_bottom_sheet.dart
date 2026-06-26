import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/constants/app_colors.dart';

class CustomBottomSheet {
  static Future<T?> show<T>({
    required Widget child,
    String? title,
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return Get.bottomSheet<T>(
      Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: Get.textTheme.headlineSmall?.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: AppColors.grey700),
            ],
            Flexible(child: child),
          ],
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
    );
  }
}

