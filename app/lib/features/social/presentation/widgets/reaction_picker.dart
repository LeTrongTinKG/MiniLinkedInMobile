import 'package:flutter/material.dart';
import '../../domain/entities/reaction_kind.dart';
import 'reaction_icon.dart';

/// Thanh nổi 6 icon cảm xúc, giống Facebook:
/// - Cả thanh trượt từ dưới lên và hiện dần.
/// - 6 emoji nảy ra lần lượt từ trái sang phải.
/// - Rê chuột / chạm vào emoji nào thì emoji đó phóng to, nhích lên và hiện tên phía trên.
class ReactionPicker extends StatefulWidget {
  const ReactionPicker({super.key, required this.onPick});
  final ValueChanged<ReactionKind> onPick;

  static const double tileWidth = 48;
  static const double barWidth = tileWidth * 6 + 16;

  @override
  State<ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker> with SingleTickerProviderStateMixin {
  // "Đồng hồ" hiệu ứng hiện ra: chạy 0 -> 1 một lần khi thanh vừa mở
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cả thanh: hiện dần (40% đầu) + trượt lên
    final fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.4));
    final slide = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Material(
          elevation: 8,
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < ReactionKind.values.length; i++)
                  _EmojiTile(
                    kind: ReactionKind.values[i],
                    index: i,
                    intro: _controller,
                    onTap: () => widget.onPick(ReactionKind.values[i]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmojiTile extends StatefulWidget {
  const _EmojiTile({
    required this.kind,
    required this.index,
    required this.intro,
    required this.onTap,
  });
  final ReactionKind kind;
  final int index; // vị trí 0..5, để emoji sau nảy ra trễ hơn emoji trước
  final Animation<double> intro;
  final VoidCallback onTap;

  @override
  State<_EmojiTile> createState() => _EmojiTileState();
}

class _EmojiTileState extends State<_EmojiTile> {
  bool _hover = false; // giống useState(false)

  @override
  Widget build(BuildContext context) {
    // Mỗi emoji có "lượt" riêng trong 450ms: emoji thứ i bắt đầu trễ i * 10%
    final start = widget.index * 0.1;
    final pop = CurvedAnimation(
      parent: widget.intro,
      curve: Interval(start, start + 0.4, curve: Curves.easeOutBack),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hover = true),
        onTapCancel: () => setState(() => _hover = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: ReactionPicker.tileWidth,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Emoji: nảy ra lúc mở, phóng to + nhích lên khi rê vào
              ScaleTransition(
                scale: pop,
                child: AnimatedSlide(
                  offset: Offset(0, _hover ? -0.2 : 0),
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  child: AnimatedScale(
                    scale: _hover ? 1.6 : 1,
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutBack,
                    child: ReactionIcon(kind: widget.kind, size: 34),
                  ),
                ),
              ),
              // Nhãn tên cảm xúc nổi phía trên emoji đang được rê vào
              if (_hover)
                Positioned(
                  top: -34,
                  left: -24,
                  right: -24,
                  child: Center(child: _NameBubble(text: widget.kind.label)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nhãn đen bo tròn hiện tên cảm xúc (Thích, Yêu thích...).
class _NameBubble extends StatelessWidget {
  const _NameBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xDD1C1E21),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
