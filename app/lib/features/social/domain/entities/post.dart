import 'post_author.dart';
import 'post_media.dart';
import 'reaction_summary.dart';

/// Bài viết. Bài chia sẻ có `sharedPost` (bài gốc, hoặc bản "đã xóa").
class Post {
  const Post({
    required this.id,
    required this.author,
    required this.createdAt,
    this.content = '',
    this.media = const [],
    this.reactionSummary = ReactionSummary.empty,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isMine = false,
    this.sharedPost,
    this.editedAt,
    this.isDeleted = false,
  });

  final String id;
  final PostAuthor author;
  final String content;
  final List<PostMedia> media;
  final ReactionSummary reactionSummary;
  final int commentCount;
  final int shareCount;
  final bool isMine;
  final Post? sharedPost;
  final DateTime createdAt;
  final DateTime? editedAt;

  /// true khi đây là bản thay thế cho bài gốc đã bị xóa; lúc đó `content` là câu thông báo.
  final bool isDeleted;

  Post copyWith({
    String? content,
    List<PostMedia>? media,
    ReactionSummary? reactionSummary,
    int? commentCount,
    int? shareCount,
    DateTime? editedAt,
  }) {
    return Post(
      id: id,
      author: author,
      createdAt: createdAt,
      content: content ?? this.content,
      media: media ?? this.media,
      reactionSummary: reactionSummary ?? this.reactionSummary,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isMine: isMine,
      sharedPost: sharedPost,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted,
    );
  }
}
