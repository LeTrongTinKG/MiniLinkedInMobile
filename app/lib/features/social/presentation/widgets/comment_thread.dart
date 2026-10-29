import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/comment.dart';
import '../providers/comments_provider.dart';
import '../social_strings.dart';
import 'comment_tile.dart';

/// 1 bình luận gốc + phần phản hồi của nó (thụt lề, mở bằng "Xem N phản hồi").
class CommentThread extends StatelessWidget {
  const CommentThread({
    super.key,
    required this.comment,
    required this.canModerate,
    required this.onReply,
  });

  final Comment comment;
  final bool canModerate; // mình là chủ bài -> được xóa mọi bình luận
  final void Function(Comment c) onReply;

  @override
  Widget build(BuildContext context) {
    // context.watch ~ useContext: provider đổi thì build lại
    final replies = context.watch<CommentsProvider>().repliesOf(comment.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentTile(
              comment: comment, canDelete: canModerate || comment.isMine, onReply: onReply),

          // Chưa mở phản hồi -> nút "Xem N phản hồi"
          if (comment.replyCount > 0 && !replies.loaded)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 4),
              child: replies.loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : _linkButton(
                      context,
                      SocialStrings.viewReplies(comment.replyCount),
                      () => _loadReplies(context),
                    ),
            ),

          // Đã mở -> danh sách phản hồi thụt lề
          if (replies.loaded)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final r in replies.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CommentTile(
                        comment: r,
                        isReply: true,
                        canDelete: canModerate || r.isMine,
                        onReply: onReply,
                      ),
                    ),
                  if (replies.hasMore)
                    _linkButton(context, SocialStrings.loadMoreReplies, () => _loadReplies(context)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadReplies(BuildContext context) async {
    final provider = context.read<CommentsProvider>();
    await provider.loadReplies(comment.id);
    final error = provider.repliesOf(comment.id).error;
    if (error != null && context.mounted) showAppError(context, error);
  }

  Widget _linkButton(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: UiTokens.mutedForeground)),
      ),
    );
  }
}
