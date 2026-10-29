import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'package:app/core/theme/app_colors.dart';

class NewsFilterChips extends StatelessWidget {
  const NewsFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();

    final langOptions = [
      ('all', 'Tất cả'),
      ('en', '🇬🇧 English'),
      ('vi', '🇻🇳 Tiếng Việt'),
    ];

    final catOptions = [
      ('all', 'Tất cả'),
      ('ai', '🤖 AI'),
      ('tech', '💻 Tech'),
      ('jobs', '💼 Việc làm IT'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Ngôn ngữ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: langOptions.map((opt) {
                final isSelected = provider.selectedLang == opt.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(opt.$2),
                    selected: isSelected,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    backgroundColor: AppColors.background,
                    selectedColor: AppColors.primary,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) => provider.setLanguage(opt.$1),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Row 2: Chủ đề
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: catOptions.map((opt) {
                final isSelected = provider.selectedCategory == opt.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(opt.$2),
                    selected: isSelected,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    backgroundColor: AppColors.background,
                    selectedColor: const Color(0xFF4F46E5), // Indigo
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF4F46E5) : AppColors.border.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) => provider.setCategory(opt.$1),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
