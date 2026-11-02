import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';

// Hàng chip lọc nhanh (Intern, Fresher, Remote...) và dòng "N kết quả".
class JobFilterChips extends StatelessWidget {
  final JobProvider provider;
  const JobFilterChips({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final currentMode = provider.filter.workMode;
    final currentLevel = provider.filter.level;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _chip(context, 'Tất cả', currentMode == null && currentLevel == null, () {
            provider.setWorkMode(null);
            provider.setLevel(null);
          }),
          _chip(context, 'Intern', currentLevel == JobLevel.intern,
              () => provider.setLevel(JobLevel.intern)),
          _chip(context, 'Fresher', currentLevel == JobLevel.fresher,
              () => provider.setLevel(JobLevel.fresher)),
          _chip(context, 'Remote', currentMode == WorkMode.remote,
              () => provider.setWorkMode(WorkMode.remote)),
          _chip(context, 'Hybrid', currentMode == WorkMode.hybrid,
              () => provider.setWorkMode(WorkMode.hybrid)),
          _chip(context, 'Tại VP', currentMode == WorkMode.onsite,
              () => provider.setWorkMode(WorkMode.onsite)),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isSelected
        ? (isDark ? Colors.white : const Color(0xFF0F172A))
        : (isDark ? const Color(0xFF1E293B) : Colors.white);
    final fg = isSelected
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? Colors.white70 : const Color(0xFF64748B));
    final borderColor = isSelected
        ? Colors.transparent
        : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08));

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.check, size: 12, color: fg),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobResultsRow extends StatelessWidget {
  final int count;
  const JobResultsRow({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$count kết quả',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500)),
          const Text('Mới nhất ▾',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
