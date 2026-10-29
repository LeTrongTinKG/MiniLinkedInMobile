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
          _chip('Tất cả', currentMode == null && currentLevel == null, () {
            provider.setWorkMode(null);
            provider.setLevel(null);
          }),
          _chip('Intern', currentLevel == JobLevel.intern,
              () => provider.setLevel(JobLevel.intern)),
          _chip('Fresher', currentLevel == JobLevel.fresher,
              () => provider.setLevel(JobLevel.fresher)),
          _chip('Remote', currentMode == WorkMode.remote,
              () => provider.setWorkMode(WorkMode.remote)),
          _chip('Hybrid', currentMode == WorkMode.hybrid,
              () => provider.setWorkMode(WorkMode.hybrid)),
          _chip('Tại VP', currentMode == WorkMode.onsite,
              () => provider.setWorkMode(WorkMode.onsite)),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check, size: 12, color: AppColors.onPrimaryContainer),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.onPrimaryContainer : AppColors.textSecondary,
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
