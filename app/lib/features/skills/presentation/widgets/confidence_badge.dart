import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/skill_confidence.dart';

/// Huy hiệu hiển thị 3 cấp độ tin cậy của kỹ năng (F-008, F-009, F-010).
/// Tích hợp đầy đủ trợ năng Semantics cho VoiceOver/TalkBack (F-019).
class ConfidenceBadge extends StatelessWidget {
  final SkillConfidence confidence;
  final bool compact;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (confidence) {
      SkillConfidence.selfClaimed => (
        Icons.person_outline,
        AppTheme.textSecondary,
        'Tự khai',
      ),
      SkillConfidence.evidenced => (
        Icons.link,
        AppTheme.successGreen,
        'Có bằng chứng',
      ),
      SkillConfidence.endorsed => (
        Icons.verified_outlined,
        AppTheme.primaryBlue,
        'Được xác nhận',
      ),
    };

    return Semantics(
      label: 'Mức tin cậy: $label',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: compact ? 12 : 14, color: color),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
