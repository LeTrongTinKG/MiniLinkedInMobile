import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../error/app_exception.dart';
import '../storage/secure_storage.dart';

/// Dio HTTP Client được cấu hình sẵn:
/// - Base URL, timeouts
/// - Interceptor tự động đính accessToken vào header
/// - Interceptor tự động refresh token khi nhận 401
class DioClient {
  final Dio _dio;
  final ITokenStorage _tokenStorage;

  DioClient._(this._dio, this._tokenStorage);

  /// Factory constructor: tạo và cấu hình Dio instance
  factory DioClient.create(ITokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeoutMs),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final client = DioClient._(dio, tokenStorage);
    dio.interceptors.add(client._buildAuthInterceptor(dio));
    return client;
  }

  Dio get dio => _dio;

  /// Interceptor xử lý:
  /// 1. Đính accessToken vào mọi request
  /// 2. Khi nhận 401 → thử refresh token → retry request gốc
  InterceptorsWrapper _buildAuthInterceptor(Dio dio) {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Bỏ qua endpoint auth (login, register, refresh)
        if (_isAuthEndpoint(options.path)) {
          return handler.next(options);
        }
        final accessToken = await _tokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },

      onError: (error, handler) async {
        // Nếu 401 và không phải endpoint auth → thử refresh
        if (error.response?.statusCode == 401 &&
            !_isAuthEndpoint(error.requestOptions.path)) {
          try {
            final newAccessToken = await _refreshAccessToken(dio);
            // Retry request gốc với token mới
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final response = await dio.fetch(retryOptions);
            return handler.resolve(response);
          } catch (_) {
            // Refresh thất bại → xóa token → ném UnauthorizedException
            await _tokenStorage.clearTokens();
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: const UnauthorizedException(),
              ),
            );
          }
        }
        handler.next(error);
      },
    );
  }

  /// Gọi POST /auth/refresh để lấy accessToken mới
  Future<String> _refreshAccessToken(Dio dio) async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) throw const UnauthorizedException();

    // Tạo Dio mới (không có interceptor) để tránh vòng lặp vô hạn
    final refreshDio = Dio(
      BaseOptions(baseUrl: AppConfig.baseUrl),
    );
    final response = await refreshDio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final data = response.data['data'];
    final newAccessToken = data['accessToken'] as String;
    final newRefreshToken = data['refreshToken'] as String;

    // Lưu cặp token mới
    await _tokenStorage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );

    return newAccessToken;
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/google');
  }

  /// Chuyển DioException thành AppException để Presentation layer xử lý
  static AppException handleDioError(DioException e) {
    if (e.error is AppException) return e.error as AppException;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final body = e.response?.data;
        final errorCode = body?['errorCode'] as String? ?? 'UNKNOWN_ERROR';
        final message = body?['message'] as String? ?? 'Đã có lỗi xảy ra';
        if (statusCode == 401) {
          return UnauthorizedException(message: message);
        }
        return ApiException(
          statusCode: statusCode,
          errorCode: errorCode,
          message: message,
        );
      default:
        return const UnknownException();
    }
  }
}

