import 'package:flutter/material.dart';
import '../../domain/entities/reaction_kind.dart';
import 'like_burst.dart';
import 'reaction_icon.dart';
import 'reaction_style.dart';

/// Biểu tượng của nút Thích, có hiệu ứng "nảy" mỗi khi người dùng thả cảm xúc.
/// - Chưa thả: ngón cái rỗng, màu xám.
/// - Đã thả (Thích, Yêu thích, Haha...): icon tròn màu của cảm xúc đó (ReactionIcon).
/// Ví với React: component có state + useEffect, chạy hiệu ứng mỗi khi `kind` đổi.
class AnimatedReactionIcon extends StatefulWidget {
  const AnimatedReactionIcon({super.key, required this.kind, this.size = 22});

  final ReactionKind? kind; // null = chưa thả cảm xúc
  final double size;

  @override
  State<AnimatedReactionIcon> createState() => _AnimatedReactionIconState();
}

class _AnimatedReactionIconState extends State<AnimatedReactionIcon>
    with SingleTickerProviderStateMixin {
  // "Đồng hồ" của hiệu ứng: chạy 0 -> 1 trong nửa giây
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 550));

  // Nảy: nhỏ lại một chút -> vọt to lên -> về bình thường
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.6).chain(CurveTween(curve: Curves.easeOut)),
      weight: 20,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.6, end: 1.4).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 35,
    ),
  ]).animate(_controller);

  // Nghiêng: ngón cái hất lên rồi lắc về chỗ cũ
  late final Animation<double> _tilt = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.45), weight: 30),
    TweenSequenceItem(
      tween: Tween(begin: -0.45, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 70,
    ),
  ]).animate(_controller);

  // Giống useEffect([kind]): khi vừa thả cảm xúc (mới hoặc đổi loại) thì chạy hiệu ứng
  @override
  void didUpdateWidget(AnimatedReactionIcon old) {
    super.didUpdateWidget(old);
    if (widget.kind != old.kind && widget.kind != null) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // dọn như return cleanup trong useEffect
    super.dispose();
  }

  // Chưa thả: ngón cái rỗng màu xám. Đã thả: icon tròn màu (giống thanh chọn và dòng thống kê)
  Widget _buildIcon(Color color) {
    final kind = widget.kind;
    if (kind == null) return Icon(Icons.thumb_up_outlined, size: widget.size, color: color);
    return ReactionIcon(kind: kind, size: widget.size);
  }

  @override
  Widget build(BuildContext context) {
    final color = reactionColor(widget.kind);
    return AnimatedBuilder(
      animation: _controller,
      child: _buildIcon(color),
      builder: (context, icon) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Lớp dưới: chấm bắn ra (chỉ khi đã thả cảm xúc)
            if (widget.kind != null)
              CustomPaint(
                size: Size.square(widget.size),
                painter: LikeBurstPainter(progress: _controller.value, color: color),
              ),
            // Lớp trên: icon nảy và nghiêng
            Transform.rotate(
              angle: _tilt.value,
              child: Transform.scale(scale: _scale.value, child: icon),
            ),
          ],
        );
      },
    );
  }
}
