import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/ui_kit/app_shad_theme.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/profile/profile_page.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/cv/presentation/providers/cv_provider.dart';
import 'package:app/features/cv/domain/usecases/cv_usecases.dart';
import 'package:app/features/cv/domain/repositories/cv_repository.dart';
import 'package:app/features/cv/domain/entities/cv_entity.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/core/services/google_auth_service.dart';
import 'package:app/core/localization/locale_view_model.dart';
import 'package:app/core/storage/preferences_storage.dart';
import 'package:dio/dio.dart';

class _FakeAuthRepo implements AuthRepository {
  final user = UserEntity(
    id: 'u1',
    email: 'test@student.edu',
    fullName: 'Nguyen Van A',
    role: 'student',
    createdAt: DateTime.now(),
  );

  @override
  Future<UserEntity> getMe() async => user;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGoogle implements IGoogleAuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeCvRepo implements CvRepository {
  @override
  Future<List<CvEntity>> getCvs() async => [];
  @override
  Future<CvEntity> uploadCv(dynamic file) => throw UnimplementedError();
  @override
  Future<CvEntity> setDefaultCv(String id) => throw UnimplementedError();
  @override
  Future<void> deleteCv(String id) async {}
}

class _FakePreferences implements IAppPreferences {
  @override
  Future<String?> getLocale() async => 'vi';
  @override
  Future<void> saveLocale(String locale) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('ProfilePage renders without error and displays content', (tester) async {
    final errors = <FlutterErrorDetails>[];
    FlutterError.onError = (details) => errors.add(details);

    final authRepo = _FakeAuthRepo();
    final authProvider = AuthProvider(
      loginUseCase: LoginUseCase(authRepo),
      registerUseCase: RegisterUseCase(authRepo),
      getMeUseCase: GetMeUseCase(authRepo),
      googleLoginUseCase: GoogleLoginUseCase(authRepo),
      githubLoginUseCase: GitHubLoginUseCase(authRepo),
      logoutUseCase: LogoutUseCase(authRepo),
      googleAuthService: _FakeGoogle(),
    );
    await authProvider.checkAuth();

    final cvProvider = CvProvider(
      getCvs: GetCvsUseCase(_FakeCvRepo()),
      uploadCv: UploadCvUseCase(_FakeCvRepo()),
      setDefault: SetDefaultCvUseCase(_FakeCvRepo()),
      deleteCv: DeleteCvUseCase(_FakeCvRepo()),
    );

    final localeVm = LocaleViewModel(_FakePreferences());

    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: cvProvider),
          ChangeNotifierProvider.value(value: localeVm),
          Provider<Dio>(create: (_) => Dio()),
        ],
        child: ShadApp.custom(
          theme: buildAppShadTheme(),
          appBuilder: (context) => MaterialApp(
            theme: AppTheme.lightTheme,
            builder: (context, child) => ShadAppBuilder(child: child!),
            home: const ProfilePage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(errors, isEmpty);
    expect(find.text('Hồ sơ'), findsOneWidget);
    expect(find.text('Nguyen Van A'), findsOneWidget);
    expect(find.text('Hồ sơ bảo vệ riêng tư mặc định (Chuẩn Atom)'), findsOneWidget);
    expect(find.text('Kỹ năng từ GitHub'), findsOneWidget);
    expect(find.text('Quét GitHub'), findsOneWidget);
  });
}
