import '../entities/comment_entity.dart';
import '../entities/reaction_kind.dart';
import '../entities/reaction_summary.dart';

/// Hợp đồng cho module cảm xúc + bình luận. targetType hiện chỉ có 'job'.
abstract interface class InteractionRepository {
  /// Tải summary của 1 tin; nhiều lời gọi sát nhau được gom thành 1 request.
  Future<ReactionSummary> loadSummary(String targetType, String targetId);

  Future<ReactionSummary> react(String targetType, String targetId, ReactionKind kind);
  Future<ReactionSummary> unreact(String targetType, String targetId);

  Future<CommentPage> comments(String targetType, String targetId, {int page = 1, int limit = 20});
  Future<CommentItem> addComment(String targetType, String targetId, String content);
  Future<void> deleteComment(String id);
}
