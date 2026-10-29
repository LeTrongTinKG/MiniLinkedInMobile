

/// Cấu hình toàn cục của ứng dụng.
/// Mặc định kết nối backend Render: https://minilinkedinmobile.onrender.com/api/v1
/// Đổi máy chủ: flutter run --dart-define=API_URL=http://localhost:5000/api/v1
class AppConfig {
  AppConfig._(); // Không cho khởi tạo

  /// Base URL động của Backend API
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    // Mặc định kết nối tới máy chủ Render của dự án (dùng khi trình bày).
    // Chạy với server trên máy mình thì truyền --dart-define=API_URL=http://localhost:5000/api/v1
    return 'https://minilinkedinmobile.onrender.com/api/v1';
  }

  // Timeout kết nối (milliseconds)
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Tên key lưu token trong SecureStorage
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';

  // Tên key lưu trạng thái UI (tab, bộ lọc tìm kiếm)
  static const String keySelectedTab = 'selected_tab_index';
  static const String keyJobFilter = 'saved_job_filter';

  // Client ID cho Google Sign-In (truyền qua cờ: flutter run --dart-define=GOOGLE_CLIENT_ID=...)
  // Trên Web: Cần Client ID dạng Web OAuth Client
  // Trên Android / iOS: Cần Server Client ID (Web Client ID) để backend verify được idToken
  static const String googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '380900817945-h1iooij3jlk7cakj6br9ok0g99o5jpvi.apps.googleusercontent.com');
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '380900817945-h1iooij3jlk7cakj6br9ok0g99o5jpvi.apps.googleusercontent.com');
}
