import 'package:flutter/foundation.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Trạng thái của luồng xác thực
enum AuthStatus {
  /// Khởi tạo ban đầu (chưa kiểm tra)
  initial,

  /// Đang xử lý (loading)
  loading,

  /// Đã xác thực thành công
  authenticated,

  /// Chưa xác thực (chưa đăng nhập hoặc token hết hạn)
  unauthenticated,

  /// Có lỗi xảy ra
  error,
}

/// AuthProvider quản lý toàn bộ trạng thái xác thực.
/// Presentation layer lắng nghe qua [Consumer<AuthProvider>].
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetMeUseCase _getMeUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final LogoutUseCase _logoutUseCase;
  final IGoogleAuthService? _googleAuthService;

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;
  AppException? _lastException;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GetMeUseCase getMeUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
    required LogoutUseCase logoutUseCase,
    IGoogleAuthService? googleAuthService,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _getMeUseCase = getMeUseCase,
        _googleLoginUseCase = googleLoginUseCase,
        _logoutUseCase = logoutUseCase,
        _googleAuthService = googleAuthService;

  // --- Getters ---
  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  AppException? get lastException => _lastException;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get isRecruiter => _currentUser?.isRecruiter ?? false;
  bool get isNetworkError => _lastException is NetworkException;

  /// Kiểm tra xác thực khi mở app: gọi GET /auth/me
  /// Tách biệt rõ ràng:
  /// - UnauthorizedException (401 / hết token): chuyển unauthenticated → về màn login
  /// - NetworkException (mất mạng / không kết nối server): giữ trạng thái error → KHÔNG kick ra login
  Future<void> checkAuth() async {
    _setLoading();
    try {
      _currentUser = await _getMeUseCase();
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _lastException = null;
    } on UnauthorizedException catch (e) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _errorMessage = null;
      _lastException = e;
    } on NetworkException catch (e) {
      // Lỗi kết nối mạng: không coi là unauthenticated, tránh bị kick ra login khi F5/mở lại app
      _status = AuthStatus.error;
      _errorMessage = e.message;
      _lastException = e;
    } on AppException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      _lastException = e;
    } finally {
      notifyListeners();
    }
  }

  /// Đăng nhập bằng email/password
  Future<void> login(String email, String password) async {
    _setLoading();
    try {
      _currentUser = await _loginUseCase(email, password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _lastException = null;
    } on AppException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      _lastException = e;
    } finally {
      notifyListeners();
    }
  }

  /// Đăng ký tài khoản mới
  Future<void> register(String email, String password, String fullName) async {
    _setLoading();
    try {
      _currentUser = await _registerUseCase(email, password, fullName);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _lastException = null;
    } on AppException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      _lastException = e;
    } finally {
      notifyListeners();
    }
  }

  /// Đăng nhập / Đăng ký trực tiếp với Google ID Token
  Future<void> googleLogin(String idToken) async {
    _setLoading();
    try {
      _currentUser = await _googleLoginUseCase(idToken);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _lastException = null;
    } on AppException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      _lastException = e;
    } finally {
      notifyListeners();
    }
  }

  /// Khởi tạo Google SDK (nút Google chính thức trên web cần làm việc này trước khi hiện).
  /// Gọi nhiều lần vẫn an toàn vì service chỉ khởi tạo một lần.
  Future<void> prepareGoogleSignIn() async {
    await _googleAuthService?.initialize();
  }

  /// Kích hoạt luồng đăng nhập / đăng ký qua Google SDK
  Future<void> signInWithGoogle() async {
    if (_googleAuthService == null) {
      _status = AuthStatus.error;
      _errorMessage = 'Dịch vụ Google Sign-In chưa được khởi tạo';
      notifyListeners();
      return;
    }

    _setLoading();
    try {
      final idToken = await _googleAuthService.getIdToken();
      if (idToken == null) {
        // Người dùng đã hủy hoặc đóng pop-up Google
        _status = AuthStatus.unauthenticated;
        _errorMessage = null;
        _lastException = null;
        notifyListeners();
        return;
      }

      _currentUser = await _googleLoginUseCase(idToken);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _lastException = null;
    } on AppException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      _lastException = e;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Đăng nhập Google thất bại: $e';
      _lastException = null;
    } finally {
      notifyListeners();
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _setLoading();
    try {
      await _logoutUseCase();
      await _googleAuthService?.signOut();
    } catch (_) {
      // Bỏ qua lỗi, vẫn đăng xuất phía client
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _lastException = null;
      notifyListeners();
    }
  }

  /// Xóa thông báo lỗi (gọi khi user bắt đầu nhập lại)
  void clearError() {
    if (_errorMessage != null || _lastException != null) {
      _errorMessage = null;
      _lastException = null;
      notifyListeners();
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _lastException = null;
    notifyListeners();
  }
}
