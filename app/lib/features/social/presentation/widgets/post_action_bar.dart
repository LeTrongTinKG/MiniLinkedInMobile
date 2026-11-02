import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/reaction_kind.dart';
import '../social_strings.dart';
import 'like_label.dart';
import 'reaction_button.dart';
import 'reaction_style.dart';

/// Thanh 3 nút dưới bài: Thích / Bình luận / Chia sẻ.
class PostActionBar extends StatelessWidget {
  const PostActionBar({
    super.key,
    required this.post,
    required this.onReact,
    required this.onComment,
    required this.onShare,
  });

  final Post post;
  final ValueChanged<ReactionKind?> onReact; // null = bỏ cảm xúc
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final mine = post.reactionSummary.myReaction;
    return Row(
      children: [
        // Nút Thích: bấm nhanh bật/tắt, giữ để chọn cảm xúc
        Expanded(
          child: ReactionButton(
            current: mine,
            onChanged: onReact,
            child: LikeLabel(kind: mine),
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: Icons.mode_comment_outlined,
            label: SocialStrings.comment,
            onTap: onComment,
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: Icons.share_outlined,
            label: SocialStrings.share,
            onTap: onShare,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = reactionColor(null);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
