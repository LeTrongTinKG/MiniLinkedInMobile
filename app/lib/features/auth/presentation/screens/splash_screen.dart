// Màn hình Splash - hiển thị khi ứng dụng khởi động
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Màn hình khởi động: kiểm tra trạng thái xác thực và điều hướng phù hợp
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Màu chủ đạo LinkedIn
  static const _linkedInBlue = Color(0xFF0A66C2);

  /// Giữ tham chiếu AuthProvider để removeListener an toàn trong dispose()
  /// mà không cần tra cứu context khi widget đã bị deactivated.
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();

    // Chờ frame đầu tiên render xong rồi mới kiểm tra auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authProvider = context.read<AuthProvider>();

      // Lắng nghe thay đổi trạng thái để điều hướng
      _authProvider?.addListener(_onAuthStatusChanged);

      // Bắt đầu kiểm tra xác thực
      _authProvider?.checkAuth();
    });
  }

  /// Xử lý khi trạng thái xác thực thay đổi
  void _onAuthStatusChanged() {
    if (!mounted || _authProvider == null) return;

    final status = _authProvider!.status;

    if (status == AuthStatus.authenticated) {
      // Điều hướng theo vai trò người dùng
      if (_authProvider!.isStudent) {
        Navigator.pushReplacementNamed(context, '/student-home');
      } else if (_authProvider!.isRecruiter) {
        Navigator.pushReplacementNamed(context, '/recruiter-home');
      }
    } else if (status == AuthStatus.unauthenticated) {
      // Chỉ khi xác nhận chưa đăng nhập / token hết hạn mới chuyển về trang login
      Navigator.pushReplacementNamed(context, '/login');
    }
    // Nếu status == AuthStatus.error (lỗi mạng hoặc lỗi server tạm thời),
    // KHÔNG tự ý kick người dùng ra login; giao diện sẽ hiển thị nút "Thử lại".
  }

  @override
  void dispose() {
    // Hủy lắng nghe trực tiếp trên tham chiếu đã lưu, KHÔNG dùng context khi widget đã deactivated
    _authProvider?.removeListener(_onAuthStatusChanged);
    _authProvider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final isError = authProvider.status == AuthStatus.error;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo LinkedIn
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _linkedInBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tên ứng dụng
                  const Text(
                    'Mini LinkedIn',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (isError) ...[
                    // Hiển thị lỗi mạng và nút thử lại thay vì kick ra Login
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authProvider.errorMessage ??
                          'Không thể kết nối đến máy chủ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        authProvider.checkAuth();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Thử lại kết nối'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _linkedInBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Chuyển đến Đăng nhập',
                        style: TextStyle(color: _linkedInBlue),
                      ),
                    ),
                  ] else ...[
                    // Hiệu ứng loading thông thường
                    const CircularProgressIndicator(
                      color: _linkedInBlue,
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
}
