import 'package:flutter/material.dart';

/// Nút menu hình vuông với 3 thanh ngang chuyển động thành chữ 'X' mượt mà,
/// chuẩn theo thiết kế Header trong Curved Menu của 21st.dev.
class CurvedMenuButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const CurvedMenuButton({
    super.key,
    required this.isActive,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    final fg = iconColor ?? (isDark ? Colors.white : Colors.black);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(4),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 18,
              child: AnimatedBuilder(
                animation: const AlwaysStoppedAnimation(0),
                builder: (context, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Thanh trên (xoay 45 độ và hạ xuống)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: isActive ? 8 : 0,
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          turns: isActive ? (45 / 360) : 0,
                          child: Container(
                            width: 24,
                            height: 2,
                            decoration: BoxDecoration(
                              color: fg,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                      // Thanh giữa (mờ dần biến mất)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: isActive ? 0.0 : 1.0,
                        child: Container(
                          width: 24,
                          height: 2,
                          decoration: BoxDecoration(
                            color: fg,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      // Thanh dưới (xoay -45 độ và nâng lên)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        bottom: isActive ? 8 : 0,
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          turns: isActive ? (-45 / 360) : 0,
                          child: Container(
                            width: 24,
                            height: 2,
                            decoration: BoxDecoration(
                              color: fg,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
