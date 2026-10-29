import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';

/// Tiêu đề từng nhóm trong bảng lọc (vd: "Cấp bậc công việc")
class FilterSectionTitle extends StatelessWidget {
  const FilterSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      );
}

/// Chip chọn 1 giá trị (cấp bậc / hình thức làm việc)
class FilterChoiceChip extends StatelessWidget {
  const FilterChoiceChip(this.label, this.isSelected, this.onTap, {super.key});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryContainer,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent),
        ),
      );
}
