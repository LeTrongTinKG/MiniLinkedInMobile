import '../entities/user_entity.dart';

/// Abstract interface của Auth Repository — Dependency Inversion Principle.
/// Domain layer định nghĩa interface, Data layer cài đặt.
/// Provider/UseCase chỉ phụ thuộc vào interface này.
abstract interface class AuthRepository {
  /// Đăng nhập bằng email và mật khẩu
  Future<UserEntity> login(String email, String password);

  /// Đăng ký tài khoản mới (role mặc định: student)
  Future<UserEntity> register(String email, String password, String fullName);

  /// Lấy thông tin user hiện tại (dùng accessToken đang lưu)
  Future<UserEntity> getMe();

  /// Đăng nhập bằng Google idToken
  Future<UserEntity> googleLogin(String idToken);

  /// Đăng nhập bằng GitHub authorization code
  Future<UserEntity> githubLogin(String code);

  /// Đăng xuất (xóa refreshToken trên server + xóa token local)
  Future<void> logout();
}
