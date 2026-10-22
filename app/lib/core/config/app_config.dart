
/// Cấu hình toàn cục của ứng dụng.
/// Tự động thích ứng theo nền tảng thực thi:
///   - Mặc định: backend Render (https://minilinkedinmobile.onrender.com/api/v1)
///   - Server local: --dart-define=API_URL=http://localhost:5000/api/v1 (Android Emulator: 10.0.2.2)
///   - Tùy chỉnh qua cờ: flutter run --dart-define=API_URL=https://your-api.com/api/v1
class AppConfig {
  AppConfig._(); // Không cho khởi tạo

  /// Base URL động tự động nhận diện thiết bị
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    // Mặc định trỏ về backend đã deploy trên Render.
    // Chạy server local: --dart-define=API_URL=http://localhost:5000/api/v1
    // (Android Emulator dùng http://10.0.2.2:5000/api/v1)
    return 'https://minilinkedinmobile.onrender.com/api/v1';
  }

  // Timeout kết nối (milliseconds). Render free tier khởi động nguội mất ~30-50s.
  static const int connectTimeoutMs = 60000;
  static const int receiveTimeoutMs = 60000;

  // Tên key lưu token trong SecureStorage
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';

  // Tên key lưu trạng thái UI (tab, bộ lọc tìm kiếm)
  static const String keySelectedTab = 'selected_tab_index';
  static const String keyJobFilter = 'saved_job_filter';
}
