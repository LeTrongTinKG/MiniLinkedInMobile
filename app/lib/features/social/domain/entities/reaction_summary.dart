import 'reaction_kind.dart';

/// Tóm tắt cảm xúc của 1 bài/bình luận: tổng, số từng loại, top 3 loại, cảm xúc của mình.
class ReactionSummary {
  const ReactionSummary({
    this.total = 0,
    this.counts = const {},
    this.top = const [],
    this.myReaction,
  });

  final int total;
  final Map<ReactionKind, int> counts;
  final List<ReactionKind> top; // tối đa 3 loại nhiều nhất, để hiện icon
  final ReactionKind? myReaction; // null = mình chưa thả

  static const empty = ReactionSummary();

  /// Tính lại summary khi MÌNH đổi cảm xúc (dùng cho cập nhật lạc quan).
  /// next = null nghĩa là bỏ cảm xúc.
  ReactionSummary withMyReaction(ReactionKind? next) {
    if (next == myReaction) return this;
    final newCounts = Map<ReactionKind, int>.of(counts);
    final old = myReaction;
    if (old != null) newCounts[old] = (newCounts[old] ?? 1) - 1;
    if (next != null) newCounts[next] = (newCounts[next] ?? 0) + 1;

    // Tổng và top tính lại từ số đếm (giống cách server tính)
    final total = newCounts.values.fold<int>(0, (a, b) => a + (b < 0 ? 0 : b));
    final kinds = ReactionKind.values.where((k) => (newCounts[k] ?? 0) > 0).toList()
      ..sort((a, b) => newCounts[b]!.compareTo(newCounts[a]!));
    return ReactionSummary(
      total: total,
      counts: newCounts,
      top: kinds.take(3).toList(),
      myReaction: next,
    );
  }
}
