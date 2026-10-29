import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import '../config/app_config.dart';
import '../error/app_exception.dart';

/// Interface định nghĩa tương tác với dịch vụ GitHub OAuth (Dependency Inversion Principle - DIP).
abstract interface class IGitHubAuthService {
  /// Kích hoạt luồng ủy quyền trình duyệt và lấy authorization code
  Future<String?> getAuthorizationCode();

  /// Tạo đường dẫn URL đăng nhập GitHub
  Uri buildAuthorizeUri();

  /// Đăng xuất / thu hồi phiên
  Future<void> signOut();
}

/// Triển khai dịch vụ xác thực GitHub OAuth 2.0 đa nền tảng (Web, Desktop, Mobile).
/// Tuân thủ Single Responsibility: Quản lý việc mở trình duyệt và lấy authorization_code.
class GitHubAuthService implements IGitHubAuthService {
  final FlutterAppAuth _appAuth;

  GitHubAuthService({FlutterAppAuth? appAuth})
      : _appAuth = appAuth ?? const FlutterAppAuth();

  @override
  Uri buildAuthorizeUri() {
    final clientId = AppConfig.githubClientId;
    final Map<String, String> queryParams = {
      'client_id': clientId,
      'scope': 'read:user user:email',
    };

    // Nếu trên web và có redirect_uri tùy chỉnh không phải custom scheme
    if (kIsWeb) {
      if (AppConfig.githubRedirectUri.isNotEmpty &&
          !AppConfig.githubRedirectUri.startsWith('minilinkedin://')) {
        queryParams['redirect_uri'] = AppConfig.githubRedirectUri;
      }
    } else {
      if (AppConfig.githubRedirectUri.isNotEmpty) {
        queryParams['redirect_uri'] = AppConfig.githubRedirectUri;
      }
    }

    return Uri.https('github.com', '/login/oauth/authorize', queryParams);
  }

  @override
  Future<String?> getAuthorizationCode() async {
    final clientId = AppConfig.githubClientId;
    if (clientId.isEmpty) {
      throw const ApiException(
        statusCode: 400,
        errorCode: 'CONFIG_ERROR',
        message:
            'GITHUB_CLIENT_ID chưa được cung cấp. Vui lòng kiểm tra file .env hoặc AppConfig',
      );
    }

    // flutter_appauth chỉ hoàn tất callback OAuth trên mobile.
    // Web/Desktop hiện chưa có callback receiver nên không được coi là đăng nhập thành công.
    if (kIsWeb) {
      throw const ApiException(
        statusCode: 501,
        errorCode: 'GITHUB_PLATFORM_UNSUPPORTED',
        message:
            'Đăng nhập GitHub trên Web chưa được cấu hình callback. Hãy chạy app trên Android/iOS hoặc cấu hình GITHUB_REDIRECT_URI cho Web.',
      );
    }

    // Windows/Linux cũng không có deep-link receiver trong cấu hình hiện tại.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      throw const ApiException(
        statusCode: 501,
        errorCode: 'GITHUB_PLATFORM_UNSUPPORTED',
        message:
            'Đăng nhập GitHub trên Windows/Linux chưa được cấu hình callback. Hãy chạy app trên Android/iOS.',
      );
    }

    // Android/iOS/macOS: flutter_appauth nhận callback qua custom URL scheme.
    return _authorizeMobile(clientId);
  }

  /// Xử lý xác thực trên Mobile bằng flutter_appauth
  Future<String?> _authorizeMobile(String clientId) async {
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
      debugPrint('GitHubAuthService mobile authorization error: $e');
      throw ApiException(
        statusCode: 400,
        errorCode: 'GITHUB_AUTH_FAILED',
        message: 'Lỗi xác thực GitHub trên thiết bị: $e',
      );
    }
  }

  @override
  Future<void> signOut() async {
    // GitHub OAuth Authorization Code flow không yêu cầu revoke cục bộ
  }
}
