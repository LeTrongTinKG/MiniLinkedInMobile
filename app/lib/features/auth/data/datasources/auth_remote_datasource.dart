import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Datasource: giao tiếp trực tiếp với REST API.
/// Single Responsibility: chỉ lo gọi HTTP, parse response thô.
class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  /// POST /auth/login → trả về {user, accessToken, refreshToken}
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  /// POST /auth/register → trả về {user, accessToken, refreshToken}
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': 'student', // Mặc định student
        },
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  /// GET /auth/me → trả về {user}
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      final data = _extractData(response);
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  /// POST /auth/google → trả về {user, accessToken, refreshToken}
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  /// POST /auth/github → trả về {user, accessToken, refreshToken, isNewUser}
  Future<Map<String, dynamic>> githubLogin(String code) async {
    try {
      final response = await _dio.post(
        '/auth/github',
        data: {'code': code},
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  /// POST /auth/logout
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  /// Trích xuất trường [data] từ response body chuẩn của server
  Map<String, dynamic> _extractData(Response response) {
    return response.data['data'] as Map<String, dynamic>;
  }
}
