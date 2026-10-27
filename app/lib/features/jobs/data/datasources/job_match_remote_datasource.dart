import 'package:dio/dio.dart';
import 'package:app/core/network/dio_client.dart';
import '../../domain/entities/job_match.dart';

/// GET /jobs/:id — sinh viên có CV mặc định thì kèm field `match`
class JobMatchRemoteDataSource {
  JobMatchRemoteDataSource(this._dio);

  final Dio _dio;

  /// Trả null khi server không tính được match (chưa có CV mặc định)
  Future<JobMatch?> fetchMatch(String jobId) async {
    try {
      final response = await _dio.get('/jobs/$jobId');
      final match = (response.data['data'] as Map<String, dynamic>)['match'];
      return match is Map<String, dynamic> ? JobMatch.fromJson(match) : null;
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }
}
