import 'package:app/core/services/google_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const webId = 'abc123.apps.googleusercontent.com';

  group('googleInitParams: tham số khởi tạo Google SDK', () {
    test('WEB: chỉ truyền clientId, KHÔNG truyền serverClientId (nếu truyền, nút kẹt "Getting ready")', () {
      final p = googleInitParams(isWeb: true, clientId: webId, serverClientId: '');
      expect(p.clientId, webId);
      expect(p.serverClientId, isNull);
    });

    test('WEB: dù có đặt GOOGLE_SERVER_CLIENT_ID riêng vẫn không truyền serverClientId', () {
      final p = googleInitParams(isWeb: true, clientId: webId, serverClientId: 'khac.apps.googleusercontent.com');
      expect(p.serverClientId, isNull);
    });

    test('WEB: chưa có Client ID thì cả hai đều null', () {
      final p = googleInitParams(isWeb: true, clientId: '', serverClientId: '');
      expect(p.clientId, isNull);
      expect(p.serverClientId, isNull);
    });

    test('Android/iOS: không truyền clientId, serverClientId mặc định lấy Web client ID', () {
      final p = googleInitParams(isWeb: false, clientId: webId, serverClientId: '');
      expect(p.clientId, isNull);
      expect(p.serverClientId, webId);
    });

    test('Android/iOS: có GOOGLE_SERVER_CLIENT_ID riêng thì dùng cái đó', () {
      final p = googleInitParams(isWeb: false, clientId: webId, serverClientId: 'rieng.apps.googleusercontent.com');
      expect(p.serverClientId, 'rieng.apps.googleusercontent.com');
    });

    test('Android/iOS: không có ID nào thì cả hai đều null', () {
      final p = googleInitParams(isWeb: false, clientId: '', serverClientId: '');
      expect(p.clientId, isNull);
      expect(p.serverClientId, isNull);
    });
  });
}
