// Màn hình Đăng nhập - giao diện phong cách LinkedIn
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Màn hình đăng nhập với form email/password và tùy chọn Google Sign-In
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Màu chủ đạo LinkedIn
  static const _linkedInBlue = Color(0xFF0A66C2);

  /// Key dùng để validate form
  final _formKey = GlobalKey<FormState>();

  /// Controllers cho các trường nhập liệu
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Trạng thái ẩn/hiện mật khẩu
  bool _obscurePassword = true;

  /// Giữ tham chiếu AuthProvider để removeListener an toàn trong dispose()
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    // Lắng nghe trạng thái auth sau khi frame đầu tiên render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authProvider = context.read<AuthProvider>();
      _authProvider?.addListener(_onAuthStatusChanged);
    });
  }

  /// Xử lý điều hướng khi trạng thái auth thay đổi
  void _onAuthStatusChanged() {
    if (!mounted || _authProvider == null) return;

    final status = _authProvider!.status;

    if (status == AuthStatus.authenticated) {
      // Điều hướng theo vai trò
      if (_authProvider!.isStudent) {
        Navigator.pushReplacementNamed(context, '/student-home');
      } else if (_authProvider!.isRecruiter) {
        Navigator.pushReplacementNamed(context, '/recruiter-home');
      }
    } else if (status == AuthStatus.error) {
      // Hiển thị thông báo lỗi
      final errorMsg = _authProvider!.errorMessage ?? 'Đã xảy ra lỗi';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Hủy lắng nghe trực tiếp trên tham chiếu đã lưu, không tra cứu context khi widget đã deactivated
    _authProvider?.removeListener(_onAuthStatusChanged);
    _authProvider = null;
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Thực hiện đăng nhập khi form hợp lệ
  void _handleLogin(AuthProvider authProvider) {
    if (_formKey.currentState?.validate() ?? false) {
      authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final isLoading = authProvider.status == AuthStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo LinkedIn ──────────────────────────────────────
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _linkedInBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Tiêu đề ───────────────────────────────────────────
                    const Text(
                      'Đăng nhập',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Phụ đề ────────────────────────────────────────────
                    const Text(
                      'Chào mừng trở lại!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Trường Email ──────────────────────────────────────
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'example@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _linkedInBlue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        // Kiểm tra định dạng email cơ bản
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Trường Mật khẩu ───────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(authProvider),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        hintText: 'Tối thiểu 6 ký tự',
                        prefixIcon: const Icon(Icons.lock_outline),
                        // Nút toggle ẩn/hiện mật khẩu
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _linkedInBlue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Nút Đăng nhập ─────────────────────────────────────
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _handleLogin(authProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _linkedInBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          disabledBackgroundColor: _linkedInBlue.withValues(alpha: 0.6),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Dòng phân cách "Hoặc" ─────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Hoặc',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Nút Tiếp tục với Google ───────────────────────────
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                // TODO: Implement Google Sign-In using google_sign_in package
                                // Cần cấu hình google-services.json và thêm dependency google_sign_in
                              },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon chữ G của Google với màu sắc đặc trưng
                            _GoogleIcon(),
                            const SizedBox(width: 10),
                            const Text(
                              'Tiếp tục với Google',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Chuyển sang trang đăng ký ─────────────────────────
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Chưa có tài khoản? Đăng ký ngay',
                        style: TextStyle(color: _linkedInBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget hiển thị logo Google với các chữ cái nhiều màu đặc trưng
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            // Màu xanh dương đặc trưng của Google
            color: Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
