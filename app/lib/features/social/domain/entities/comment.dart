import 'post_author.dart';
import 'reaction_summary.dart';

/// Bình luận (cấp 1) hoặc trả lời (cấp 2, có parentId).
class Comment {
  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.postId,
    this.parentId,
    this.replyCount = 0,
    this.reactionSummary = ReactionSummary.empty,
    this.isMine = false,
    this.editedAt,
  });

  final String id;
  final String? postId;
  final String? parentId; // null = bình luận gốc
  final PostAuthor author;
  final String content;
  final int replyCount;
  final ReactionSummary reactionSummary;
  final bool isMine;
  final DateTime createdAt;
  final DateTime? editedAt;

  Comment copyWith({
    String? content,
    int? replyCount,
    ReactionSummary? reactionSummary,
    DateTime? editedAt,
  }) {
    return Comment(
      id: id,
      postId: postId,
      parentId: parentId,
      author: author,
      createdAt: createdAt,
      isMine: isMine,
      content: content ?? this.content,
      replyCount: replyCount ?? this.replyCount,
      reactionSummary: reactionSummary ?? this.reactionSummary,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}
