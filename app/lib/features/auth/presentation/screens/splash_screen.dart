// Màn hình Splash - hiển thị khi ứng dụng khởi động
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../../../../core/services/github_web_callback.dart';
import '../providers/auth_provider.dart';

/// Màn hình khởi động: kiểm tra trạng thái xác thực và điều hướng phù hợp
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authProvider = context.read<AuthProvider>();
      _authProvider?.addListener(_onAuthStatusChanged);
      final githubCode = takeGithubCode();
      if (githubCode != null) {
        _authProvider?.githubLogin(githubCode);
      } else {
        _authProvider?.checkAuth();
      }
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
    } else if (status == AuthStatus.unauthenticated) {
      Navigator.pushReplacementNamed(context, '/login');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final isError = authProvider.status == AuthStatus.error;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Atom',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isError) ...[
                    _buildErrorBox(authProvider),
                  ] else ...[
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorBox(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.error,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            authProvider.errorMessage ?? 'Không thể kết nối đến máy chủ',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => authProvider.checkAuth(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại kết nối'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Chuyển đến Đăng nhập',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
