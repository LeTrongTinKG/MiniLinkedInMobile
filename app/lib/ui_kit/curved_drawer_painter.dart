import 'package:flutter/material.dart';

/// Painter vẽ đường viền cong Bezier bậc 2 cho Curved Menu.
/// Tái hiện chuẩn xác SVG Path từ 21st.dev:
/// initialPath: M100 0 L200 0 L200 H L100 H Q-100 H/2 100 0
/// targetPath:  M100 0 L200 0 L200 H L100 H Q100  H/2 100 0
class CurvedDrawerPainter extends CustomPainter {
  final double progress; // 0.0 (cong tối đa) -> 1.0 (phẳng)
  final Color color;

  const CurvedDrawerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Trong 21st.dev: w = 100.
    // Khi bắt đầu (progress = 0): điểm uốn cong ở x = -w (phồng 200px sang trái).
    // Khi kết thúc (progress = 1): điểm uốn cong ở x = w (thẳng tuyệt đối x = w).
    final controlX = -w * (1.0 - progress) + w * progress;

    final path = Path()
      ..moveTo(w, 0)
      ..lineTo(w, h)
      ..quadraticBezierTo(controlX, h / 2, w, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CurvedDrawerPainter old) =>
      old.progress != progress || old.color != color;
}
