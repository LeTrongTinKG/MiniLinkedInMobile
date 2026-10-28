import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/reaction_kind.dart';

/// Vẽ khuôn mặt (mắt, miệng, lông mày) cho 4 cảm xúc: Haha, Wow, Buồn, Phẫn nộ.
/// Vẽ bằng code nên hiện giống nhau trên mọi máy, kể cả web (không phụ thuộc font emoji).
/// Ví với React: như một thẻ `svg` nhỏ, toạ độ x/y tính theo tỉ lệ 0..1 của kích thước icon.
class ReactionFacePainter extends CustomPainter {
  ReactionFacePainter(this.kind);

  final ReactionKind kind;

  static const _ink = Color(0xFF4A2C0A); // nâu đậm cho mắt/miệng

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(double x, double y) => Offset(x * s, y * s); // đổi tỉ lệ -> toạ độ thật

    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = _ink;

    switch (kind) {
      case ReactionKind.haha:
        // Mắt cười: hai nét cong lên. Miệng há to nửa hình tròn, có cái lưỡi hồng.
        for (final x in [0.30, 0.70]) {
          canvas.drawArc(Rect.fromCenter(center: p(x, 0.42), width: s * 0.2, height: s * 0.14), pi, pi, false, line);
        }
        final mouth = Path()
          ..moveTo(p(0.2, 0.55).dx, p(0.2, 0.55).dy)
          ..lineTo(p(0.8, 0.55).dx, p(0.8, 0.55).dy)
          ..arcToPoint(p(0.2, 0.55), radius: Radius.circular(s * 0.3), clockwise: true)
          ..close();
        canvas.drawPath(mouth, fill);
        canvas.save();
        canvas.clipPath(mouth);
        canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.88), width: s * 0.32, height: s * 0.22),
            Paint()..color = const Color(0xFFFF7A8A));
        canvas.restore();
      case ReactionKind.wow:
        // Mắt tròn to, lông mày nhướn, miệng tròn nhỏ.
        for (final x in [0.32, 0.68]) {
          canvas.drawOval(Rect.fromCenter(center: p(x, 0.42), width: s * 0.12, height: s * 0.17), fill);
          canvas.drawArc(Rect.fromCenter(center: p(x, 0.25), width: s * 0.2, height: s * 0.1), pi, pi, false,
              line..strokeWidth = s * 0.05);
        }
        canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.71), width: s * 0.17, height: s * 0.24), fill);
      case ReactionKind.sad:
        // Mắt chấm, lông mày xệ, miệng mếu, có giọt nước mắt xanh.
        for (final x in [0.32, 0.68]) {
          canvas.drawCircle(p(x, 0.44), s * 0.055, fill);
        }
        final brow = line..strokeWidth = s * 0.05;
        canvas.drawLine(p(0.20, 0.34), p(0.42, 0.27), brow);
        canvas.drawLine(p(0.80, 0.34), p(0.58, 0.27), brow);
        canvas.drawArc(Rect.fromCenter(center: p(0.5, 0.78), width: s * 0.34, height: s * 0.22), pi, pi, false,
            line..strokeWidth = s * 0.07);
        canvas.drawCircle(p(0.80, 0.60), s * 0.06, Paint()..color = const Color(0xFF7ECBFF));
      case ReactionKind.angry:
        // Lông mày dốc xuống giữa mặt, mắt chấm, miệng mếu.
        final brow = line..strokeWidth = s * 0.09;
        canvas.drawLine(p(0.18, 0.30), p(0.45, 0.43), brow);
        canvas.drawLine(p(0.82, 0.30), p(0.55, 0.43), brow);
        for (final x in [0.34, 0.66]) {
          canvas.drawCircle(p(x, 0.54), s * 0.05, fill);
        }
        canvas.drawArc(Rect.fromCenter(center: p(0.5, 0.80), width: s * 0.30, height: s * 0.16), pi, pi, false,
            line..strokeWidth = s * 0.07);
      case ReactionKind.like:
      case ReactionKind.love:
        break; // hai loại này dùng icon, không vẽ mặt
    }
  }

  @override
  bool shouldRepaint(ReactionFacePainter old) => old.kind != kind;
}
