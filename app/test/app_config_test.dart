import 'package:app/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('địa chỉ API mặc định là server Render (dùng khi trình bày), không phải localhost', () {
    // Chạy test không truyền --dart-define=API_URL nên lấy giá trị mặc định
    expect(AppConfig.baseUrl, 'https://minilinkedinmobile.onrender.com/api/v1');
  });

  test('đã có Google Client ID mặc định cho web', () {
    expect(AppConfig.googleClientId, endsWith('.apps.googleusercontent.com'));
  });
}
