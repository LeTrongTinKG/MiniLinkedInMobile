import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';

/// Nguồn dữ liệu cảm xúc/bình luận (API thật hoặc mock).
abstract interface class InteractionDataSource {
  Future<List<ReactionSummary>> summaries(String targetType, List<String> ids);
  Future<ReactionSummary> react(String targetType, String targetId, ReactionKind kind);
  Future<ReactionSummary> unreact(String targetType, String targetId);
  Future<CommentPage> comments(String targetType, String targetId, {int page, int limit});
  Future<CommentItem> addComment(String targetType, String targetId, String content);
  Future<void> deleteComment(String id);
}
