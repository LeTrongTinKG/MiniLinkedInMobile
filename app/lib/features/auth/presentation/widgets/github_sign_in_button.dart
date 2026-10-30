import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Nút bấm GitHub Sign-In tái sử dụng cho cả màn hình Đăng nhập và Đăng ký.
/// Tuân thủ quy chuẩn thương hiệu GitHub & phong cách Mini LinkedIn.
class GitHubSignInButton extends StatelessWidget {
  final String label;
  final VoidCallback? onSuccess;

  const GitHubSignInButton({
    super.key,
    this.label = 'Tiếp tục với GitHub',
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.isLoading;

        return SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () async {
                    await authProvider.signInWithGitHub();
                    if (authProvider.isAuthenticated && onSuccess != null) {
                      onSuccess!();
                    }
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF24292E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              side: const BorderSide(color: Color(0xFF24292E)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GitHubLogo(size: 22.0),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

/// Logo GitHub Octocat chính xác vẽ bằng CustomPainter vector
class GitHubLogo extends StatelessWidget {
  final double size;
  final Color color;

  const GitHubLogo({
    super.key,
    this.size = 22.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GitHubLogoPainter(color: color),
    );
  }
}

class _GitHubLogoPainter extends CustomPainter {
  final Color color;

  _GitHubLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(12.0, 2.0);
    path.cubicTo(6.477, 2.0, 2.0, 6.484, 2.0, 12.017);
    path.cubicTo(2.0, 16.442, 4.865, 20.197, 8.839, 21.521);
    path.cubicTo(9.339, 21.613, 9.521, 21.304, 9.521, 21.038);
    path.cubicTo(9.521, 20.801, 9.513, 20.170, 9.508, 19.335);
    path.cubicTo(6.726, 19.940, 6.139, 17.992, 6.139, 17.992);
    path.cubicTo(5.685, 16.834, 5.029, 16.526, 5.029, 16.526);
    path.cubicTo(4.121, 15.906, 5.098, 15.918, 5.098, 15.918);
    path.cubicTo(6.101, 15.988, 6.628, 16.950, 6.628, 16.950);
    path.cubicTo(7.520, 18.480, 8.969, 18.038, 9.538, 17.782);
    path.cubicTo(9.630, 17.135, 9.888, 16.694, 10.174, 16.444);
    path.cubicTo(7.954, 16.191, 5.619, 15.331, 5.619, 11.493);
    path.cubicTo(5.619, 10.400, 6.009, 9.505, 6.648, 8.805);
    path.cubicTo(6.545, 8.552, 6.202, 7.533, 6.746, 6.155);
    path.cubicTo(6.746, 6.155, 7.586, 5.885, 9.496, 7.181);
    path.cubicTo(10.294, 6.959, 11.149, 6.848, 11.999, 6.844);
    path.cubicTo(12.849, 6.848, 13.704, 6.959, 14.502, 7.181);
    path.cubicTo(16.412, 5.885, 17.252, 6.155, 17.252, 6.155);
    path.cubicTo(17.796, 7.533, 17.453, 8.552, 17.350, 8.805);
    path.cubicTo(17.989, 9.505, 18.379, 10.400, 18.379, 11.493);
    path.cubicTo(18.379, 15.341, 16.040, 16.188, 13.813, 16.436);
    path.cubicTo(14.172, 16.745, 14.491, 17.356, 14.491, 18.291);
    path.cubicTo(14.491, 19.629, 14.479, 20.710, 14.479, 21.038);
    path.cubicTo(14.479, 21.306, 14.659, 21.618, 15.167, 21.520);
    path.cubicTo(19.135, 20.193, 22.0, 16.440, 22.0, 12.017);
    path.cubicTo(22.0, 6.484, 17.522, 2.0, 12.0, 2.0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GitHubLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

