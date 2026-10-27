import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
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
      builder: (_) => RecruiterApplicationsPage(jobId: job.id, jobTitle: job.title),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Việc đã đăng')),
      body: FutureBuilder<List<RecruiterJob>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final jobs = snapshot.data ?? const <RecruiterJob>[];
          if (snapshot.hasError || jobs.isEmpty) {
            return Center(
              child: Text(
                snapshot.hasError ? 'Không tải được danh sách việc' : 'Bạn chưa đăng việc nào',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: jobs.length,
            itemBuilder: (_, i) => _jobTile(jobs[i]),
          );
        },
      ),
    );
  }

  Widget _jobTile(RecruiterJob job) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${job.location} · ${job.applicationsCount} ứng viên'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openApplicants(job),
        ),
      );
}
