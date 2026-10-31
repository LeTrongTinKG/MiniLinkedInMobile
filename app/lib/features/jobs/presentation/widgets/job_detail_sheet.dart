import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/applications/presentation/providers/student_applications_provider.dart';
import '../../data/datasources/job_match_remote_datasource.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/job_match.dart';
import 'job_apply_button.dart';
import 'job_badge.dart';
import 'job_detail_helpers.dart';
import 'job_match_section.dart';

class JobDetailSheet extends StatefulWidget {
  final JobEntity job;

  const JobDetailSheet({super.key, required this.job});

  @override
  State<JobDetailSheet> createState() => _JobDetailSheetState();
}

class _JobDetailSheetState extends State<JobDetailSheet> {
  late final Future<JobMatch?> _matchFuture;

  JobEntity get job => widget.job;

  @override
  void initState() {
    super.initState();
    _matchFuture = _loadMatch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentApplicationsProvider>().load();
    });
  }

  Future<JobMatch?> _loadMatch() async {
    try {
      return await context.read<JobMatchRemoteDataSource>().fetchMatch(job.id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.companyName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  JobBadge(job.sourceName, highlight: true),
                  JobBadge(job.level.label),
                ]),
                const SizedBox(height: 8),
                Text(
                  [job.location, job.workMode.label]
                      .where((e) => e.isNotEmpty)
                      .join(' · '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      JobInfoCol(label: 'Mức lương', value: job.formattedSalary),
                      JobInfoCol(label: 'Cấp bậc', value: job.level.label),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<JobMatch?>(
                  future: _matchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LinearProgressIndicator();
                    }
                    return JobMatchSection(match: snapshot.data);
                  },
                ),
                const SizedBox(height: 20),
                const JobDetailSectionTitle('Kỹ năng bắt buộc'),
                const SizedBox(height: 8),
                JobSkillsWrap(
                  skills: job.requiredSkills,
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                ),
                if (job.niceToHave.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const JobDetailSectionTitle('Kỹ năng ưu tiên'),
                  const SizedBox(height: 8),
                  JobSkillsWrap(
                    skills: job.niceToHave,
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.textSecondary,
                  ),
                ],
                const SizedBox(height: 20),
                const JobDetailSectionTitle('Mô tả công việc'),
                const SizedBox(height: 8),
                Text(
                  job.description.isEmpty
                      ? 'Chưa có mô tả'
                      : job.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          JobApplyButton(job: job),
        ],
      ),
    );
  }
}
