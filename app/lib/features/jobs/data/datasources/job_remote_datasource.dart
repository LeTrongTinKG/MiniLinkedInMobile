import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/job_filter.dart';
import '../models/job_model.dart';
import 'job_datasource.dart';

/// Triển khai JobDataSource gọi REST API thật từ Backend (Render)
class JobRemoteDataSource implements JobDataSource {
  final Dio _dio;
  final Set<String> _collectedSkills = {};

  /// Danh mục kỹ năng IT phổ biến mặc định
  static const List<String> _baseSkills = [
    'Flutter',
    'Dart',
    'React',
    'React Native',
    'Node.js',
    'Express',
    'NestJS',
    'JavaScript',
    'TypeScript',
    'Python',
    'FastAPI',
    'Django',
    'Java',
    'Spring Boot',
    'C#',
    '.NET',
    'Golang',
    'PHP',
    'SQL',
    'PostgreSQL',
    'MySQL',
    'MongoDB',
    'Redis',
    'Docker',
    'Kubernetes',
    'Git',
    'REST API',
    'GraphQL',
    'AWS',
    'Firebase',
    'CI/CD',
    'Linux',
    'Figma',
  ];

  JobRemoteDataSource(this._dio) {
    _collectedSkills.addAll(_baseSkills);
  }

  @override
  Future<List<JobModel>> getJobs({JobFilter? filter}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filter != null) {
        if (filter.keyword.trim().isNotEmpty) {
          queryParams['q'] = filter.keyword.trim();
        }

        if (filter.selectedSkills.isNotEmpty) {
          // Backend hỗ trợ định dạng chuỗi phân tách dấu phẩy: "Flutter,Dart"
          queryParams['skills'] = filter.selectedSkills.join(',');
        }

        if (filter.level != null) {
          queryParams['level'] = filter.level!.name;
        }

        if (filter.workMode != null) {
          queryParams['workMode'] = filter.workMode!.name;
        }
      }

      final response = await _dio.get(
        '/jobs',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final body = response.data;
      List<dynamic> rawList = [];

      if (body is Map<String, dynamic>) {
        if (body['data'] is List<dynamic>) {
          rawList = body['data'] as List<dynamic>;
        }
      } else if (body is List<dynamic>) {
        rawList = body;
      }

      final jobs = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => JobModel.fromJson(item))
          .toList();

      // Cập nhật thêm các kỹ năng từ job thực tế vào cache
      for (final job in jobs) {
        _collectedSkills.addAll(job.requiredSkills);
        _collectedSkills.addAll(job.niceToHave);
      }

      return jobs;
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  @override
  Future<JobModel?> getJobById(String id) async {
    try {
      final response = await _dio.get('/jobs/$id');
      final body = response.data;

      if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
        return JobModel.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw DioClient.handleDioError(e);
    }
  }

  @override
  Future<List<String>> getAvailableSkills() async {
    final list = _collectedSkills.toList()..sort();
    return list;
  }
}

