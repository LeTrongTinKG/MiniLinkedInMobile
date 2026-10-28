import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Cài đặt cụ thể của [AuthRepository].
/// Orchestrate giữa [AuthRemoteDataSource] (gọi API)
/// và [ITokenStorage] (lưu/xóa token).
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final ITokenStorage _tokenStorage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required ITokenStorage tokenStorage,
  })  : _dataSource = dataSource,
        _tokenStorage = tokenStorage;

  @override
  Future<UserEntity> login(String email, String password) async {
    final data = await _dataSource.login(email, password);
    await _saveTokensFromData(data);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>).toEntity();
  }

  @override
  Future<UserEntity> register(
      String email, String password, String fullName) async {
    final data = await _dataSource.register(email, password, fullName);
    await _saveTokensFromData(data);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>).toEntity();
  }

  @override
  Future<UserEntity> getMe() async {
    final model = await _dataSource.getMe();
    return model.toEntity();
  }

  @override
  Future<UserEntity> googleLogin(String idToken) async {
    final data = await _dataSource.googleLogin(idToken);
    await _saveTokensFromData(data);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>).toEntity();
  }

  @override
  Future<UserEntity> githubLogin(String code) async {
    final data = await _dataSource.githubLogin(code);
    await _saveTokensFromData(data);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>).toEntity();
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    // Gọi server xóa refreshToken (best-effort, không throw nếu lỗi)
    if (refreshToken != null) {
      try {
        await _dataSource.logout(refreshToken);
      } catch (_) {
        // Bỏ qua lỗi server, vẫn xóa token local
      }
    }
    await _tokenStorage.clearTokens();
  }

  /// Helper: lưu access + refresh token từ response data
  Future<void> _saveTokensFromData(Map<String, dynamic> data) async {
    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}
