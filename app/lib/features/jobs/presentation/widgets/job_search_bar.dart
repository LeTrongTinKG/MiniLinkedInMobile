import 'package:flutter/material.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';

/// Thanh tìm kiếm và các chip lọc nhanh phong cách LinkedIn
class JobSearchBar extends StatefulWidget {
  final JobProvider provider;
  final VoidCallback onOpenFilterSheet;

  const JobSearchBar({
    super.key,
    required this.provider,
    required this.onOpenFilterSheet,
  });

  @override
  State<JobSearchBar> createState() => _JobSearchBarState();
}

class _JobSearchBarState extends State<JobSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.provider.filter.keyword);
  }

  @override
  void didUpdateWidget(covariant JobSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider.filter.keyword != _controller.text) {
      _controller.text = widget.provider.filter.keyword;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = widget.provider.activeFilterCount;
    final currentMode = widget.provider.filter.workMode;
    final currentLevel = widget.provider.filter.level;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Hàng Input tìm kiếm + Nút Filter
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF3F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => widget.provider.search(value),
                    onChanged: (value) {
                      // Tự động tìm kiếm sau khi người dùng xóa hết chữ
                      if (value.isEmpty) {
                        widget.provider.search('');
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm vị trí, công ty, kỹ năng...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              color: const Color(0xFF666666),
                              onPressed: () {
                                _controller.clear();
                                widget.provider.search('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Nút mở Modal Bộ lọc chi tiết
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: activeCount > 0
                        ? const Color(0xFFEAF4FF)
                        : const Color(0xFFEEF3F8),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: widget.onOpenFilterSheet,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.tune_rounded,
                          color: activeCount > 0
                              ? const Color(0xFF0A66C2)
                              : const Color(0xFF444444),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // Huy hiệu hiển thị số bộ lọc đang chọn
                  if (activeCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0A66C2),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Hàng Chip lọc nhanh (Quick Filter Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickFilterChip(
                  label: 'Tất cả',
                  isSelected: currentMode == null && currentLevel == null,
                  onTap: () {
                    widget.provider.setWorkMode(null);
                    widget.provider.setLevel(null);
                  },
                ),
                const SizedBox(width: 6),
                _buildQuickFilterChip(
                  label: 'Intern',
                  isSelected: currentLevel == JobLevel.intern,
                  onTap: () => widget.provider.setLevel(JobLevel.intern),
                ),
                const SizedBox(width: 6),
                _buildQuickFilterChip(
                  label: 'Fresher',
                  isSelected: currentLevel == JobLevel.fresher,
                  onTap: () => widget.provider.setLevel(JobLevel.fresher),
                ),
                const SizedBox(width: 6),
                _buildQuickFilterChip(
                  label: 'Remote',
                  isSelected: currentMode == WorkMode.remote,
                  onTap: () => widget.provider.setWorkMode(WorkMode.remote),
                ),
                const SizedBox(width: 6),
                _buildQuickFilterChip(
                  label: 'Hybrid',
                  isSelected: currentMode == WorkMode.hybrid,
                  onTap: () => widget.provider.setWorkMode(WorkMode.hybrid),
                ),
                const SizedBox(width: 6),
                _buildQuickFilterChip(
                  label: 'Tại VP',
                  isSelected: currentMode == WorkMode.onsite,
                  onTap: () => widget.provider.setWorkMode(WorkMode.onsite),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A66C2) : const Color(0xFFF3F2EF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0A66C2) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF444444),
          ),
        ),
      ),
    );
  }
}

