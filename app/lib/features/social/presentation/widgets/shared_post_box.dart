import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/post.dart';
import '../social_strings.dart';
import 'post_header.dart';
import 'post_images_grid.dart';
import 'post_text.dart';

/// Khung bài GỐC nằm lồng trong bài chia sẻ. Bài gốc đã xóa thì hiện ô xám thông báo.
class SharedPostBox extends StatelessWidget {
  const SharedPostBox({super.key, required this.original, required this.onOpenImage});

  final Post original;
  final void Function(int index) onOpenImage;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: UiTokens.border);

    // Bài gốc đã bị xóa
    if (original.isDeleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: UiTokens.muted, border: border, borderRadius: BorderRadius.circular(8)),
        child: const Text(SocialStrings.sharedGone,
            textAlign: TextAlign.center, style: TextStyle(color: UiTokens.mutedForeground)),
      );
    }

    return Container(
      decoration: BoxDecoration(border: border, borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostImagesGrid(media: original.media, onTap: onOpenImage),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostHeader(post: original), // không truyền onEdit/onDelete -> không có menu
                const SizedBox(height: 8),
                PostText(content: original.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
