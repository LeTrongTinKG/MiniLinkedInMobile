import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/post.dart';
import '../social_strings.dart';
import '../utils/time_ago.dart';

/// Hàng đầu của bài: avatar + tên + "x phút trước · Đã chỉnh sửa" + menu "..." (chỉ bài của mình).
class PostHeader extends StatelessWidget {
  const PostHeader({super.key, required this.post, this.onEdit, this.onDelete});

  final Post post;
  final VoidCallback? onEdit; // null cả hai = không hiện menu (vd bài gốc được lồng)
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final time = timeAgo(post.createdAt);
    final subtitle = post.editedAt == null ? time : '$time · ${SocialStrings.edited}';
    final showMenu = post.isMine && onEdit != null && onDelete != null;

    return Row(
      children: [
        AppAvatar(imageUrl: post.author.avatarUrl, name: post.author.fullName, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.author.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: UiTokens.mutedForeground)),
            ],
          ),
        ),
        if (showMenu)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) => value == 'edit' ? onEdit!() : onDelete!(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text(SocialStrings.menuEdit)),
              PopupMenuItem(value: 'delete', child: Text(SocialStrings.menuDelete)),
            ],
          ),
      ],
    );
  }
}
