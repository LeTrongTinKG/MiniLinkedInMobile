import 'package:flutter/material.dart';

/// Thẻ Milestone tiến trình học tập theo phong cách v0.
class CoachMilestoneCard extends StatelessWidget {
  final String title;
  final String estimate;
  final VoidCallback? onTap;

  const CoachMilestoneCard({
    super.key,
    this.title = 'Milestone 01 · Build a test suite',
    this.estimate = 'Est. 2–3 hours · +12 profile strength',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF78350F).withValues(alpha: 0.25)
              : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF92400E).withValues(alpha: 0.6)
                : const Color(0xFFFEF3C7),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF78350F).withValues(alpha: 0.5)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 18,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    estimate,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFFFCD34D).withValues(alpha: 0.7) : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }
}
