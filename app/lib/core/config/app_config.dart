/// Cấu hình toàn cục của ứng dụng.
/// Thay đổi [baseUrl] khi deploy hoặc dùng emulator Android:
///   - Web / iOS Simulator: http://localhost:3000
///   - Android Emulator:    http://10.0.2.2:3000
///   - Production:          https://api.yourserver.com
class AppConfig {
  AppConfig._(); // Không cho khởi tạo

  static const String baseUrl = 'http://localhost:5000/api/v1';

  // Timeout kết nối (milliseconds)
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Tên key lưu token trong SecureStorage
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
}

