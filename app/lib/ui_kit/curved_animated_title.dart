import 'package:flutter/material.dart';

/// Hiệu ứng chuyển động chữ từng ký tự (Letter-by-letter spring stagger effect).
/// Tái hiện chuẩn xác Framer Motion của 21st.dev:
/// Parent dịch lùi sang trái (x: -12), các ký tự lần lượt tiến sang phải (x: +12)
/// với độ trễ (stagger delay) và đường cong spring đàn hồi.
class CurvedAnimatedTitle extends StatefulWidget {
  final String text;
  final bool isHovered;
  final TextStyle style;
  final Color? hoverColor;

  const CurvedAnimatedTitle({
    super.key,
    required this.text,
    required this.isHovered,
    required this.style,
    this.hoverColor,
  });

  @override
  State<CurvedAnimatedTitle> createState() => _CurvedAnimatedTitleState();
}

class _CurvedAnimatedTitleState extends State<CurvedAnimatedTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    if (widget.isHovered) _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant CurvedAnimatedTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered != oldWidget.isHovered) {
      if (widget.isHovered) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.split('');
    final total = chars.length;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final parentOffset = -12.0 * Curves.easeOutCubic.transform(_ctrl.value);

        return Transform.translate(
          offset: Offset(parentOffset, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(total, (i) {
              final ch = chars[i];
              final start = (i * 0.04).clamp(0.0, 0.5);
              final end = (start + 0.5).clamp(0.0, 1.0);
              final progress = Interval(
                start,
                end,
                curve: Curves.easeOutBack,
              ).transform(_ctrl.value);

              final letterOffset = 12.0 * progress;

              return Transform.translate(
                offset: Offset(letterOffset, 0),
                child: Text(
                  ch == ' ' ? '\u00A0' : ch,
                  style: widget.style.copyWith(
                    color: widget.hoverColor != null
                        ? Color.lerp(
                            widget.style.color,
                            widget.hoverColor,
                            _ctrl.value,
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

