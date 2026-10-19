import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Đăng nhập — Single Responsibility: chỉ lo login.
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<UserEntity> call(String email, String password) =>
      _repository.login(email, password);
}

/// UseCase: Đăng ký — Single Responsibility: chỉ lo register.
class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<UserEntity> call(String email, String password, String fullName) =>
      _repository.register(email, password, fullName);
}

/// UseCase: Lấy thông tin user hiện tại.
class GetMeUseCase {
  final AuthRepository _repository;
  const GetMeUseCase(this._repository);

  Future<UserEntity> call() => _repository.getMe();
}

/// UseCase: Đăng nhập Google.
class GoogleLoginUseCase {
  final AuthRepository _repository;
  const GoogleLoginUseCase(this._repository);

  Future<UserEntity> call(String idToken) => _repository.googleLogin(idToken);
}

/// UseCase: Đăng xuất.
class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

