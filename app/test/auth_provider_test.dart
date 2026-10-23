import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/error/app_exception.dart';
import 'package:app/core/services/google_auth_service.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  UserEntity? mockUser;
  bool shouldThrow = false;
  AppException? exceptionToThrow;

  @override
  Future<UserEntity> login(String email, String password) async {
    if (shouldThrow) {
      throw exceptionToThrow ??
          const ApiException(
            statusCode: 400,
            errorCode: 'LOGIN_FAILED',
            message: 'Login failed',
          );
    }
    return mockUser!;
  }

  @override
  Future<UserEntity> register(String email, String password, String fullName) async {
    if (shouldThrow) {
      throw exceptionToThrow ??
          const ApiException(
            statusCode: 400,
            errorCode: 'REGISTER_FAILED',
            message: 'Register failed',
          );
    }
    return mockUser!;
  }

  @override
  Future<UserEntity> getMe() async {
    if (shouldThrow) {
      throw exceptionToThrow ??
          const ApiException(
            statusCode: 401,
            errorCode: 'UNAUTHORIZED',
            message: 'Unauthorized',
          );
    }
    return mockUser!;
  }

  @override
  Future<UserEntity> googleLogin(String idToken) async {
    if (shouldThrow) {
      throw exceptionToThrow ??
          const ApiException(
            statusCode: 401,
            errorCode: 'INVALID_GOOGLE_TOKEN',
            message: 'Google token invalid',
          );
    }
    return mockUser!;
  }

  @override
  Future<void> logout() async {}
}

class FakeGoogleAuthService implements IGoogleAuthService {
  String? mockToken = 'mock-id-token-xyz';
  bool shouldThrow = false;
  bool signOutCalled = false;
  AppException? exceptionToThrow;

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getIdToken() async {
    if (shouldThrow) {
      throw exceptionToThrow ??
          const ApiException(
            statusCode: 400,
            errorCode: 'GOOGLE_SIGN_IN_FAILED',
            message: 'Sign in failed',
          );
    }
    return mockToken;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

void main() {
  group('AuthProvider Google Authentication Tests', () {
    late FakeAuthRepository fakeRepo;
    late FakeGoogleAuthService fakeGoogleService;
    late AuthProvider provider;

    final testUser = UserEntity(
      id: 'google-user-1',
      email: 'student@gmail.com',
      fullName: 'Google Student',
      role: 'student',
      avatarUrl: 'https://lh3.googleusercontent.com/avatar',
      createdAt: DateTime.now(),
    );

    setUp(() {
      fakeRepo = FakeAuthRepository()..mockUser = testUser;
      fakeGoogleService = FakeGoogleAuthService();

      provider = AuthProvider(
        loginUseCase: LoginUseCase(fakeRepo),
        registerUseCase: RegisterUseCase(fakeRepo),
        getMeUseCase: GetMeUseCase(fakeRepo),
        googleLoginUseCase: GoogleLoginUseCase(fakeRepo),
        logoutUseCase: LogoutUseCase(fakeRepo),
        googleAuthService: fakeGoogleService,
      );
    });

    test('signInWithGoogle succeeds and updates state to authenticated', () async {
      expect(provider.status, AuthStatus.initial);

      await provider.signInWithGoogle();

      expect(provider.status, AuthStatus.authenticated);
      expect(provider.currentUser?.email, 'student@gmail.com');
      expect(provider.currentUser?.isStudent, true);
      expect(provider.errorMessage, isNull);
    });

    test('signInWithGoogle handles user cancellation gracefully', () async {
      // User cancels / closes Google dialog -> getIdToken returns null
      fakeGoogleService.mockToken = null;

      await provider.signInWithGoogle();

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('signInWithGoogle handles Google SDK errors', () async {
      fakeGoogleService.shouldThrow = true;
      fakeGoogleService.exceptionToThrow = const ApiException(
        statusCode: 400,
        errorCode: 'GOOGLE_SIGN_IN_FAILED',
        message: 'Lỗi xác thực Google',
      );

      await provider.signInWithGoogle();

      expect(provider.status, AuthStatus.error);
      expect(provider.errorMessage, 'Lỗi xác thực Google');
      expect(provider.currentUser, isNull);
    });

    test('signInWithGoogle handles server validation errors', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.exceptionToThrow = const ApiException(
        statusCode: 401,
        errorCode: 'GOOGLE_EMAIL_UNVERIFIED',
        message: 'Tài khoản Google cần có email đã được xác thực',
      );

      await provider.signInWithGoogle();

      expect(provider.status, AuthStatus.error);
      expect(provider.errorMessage, 'Tài khoản Google cần có email đã được xác thực');
      expect(provider.currentUser, isNull);
    });

    test('logout clears user state and triggers Google signOut', () async {
      // Đầu tiên đăng nhập thành công
      await provider.signInWithGoogle();
      expect(provider.isAuthenticated, true);

      // Thực hiện đăng xuất
      await provider.logout();

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.currentUser, isNull);
      expect(fakeGoogleService.signOutCalled, true);
    });
  });
}
