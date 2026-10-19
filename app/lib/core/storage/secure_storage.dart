import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Interface định nghĩa hợp đồng lưu/đọc token (Dependency Inversion Principle).
/// Presentation layer chỉ phụ thuộc vào interface này, không phụ thuộc
/// trực tiếp vào FlutterSecureStorage.
abstract interface class ITokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

/// Triển khai cụ thể dùng flutter_secure_storage.
/// Token được mã hóa AES trên Android và Keychain trên iOS.
class SecureTokenStorage implements ITokenStorage {
  final FlutterSecureStorage _storage;

  const SecureTokenStorage(this._storage);

  /// Factory constructor với cấu hình mặc định
  factory SecureTokenStorage.defaultStorage() {
    const storage = FlutterSecureStorage();
    return SecureTokenStorage(storage);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConfig.keyAccessToken, value: accessToken),
      _storage.write(key: AppConfig.keyRefreshToken, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() =>
      _storage.read(key: AppConfig.keyAccessToken);

  @override
  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConfig.keyRefreshToken);

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConfig.keyAccessToken),
      _storage.delete(key: AppConfig.keyRefreshToken),
    ]);
  }
}

