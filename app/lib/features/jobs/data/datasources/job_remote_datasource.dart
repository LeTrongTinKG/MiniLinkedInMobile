import 'package:dio/dio.dart';
import '../models/job_model.dart';
import '../../domain/entities/job_filter.dart';
import 'job_datasource.dart';

/// Lấy job thật từ GET /jobs, lọc keyword/workMode/level/kỹ năng phía client.
class JobRemoteDataSource implements JobDataSource {
  JobRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<JobModel>> getJobs({JobFilter? filter}) async {
    final res = await _dio.get('/jobs');
    final jobs = (res.data['data'] as List)
        .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
        .toList();
    if (filter == null || !filter.hasFilter) return jobs;
    return jobs.where((job) => _matches(job, filter)).toList();
  }

  bool _matches(JobModel job, JobFilter filter) {
    final query = filter.keyword.trim().toLowerCase();
    if (query.isNotEmpty) {
      final hit = job.title.toLowerCase().contains(query) ||
          job.companyName.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query) ||
          job.requiredSkills.any((s) => s.toLowerCase().contains(query));
      if (!hit) return false;
    }
    if (filter.workMode != null &&
        job.workMode.toLowerCase() != filter.workMode!.name.toLowerCase()) {
      return false;
    }
    if (filter.level != null &&
        job.level.toLowerCase() != filter.level!.name.toLowerCase()) {
      return false;
    }
    if (filter.selectedSkills.isNotEmpty) {
      final skills = job.requiredSkills.map((s) => s.toLowerCase()).toSet();
      if (!filter.selectedSkills.any((s) => skills.contains(s.toLowerCase()))) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<JobModel?> getJobById(String id) async {
    try {
      final res = await _dio.get('/jobs/$id');
      return JobModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<String>> getAvailableSkills() async {
    final jobs = await getJobs();
    return {for (final j in jobs) ...j.requiredSkills}.toList()..sort();
  }
}
