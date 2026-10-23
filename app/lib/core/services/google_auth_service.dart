import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_config.dart';
import '../error/app_exception.dart';

/// Interface định nghĩa tương tác với Google Authentication SDK (DIP)
abstract interface class IGoogleAuthService {
  Future<void> initialize();
  Future<String?> getIdToken();
  Future<void> signOut();
}

/// Triển khai dịch vụ Google Sign-In sử dụng package google_sign_in (v7.x)
class GoogleAuthService implements IGoogleAuthService {
  final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final clientId = kIsWeb && AppConfig.googleClientId.isNotEmpty
          ? AppConfig.googleClientId
          : null;

      final serverClientId = AppConfig.googleServerClientId.isNotEmpty
          ? AppConfig.googleServerClientId
          : (AppConfig.googleClientId.isNotEmpty
              ? AppConfig.googleClientId
              : null);

      await _googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('GoogleSignIn initialize warning: $e');
    }
  }

  @override
  Future<String?> getIdToken() async {
    try {
      if (!_initialized) {
        await initialize();
      }

      // 1. Kích hoạt giao diện chọn tài khoản Google (interactive)
      final account = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile', 'openid'],
      );

      // 2. Lấy authentication token từ tài khoản đã chọn
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const ApiException(
          statusCode: 400,
          errorCode: 'NO_ID_TOKEN',
          message:
              'Không nhận được idToken từ Google. Vui lòng kiểm tra lại cấu hình Client ID.',
        );
      }

      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // Người dùng chủ động đóng hộp thoại / hủy đăng nhập
        return null;
      }
      debugPrint('GoogleSignInException: [${e.code}] ${e.description}');
      throw ApiException(
        statusCode: 400,
        errorCode: 'GOOGLE_SIGN_IN_FAILED',
        message: e.description?.isNotEmpty == true
            ? e.description!
            : 'Đăng nhập Google không thành công (${e.code.name}).',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In Exception: $e');
      throw ApiException(
        statusCode: 400,
        errorCode: 'GOOGLE_SIGN_IN_FAILED',
        message: 'Đăng nhập Google không thành công: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
