import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';

/// Parse JSON của backend sang entity.
class ReactionSummaryModel {
  ReactionSummaryModel._();

  static ReactionSummary fromJson(Map<String, dynamic> j) {
    final counts = <ReactionKind, int>{};
    (j['counts'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      final kind = ReactionKind.fromApi(k);
      if (kind != null) counts[kind] = (v as num).toInt();
    });
    return ReactionSummary(
      targetType: j['targetType'] as String,
      targetId: j['targetId'] as String,
      total: (j['total'] as num).toInt(),
      counts: counts,
      top: (j['top'] as List? ?? [])
          .map((e) => ReactionKind.fromApi(e as String))
          .whereType<ReactionKind>()
          .toList(),
      myReaction: ReactionKind.fromApi(j['myReaction'] as String?),
      commentCount: (j['commentCount'] as num? ?? 0).toInt(),
    );
  }
}

class CommentModel {
  CommentModel._();

  static CommentItem fromJson(Map<String, dynamic> j) {
    final a = j['author'] as Map<String, dynamic>;
    return CommentItem(
      id: j['id'] as String,
      content: j['content'] as String,
      createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      author: CommentAuthor(
        id: a['id'] as String,
        fullName: a['fullName'] as String? ?? 'Người dùng',
        avatarUrl: a['avatarUrl'] as String?,
      ),
      isMine: j['isMine'] as bool? ?? false,
    );
  }
}
