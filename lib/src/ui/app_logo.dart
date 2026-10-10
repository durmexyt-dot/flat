import 'package:flutter/material.dart';

import 'hero_tags.dart';

/// The app logo. Flies between screens as a shared element.
///
/// The logo derives its shape from the space it gets, so it scales smoothly
/// while the Hero flight resizes it.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Hero(
      tag: HeroTags.appLogo,
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
                  Icons.home_rounded,
                  size: side * 0.6,
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
