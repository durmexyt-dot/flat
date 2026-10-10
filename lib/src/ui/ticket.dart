import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_style.dart';

/// Outline of a ticket: rounded corners and two half-circle notches where
/// the stub is torn off.
class TicketBorder extends ShapeBorder {
  const TicketBorder({
    this.radius = 16,
    this.notchRadius = 10,
    this.stubWidth = 88,
    this.side = BorderSide.none,
  });

  final double radius;
  final double notchRadius;

  /// Width of the stub on the right; the notches sit at its edge.
  final double stubWidth;
  final BorderSide side;

  double _notchX(Rect rect) => rect.right - math.min(stubWidth, rect.width / 2);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final x = _notchX(rect);
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(x, rect.top), radius: notchRadius),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(x, rect.bottom), radius: notchRadius),
      );
    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(side.width), textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(getOuterPath(rect), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => TicketBorder(
    radius: radius * t,
    notchRadius: notchRadius * t,
    stubWidth: stubWidth * t,
    side: side.scale(t),
  );
}

/// Dashed tear-off line between ticket body and stub.
class _PerforationPainter extends CustomPainter {
  _PerforationPainter(this.color, this.inset);

  final Color color;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dash = 5.0, gap = 5.0;
    for (var y = inset; y < size.height - inset; y += dash + gap) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, math.min(y + dash, size.height - inset)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter old) =>
      old.color != color || old.inset != inset;
}

/// A ticket-shaped card with a [stub] on the right.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.child,
    required this.stub,
    this.onTap,
    this.stubWidth = 88,
    this.color,
  });

  final Widget child;
  final Widget stub;
  final VoidCallback? onTap;
  final double stubWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AppStyle.of(context);
    const notch = 10.0;

    return Material(
      color: color ?? theme.colorScheme.surfaceContainerLow,
      shape: TicketBorder(
        radius: style.cardRadius,
        notchRadius: notch,
        stubWidth: stubWidth,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(padding: const EdgeInsets.all(14), child: child),
              ),
              SizedBox(
                width: 2,
                child: CustomPaint(
                  painter: _PerforationPainter(
                    theme.colorScheme.outlineVariant,
                    notch + 4,
                  ),
                ),
              ),
              SizedBox(
                width: stubWidth - 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  child: Center(child: stub),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
