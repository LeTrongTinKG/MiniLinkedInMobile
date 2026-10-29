import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'google_web_sign_in.dart';

/// Nút bấm Google Sign-In tái sử dụng cho cả màn hình Đăng nhập và Đăng ký.
/// Tuân thủ quy chuẩn thiết kế nút xác thực của Google & giao diện LinkedIn.
/// Trên web Google không cho tự gọi hộp đăng nhập, nên thay bằng nút chính thức của Google
/// (xem GoogleWebSignIn). Android và iOS giữ nguyên nút bên dưới.
class GoogleSignInButton extends StatelessWidget {
  final String label;
  final VoidCallback? onSuccess;

  const GoogleSignInButton({
    super.key,
    this.label = 'Tiếp tục với Google',
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return GoogleWebSignIn(onSuccess: onSuccess);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.isLoading;

        return SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () async {
                    await authProvider.signInWithGoogle();
                    if (authProvider.isAuthenticated && onSuccess != null) {
                      onSuccess!();
                    }
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4285F4),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GoogleLogo(size: 22.0),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Logo chữ G nhiều màu đặc trưng của Google được vẽ bằng CustomPainter
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 22.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Google Colors
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final redPaint = Paint()..color = const Color(0xFFEA4335);

    // Bán kính nét vẽ
    final strokeWidth = radius * 0.42;
    bluePaint.style = PaintingStyle.stroke;
    bluePaint.strokeWidth = strokeWidth;
    greenPaint.style = PaintingStyle.stroke;
    greenPaint.strokeWidth = strokeWidth;
    yellowPaint.style = PaintingStyle.stroke;
    yellowPaint.strokeWidth = strokeWidth;
    redPaint.style = PaintingStyle.stroke;
    redPaint.strokeWidth = strokeWidth;

    final arcRect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    // Cung đỏ (Top)
    canvas.drawArc(arcRect, -2.35, 1.57, false, redPaint);
    // Cung vàng (Left)
    canvas.drawArc(arcRect, -3.92, 1.57, false, yellowPaint);
    // Cung xanh lá (Bottom)
    canvas.drawArc(arcRect, 0.78, 1.57, false, greenPaint);
    // Cung xanh dương (Right)
    canvas.drawArc(arcRect, 0.0, 0.78, false, bluePaint);

    // Thanh ngang màu xanh dương ở giữa chữ G
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTRB(
      center.dx,
      center.dy - strokeWidth / 2,
      center.dx + radius,
      center.dy + strokeWidth / 2,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
