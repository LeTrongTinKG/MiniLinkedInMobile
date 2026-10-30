import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'coach_models.dart';

class CoachRemoteDataSource {
  final Dio _dio;
  CoachRemoteDataSource(this._dio);

  Future<CoachSettings> getSettings() async {
    try {
      final response = await _dio.get('/coach/settings');
      return CoachSettings.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<CoachSettings> saveSettings(
      {bool? consent, String? targetRole}) async {
    try {
      final body = <String, dynamic>{};
      if (consent != null) body['consent'] = consent;
      if (targetRole != null) body['targetRole'] = targetRole;
      final response = await _dio.put('/coach/settings', data: body);
      return CoachSettings.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<CoachAnswer> ask(
      {String? question, String? intent, String? jobId}) async {
    try {
      final body = <String, dynamic>{};
      if (intent != null) {
        body['intent'] = intent;
      } else {
        body['question'] = question;
      }
      if (jobId != null) body['jobId'] = jobId;
      final response = await _dio.post('/coach/ask', data: body);
      return CoachAnswer.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }
}
