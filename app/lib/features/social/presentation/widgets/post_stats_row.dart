import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/reaction_kind.dart';
import '../social_strings.dart';
import 'reaction_icon.dart';

/// Dòng thống kê dưới bài: [icon cảm xúc chồng + tổng cảm xúc] ........ [N bình luận · N lượt chia sẻ].
class PostStatsRow extends StatelessWidget {
  const PostStatsRow({
    super.key,
    required this.post,
    required this.onReactionsTap,
    required this.onCommentsTap,
  });

  final Post post;
  final VoidCallback onReactionsTap; // bấm vào số cảm xúc -> xem ai đã react
  final VoidCallback onCommentsTap;

  static const _grey = TextStyle(fontSize: 13, color: UiTokens.mutedForeground);

  @override
  Widget build(BuildContext context) {
    final summary = post.reactionSummary;

    // Ghép "N bình luận · N lượt chia sẻ" (chỉ hiện số nào > 0)
    final right = [
      if (post.commentCount > 0) SocialStrings.commentsCount(post.commentCount),
      if (post.shareCount > 0) SocialStrings.sharesCount(post.shareCount),
    ].join(' · ');

    if (summary.total == 0 && right.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          if (summary.total > 0)
            GestureDetector(
              onTap: onReactionsTap,
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                _reactionStack(summary.top),
                const SizedBox(width: 6),
                Text('${summary.total}', style: _grey),
              ]),
            ),
          const Spacer(),
          if (right.isNotEmpty)
            GestureDetector(
              onTap: onCommentsTap,
              child: Text(right, style: _grey),
            ),
        ],
      ),
    );
  }

  // Các icon cảm xúc chồng lên nhau một phần, viền trắng, cái đầu tiên nằm trên cùng như Facebook
  Widget _reactionStack(List<ReactionKind> kinds) {
    const icon = 18.0; // icon 18 + viền trắng 1.5 mỗi bên = 21
    const ring = 1.5;
    const step = 14.0;
    const total = icon + ring * 2;
    return SizedBox(
      width: total + (kinds.length - 1) * step,
      height: total,
      child: Stack(children: [
        // Vẽ từ cuối về đầu: cái vẽ sau nằm đè lên, nên cái đầu tiên nằm trên cùng
        for (var i = kinds.length - 1; i >= 0; i--)
          Positioned(
            left: i * step,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: ring),
              ),
              child: ReactionIcon(kind: kinds[i], size: icon),
            ),
          ),
      ]),
    );
  }
}
