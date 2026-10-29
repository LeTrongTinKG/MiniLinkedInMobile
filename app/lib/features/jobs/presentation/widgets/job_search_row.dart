import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';

// Ô tìm kiếm + nút mở bộ lọc (giống 1 component React nhận props).
class JobSearchRow extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final int activeCount;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final VoidCallback onFilter;

  const JobSearchRow({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.activeCount,
    required this.onSearch,
    required this.onClear,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
              border: Border.all(
                color: focused ? AppColors.primary : AppColors.border,
                width: focused ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: onSearch,
              onChanged: (v) { if (v.isEmpty) onSearch(''); },
              decoration: InputDecoration(
                hintText: 'Tìm vị trí, công ty, kỹ năng…',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        color: AppColors.textMuted,
                        onPressed: onClear,
                        tooltip: 'Xoá',
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Tooltip(
              message: 'Bộ lọc',
              child: Material(
                color: activeCount > 0 ? AppColors.primaryContainer : AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                child: InkWell(
                  onTap: onFilter,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.tune_rounded,
                      color: activeCount > 0 ? AppColors.primary : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            if (activeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
