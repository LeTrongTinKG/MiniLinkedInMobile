import 'package:flutter/material.dart';
import 'package:app/ui_kit/curved_animated_title.dart';
import 'package:app/ui_kit/curved_nav_item.dart';

/// Mục điều hướng đơn lẻ trong CurvedDrawer với hiệu ứng rê chuột (Hover motion),
/// chuyển động từng ký tự (Letter-by-letter spring effect).
class CurvedDrawerItem extends StatefulWidget {
  final CurvedNavItem item;
  final int index;
  final Color fgColor;
  final VoidCallback onTap;

  const CurvedDrawerItem({
    super.key,
    required this.item,
    required this.index,
    required this.fgColor,
    required this.onTap,
  });

  @override
  State<CurvedDrawerItem> createState() => _CurvedDrawerItemState();
}

class _CurvedDrawerItemState extends State<CurvedDrawerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final numStr = '${widget.index + 1}.';
    final fg = widget.fgColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            children: [
              // Số thứ tự đánh số
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  color: _isHovered
                      ? fg
                      : fg.withValues(alpha: 0.35),
                ),
                child: Text(numStr),
              ),
              const SizedBox(width: 14),
              // Tiêu đề chữ chạy hiệu ứng từng ký tự
              Expanded(
                child: CurvedAnimatedTitle(
                  text: widget.item.title.toUpperCase(),
                  isHovered: _isHovered,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                    color: fg.withValues(alpha: _isHovered ? 1.0 : 0.85),
                  ),
                  hoverColor: fg,
                ),
              ),
              // Icon phụ với hiệu ứng dịch chuyển nhẹ khi hover
              if (widget.item.icon != null)
                AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  offset: Offset(_isHovered ? 0.2 : 0.0, 0.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _isHovered ? 0.8 : 0.3,
                    child: Icon(widget.item.icon, size: 20, color: fg),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

