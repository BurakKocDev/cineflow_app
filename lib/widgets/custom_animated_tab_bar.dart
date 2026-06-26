import 'package:flutter/material.dart';
import 'package:cineflow_app/constants/app_colors.dart';

class CustomAnimatedTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomAnimatedTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: (currentIndex * (MediaQuery.of(context).size.width / tabs.length)) +
                ((MediaQuery.of(context).size.width / tabs.length - 60) / 2),
            top: 5,
            bottom: 5,
            child: Container(
              width: (MediaQuery.of(context).size.width / tabs.length) - 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = currentIndex == index;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? AppColors.onPrimary : AppColors.grey400,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: 18,
                          color: isSelected ? AppColors.onPrimary : AppColors.grey400,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            tab.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class TabItem {
  final IconData icon;
  final String label;

  TabItem({required this.icon, required this.label});
}

