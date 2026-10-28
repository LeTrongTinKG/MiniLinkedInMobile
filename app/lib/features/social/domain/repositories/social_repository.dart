import '../entities/comment.dart';
import '../entities/cursor_page.dart';
import '../entities/post.dart';
import '../entities/reaction_kind.dart';
import '../entities/reaction_summary.dart';
import '../entities/reactor.dart';
import '../entities/uploaded_media.dart';

/// Hợp đồng dữ liệu mạng xã hội. Lỗi được ném ra dạng AppException.
abstract interface class SocialRepository {
  Future<CursorPage<Post>> getFeed({String? cursor, int limit = 10});
  Future<CursorPage<Post>> getUserPosts(String userId, {String? cursor, int limit = 10});
  Future<Post> getPost(String postId);
  Future<Post> createPost(String content, List<String> mediaIds);
  Future<Post> updatePost(String postId, {String? content, List<String>? mediaIds});
  Future<void> deletePost(String postId);
  Future<Post> sharePost(String postId, String content);

  Future<UploadedMedia> uploadImage(List<int> bytes, String filename);

  Future<ReactionSummary> setReaction(String postId, ReactionKind kind);
  Future<ReactionSummary> removeReaction(String postId);
  Future<List<Reactor>> getReactions(String postId, {ReactionKind? kind});

  Future<CursorPage<Comment>> getComments(String postId, {String? cursor, int limit = 10});
  Future<CursorPage<Comment>> getReplies(String commentId, {String? cursor, int limit = 10});
  Future<Comment> createComment(String postId, String content, {String? parentId});
  Future<Comment> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
  Future<ReactionSummary> setCommentReaction(String commentId, ReactionKind kind);
  Future<ReactionSummary> removeCommentReaction(String commentId);
}
