import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../providers/job_provider.dart';
import 'job_filter_chips.dart';
import 'job_greeting_row.dart';
import 'job_search_row.dart';

// Phần đầu thân màn Việc làm: lời chào, ô tìm kiếm, chip lọc.
// (Tiêu đề app + nút menu đã chuyển sang AppHeader dùng chung ở shell.)
class JobListHeader extends StatefulWidget {
  final JobProvider provider;
  final VoidCallback onOpenFilterSheet;

  const JobListHeader({
    super.key,
    required this.provider,
    required this.onOpenFilterSheet,
  });

  @override
  State<JobListHeader> createState() => _JobListHeaderState();
}

class _JobListHeaderState extends State<JobListHeader> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.provider.filter.keyword);
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void didUpdateWidget(covariant JobListHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider.filter.keyword != _controller.text) {
      _controller.text = widget.provider.filter.keyword;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    return Container(
      color: AppColors.surface,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobGreetingRow(provider: p),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: JobSearchRow(
                controller: _controller,
                focusNode: _focusNode,
                focused: _focused,
                activeCount: p.activeFilterCount,
                onSearch: (v) { widget.provider.search(v); setState(() {}); },
                onClear: () { _controller.clear(); widget.provider.search(''); setState(() {}); },
                onFilter: widget.onOpenFilterSheet,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            JobFilterChips(provider: p),
            if (!p.isLoading && p.jobs.isNotEmpty) JobResultsRow(count: p.jobs.length),
            const Divider(height: 1),
          ],
      ),
    );
  }
}
