import 'dart:math';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import 'interaction_datasource.dart';

/// Dữ liệu giả trong bộ nhớ để phát triển UI khi chưa có backend.
class InteractionMockDataSource implements InteractionDataSource {
  final Map<String, ReactionSummary> _summaries = {};
  final Map<String, List<CommentItem>> _comments = {};

  static const _me = CommentAuthor(id: 'me', fullName: 'Bạn');

  String _key(String type, String id) => '$type:$id';

  ReactionSummary _seed(String type, String id) {
    final rnd = Random(id.hashCode);
    final kinds = ReactionKind.values;
    final counts = <ReactionKind, int>{};
    for (var i = 0; i < rnd.nextInt(30); i++) {
      final k = kinds[rnd.nextInt(kinds.length)];
      counts[k] = (counts[k] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return ReactionSummary(
      targetType: type,
      targetId: id,
      total: counts.values.fold(0, (s, n) => s + n),
      counts: counts,
      top: sorted.take(3).map((e) => e.key).toList(),
      myReaction: null,
      commentCount: rnd.nextInt(6),
    );
  }

  ReactionSummary _get(String type, String id) =>
      _summaries.putIfAbsent(_key(type, id), () => _seed(type, id));

  List<CommentItem> _commentsOf(String type, String id) =>
      _comments.putIfAbsent(_key(type, id), () {
        final n = _get(type, id).commentCount;
        return [
          for (var i = 0; i < n; i++)
            CommentItem(
              id: '$id-seed-$i',
              content: 'Bình luận mẫu số ${i + 1}',
              createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
              author: CommentAuthor(id: 'u$i', fullName: 'Người dùng ${i + 1}'),
              isMine: false,
            ),
        ];
      });

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 250));

  @override
  Future<List<ReactionSummary>> summaries(String targetType, List<String> ids) async {
    await _delay();
    return [for (final id in ids) _get(targetType, id)];
  }

  @override
  Future<ReactionSummary> react(String targetType, String targetId, ReactionKind kind) async {
    await _delay();
    return _summaries[_key(targetType, targetId)] =
        _get(targetType, targetId).withMyReaction(kind);
  }

  @override
  Future<ReactionSummary> unreact(String targetType, String targetId) async {
    await _delay();
    return _summaries[_key(targetType, targetId)] =
        _get(targetType, targetId).withMyReaction(null);
  }

  @override
  Future<CommentPage> comments(String targetType, String targetId,
      {int page = 1, int limit = 20}) async {
    await _delay();
    final all = _commentsOf(targetType, targetId);
    final start = (page - 1) * limit;
    final items = start >= all.length ? <CommentItem>[] : all.skip(start).take(limit).toList();
    return CommentPage(items: items, page: page, limit: limit, total: all.length);
  }

  @override
  Future<CommentItem> addComment(String targetType, String targetId, String content) async {
    await _delay();
    final item = CommentItem(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      content: content,
      createdAt: DateTime.now(),
      author: _me,
      isMine: true,
    );
    _commentsOf(targetType, targetId).insert(0, item);
    final s = _get(targetType, targetId);
    _summaries[_key(targetType, targetId)] = s.withCommentCount(s.commentCount + 1);
    return item;
  }

  @override
  Future<void> deleteComment(String id) async {
    await _delay();
    for (final e in _comments.entries) {
      if (e.value.any((c) => c.id == id)) {
        e.value.removeWhere((c) => c.id == id);
        final s = _summaries[e.key];
        if (s != null) _summaries[e.key] = s.withCommentCount(s.commentCount - 1);
        return;
      }
    }
  }
}
