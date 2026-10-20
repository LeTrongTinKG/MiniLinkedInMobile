import 'package:flutter/material.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';

/// Modal Bottom Sheet cho phép người dùng cấu hình chi tiết các tiêu chí lọc
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

  void _reset() {
    setState(() {
      _workMode = null;
      _level = null;
      _selectedSkills.clear();
    });
  }

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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Thanh kéo (Drag handle)
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
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
                    color: Color(0xFF191919),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Đặt lại',
                    style: TextStyle(
                      color: Color(0xFF0A66C2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0DFDC)),

          // Nội dung các nhóm lọc
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Nhóm Cấp bậc (Level)
                _buildSectionTitle('Cấp bậc công việc'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: 'Tất cả cấp bậc',
                      isSelected: _level == null,
                      onSelected: () => setState(() => _level = null),
                    ),
                    ...JobLevel.values.map((lvl) {
                      return _buildChoiceChip(
                        label: lvl.label,
                        isSelected: _level == lvl,
                        onSelected: () => setState(() => _level = lvl),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. Nhóm Hình thức làm việc (WorkMode)
                _buildSectionTitle('Hình thức làm việc'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: 'Tất cả hình thức',
                      isSelected: _workMode == null,
                      onSelected: () => setState(() => _workMode = null),
                    ),
                    ...WorkMode.values.map((mode) {
                      return _buildChoiceChip(
                        label: mode.label,
                        isSelected: _workMode == mode,
                        onSelected: () => setState(() => _workMode = mode),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. Nhóm Kỹ năng IT (Skills)
                _buildSectionTitle('Kỹ năng chuyên môn IT'),
                if (availableSkills.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Đang nạp danh sách kỹ năng...',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSkills.map((skill) {
                      final isSelected = _selectedSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFEAF4FF),
                        checkmarkColor: const Color(0xFF0A66C2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF0A66C2)
                              : const Color(0xFF333333),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: const Color(0xFFF3F2EF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0A66C2)
                                : Colors.transparent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          // Footer: Nút Áp dụng
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0DFDC))),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng bộ lọc',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF191919),
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFFEAF4FF),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0A66C2) : const Color(0xFF333333),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: const Color(0xFFF3F2EF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0A66C2) : Colors.transparent,
        ),
      ),
    );
  }
}

