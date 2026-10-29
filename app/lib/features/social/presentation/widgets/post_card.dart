import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/post.dart';
import 'post_action_bar.dart';
import 'post_actions.dart';
import 'post_header.dart';
import 'post_images_grid.dart';
import 'post_stats_row.dart';
import 'post_text.dart';
import 'shared_post_box.dart';

/// Thẻ 1 bài viết. Ghép từ các widget con (giống component cha import component con trong React).
/// Từ trên xuống: header -> chữ -> ảnh / bài gốc chia sẻ -> thống kê -> 3 nút.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final shared = post.sharedPost;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
            child: PostHeader(
              post: post,
              onEdit: () => openEditPost(context, post),
              onDelete: () => confirmDeletePost(context, post),
            ),
          ),

          // 2. Chữ
          if (post.content.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: PostText(content: post.content),
            ),

          // 3. Bài gốc được chia sẻ (nếu là bài chia sẻ)
          if (shared != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: SharedPostBox(
                original: shared,
                onOpenImage: (i) => openImageViewer(context, shared.media, i),
              ),
            ),

          // 4. Ảnh của bài
          PostImagesGrid(
            media: post.media,
            onTap: (i) => openImageViewer(context, post.media, i),
          ),

          // 5. Thống kê
          PostStatsRow(
            post: post,
            onReactionsTap: () => openReactors(context, post),
            onCommentsTap: () => openComments(context, post),
          ),

          // 6. Ba nút
          const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: AppDivider()),
          PostActionBar(
            post: post,
            onReact: (kind) => reactToPost(context, post, kind),
            onComment: () => openComments(context, post),
            onShare: () => openShareSheet(context, post),
          ),
        ],
      ),
    );
  }
}
