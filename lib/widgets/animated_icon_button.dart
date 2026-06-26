import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animated_button.dart';

/// Micro-interaction efektleri olan animasyonlu IconButton
class AnimatedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double iconSize;
  final bool enableHapticFeedback;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.iconSize = 24.0,
    this.enableHapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: () {
        if (enableHapticFeedback) {
          HapticFeedback.selectionClick();
        }
        onPressed?.call();
      },
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: iconSize),
        onPressed: null, // AnimatedButton handles the tap
        tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      ),
    );
  }
}

