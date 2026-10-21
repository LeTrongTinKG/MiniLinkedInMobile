import 'package:flutter/foundation.dart';

/// Cấu hình toàn cục của ứng dụng.
/// Tự động thích ứng theo nền tảng thực thi:
///   - Android Emulator: http://10.0.2.2:5000/api/v1 (trỏ về localhost máy tính host)
///   - Web / iOS Simulator / Desktop: http://localhost:5000/api/v1
///   - Tùy chỉnh qua cờ: flutter run --dart-define=API_URL=https://your-api.com/api/v1
class AppConfig {
  AppConfig._(); // Không cho khởi tạo

  /// Base URL động tự động nhận diện thiết bị
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    // Android Emulator cần địa chỉ 10.0.2.2 để kết nối đến localhost của máy tính chạy server
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1';
    }

    // Mặc định cho Web (Chrome), iOS Simulator, macOS, Windows
    return 'http://localhost:5000/api/v1';
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
      String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');
}
