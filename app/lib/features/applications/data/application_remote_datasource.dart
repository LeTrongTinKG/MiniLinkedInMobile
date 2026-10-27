import 'package:dio/dio.dart';
import 'package:app/core/network/dio_client.dart';
import '../domain/entities/application_entity.dart';
import 'application_model.dart';

/// Gọi các API đơn ứng tuyển của B7 (sinh viên và nhà tuyển dụng)
class ApplicationRemoteDataSource {
  ApplicationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  List<ApplicationEntity> _parseList(Response<dynamic> response) =>
      (response.data['data'] as List<dynamic>)
          .map((e) => applicationFromJson(e as Map<String, dynamic>))
          .toList();

  ApplicationEntity _parseOne(Response<dynamic> response) =>
      applicationFromJson(response.data['data'] as Map<String, dynamic>);

  // --- Sinh viên ---

  Future<ApplicationEntity> apply(String jobId) => _guard(() async =>
      _parseOne(await _dio.post('/applications', data: {'jobId': jobId})));

  Future<List<ApplicationEntity>> getMyApplications() => _guard(() async =>
      _parseList(await _dio.get('/applications/my', queryParameters: {'limit': 50})));

  Future<ApplicationEntity> withdraw(String id) =>
      _guard(() async => _parseOne(await _dio.patch('/applications/$id/withdraw')));

  // --- Nhà tuyển dụng ---

  Future<List<ApplicationEntity>> getRecruiterApplications({String? jobId}) =>
      _guard(() async => _parseList(await _dio.get(
            '/recruiter/applications',
            queryParameters: {'limit': 50, if (jobId != null) 'jobId': jobId},
          )));

  Future<ApplicationEntity> updateStatus(String id, ApplicationStatus status) =>
      _guard(() async => _parseOne(await _dio.patch(
            '/recruiter/applications/$id/status',
            data: {'status': status.name},
          )));
}
