import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One concentric ring's data.
class RingData {
  const RingData({required this.value, required this.color, this.track});

  /// 0..1 fill fraction.
  final double value;
  final Color color;
  final Color? track;
}

/// A set of nested progress rings with rounded caps and soft tracks — the
/// hero "financial health" diagram. Mirrors the multi-ring statistics chart in
/// the reference design (outer → inner).
class HealthRingChart extends StatelessWidget {
  const HealthRingChart({
    super.key,
    required this.rings,
    this.size = 188,
    this.strokeWidth = 14,
    this.gap = 7,
    this.center,
  });

  /// Outer ring first.
  final List<RingData> rings;
  final double size;
  final double strokeWidth;
  final double gap;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          rings: rings,
          strokeWidth: strokeWidth,
          gap: gap,
        ),
        child: center == null ? null : Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.rings,
    required this.strokeWidth,
    required this.gap,
  });

  final List<RingData> rings;
  final double strokeWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2 - strokeWidth / 2;
    const start = -math.pi / 2;

    for (var i = 0; i < rings.length; i++) {
      final ring = rings[i];
      final radius = maxRadius - i * (strokeWidth + gap);
      if (radius <= 0) continue;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = ring.track ?? AppColors.ringTrack;
      canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

      final sweep = (ring.value.clamp(0.0, 1.0)) * 2 * math.pi;
      if (sweep <= 0) continue;
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          transform: const GradientRotation(-math.pi / 2),
          colors: [ring.color.withValues(alpha: 0.75), ring.color],
        ).createShader(rect);
      canvas.drawArc(rect, start, sweep, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.rings != rings ||
      old.strokeWidth != strokeWidth ||
      old.gap != gap;
}
