import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Grade badge widget displaying sustainability grade (A-F)
class GradeBadge extends StatelessWidget {
  final String grade;
  final double size;

  const GradeBadge({
    super.key,
    required this.grade,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getGradeColor(grade);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Center(
        child: Text(
          grade.toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
