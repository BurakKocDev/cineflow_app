import 'package:flutter/material.dart';
import 'package:cineflow_app/constants/app_colors.dart';

class AnimatedRatingStars extends StatefulWidget {
  final double rating;
  final double maxRating;
  final double starSize;
  final Color activeColor;
  final Color inactiveColor;
  final bool showRatingText;
  final bool allowInteraction;
  final ValueChanged<double>? onRatingChanged;

  const AnimatedRatingStars({
    super.key,
    required this.rating,
    this.maxRating = 10.0,
    this.starSize = 20.0,
    this.activeColor = AppColors.accent,
    this.inactiveColor = AppColors.grey600,
    this.showRatingText = true,
    this.allowInteraction = false,
    this.onRatingChanged,
  });

  @override
  State<AnimatedRatingStars> createState() => _AnimatedRatingStarsState();
}

class _AnimatedRatingStarsState extends State<AnimatedRatingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _displayRating = 0;

  @override
  void initState() {
    super.initState();
    _displayRating = widget.rating;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.rating).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedRatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      _controller.reset();
      _animation = Tween<double>(begin: _displayRating, end: widget.rating)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _convertTo5Star(double rating, double maxRating) {
    return (rating / maxRating) * 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final starRating = _convertTo5Star(_animation.value, widget.maxRating);
    final fullStars = starRating.floor();
    final hasHalfStar = (starRating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(fullStars, (index) => _buildStar(true, false, index)),
        if (hasHalfStar) _buildStar(false, true, fullStars),
        ...List.generate(emptyStars, (index) => _buildStar(false, false, fullStars + (hasHalfStar ? 1 : 0) + index)),
        if (widget.showRatingText) ...[
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                widget.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.starSize * 0.7,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildStar(bool isFull, bool isHalf, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            isFull
                ? Icons.star
                : isHalf
                    ? Icons.star_half
                    : Icons.star_border,
            color: isFull || isHalf ? widget.activeColor : widget.inactiveColor,
            size: widget.starSize,
          ),
        );
      },
    );
  }
}

