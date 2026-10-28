import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/reaction_kind.dart';
import 'reaction_picker.dart';

/// Nút "Thích" kiểu Facebook, dùng cho cả bài viết và bình luận.
/// - Bấm nhanh: bật/tắt LIKE.
/// - Giữ (long-press, trên web là giữ chuột): hiện thanh 6 emoji, chọn 1 cái.
/// `onChanged(null)` nghĩa là bỏ cảm xúc. `child` là phần hiển thị do nơi dùng tự vẽ.
class ReactionButton extends StatefulWidget {
  const ReactionButton({
    super.key,
    required this.current,
    required this.onChanged,
    required this.child,
  });

  final ReactionKind? current; // cảm xúc hiện tại của mình
  final ValueChanged<ReactionKind?> onChanged;
  final Widget child;

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  OverlayEntry? _entry; // lớp nổi chứa thanh emoji
  bool _pressed = false; // đang bị nhấn xuống (giống useState(false))

  void _quickTap() {
    // Rung nhẹ khi vừa thả cảm xúc (trên điện thoại; web tự bỏ qua)
    if (widget.current == null) HapticFeedback.lightImpact();
    widget.onChanged(widget.current == null ? ReactionKind.like : null);
  }

  void _showPicker() {
    if (_entry != null) return;
    HapticFeedback.mediumImpact();
    // 1. Tính vị trí nút trên màn hình để đặt thanh emoji ngay phía trên
    final box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final left = pos.dx.clamp(8.0, max(8.0, screenWidth - ReactionPicker.barWidth - 8)).toDouble();
    final top = pos.dy > 80 ? pos.dy - 64 : pos.dy + box.size.height + 8;

    // 2. Lớp nổi: nền trong suốt (bấm ra ngoài = đóng) + thanh emoji
    _entry = OverlayEntry(
      builder: (_) => Stack(children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _closePicker),
        ),
        Positioned(
          left: left,
          top: top,
          child: ReactionPicker(onPick: (kind) {
            _closePicker();
            widget.onChanged(kind);
          }),
        ),
      ]),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _closePicker() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _closePicker(); // dọn như return cleanup trong useEffect
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _quickTap,
      onLongPress: _showPicker,
      // Nhấn xuống thì nút co lại một chút, thả ra thì phồng về (cảm giác "bấm được")
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
