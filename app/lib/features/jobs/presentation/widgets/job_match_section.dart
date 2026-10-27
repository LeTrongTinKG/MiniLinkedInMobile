import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import '../../domain/entities/job_match.dart';

/// "72% phù hợp" + kỹ năng khớp, còn thiếu và gợi ý nên học
class JobMatchSection extends StatelessWidget {
  const JobMatchSection({super.key, required this.match});

  final JobMatch? match;

  @override
  Widget build(BuildContext context) {
    final m = match;
    if (m == null) return _noCvHint();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _scoreRing(m.score),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${m.score}% phù hợp với CV của bạn',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (m.matchedSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _label('Kỹ năng bạn đã có'),
            _chips(m.matchedSkills, const Color(0xFFD4EDDA), const Color(0xFF155724)),
          ],
          if (m.missingSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _label('Kỹ năng còn thiếu'),
            _chips(m.missingSkills, const Color(0xFFFADADD), AppColors.error),
          ],
          if (m.suggestion.isNotEmpty) ...[
            const SizedBox(height: 12),
            _label('Gợi ý nên học'),
            Text(m.suggestion, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _noCvHint() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.description_outlined, color: AppColors.textMuted),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tải CV lên ở tab Hồ sơ để xem bạn phù hợp bao nhiêu %.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );

  Widget _scoreRing(int score) => SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 6,
                backgroundColor: AppColors.border,
                color: score >= 70 ? AppColors.salary : AppColors.accent,
              ),
            ),
            Text('$score%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      );

  Widget _chips(List<String> skills, Color bg, Color fg) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: skills
            .map((s) => Chip(
                  label: Text(s),
                  backgroundColor: bg,
                  labelStyle: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ))
            .toList(),
      );
}
