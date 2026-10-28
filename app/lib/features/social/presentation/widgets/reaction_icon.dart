import 'package:flutter/material.dart';
import '../../domain/entities/reaction_kind.dart';
import 'reaction_face_painter.dart';

/// Icon cảm xúc DUY NHẤT của module social, giống Facebook: hình tròn màu chuyển nhẹ.
/// - Thích: tròn xanh + ngón cái trắng.   - Yêu thích: tròn đỏ + trái tim trắng.
/// - Haha / Wow / Buồn: tròn vàng + mặt vẽ bằng code.   - Phẫn nộ: tròn cam đỏ + mặt giận.
/// Dùng chung ở nút Thích, thanh chọn cảm xúc, dòng thống kê, danh sách người react, bình luận
/// => mọi nơi nhìn giống nhau. Ví với React: một component `ReactionIcon` nhận prop `kind`.
class ReactionIcon extends StatelessWidget {
  const ReactionIcon({super.key, required this.kind, this.size = 24});

  final ReactionKind kind;
  final double size;

  static const _blue = [Color(0xFF4DB2FF), Color(0xFF1465E0)];
  static const _red = [Color(0xFFFF7A93), Color(0xFFEB2B4F)];
  static const _yellow = [Color(0xFFFFE97A), Color(0xFFF59A23)];
  static const _orange = [Color(0xFFFFA45C), Color(0xFFE8421A)];

  // Màu nền tròn theo từng loại cảm xúc
  List<Color> get _colors {
    switch (kind) {
      case ReactionKind.like:
        return _blue;
      case ReactionKind.love:
        return _red;
      case ReactionKind.angry:
        return _orange;
      case ReactionKind.haha:
      case ReactionKind.wow:
      case ReactionKind.sad:
        return _yellow;
    }
  }

  // Phần bên trong hình tròn: icon trắng (Thích, Yêu thích) hoặc khuôn mặt vẽ tay
  Widget _inside() {
    switch (kind) {
      case ReactionKind.like:
        return Center(child: Icon(Icons.thumb_up, size: size * 0.54, color: Colors.white));
      case ReactionKind.love:
        return Center(child: Icon(Icons.favorite, size: size * 0.56, color: Colors.white));
      default:
        return CustomPaint(painter: ReactionFacePainter(kind));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: kind.label, // để đọc màn hình và để test tìm theo tên
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _colors,
            ),
          ),
          child: _inside(),
        ),
      ),
    );
  }
}
