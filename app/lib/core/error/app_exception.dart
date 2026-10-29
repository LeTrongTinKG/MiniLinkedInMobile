/// Lớp exception cơ sở cho toàn bộ ứng dụng.
/// Tuân thủ ISP: mỗi loại lỗi là 1 class riêng.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

/// Lỗi từ API server (có statusCode và errorCode)
class ApiException extends AppException {
  final int statusCode;
  final String errorCode;

  // Link ứng tuyển gốc, chỉ có khi server trả lỗi EXTERNAL_JOB_APPLY
  final String? applyUrl;

  const ApiException({
    required this.statusCode,
    required this.errorCode,
    required String message,
    this.applyUrl,
  }) : super(message);

  @override
  String toString() => 'ApiException[$statusCode/$errorCode]: $message';
}

/// Token hết hạn hoặc không hợp lệ → cần đăng nhập lại
class UnauthorizedException extends ApiException {
  // ignore: use_super_parameters
  const UnauthorizedException({String message = 'Phiên đăng nhập đã hết hạn'})
      : super(statusCode: 401, errorCode: 'UNAUTHORIZED', message: message);
}

/// Lỗi mạng (không có internet, timeout...)
class NetworkException extends AppException {
  // ignore: use_super_parameters
  const NetworkException({String message = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.'})
      : super(message);
}

/// Lỗi không xác định
class UnknownException extends AppException {
  // ignore: use_super_parameters
  const UnknownException({String message = 'Đã có lỗi xảy ra. Vui lòng thử lại.'})
      : super(message);
}

