import 'dart:math';
import 'package:flutter/material.dart';

/// Vẽ các chấm nhỏ bắn ra xung quanh icon khi vừa thả cảm xúc (giống tia lấp lánh của Facebook).
/// `progress` chạy từ 0 đến 1: chấm bay ra xa dần, nhỏ dần và mờ dần.
/// Ví với React: giống vẽ <canvas>, mỗi khung hình vẽ lại theo `progress`.
class LikeBurstPainter extends CustomPainter {
  LikeBurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static const int _dotCount = 8;

  @override
  void paint(Canvas canvas, Size size) {
    // Chưa bắt đầu hoặc đã xong thì không vẽ gì
    if (progress <= 0 || progress >= 1) return;

    final center = size.center(Offset.zero);
    final radius = size.width * (0.55 + 0.9 * progress); // bay ra xa dần
    final dotSize = 1.5 + 2.5 * (1 - progress); // nhỏ dần
    final paint = Paint()..color = color.withValues(alpha: 1 - progress); // mờ dần

    // Chia đều 8 chấm quanh vòng tròn
    for (var i = 0; i < _dotCount; i++) {
      final angle = 2 * pi * i / _dotCount;
      final offset = Offset(cos(angle), sin(angle)) * radius;
      canvas.drawCircle(center + offset, dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(LikeBurstPainter old) => old.progress != progress || old.color != color;
}
