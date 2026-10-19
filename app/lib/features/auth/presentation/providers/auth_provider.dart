import 'package:flutter/foundation.dart';
import '../../../../core/error/app_exception.dart';
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

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GetMeUseCase getMeUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _getMeUseCase = getMeUseCase,
        _googleLoginUseCase = googleLoginUseCase,
        _logoutUseCase = logoutUseCase;

  // --- Getters ---
  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get isRecruiter => _currentUser?.isRecruiter ?? false;

  /// Kiểm tra xác thực khi mở app: gọi GET /auth/me
  Future<void> checkAuth() async {
    _setLoading();
    try {
      _currentUser = await _getMeUseCase();
      _status = AuthStatus.authenticated;
    } on UnauthorizedException {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
    } on AppException {
      // Lỗi mạng hoặc khác → coi như chưa xác thực
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
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
    } on AppException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
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
    } on AppException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } finally {
      notifyListeners();
    }
  }

  /// Đăng nhập bằng Google
  Future<void> googleLogin(String idToken) async {
    _setLoading();
    try {
      _currentUser = await _googleLoginUseCase(idToken);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } on AppException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } finally {
      notifyListeners();
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _setLoading();
    try {
      await _logoutUseCase();
    } catch (_) {
      // Bỏ qua lỗi, vẫn đăng xuất phía client
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// Xóa thông báo lỗi (gọi khi user bắt đầu nhập lại)
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}

