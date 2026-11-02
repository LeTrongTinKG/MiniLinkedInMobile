import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/auth/data/models/user_model.dart';

void main() {
  group('UserEntity & UserModel Tests', () {
    test('UserEntity should correctly identify student and recruiter', () {
      final student = UserEntity(
        id: '1',
        email: 'student@example.com',
        fullName: 'Nguyen Van A',
        role: 'student',
        createdAt: DateTime.now(),
      );

      final recruiter = UserEntity(
        id: '2',
        email: 'recruiter@example.com',
        fullName: 'Tran Van B',
        role: 'recruiter',
        createdAt: DateTime.now(),
      );

      expect(student.isStudent, true);
      expect(student.isRecruiter, false);
      expect(student.displayName, 'Nguyen Van A');

      expect(recruiter.isStudent, false);
      expect(recruiter.isRecruiter, true);
      expect(recruiter.displayName, 'Tran Van B');
    });

    test('UserModel.fromJson converts accurately to UserEntity', () {
      final json = {
        'id': 'uuid-123',
        'email': 'test@gmail.com',
        'fullName': 'Test User',
        'role': 'student',
        'avatarUrl': 'https://example.com/avatar.png',
        'createdAt': '2026-10-19T00:00:00.000Z',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.id, 'uuid-123');
      expect(entity.email, 'test@gmail.com');
      expect(entity.fullName, 'Test User');
      expect(entity.role, 'student');
      expect(entity.avatarUrl, 'https://example.com/avatar.png');
      expect(entity.isStudent, true);
    });
  });
}
