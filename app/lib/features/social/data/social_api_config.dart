import '../../../core/config/app_config.dart';

/// API social nằm ở /api/social (KHÔNG có v1), còn AppConfig.baseUrl kết thúc bằng /api/v1.
/// Ở đây đổi đuôi, vẫn tôn trọng --dart-define=API_URL.
String get socialBaseUrl {
  const v1 = '/api/v1';
  final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
  if (base.endsWith(v1)) {
    return '${base.substring(0, base.length - v1.length)}/api/social';
  }
  return '$base/api/social'; // API_URL không có đuôi /api/v1 thì nối thêm
}

/// Ghép URL tuyệt đối. Dio thấy URL bắt đầu bằng http thì bỏ qua baseUrl,
/// nhưng vẫn chạy interceptor gắn token của dioClient.
String socialUrl(String path) => '$socialBaseUrl$path';
