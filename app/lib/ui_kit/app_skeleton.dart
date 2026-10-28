import 'package:flutter/material.dart';

import 'ui_tokens.dart';

// Khối xám nhấp nháy khi đang tải dữ liệu (không cần package ngoài).
// Ví với React: <Skeleton className="h-4 w-40" />
class AppSkeleton extends StatefulWidget {
  const AppSkeleton(
      {super.key, this.width, this.height = 16, this.circle = false});

  final double? width; // null = chiếm hết chiều ngang
  final double height;
  final bool circle; // true = hình tròn (cho avatar)

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  // Bộ điều khiển hoạt ảnh lặp qua lại (giống setInterval trong React)
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose(); // nhớ hủy, giống clearInterval trong useEffect
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Màu đổi dần giữa xám nhạt và xám đậm hơn một chút
        final color = Color.lerp(
          UiTokens.muted,
          UiTokens.border,
          _controller.value,
        );
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.circle
                ? null
                : BorderRadius.circular(UiTokens.radius / 2),
          ),
        );
      },
    );
  }
}
