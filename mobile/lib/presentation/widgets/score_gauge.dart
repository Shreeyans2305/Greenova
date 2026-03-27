import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular gauge widget for displaying sustainability scores
class ScoreGauge extends StatelessWidget {
  final double score;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  const ScoreGauge({
    super.key,
    required this.score,
    this.size = 120,
    this.strokeWidth = 12,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getCarbonScoreColor(score);
    final normalizedScore = (score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              progress: 1.0,
              color: Colors.grey.shade200,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress arc
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              progress: normalizedScore,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
          // Center content
          if (showLabel)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  score.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'CO2',
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
