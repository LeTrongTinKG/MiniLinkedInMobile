import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';

/// "Match 85%" — xanh khi ≥ 70, cam khi ≥ 40, đỏ nhạt khi thấp hơn
class MatchScoreChip extends StatelessWidget {
  const MatchScoreChip(this.score, {super.key});

  final int score;

  Color get _color {
    if (score >= 70) return AppColors.salary;
    if (score >= 40) return AppColors.accent;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Match $score%',
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
