import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../ui/hero_tags.dart';

/// The Stubswap ticket logo. Flies between screens as a shared element.
///
/// It derives its shape from the space it gets, so it scales smoothly while a
/// Hero flight resizes it.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Hero(
      tag: HeroTags.brandMark,
      child: SizedBox.square(
        dimension: size,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = constraints.biggest.shortestSide;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(side * 0.28),
              ),
              child: Center(
                child: Icon(
                  FLucideIcons.ticket,
                  size: side * 0.56,
                  color: colors.onPrimary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The "Stubswap" wordmark. Scales with its height, also during a flight.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const style = TextStyle(
      fontSize: 100,
      height: 1,
      fontWeight: FontWeight.w800,
      letterSpacing: -2,
    );

    return Hero(
      tag: HeroTags.brandWordmark,
      // Text needs a Material ancestor while it flies in the overlay.
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: height,
          child: FittedBox(
            child: Text.rich(
              TextSpan(
                style: style,
                children: [
                  TextSpan(
                    text: 'Stub',
                    style: TextStyle(color: colors.onSurface),
                  ),
                  TextSpan(
                    text: 'swap',
                    style: TextStyle(color: colors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The line under the brand. Its text differs per screen ("Buy and sell
/// tickets" on the splash, "Welcome" on login), so in flight the old text
/// fades into the new one.
class BrandTagline extends StatelessWidget {
  const BrandTagline(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: HeroTags.brandTagline,
      flightShuttleBuilder: _crossFade,
      child: Material(
        type: MaterialType.transparency,
        child: Text(text, textAlign: TextAlign.center, style: style),
      ),
    );
  }

  static Widget _crossFade(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final from = (fromContext.widget as Hero).child;
    final to = (toContext.widget as Hero).child;
    // The route animation runs 0→1 on push and 1→0 on pop.
    final toOpacity = direction == HeroFlightDirection.push
        ? animation
        : ReverseAnimation(animation);

    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: ReverseAnimation(toOpacity),
          child: FittedBox(fit: BoxFit.scaleDown, child: from),
        ),
        FadeTransition(
          opacity: toOpacity,
          child: FittedBox(fit: BoxFit.scaleDown, child: to),
        ),
      ],
    );
  }
}

/// Logo and wordmark side by side, used at the top of screens.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.markSize = 40, this.wordmarkHeight = 26});

  final double markSize;
  final double wordmarkHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize),
        SizedBox(width: markSize * 0.25),
        BrandWordmark(height: wordmarkHeight),
      ],
    );
  }
}
