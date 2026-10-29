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

/// Chọn tham số khởi tạo Google SDK theo nền tảng (tách thành hàm riêng để test được).
/// - Web: CHỈ truyền `clientId`. Tuyệt đối không truyền `serverClientId`, vì thư viện web
///   từ chối ("serverClientId is not supported on Web"), SDK không khởi tạo xong và nút Google
///   kẹt mãi ở chữ "Getting ready".
/// - Android/iOS: không cần `clientId`; `serverClientId` dùng để lấy idToken cho server kiểm tra
///   (mặc định lấy cùng Web client ID nếu không truyền riêng).
({String? clientId, String? serverClientId}) googleInitParams({
  required bool isWeb,
  required String clientId,
  required String serverClientId,
}) {
  if (isWeb) {
    return (clientId: clientId.isNotEmpty ? clientId : null, serverClientId: null);
  }
  final server = serverClientId.isNotEmpty
      ? serverClientId
      : (clientId.isNotEmpty ? clientId : null);
  return (clientId: null, serverClientId: server);
}

/// Triển khai dịch vụ Google Sign-In sử dụng package google_sign_in (v7.x)
class GoogleAuthService implements IGoogleAuthService {
  final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  // Lời hứa "đang khởi tạo". Nhiều nơi gọi initialize() cùng lúc (khởi động app, nút Google...)
  // thì đều chờ CHUNG một lần khởi tạo, không gọi SDK hai lần (web sẽ báo lỗi nếu gọi hai lần).
  Future<void>? _initFuture;

  @override
  Future<void> initialize() => _initFuture ??= _initOnce();

  Future<void> _initOnce() async {
    try {
      final params = googleInitParams(
        isWeb: kIsWeb,
        clientId: AppConfig.googleClientId,
        serverClientId: AppConfig.googleServerClientId,
      );

      await _googleSignIn.initialize(
        clientId: params.clientId,
        serverClientId: params.serverClientId,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('GoogleSignIn initialize warning: $e');
      _initFuture = null; // lỗi thì cho phép thử lại lần sau
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
