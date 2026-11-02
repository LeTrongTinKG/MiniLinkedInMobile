import '../../domain/entities/user_entity.dart';

/// Data Transfer Object cho User từ API.
/// Chịu trách nhiệm parse JSON → UserEntity.
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Chuyển sang Domain Entity (tách biệt tầng Data và Domain)
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        fullName: fullName,
        role: role,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
      );
}

