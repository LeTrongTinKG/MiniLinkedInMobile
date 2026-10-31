import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/github_web_callback.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_sso_section.dart';

/// Màn hình đăng nhập phong cách Clay Minimalist & 21st.dev Premium Auth.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authProvider = context.read<AuthProvider>();
      _authProvider?.addListener(_onAuthStatusChanged);
      final githubCode = takeGithubCode();
      if (githubCode != null) _authProvider?.githubLogin(githubCode);
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    String? emailErr;
    String? passErr;

    if (email.isEmpty) {
      emailErr = 'Vui lòng nhập email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailErr = 'Email không hợp lệ';
    }

    if (password.isEmpty) {
      passErr = 'Vui lòng nhập mật khẩu';
    } else if (password.length < 6) {
      passErr = 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  void _submit(AuthProvider auth) {
    if (_validate()) {
      auth.login(_emailController.text.trim(), _passwordController.text);
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                      title: 'Chào mừng trở lại',
                      subtitle: 'Đăng nhập để tiếp tục lộ trình nghề nghiệp',
                    ),
                    const SizedBox(height: 20),
                    AppSegmentedTab(
                      tabs: const ['Đăng nhập', 'Đăng ký'],
                      selectedIndex: 0,
                      onTabChanged: (i) {
                        if (i == 1) {
                          Navigator.pushReplacementNamed(context, '/register');
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _emailController,
                      placeholder: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      leadingIcon: Icons.email_outlined,
                      errorText: _emailError,
                      enabled: !isLoading,
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _passwordController,
                      placeholder: 'Mật khẩu',
                      obscureText: _obscurePassword,
                      leadingIcon: Icons.lock_outline,
                      trailingIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onTrailingTap: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      errorText: _passwordError,
                      enabled: !isLoading,
                      onChanged: (_) {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Đăng nhập',
                      loading: isLoading,
                      fullWidth: true,
                      onPressed: () => _submit(auth),
                    ),
                    const SizedBox(height: 20),
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
