import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/job_filter.dart';
import '../models/job_model.dart';
import 'job_datasource.dart';

/// Gọi GET /jobs trên backend (Render). Lọc keyword/workMode/level/kỹ năng phía client
/// để khớp đúng ô tìm kiếm (địa điểm, kỹ năng), không chỉ các field server đang search.
class JobRemoteDataSource implements JobDataSource {
  JobRemoteDataSource(this._dio);

  final Dio _dio;

  static const int _pageSize = 50;
  static const int _maxPages = 20;

  /// Render free tier ngủ đông; request đầu có thể mất ~1 phút mới trả body.
  static final _slowServer = Options(
    receiveTimeout: const Duration(seconds: 60),
  );

  static const List<String> _baseSkills = [
    'Flutter',
    'Dart',
    'React',
    'React Native',
    'Node.js',
    'Express',
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'SQL',
    'PostgreSQL',
    'Docker',
    'Git',
  ];

  @override
  Future<List<JobModel>> getJobs({JobFilter? filter}) async {
    try {
      final jobs = await _fetchAllPages();
      if (filter == null || !filter.hasFilter) return jobs;
      return jobs.where((job) => _matches(job, filter)).toList();
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<List<JobModel>> _fetchAllPages() async {
    final jobs = <JobModel>[];
    for (var page = 1; page <= _maxPages; page++) {
      final response = await _dio.get(
        '/jobs',
        queryParameters: {'page': page, 'limit': _pageSize},
        options: _slowServer,
      );
      final body = response.data;
      final rawList = _extractList(body);
      for (final item in rawList) {
        if (item is Map) {
          jobs.add(JobModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      if (!_hasNextPage(body) || rawList.isEmpty) break;
    }
    return jobs;
  }

  List<dynamic> _extractList(dynamic body) {
    if (body is Map && body['data'] is List) return body['data'] as List;
    if (body is List) return body;
    return const [];
  }

  bool _hasNextPage(dynamic body) {
    if (body is! Map) return false;
    final meta = body['meta'];
    return meta is Map && meta['hasNextPage'] == true;
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
      final response = await _dio.get('/jobs/$id', options: _slowServer);
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        return JobModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw DioClient.handleDioError(e);
    }
  }

  @override
  Future<List<String>> getAvailableSkills() async {
    final jobs = await getJobs();
    final byKey = <String, String>{};
    for (final skill in [
      ..._baseSkills,
      for (final job in jobs) ...job.requiredSkills,
    ]) {
      byKey.putIfAbsent(skill.toLowerCase(), () => skill);
    }
    final list = byKey.values.toList()..sort();
    return list;
  }
}
