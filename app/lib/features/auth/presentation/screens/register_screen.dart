import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_sso_section.dart';
import '../widgets/register_form.dart';

/// Màn hình đăng ký phong cách Clay Minimalist & 21st.dev Premium Auth.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authProvider = context.read<AuthProvider>();
      _authProvider?.addListener(_onAuthStatusChanged);
    });
  }

  void _onAuthStatusChanged() {
    if (!mounted || _authProvider == null) return;
    final status = _authProvider!.status;
    if (status == AuthStatus.authenticated) {
      if (_authProvider!.isStudent) {
        Navigator.pushReplacementNamed(context, '/student-home');
      } else if (_authProvider!.isRecruiter) {
        Navigator.pushReplacementNamed(context, '/recruiter-home');
      }
    } else if (status == AuthStatus.error) {
      final msg = _authProvider!.errorMessage ?? 'Đã xảy ra lỗi';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthStatusChanged);
    _authProvider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthBrandHeader(
                      title: 'Tạo tài khoản mới',
                      subtitle: 'Mở rộng cơ hội nghề nghiệp & kết nối công nghệ',
                    ),
                    const SizedBox(height: 16),
                    AppSegmentedTab(
                      tabs: const ['Đăng nhập', 'Đăng ký'],
                      selectedIndex: 1,
                      onTabChanged: (i) {
                        if (i == 0) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    RegisterForm(auth: auth, isLoading: isLoading),
                    const SizedBox(height: 18),
                    const AuthSsoSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
