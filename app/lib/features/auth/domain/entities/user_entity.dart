/// Domain entity thuần túy — không phụ thuộc vào bất kỳ framework hay package nào.
/// Đây là trung tâm của Clean Architecture: business rules nằm ở đây.
class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'student' | 'recruiter'
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  /// Kiểm tra nhanh xem user có phải student không
  bool get isStudent => role == 'student';

  /// Kiểm tra nhanh xem user có phải recruiter không
  bool get isRecruiter => role == 'recruiter';

  /// Tên hiển thị: ưu tiên fullName, fallback về email prefix
  String get displayName =>
      fullName.isNotEmpty ? fullName : email.split('@').first;

  @override
  String toString() => 'UserEntity(id: $id, email: $email, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}

