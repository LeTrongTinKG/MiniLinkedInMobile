import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/job_detail_sheet.dart';
import '../widgets/job_filter_sheet.dart';
import '../widgets/job_list_header.dart';
import '../widgets/job_list_states.dart';
import '../widgets/job_skeleton_card.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().init();
    });
  }

  void _openFilterSheet(JobProvider provider) =>
      JobFilterSheet.show(context, provider);

  void _showDetail(JobEntity job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobDetailSheet(job: job),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.maxGridWidth),
            child: Column(
              children: [
                JobListHeader(
                  provider: provider,
                  onOpenFilterSheet: () => _openFilterSheet(provider),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => provider.loadJobs(),
                    child: _buildBody(provider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 1 cột trên mobile, 2 cột tablet, 3 cột trên web/màn rộng.
  static int _columnsFor(double width) {
    if (width >= 960) return 3;
    if (width >= 640) return 2;
    return 1;
  }

  /// Xếp item thành lưới nhiều cột, mỗi hàng cao bằng card cao nhất.
  Widget _grid({
    required int itemCount,
    required Widget Function(int index) itemBuilder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final rows = (itemCount / columns).ceil();
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
          itemCount: rows,
          itemBuilder: (_, row) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < columns; c++) ...[
                    if (c > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: row * columns + c < itemCount
                          ? itemBuilder(row * columns + c)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(JobProvider provider) {
    if (provider.isLoading) {
      return _grid(itemCount: 6, itemBuilder: (_) => const JobSkeletonCard());
    }

    if (provider.errorMessage != null) {
      return JobListErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.loadJobs(),
      );
    }

    if (provider.jobs.isEmpty) {
      return JobListEmptyState(onClearFilter: () => provider.resetFilter());
    }

    return Column(
      children: [
        if (provider.isUsingMockData) const JobMockDataBanner(),
        Expanded(
          child: _grid(
            itemCount: provider.jobs.length,
            itemBuilder: (i) {
              final job = provider.jobs[i];
              return JobCard(job: job, onTap: () => _showDetail(job));
            },
          ),
        ),
      ],
    );
  }
}
