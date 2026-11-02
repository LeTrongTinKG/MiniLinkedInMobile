import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';
import 'job_filter_parts.dart';

class JobFilterSheet extends StatefulWidget {
  final JobProvider provider;

  const JobFilterSheet({super.key, required this.provider});

  static Future<void> show(BuildContext context, JobProvider provider) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobFilterSheet(provider: provider),
    );
  }

  @override
  State<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends State<JobFilterSheet> {
  late WorkMode? _workMode;
  late JobLevel? _level;
  late Set<String> _selectedSkills;

  @override
  void initState() {
    super.initState();
    _workMode = widget.provider.filter.workMode;
    _level = widget.provider.filter.level;
    _selectedSkills = Set<String>.from(widget.provider.filter.selectedSkills);
  }

  void _reset() => setState(() {
        _workMode = null;
        _level = null;
        _selectedSkills.clear();
      });

  void _apply() {
    final updatedFilter = widget.provider.filter.copyWith(
      workMode: () => _workMode,
      level: () => _level,
      selectedSkills: _selectedSkills,
    );
    widget.provider.applyFilter(updatedFilter);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final availableSkills = widget.provider.availableSkills;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc công việc',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Đặt lại',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const FilterSectionTitle('Cấp bậc công việc'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChoiceChip('Tất cả cấp bậc', _level == null,
                        () => setState(() => _level = null)),
                    ...JobLevel.values.map((lvl) => FilterChoiceChip(
                        lvl.label, _level == lvl,
                        () => setState(() => _level = lvl))),
                  ],
                ),
                const SizedBox(height: 24),
                const FilterSectionTitle('Hình thức làm việc'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChoiceChip('Tất cả hình thức', _workMode == null,
                        () => setState(() => _workMode = null)),
                    ...WorkMode.values.map((m) => FilterChoiceChip(
                        m.label, _workMode == m,
                        () => setState(() => _workMode = m))),
                  ],
                ),
                const SizedBox(height: 24),
                const FilterSectionTitle('Kỹ năng chuyên môn IT'),
                if (availableSkills.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Đang nạp danh sách kỹ năng…',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSkills.map((skill) {
                      final sel = _selectedSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: sel,
                        onSelected: (v) => setState(() => v
                            ? _selectedSkills.add(skill)
                            : _selectedSkills.remove(skill)),
                        selectedColor: AppColors.primaryContainer,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color:
                              sel ? AppColors.primary : AppColors.textPrimary,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusPill),
                          side: BorderSide(
                            color: sel ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          FilterApplyFooter(onApply: _apply),
        ],
      ),
    );
  }
}
