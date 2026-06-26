import 'package:flutter/material.dart';

/// Parallax scroll efekti olan scroll view
class ParallaxScrollView extends StatelessWidget {
  final String? backdropImageUrl;
  final Widget child;
  final double maxHeight;
  final double minHeight;

  const ParallaxScrollView({
    super.key,
    required this.child,
    this.backdropImageUrl,
    this.maxHeight = 300,
    this.minHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: maxHeight,
          pinned: true,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (backdropImageUrl != null)
                  Positioned.fill(
                    child: Image.network(
                      backdropImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey[900]!,
                          Colors.grey[800]!,
                        ],
                      ),
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: child,
        ),
      ],
    );
  }
}

