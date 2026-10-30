import 'package:app/core/services/google_auth_service.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:app/features/auth/presentation/widgets/google_web_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthRepo implements AuthRepository {
  final user = UserEntity(
    id: 'u1',
    email: 'sv@gmail.com',
    fullName: 'Sinh Vien',
    role: 'student',
    avatarUrl: null,
    createdAt: DateTime(2026, 1, 1),
  );
  @override
  Future<UserEntity> login(String email, String password) async => user;
  @override
  Future<UserEntity> register(String email, String password, String fullName) async => user;
  @override
  Future<UserEntity> getMe() async => user;
  @override
  Future<UserEntity> githubLogin(String code) async => user;
  @override
  Future<UserEntity> googleLogin(String idToken) async => user;
  @override
  Future<void> logout() async {}
}

// Dịch vụ Google giả: ghi lại việc có bị gọi mở hộp đăng nhập hay không
class _FakeGoogle implements IGoogleAuthService {
  int getIdTokenCalls = 0;
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> getIdToken() async {
    getIdTokenCalls++;
    return null;
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  late _FakeGoogle google;
  late AuthProvider auth;

  setUp(() {
    final repo = _FakeAuthRepo();
    google = _FakeGoogle();
    auth = AuthProvider(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      getMeUseCase: GetMeUseCase(repo),
      googleLoginUseCase: GoogleLoginUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      googleAuthService: google,
    );
  });

  Future<void> open(WidgetTester t, {required bool web, required bool configured}) async {
    await t.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp(
        home: Scaffold(body: GoogleSignInButton(isWeb: web, clientIdConfigured: configured)),
      ),
    ));
    await t.pump();
  }

  testWidgets('web nhưng thiếu GOOGLE_CLIENT_ID: nút VẪN hiện, bấm thì báo cách cấu hình', (t) async {
    await open(t, web: true, configured: false);
    expect(find.text('Tiếp tục với Google'), findsOneWidget); // nút luôn thấy được

    await t.tap(find.text('Tiếp tục với Google'));
    await t.pump();

    expect(find.textContaining('GOOGLE_CLIENT_ID'), findsOneWidget); // thông báo nêu rõ thiếu gì
    expect(google.getIdTokenCalls, 0); // không gọi Google (trên web sẽ lỗi)
  });

  testWidgets('web và đã có GOOGLE_CLIENT_ID: dùng nút chính thức của Google', (t) async {
    await open(t, web: true, configured: true);
    expect(find.byType(GoogleWebSignIn), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsNothing); // nút tự vẽ được thay bằng nút của Google
  });

  testWidgets('Android/iOS: giữ nguyên nút cũ, bấm là mở hộp đăng nhập Google', (t) async {
    await open(t, web: false, configured: false);
    expect(find.byType(GoogleWebSignIn), findsNothing);

    await t.tap(find.text('Tiếp tục với Google'));
    await t.pump();

    expect(google.getIdTokenCalls, 1);
  });
}
