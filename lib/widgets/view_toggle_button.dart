import 'package:flutter/material.dart';
import 'package:cineflow_app/constants/app_colors.dart';

enum ViewMode { grid, list }

class ViewToggleButton extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onModeChanged;

  const ViewToggleButton({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(Icons.grid_view, ViewMode.grid),
          _buildButton(Icons.view_list, ViewMode.list),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, ViewMode mode) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.onPrimary : AppColors.grey400,
          size: 20,
        ),
      ),
    );
  }
}

