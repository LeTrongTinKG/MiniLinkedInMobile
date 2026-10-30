import 'package:app/core/services/google_auth_service.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/student_home/widgets/app_header.dart';
import 'package:app/ui_kit/app_avatar.dart';
import 'package:app/ui_kit/app_shad_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Repository giả: đếm số lần gọi đăng xuất
class _FakeAuthRepo implements AuthRepository {
  int logoutCalls = 0;
  final user = UserEntity(
    id: 'u1',
    email: 'sv@gmail.com',
    fullName: 'Nguyen Van A',
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
  Future<void> logout() async => logoutCalls++;
}

class _FakeGoogle implements IGoogleAuthService {
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> getIdToken() async => null;
  @override
  Future<void> signOut() async {}
}

void main() {
  late _FakeAuthRepo repo;
  late AuthProvider auth;

  setUp(() async {
    repo = _FakeAuthRepo();
    auth = AuthProvider(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      getMeUseCase: GetMeUseCase(repo),
      googleLoginUseCase: GoogleLoginUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      googleAuthService: _FakeGoogle(),
    );
    await auth.login('sv@gmail.com', 'matkhau'); // đã đăng nhập sẵn
  });

  // Header trong đúng cấu trúc gốc app, có route '/login' để biết đã chuyển về đăng nhập
  Future<void> openHeader(WidgetTester t) async {
    t.view.physicalSize = const Size(800, 600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(ShadApp.custom(
      theme: buildAppShadTheme(),
      appBuilder: (context) => MaterialApp(
        builder: (context, child) => ShadAppBuilder(child: child!),
        routes: {'/login': (_) => const Scaffold(body: Text('MAN_DANG_NHAP'))},
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: const Scaffold(body: AppHeader(title: 'Mạng xã hội')),
        ),
      ),
    ));
    await t.pumpAndSettle();
  }

  testWidgets('bấm avatar mở menu có tên, email và nút Đăng xuất', (t) async {
    await openHeader(t);
    expect(find.text('Đăng xuất'), findsNothing); // menu chưa mở

    await t.tap(find.byType(AppAvatar));
    await t.pumpAndSettle();

    expect(find.text('Nguyen Van A'), findsOneWidget);
    expect(find.text('sv@gmail.com'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });

  testWidgets('bấm Đăng xuất rồi Hủy: vẫn ở lại, chưa đăng xuất', (t) async {
    await openHeader(t);
    await t.tap(find.byType(AppAvatar));
    await t.pumpAndSettle();
    await t.tap(find.text('Đăng xuất'));
    await t.pumpAndSettle();

    expect(find.text('Đăng xuất?'), findsOneWidget); // hộp hỏi xác nhận
    await t.tap(find.text('Hủy'));
    await t.pumpAndSettle();

    expect(repo.logoutCalls, 0);
    expect(auth.isAuthenticated, isTrue);
    expect(find.text('MAN_DANG_NHAP'), findsNothing);
  });

  testWidgets('xác nhận đăng xuất: xóa phiên và về màn đăng nhập', (t) async {
    await openHeader(t);
    await t.tap(find.byType(AppAvatar));
    await t.pumpAndSettle();
    await t.tap(find.text('Đăng xuất'));
    await t.pumpAndSettle();
    await t.tap(find.text('Đăng xuất')); // nút xác nhận trong hộp thoại
    await t.pumpAndSettle();

    expect(repo.logoutCalls, 1);
    expect(auth.isAuthenticated, isFalse);
    expect(find.text('MAN_DANG_NHAP'), findsOneWidget);
  });
}
