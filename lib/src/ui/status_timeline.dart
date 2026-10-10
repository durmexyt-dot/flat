import 'dart:math' as math;

import 'package:flutter/material.dart';

enum TimelineState { done, current, upcoming, failed }

@immutable
class TimelineStep {
  const TimelineStep({required this.label, required this.state, this.detail});

  final String label;
  final TimelineState state;

  /// E.g. the date the step was reached.
  final String? detail;
}

/// Vertical progress of a status flow. The rail fills from the top when it
/// appears, the current step pulses, a failed step is marked red.
class StatusTimeline extends StatefulWidget {
  const StatusTimeline({super.key, required this.steps});

  final List<TimelineStep> steps;

  @override
  State<StatusTimeline> createState() => _StatusTimelineState();
}

class _StatusTimelineState extends State<StatusTimeline>
    with TickerProviderStateMixin {
  late final _fill = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 250 * widget.steps.length + 300),
  )..forward();
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A few pulses draw the eye to the current step; endless pulsing would
    // only cost battery. None with reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating && _pulse.value == 0) {
      _pulse.repeat(count: 3).whenComplete(() {
        if (mounted) _pulse.value = 0;
      });
    }
  }

  @override
  void didUpdateWidget(StatusTimeline old) {
    super.didUpdateWidget(old);
    final changed =
        old.steps.length != widget.steps.length ||
        [
          for (var i = 0; i < widget.steps.length; i++)
            old.steps[i].state != widget.steps[i].state,
        ].any((c) => c);
    if (changed) _fill.forward(from: 0);
  }

  @override
  void dispose() {
    _fill.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final states = [for (final s in widget.steps) s.state];
    final fill = CurvedAnimation(parent: _fill, curve: Curves.easeInOutCubic);

    return Column(
      children: [
        for (var i = 0; i < widget.steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: CustomPaint(
                    painter: _RailPainter(
                      index: i,
                      states: states,
                      fill: fill,
                      pulse: _pulse,
                      colors: theme.colorScheme,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.steps[i].label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: switch (states[i]) {
                              TimelineState.upcoming =>
                                theme.colorScheme.onSurfaceVariant,
                              TimelineState.failed => theme.colorScheme.error,
                              _ => theme.colorScheme.onSurface,
                            },
                            fontWeight: states[i] == TimelineState.current
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        if (widget.steps[i].detail case final detail?)
                          Text(
                            detail,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter({
    required this.index,
    required this.states,
    required this.fill,
    required this.pulse,
    required this.colors,
  }) : super(repaint: Listenable.merge([fill, pulse]));

  final int index;
  final List<TimelineState> states;
  final Animation<double> fill;
  final Animation<double> pulse;
  final ColorScheme colors;

  static const _nodeY = 14.0;
  static const _radius = 10.0;

  bool _reached(int i) => states[i] != TimelineState.upcoming;

  /// Progress through the steps: 0 at the first node, n-1 at the last.
  double get _t => fill.value * (states.length - 1);

  /// How far the segment ending at node [i] is drawn, 0..1.
  double _segment(int i) => _reached(i) ? (_t - (i - 1)).clamp(0.0, 1.0) : 0.0;

  Color _accent(int i) =>
      states[i] == TimelineState.failed ? colors.error : colors.primary;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final base = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    void line(double from, double to, double fraction, Color color) {
      canvas.drawLine(Offset(x, from), Offset(x, to), base);
      if (fraction <= 0) return;
      canvas.drawLine(
        Offset(x, from),
        Offset(x, from + (to - from) * fraction),
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    // Upper half: second half of the segment from the previous node.
    if (index > 0) {
      final f = _segment(index);
      line(0, _nodeY - _radius, (f * 2 - 1).clamp(0.0, 1.0), _accent(index));
    }
    // Lower half: first half of the segment to the next node.
    if (index < states.length - 1) {
      final f = _segment(index + 1);
      line(
        _nodeY + _radius,
        size.height,
        (f * 2).clamp(0.0, 1.0),
        _accent(index + 1),
      );
    }

    _paintNode(canvas, Offset(x, _nodeY));
  }

  void _paintNode(Canvas canvas, Offset c) {
    final state = states[index];
    // A node shows its state once the rail has reached it.
    final arrived = index == 0 ? fill.value > 0 : _segment(index) >= 1;
    if (state == TimelineState.upcoming || !arrived) {
      canvas.drawCircle(
        c,
        _radius - 1.5,
        Paint()
          ..color = colors.outlineVariant
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      return;
    }

    final accent = _accent(index);
    if (state == TimelineState.current) {
      final p = pulse.value;
      canvas.drawCircle(
        c,
        _radius + 8 * p,
        Paint()..color = accent.withValues(alpha: 0.35 * (1 - p)),
      );
    }
    canvas.drawCircle(c, _radius, Paint()..color = accent);

    final mark = Paint()
      ..color = state == TimelineState.failed
          ? colors.onError
          : colors.onPrimary
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (state) {
      case TimelineState.done:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 4.5, c.dy + 0.2)
            ..lineTo(c.dx - 1.2, c.dy + 3.5)
            ..lineTo(c.dx + 4.8, c.dy - 3.2),
          mark,
        );
      case TimelineState.failed:
        const d = 3.6;
        canvas
          ..drawLine(c.translate(-d, -d), c.translate(d, d), mark)
          ..drawLine(c.translate(d, -d), c.translate(-d, d), mark);
      case TimelineState.current:
        canvas.drawCircle(
          c,
          math.max(2.5, _radius * 0.3),
          Paint()..color = colors.onPrimary,
        );
      case TimelineState.upcoming:
        break;
    }
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.index != index ||
      old.colors != colors ||
      old.states.length != states.length ||
      [for (var i = 0; i < states.length; i++) old.states[i] != states[i]]
          .any((c) => c);
}
