import 'package:flutter/material.dart';
import '../../domain/entities/reaction_kind.dart';
import '../social_strings.dart';
import 'like_icon.dart';
import 'reaction_style.dart';

/// Phần hiển thị của nút Thích: icon (có hiệu ứng) + chữ (đổi màu mượt).
/// Chưa thả: "Thích" xám. Đã thả: tên cảm xúc + màu theo cảm xúc.
class LikeLabel extends StatelessWidget {
  const LikeLabel({super.key, required this.kind});

  final ReactionKind? kind;

  @override
  Widget build(BuildContext context) {
    final color = reactionColor(kind);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedReactionIcon(kind: kind),
          const SizedBox(width: 6),
          Flexible(
            // Chữ đổi màu từ từ trong 200ms thay vì nhảy đột ngột
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color),
              child: Text(kind?.label ?? SocialStrings.like),
            ),
          ),
        ],
      ),
    );
  }
}
