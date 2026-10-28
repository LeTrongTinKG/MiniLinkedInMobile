import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_media.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/repositories/social_repository.dart';
import '../providers/comments_provider.dart';
import '../providers/social_feed_provider.dart';
import '../screens/create_post_screen.dart';
import '../social_strings.dart';
import 'comments_sheet.dart';
import 'image_viewer_screen.dart';
import 'reactors_sheet.dart';
import 'share_sheet.dart';

// Các hành động của 1 bài (giống các hàm handleXxx trong component React).
// Màn/sheet mở ra nằm ở route khác nên không "thấy" Provider của trang;
// vì vậy ta lấy provider ra trước rồi truyền xuống bằng ChangeNotifierProvider.value.

/// Mở màn soạn bài mới.
void openCreatePost(BuildContext context, {required String userName, String? userAvatar}) {
  final feed = context.read<SocialFeedProvider>();
  Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: feed,
      child: CreatePostScreen(userName: userName, userAvatar: userAvatar),
    ),
  ));
}

/// Mở màn sửa bài (cùng màn soạn bài, chế độ edit).
void openEditPost(BuildContext context, Post post) {
  final feed = context.read<SocialFeedProvider>();
  Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: feed,
      child: CreatePostScreen(
        userName: post.author.fullName,
        userAvatar: post.author.avatarUrl,
        editing: post,
      ),
    ),
  ));
}

/// Hỏi xác nhận rồi xóa bài.
Future<void> confirmDeletePost(BuildContext context, Post post) async {
  final feed = context.read<SocialFeedProvider>();
  final ok = await showAppConfirmDialog(context,
      title: SocialStrings.deletePostTitle,
      message: SocialStrings.deletePostMessage,
      confirmLabel: SocialStrings.menuDelete,
      destructive: true);
  if (!ok) return;
  final error = await feed.deletePost(post.id);
  if (!context.mounted) return;
  error == null ? showAppSuccess(context, SocialStrings.deletedOk) : showAppError(context, error);
}

/// Thả / bỏ cảm xúc cho bài. kind = null là bỏ.
Future<void> reactToPost(BuildContext context, Post post, ReactionKind? kind) async {
  final error = await context.read<SocialFeedProvider>().react(post.id, kind);
  if (error != null && context.mounted) showAppError(context, error);
}

/// Mở sheet bình luận, mỗi lần mở tạo 1 CommentsProvider riêng cho bài này.
void openComments(BuildContext context, Post post) {
  final feed = context.read<SocialFeedProvider>();
  final repo = context.read<SocialRepository>();
  showAppBottomSheet(
    context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => CommentsProvider(
        repo,
        post.id,
        onCountChanged: (delta) => feed.bumpCommentCount(post.id, delta), // cập nhật số ở feed
      )..loadInitial(),
      child: CommentsSheet(canModerate: post.isMine),
    ),
  );
}

/// Mở sheet chia sẻ.
void openShareSheet(BuildContext context, Post post) {
  final feed = context.read<SocialFeedProvider>();
  showAppBottomSheet(
    context,
    builder: (_) => ShareSheet(post: post, onShare: (text) => feed.sharePost(post.id, text)),
  );
}

/// Mở sheet danh sách người đã thả cảm xúc.
void openReactors(BuildContext context, Post post) {
  final feed = context.read<SocialFeedProvider>();
  showAppBottomSheet(
    context,
    builder: (_) => ReactorsSheet(loader: () => feed.loadReactors(post.id)),
  );
}

/// Xem ảnh toàn màn hình.
void openImageViewer(BuildContext context, List<PostMedia> media, int index) {
  Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => ImageViewerScreen(media: media, initialIndex: index),
  ));
}
