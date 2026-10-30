import 'dart:async';
import 'package:app/core/error/app_exception.dart';
import 'package:app/core/services/google_auth_service.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/widgets/google_web_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Repository giả: ghi lại idToken được gửi lên "server" và có thể giả lỗi
class _FakeAuthRepo implements AuthRepository {
  String? lastIdToken;
  bool reject = false;
  final user = UserEntity(
    id: 'u1',
    email: 'sv@gmail.com',
    fullName: 'Sinh Vien',
    role: 'student',
    avatarUrl: null,
    createdAt: DateTime(2026, 1, 1),
  );

  @override
  Future<UserEntity> githubLogin(String code) async => user;
  @override
  Future<UserEntity> googleLogin(String idToken) async {
    lastIdToken = idToken;
    if (reject) {
      throw const ApiException(
          statusCode: 401, errorCode: 'INVALID_GOOGLE_TOKEN', message: 'Google idToken không hợp lệ');
    }
    return user;
  }

  @override
  Future<UserEntity> login(String email, String password) async => user;
  @override
  Future<UserEntity> register(String email, String password, String fullName) async => user;
  @override
  Future<UserEntity> getMe() async => user;
  @override
  Future<void> logout() async {}
}

// Dịch vụ Google giả: đếm số lần khởi tạo SDK
class _FakeGoogle implements IGoogleAuthService {
  int initializeCount = 0;
  @override
  Future<void> initialize() async => initializeCount++;
  @override
  Future<String?> getIdToken() async => null;
  @override
  Future<void> signOut() async {}
}

void main() {
  late _FakeAuthRepo repo;
  late _FakeGoogle google;
  late AuthProvider auth;
  late StreamController<String> tokens;

  setUp(() {
    repo = _FakeAuthRepo();
    google = _FakeGoogle();
    tokens = StreamController<String>();
    auth = AuthProvider(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      getMeUseCase: GetMeUseCase(repo),
      googleLoginUseCase: GoogleLoginUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      googleAuthService: google,
    );
  });

  // Không `await` close(): nếu không ai đang nghe luồng thì Future của close() không bao giờ xong
  tearDown(() {
    tokens.close();
  });

  Future<void> open(WidgetTester t, {bool configured = true, VoidCallback? onSuccess}) async {
    await t.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp(
        home: Scaffold(
          body: GoogleWebSignIn(tokens: tokens.stream, clientIdConfigured: configured, onSuccess: onSuccess),
        ),
      ),
    ));
    await t.pump(); // chờ khởi tạo SDK xong
  }

  testWidgets('nhận idToken từ Google thì gửi lên server, đăng nhập xong gọi onSuccess', (t) async {
    var success = 0;
    await open(t, onSuccess: () => success++);
    expect(google.initializeCount, 1);
    expect(repo.lastIdToken, isNull); // chưa có token thì chưa gọi server

    tokens.add('id-token-abc');
    await t.pump();
    await t.pump();

    expect(repo.lastIdToken, 'id-token-abc');
    expect(auth.isAuthenticated, isTrue);
    expect(success, 1);
  });

  testWidgets('server từ chối idToken thì không báo thành công', (t) async {
    repo.reject = true;
    var success = 0;
    await open(t, onSuccess: () => success++);

    tokens.add('id-token-gia');
    await t.pump();
    await t.pump();

    expect(auth.isAuthenticated, isFalse);
    expect(auth.errorMessage, 'Google idToken không hợp lệ');
    expect(success, 0);
  });

  testWidgets('chưa truyền GOOGLE_CLIENT_ID thì báo rõ và không khởi tạo SDK', (t) async {
    await open(t, configured: false);
    expect(find.textContaining('GOOGLE_CLIENT_ID'), findsOneWidget);
    expect(google.initializeCount, 0);
  });
}
