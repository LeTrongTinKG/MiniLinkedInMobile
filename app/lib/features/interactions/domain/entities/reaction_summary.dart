import 'reaction_kind.dart';

/// Tổng hợp cảm xúc + số bình luận của 1 tin tuyển dụng, kèm cảm xúc của chính mình.
class ReactionSummary {
  const ReactionSummary({
    required this.targetType,
    required this.targetId,
    required this.total,
    required this.counts,
    required this.top,
    required this.myReaction,
    required this.commentCount,
  });

  final String targetType;
  final String targetId;
  final int total;
  final Map<ReactionKind, int> counts;
  final List<ReactionKind> top;
  final ReactionKind? myReaction;
  final int commentCount;

  factory ReactionSummary.empty(String targetType, String targetId) =>
      ReactionSummary(
        targetType: targetType,
        targetId: targetId,
        total: 0,
        counts: const {},
        top: const [],
        myReaction: null,
        commentCount: 0,
      );

  /// Tính trước kết quả ở máy để UI đổi ngay khi bấm (optimistic update).
  ReactionSummary withMyReaction(ReactionKind? next) {
    final c = Map<ReactionKind, int>.from(counts);
    if (myReaction != null) {
      final left = (c[myReaction!] ?? 1) - 1;
      if (left <= 0) {
        c.remove(myReaction);
      } else {
        c[myReaction!] = left;
      }
    }
    if (next != null) c[next] = (c[next] ?? 0) + 1;
    final sorted = c.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ReactionSummary(
      targetType: targetType,
      targetId: targetId,
      total: c.values.fold(0, (s, n) => s + n),
      counts: c,
      top: sorted.take(3).map((e) => e.key).toList(),
      myReaction: next,
      commentCount: commentCount,
    );
  }

  ReactionSummary withCommentCount(int n) => ReactionSummary(
        targetType: targetType,
        targetId: targetId,
        total: total,
        counts: counts,
        top: top,
        myReaction: myReaction,
        commentCount: n < 0 ? 0 : n,
      );
}
