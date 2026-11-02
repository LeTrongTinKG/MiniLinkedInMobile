/// Cấu hình toàn cục của ứng dụng.
/// Mặc định khi debug local sẽ kết nối tới backend máy chủ: http://localhost:5000/api/v1
/// Khi build production hoặc chỉ định: flutter run --dart-define=API_URL=https://minilinkedinmobile.onrender.com/api/v1
class AppConfig {
  AppConfig._(); // Không cho khởi tạo

  /// Base URL động của Backend API
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    // Mặc định kết nối tới máy chủ Render của dự án (dùng khi trình bày):
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

  // Cấu hình GitHub OAuth
  // Mặc định lấy theo Client ID đã cấu hình trong .env: Ov23liVnRc4PYkJuD1Pz
  // Có thể ghi đè qua: flutter run --dart-define=GITHUB_CLIENT_ID=...
  static const String githubClientId = String.fromEnvironment(
    'GITHUB_CLIENT_ID',
    defaultValue: 'Ov23liVnRc4PYkJuD1Pz',
  );

  static const String githubRedirectUri = String.fromEnvironment(
    'GITHUB_REDIRECT_URI',
    defaultValue: 'minilinkedin://oauth-callback',
  );
}
