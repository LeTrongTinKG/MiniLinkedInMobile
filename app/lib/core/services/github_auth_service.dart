import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import '../config/app_config.dart';

/// Interface định nghĩa tương tác với dịch vụ GitHub OAuth (Dependency Inversion Principle - DIP).
abstract interface class IGitHubAuthService {
  /// Kích hoạt luồng ủy quyền trình duyệt và lấy authorization code
  Future<String?> getAuthorizationCode();

  /// Đăng xuất / thu hồi phiên
  Future<void> signOut();
}

/// Triển khai dịch vụ xác thực GitHub OAuth 2.0 bằng `flutter_appauth`.
/// Tuân thủ Single Responsibility: Chỉ quản lý việc mở trình duyệt và lấy authorization_code.
class GitHubAuthService implements IGitHubAuthService {
  final FlutterAppAuth _appAuth;

  GitHubAuthService({FlutterAppAuth? appAuth})
      : _appAuth = appAuth ?? const FlutterAppAuth();

  @override
  Future<String?> getAuthorizationCode() async {
    final clientId = AppConfig.githubClientId;
    if (clientId.isEmpty) {
      debugPrint('Warning: GITHUB_CLIENT_ID chưa được cung cấp qua --dart-define');
    }

    try {
      final AuthorizationResponse? result = await _appAuth.authorize(
        AuthorizationRequest(
          clientId,
          AppConfig.githubRedirectUri,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: 'https://github.com/login/oauth/authorize',
            tokenEndpoint: 'https://github.com/login/oauth/access_token',
          ),
          scopes: const ['read:user', 'user:email'],
        ),
      );

      return result?.authorizationCode;
    } catch (e) {
      debugPrint('GitHubAuthService authorization error: $e');
      // Người dùng hủy ủy quyền hoặc đóng trình duyệt
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    // GitHub OAuth Authorization Code flow không cần revoke cục bộ phía appauth
  }
}
