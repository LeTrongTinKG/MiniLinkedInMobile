import 'package:flutter/foundation.dart';
import '../../data/repositories/interaction_repository_impl.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import '../../domain/repositories/interaction_repository.dart';

/// Giữ state cảm xúc của các tin tuyển dụng.
/// UI đổi NGAY khi bấm (optimistic), request chạy sau; lỗi thì trả về trạng thái
/// đã được server xác nhận và báo lỗi cho người dùng.
class InteractionProvider extends ChangeNotifier {
  InteractionProvider(this._repo);

  final InteractionRepository _repo;

  static const targetJob = 'job';

  final Map<String, ReactionSummary> _view = {}; // đang hiển thị (có optimistic)
  final Map<String, ReactionSummary> _confirmed = {}; // server đã xác nhận
  final Set<String> _loading = {};
  final Set<String> _failedLoad = {};
  final Set<String> _flushing = {};

  ReactionSummary? summaryOf(String id) => _view[id];
  bool isFailed(String id) => _failedLoad.contains(id);

  Future<void> ensureLoaded(String id) async {
    if (_view.containsKey(id) || _loading.contains(id)) return;
    _loading.add(id);
    _failedLoad.remove(id);
    try {
      final s = await _repo.loadSummary(targetJob, id);
      _confirmed[id] = s;
      _view[id] = s;
    } catch (_) {
      _failedLoad.add(id);
    } finally {
      _loading.remove(id);
      notifyListeners();
    }
  }

  Future<void> retryLoad(String id) {
    _failedLoad.remove(id);
    notifyListeners();
    return ensureLoaded(id);
  }

  /// Thả/đổi/bỏ cảm xúc. Trả về thông báo lỗi nếu server từ chối, ngược lại null.
  /// Có thể bấm liên tiếp: chỉ gửi trạng thái cuối cùng người dùng chọn.
  Future<String?> react(String id, ReactionKind? next) async {
    final cur = _view[id];
    if (cur == null) return null;
    _view[id] = cur.withMyReaction(next); // 1. đổi UI ngay
    notifyListeners();
    if (!_flushing.add(id)) return null; // đang có vòng gửi, nó sẽ lấy trạng thái mới nhất

    String? error;
    try {
      while (true) {
        final want = _view[id]!.myReaction;
        final base = _confirmed[id]!;
        if (want == base.myReaction) break;
        try {
          final fresh = want == null
              ? await _repo.unreact(targetJob, id)
              : await _repo.react(targetJob, id, want);
          _confirmed[id] = fresh;
          // người dùng có thể đã bấm tiếp trong lúc chờ: chỉ ghi đè khi chưa đổi ý
          if (_view[id]!.myReaction == want) _view[id] = fresh;
        } catch (e) {
          error = interactionErrorMessage(e);
          _view[id] = _confirmed[id]!.withCommentCount(_view[id]!.commentCount); // 2. lỗi: về như cũ
          break;
        }
      }
    } finally {
      _flushing.remove(id);
      notifyListeners();
    }
    return error;
  }

  /// Cập nhật số bình luận (sau khi thêm/xoá ở bottom sheet).
  void adjustCommentCount(String id, int delta) {
    final cur = _view[id];
    if (cur == null) return;
    _view[id] = cur.withCommentCount(cur.commentCount + delta);
    final c = _confirmed[id];
    if (c != null) _confirmed[id] = c.withCommentCount(c.commentCount + delta);
    notifyListeners();
  }
}
