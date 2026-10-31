import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ConsentRemoteDataSource {
  final Dio _dio;

  ConsentRemoteDataSource(this._dio);

  Future<bool> getConsentStatus() async {
    try {
      final response = await _dio.get('/coach/settings');
      return response.data['data']['ready'] == true ||
          response.data['data']['consent'] == true;
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<void> updateConsent(bool granted) async {
    try {
      await _dio.put(
        '/coach/settings',
        data: {'consent': granted},
      );
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }
}

