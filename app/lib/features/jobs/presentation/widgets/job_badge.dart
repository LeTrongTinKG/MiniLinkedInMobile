import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';

/// Nhãn nhỏ bo tròn (vd: "Remotive", "Senior"). Giống thẻ span badge trong React.
class JobBadge extends StatelessWidget {
  const JobBadge(this.text, {super.key, this.highlight = false});

  final String text;
  final bool highlight; // true: nền màu chủ đạo (dùng cho nguồn), false: nền xám

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primaryContainer : AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: highlight ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
