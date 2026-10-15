import 'package:flutter/material.dart';

import 'tokens.dart';

/// Sweeps a highlight across its [child]. Children are drawn with
/// [SkeletonBox]es; the sweep runs across all of them as one surface.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Motion.shimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = colors.surfaceContainerHighest;
    final highlight = Color.lerp(base, colors.surface, 0.7)!;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.35, 0.5, 0.65],
          begin: const Alignment(-1, -0.3),
          end: const Alignment(1, 0.3),
          transform: _SlideGradient(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.t);
  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
}

/// A placeholder block. Use inside a [Shimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A list of ticket-shaped placeholders while a list loads.
class SkeletonTicketList extends StatelessWidget {
  const SkeletonTicketList({super.key, this.count = 4, this.padding});

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        padding: padding ?? const EdgeInsets.all(Space.xl),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: Space.lg),
        itemBuilder: (_, _) => const SkeletonTicketTile(),
      ),
    );
  }
}

class SkeletonTicketTile extends StatelessWidget {
  const SkeletonTicketTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 96,
      child: Row(
        children: [
          SkeletonBox(width: 56, height: 72, radius: 12),
          SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 180, height: 16),
                SizedBox(height: Space.md),
                SkeletonBox(width: 120, height: 12),
                SizedBox(height: Space.md),
                SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 64, height: 24, radius: 12),
        ],
      ),
    );
  }
}
