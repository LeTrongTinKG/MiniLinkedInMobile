import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../../data/skill_suggestion.dart';
import '../../domain/models/skill_confidence.dart';
import 'confidence_badge.dart';

class RepoSuggestionCard extends StatelessWidget {
  const RepoSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onAccept,
    required this.onIgnore,
  });

  final SkillSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                suggestion.skillName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const ConfidenceBadge(confidence: SkillConfidence.evidenced),
            ],
          ),
          const SizedBox(height: 6),
          for (final e in suggestion.evidence)
            Text(
              '${e.repo}: ${e.signals.join(', ')}',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onIgnore,
                child: const Text('Bỏ qua'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
                onPressed: onAccept,
                child: const Text('Thêm vào hồ sơ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
