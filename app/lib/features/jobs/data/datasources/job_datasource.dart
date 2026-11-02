import '../models/job_model.dart';
import '../../domain/entities/job_filter.dart';

/// Interface cho Data Source của Job
abstract interface class JobDataSource {
  Future<List<JobModel>> getJobs({JobFilter? filter});
  Future<JobModel?> getJobById(String id);
  Future<List<String>> getAvailableSkills();
}

