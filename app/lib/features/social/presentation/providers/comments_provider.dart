import 'package:flutter/foundation.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import '../../domain/repositories/social_repository.dart';
import 'replies_state.dart';
import 'social_error.dart';

enum CommentsStatus { loading, ready, error }

/// State bình luận của MỘT bài viết (mỗi bài 1 provider, tạo khi mở khung bình luận).
/// Các hàm hành động trả về String? = thông báo lỗi, null = thành công.
class CommentsProvider extends ChangeNotifier {
  CommentsProvider(this._repo, this.postId, {this.onCountChanged, this.pageSize = 10});

  final SocialRepository _repo;
  final String postId;
  final int pageSize;

  /// Báo cho feed khi số bình luận đổi (vd: (d) => feed.bumpCommentCount(postId, d)).
  final void Function(int delta)? onCountChanged;

  // ---- state UI đọc ----
  List<Comment> comments = []; // bình luận gốc, cũ nhất lên đầu
  CommentsStatus status = CommentsStatus.loading;
  String? error;
  bool loadingMore = false;
  bool hasMore = false;
  final Map<String, RepliesState> replies = {}; // theo id bình luận gốc

  bool get isEmpty => status == CommentsStatus.ready && comments.isEmpty;
  RepliesState repliesOf(String commentId) => replies[commentId] ?? RepliesState();

  String? _cursor;

  // ---- tải bình luận gốc ----
  Future<void> loadInitial() async {
    status = CommentsStatus.loading;
    error = null;
    notifyListeners();
    try {
      final page = await _repo.getComments(postId, limit: pageSize);
      comments = page.items;
      _cursor = page.nextCursor;
      hasMore = page.hasMore;
      status = CommentsStatus.ready;
    } catch (e) {
      error = socialErrorMessage(e);
      status = CommentsStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (loadingMore || !hasMore || _cursor == null || status != CommentsStatus.ready) return;
    loadingMore = true;
    notifyListeners();
    try {
      final page = await _repo.getComments(postId, cursor: _cursor, limit: pageSize);
      comments = _appendUnique(comments, page.items);
      _cursor = page.nextCursor;
      hasMore = page.hasMore;
    } catch (e) {
      error = socialErrorMessage(e);
    }
    loadingMore = false;
    notifyListeners();
  }

  // ---- tải trả lời (lần đầu và các lần "xem thêm" đều gọi hàm này) ----
  Future<void> loadReplies(String commentId) async {
    final state = replies.putIfAbsent(commentId, RepliesState.new);
    if (state.loading || (state.loaded && !state.hasMore)) return;
    state.loading = true;
    state.error = null;
    notifyListeners();
    try {
      final page = await _repo.getReplies(commentId, cursor: state.cursor, limit: pageSize);
      state.items = _appendUnique(state.items, page.items);
      state.cursor = page.nextCursor;
      state.hasMore = page.hasMore;
      state.loaded = true;
    } catch (e) {
      state.error = socialErrorMessage(e);
    }
    state.loading = false;
    notifyListeners();
  }

  // ---- thêm / sửa / xóa ----
  /// parentId = id bình luận được trả lời (trả lời vào reply thì server tự gắn về bình luận gốc).
  Future<String?> addComment(String content, {String? parentId}) async {
    final text = content.trim();
    if (text.isEmpty) return 'Nội dung bình luận không được để trống';
    try {
      final c = await _repo.createComment(postId, text, parentId: parentId);
      final rootId = c.parentId;
      if (rootId == null) {
        comments = [...comments, c];
      } else {
        _mutate(rootId, (x) => x.copyWith(replyCount: x.replyCount + 1));
        final state = replies[rootId];
        // Chỉ chèn ngay khi đã tải hết trả lời; chưa thì lần tải sau sẽ có
        if (state != null && state.loaded && !state.hasMore) {
          state.items = _appendUnique(state.items, [c]);
        }
      }
      onCountChanged?.call(1);
      notifyListeners();
      return null;
    } catch (e) {
      return socialErrorMessage(e);
    }
  }

  Future<String?> updateComment(String commentId, String content) async {
    final text = content.trim();
    if (text.isEmpty) return 'Nội dung bình luận không được để trống';
    try {
      final updated = await _repo.updateComment(commentId, text);
      _mutate(commentId, (_) => updated);
      notifyListeners();
      return null;
    } catch (e) {
      return socialErrorMessage(e);
    }
  }

  Future<String?> deleteComment(String commentId) async {
    final target = _find(commentId);
    try {
      await _repo.deleteComment(commentId);
      final rootId = target?.parentId;
      if (rootId == null) {
        comments = comments.where((c) => c.id != commentId).toList();
        replies.remove(commentId);
      } else {
        replies[rootId]?.items = replies[rootId]!.items.where((c) => c.id != commentId).toList();
        _mutate(rootId, (x) => x.copyWith(replyCount: x.replyCount > 0 ? x.replyCount - 1 : 0));
      }
      onCountChanged?.call(-1);
      notifyListeners();
      return null;
    } catch (e) {
      return socialErrorMessage(e);
    }
  }

  // ---- cảm xúc bình luận (lạc quan) ----
  Future<String?> react(String commentId, ReactionKind? kind) async {
    final before = _find(commentId)?.reactionSummary;
    if (before == null) return null;
    _setSummary(commentId, before.withMyReaction(kind));
    try {
      final real = kind == null
          ? await _repo.removeCommentReaction(commentId)
          : await _repo.setCommentReaction(commentId, kind);
      _setSummary(commentId, real);
      return null;
    } catch (e) {
      _setSummary(commentId, before);
      return socialErrorMessage(e);
    }
  }

  // ---- nội bộ ----
  List<Comment> _appendUnique(List<Comment> old, List<Comment> more) {
    final have = old.map((c) => c.id).toSet();
    return [...old, ...more.where((c) => !have.contains(c.id))];
  }

  Comment? _find(String id) {
    for (final c in comments) {
      if (c.id == id) return c;
    }
    for (final s in replies.values) {
      for (final c in s.items) {
        if (c.id == id) return c;
      }
    }
    return null;
  }

  /// Đổi 1 bình luận (gốc hoặc trả lời).
  void _mutate(String id, Comment Function(Comment) change) {
    comments = [for (final c in comments) c.id == id ? change(c) : c];
    for (final s in replies.values) {
      s.items = [for (final c in s.items) c.id == id ? change(c) : c];
    }
  }

  void _setSummary(String id, ReactionSummary s) {
    _mutate(id, (c) => c.copyWith(reactionSummary: s));
    notifyListeners();
  }
}
