import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cineflow_app/constants/app_colors.dart';

/// Özel yükleme animasyonu progress indicator
class CustomProgressIndicator extends StatefulWidget {
  final double? size;
  final Color? color;

  const CustomProgressIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  State<CustomProgressIndicator> createState() => _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CustomProgressPainter(
              progress: _animation.value,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _CustomProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CustomProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    // Draw background circle
    canvas.drawCircle(center, radius, paint..color = color.withOpacity(0.2));

    // Draw progress arc
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      paint..color = color,
    );

    // Draw animated dots
    const dotCount = 8;
    for (int i = 0; i < dotCount; i++) {
      final dotProgress = (progress + (i / dotCount)) % 1.0;
      final dotOpacity = (1.0 - dotProgress) * 0.8 + 0.2;
      final angle = -math.pi / 2 + (2 * math.pi * dotProgress);
      final dotX = center.dx + radius * 0.7 * math.cos(angle);
      final dotY = center.dy + radius * 0.7 * math.sin(angle);
      
      canvas.drawCircle(
        Offset(dotX, dotY),
        3.0,
        Paint()..color = color.withOpacity(dotOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(_CustomProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

