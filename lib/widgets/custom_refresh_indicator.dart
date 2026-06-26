import 'package:flutter/material.dart';
import 'package:cineflow_app/constants/app_colors.dart';

/// Özel görsel refresh indicator
class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primary,
      backgroundColor: AppColors.surface,
      strokeWidth: 3.0,
      displacement: 40.0,
      edgeOffset: 20.0,
      child: child,
    );
  }
}

