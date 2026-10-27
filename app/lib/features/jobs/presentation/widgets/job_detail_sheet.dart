import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/applications/presentation/providers/student_applications_provider.dart';
import '../../data/datasources/job_match_remote_datasource.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/job_match.dart';
import 'job_apply_button.dart';
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
    // Cần biết đã ứng tuyển job này chưa để hiện đúng nút
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
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 4),
                Text(
                  '${job.location} · ${job.workMode.label}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoCol('Mức lương', job.formattedSalary),
                      _infoCol('Cấp bậc', job.level.label),
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
                _sectionTitle('Kỹ năng bắt buộc'),
                const SizedBox(height: 8),
                _skillsWrap(job.requiredSkills, AppColors.primaryContainer, AppColors.onPrimaryContainer),
                if (job.niceToHave.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _sectionTitle('Kỹ năng ưu tiên'),
                  const SizedBox(height: 8),
                  _skillsWrap(job.niceToHave, AppColors.background, AppColors.textSecondary),
                ],
                const SizedBox(height: 20),
                _sectionTitle('Mô tả công việc'),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          JobApplyButton(jobId: job.id),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );

  Widget _skillsWrap(List<String> skills, Color bg, Color fg) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: skills
            .map((s) => Chip(
                  label: Text(s),
                  backgroundColor: bg,
                  labelStyle: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ))
            .toList(),
      );

  Widget _infoCol(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      );
}
