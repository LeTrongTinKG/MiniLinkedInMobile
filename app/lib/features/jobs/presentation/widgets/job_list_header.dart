import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/student_home/student_nav.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';

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
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleRow(),
            _GreetingRow(provider: p),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _SearchRow(
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
            _FilterChips(provider: p),
            if (!p.isLoading && p.jobs.isNotEmpty) _ResultsRow(count: p.jobs.length),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
      child: Row(
        children: [
          const StudentMenuButton(),
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: const Text(
              'ML',
              style: TextStyle(
                color: AppColors.surface,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text(
            'Mini LinkedIn',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Consumer<AuthProvider>(
            builder: (_, auth, __) {
              final name = auth.currentUser?.displayName ?? '';
              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
              return Tooltip(
                message: name.isNotEmpty ? name : 'Người dùng',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GreetingRow extends StatelessWidget {
  final JobProvider provider;
  const _GreetingRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final displayName = auth.currentUser?.displayName ?? '';
        final firstName = displayName.split(' ').last;
        final greeting = firstName.isNotEmpty ? 'Chào $firstName,' : 'Xin chào,';
        final count = provider.jobs.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              if (!provider.isLoading && count > 0)
                Text(
                  'Hôm nay có $count việc làm IT đang tuyển',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final int activeCount;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final VoidCallback onFilter;

  const _SearchRow({
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

class _FilterChips extends StatelessWidget {
  final JobProvider provider;
  const _FilterChips({required this.provider});

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

class _ResultsRow extends StatelessWidget {
  final int count;
  const _ResultsRow({required this.count});

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
