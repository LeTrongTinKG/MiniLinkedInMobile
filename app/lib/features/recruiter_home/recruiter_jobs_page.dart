import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/ui_kit/app_empty_state.dart';
import 'recruiter_applications_page.dart';
import 'recruiter_jobs_datasource.dart';

/// Tab "Việc đăng": các job của mình, bấm vào để xem ứng viên theo điểm
class RecruiterJobsPage extends StatefulWidget {
  const RecruiterJobsPage({super.key});

  @override
  State<RecruiterJobsPage> createState() => _RecruiterJobsPageState();
}

class _RecruiterJobsPageState extends State<RecruiterJobsPage> {
  late Future<List<RecruiterJob>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<RecruiterJobsDataSource>().getMyJobs();
  }

  void _openApplicants(RecruiterJob job) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          RecruiterApplicationsPage(jobId: job.id, jobTitle: job.title),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Việc đã đăng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: FutureBuilder<List<RecruiterJob>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final jobs = snapshot.data ?? const <RecruiterJob>[];
          if (snapshot.hasError || jobs.isEmpty) {
            return AppEmptyState(
              icon: snapshot.hasError
                  ? Icons.error_outline
                  : Icons.work_outline_rounded,
              title: snapshot.hasError
                  ? 'Lỗi tải danh sách việc'
                  : 'Bạn chưa đăng việc nào',
              message: snapshot.hasError
                  ? 'Không thể kết nối đến máy chủ. Vui lòng thử lại.'
                  : 'Đăng tin tuyển dụng mới để tìm kiếm ứng viên phù hợp.',
              actionLabel: snapshot.hasError ? 'Thử lại' : null,
              onAction: snapshot.hasError
                  ? () => setState(() {
                        _future = context
                            .read<RecruiterJobsDataSource>()
                            .getMyJobs();
                      })
                  : null,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: jobs.length,
            itemBuilder: (_, i) => _jobTile(jobs[i]),
          );
        },
      ),
    );
  }

  Widget _jobTile(RecruiterJob job) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 4,
          ),
          title: Text(
            job.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${job.location} · ${job.applicationsCount} ứng viên',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
          onTap: () => _openApplicants(job),
        ),
      );
}
