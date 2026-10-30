import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../error/app_exception.dart';
import 'github_web_callback.dart';

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

    // Web: GitHub trả người dùng về chính trang web này (vd http://localhost:3000).
    // Địa chỉ này phải trùng "Authorization callback URL" của GitHub OAuth App.
    // Mobile: trả về theo địa chỉ riêng của app (minilinkedin://oauth-callback).
    if (kIsWeb) {
      final origin = currentWebOrigin();
      if (origin != null) queryParams['redirect_uri'] = origin;
      final state = newGithubState();
      if (state != null) queryParams['state'] = state;
    } else if (AppConfig.githubRedirectUri.isNotEmpty) {
      queryParams['redirect_uri'] = AppConfig.githubRedirectUri;
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

    // Web: chuyển cả trang sang GitHub (giống window.location.href = url trong React).
    // Bấm đồng ý xong GitHub đưa về lại trang này kèm ?code=..., màn đăng nhập sẽ lấy mã
    // đó (takeGithubCode) rồi gửi cho server. Ở đây chưa có mã nên trả null.
    if (kIsWeb) {
      await launchUrl(buildAuthorizeUri(), webOnlyWindowName: '_self');
      return null;
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
