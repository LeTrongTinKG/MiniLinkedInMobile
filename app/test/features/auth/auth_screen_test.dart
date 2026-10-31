import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/auth/presentation/screens/register_screen.dart';
import 'package:app/ui_kit/app_shad_theme.dart';
import 'package:app/ui_kit/ui_kit.dart';

class _MockAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildAuthApp(Widget home) {
  final repo = _MockAuthRepo();
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      getMeUseCase: GetMeUseCase(repo),
      googleLoginUseCase: GoogleLoginUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      googleAuthService: null,
    ),
    child: ShadApp.custom(
      theme: buildAppShadTheme(),
      appBuilder: (context) => MaterialApp(
        builder: (context, child) => ShadAppBuilder(child: child!),
        home: home,
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
        },
      ),
    ),
  );
}

void main() {
  testWidgets('LoginScreen renders segmented tab, inputs, and inline errors', (tester) async {
    await tester.pumpWidget(_buildAuthApp(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(AppSegmentedTab), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Đăng ký'), findsOneWidget);

    // Bấm Đăng nhập khi để trống -> hiện lỗi inline
    await tester.tap(find.widgetWithText(AppButton, 'Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
  });

  testWidgets('RegisterScreen renders inputs and validates empty form', (tester) async {
    await tester.pumpWidget(_buildAuthApp(const RegisterScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tạo tài khoản mới'), findsOneWidget);
    expect(find.text('Tạo tài khoản'), findsOneWidget);

    // Bấm Tạo tài khoản khi để trống
    await tester.tap(find.widgetWithText(AppButton, 'Tạo tài khoản'));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
  });
}
