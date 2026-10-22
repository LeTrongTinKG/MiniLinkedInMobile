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
                const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
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

  Widget _buildBody(JobProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Đang tìm kiếm cơ hội việc làm IT…',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 56, color: AppColors.error),
              const SizedBox(height: 16),
              Text(provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.loadJobs(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_off_outlined,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text('Không tìm thấy việc phù hợp',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Thử bỏ bớt bộ lọc hoặc tìm từ khoá khác',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textMuted, height: 1.4)),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => provider.resetFilter(),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Xoá bộ lọc'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
      itemCount: provider.jobs.length,
      itemBuilder: (context, index) {
        final job = provider.jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: JobCard(job: job, onTap: () => _showDetail(job)),
        );
      },
    );
  }
}
