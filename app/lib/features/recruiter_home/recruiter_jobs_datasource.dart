import 'package:dio/dio.dart';
import 'package:app/core/network/dio_client.dart';

/// Job của nhà tuyển dụng kèm số ứng viên (GET /recruiter/jobs)
class RecruiterJob {
  final String id;
  final String title;
  final String location;
  final String status;
  final int applicationsCount;

  const RecruiterJob({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
    required this.applicationsCount,
  });

  factory RecruiterJob.fromJson(Map<String, dynamic> json) => RecruiterJob(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        status: json['status']?.toString() ?? 'open',
        applicationsCount: (json['applicationsCount'] as num?)?.toInt() ?? 0,
      );
}

class RecruiterJobsDataSource {
  RecruiterJobsDataSource(this._dio);

  final Dio _dio;

  Future<List<RecruiterJob>> getMyJobs() async {
    try {
      final response = await _dio.get('/recruiter/jobs', queryParameters: {'limit': 50});
      return (response.data['data'] as List<dynamic>)
          .map((e) => RecruiterJob.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }
}
