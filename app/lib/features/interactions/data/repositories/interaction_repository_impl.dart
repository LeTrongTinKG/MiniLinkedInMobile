import 'dart:async';
import 'package:dio/dio.dart';
import 'package:app/core/error/app_exception.dart';
import 'package:app/core/network/dio_client.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import '../../domain/repositories/interaction_repository.dart';
import '../datasources/interaction_datasource.dart';

class InteractionRepositoryImpl implements InteractionRepository {
  InteractionRepositoryImpl(this._ds);
  final InteractionDataSource _ds;

  // Gom nhiều loadSummary sát nhau (cả danh sách job) thành 1 request.
  static const _maxIds = 50; // backend nhận tối đa 50 id / request
  final Map<String, Map<String, Completer<ReactionSummary>>> _pending = {};
  Timer? _timer;

  @override
  Future<ReactionSummary> loadSummary(String targetType, String targetId) {
    final byType = _pending.putIfAbsent(targetType, () => {});
    final completer =
        byType.putIfAbsent(targetId, () => Completer<ReactionSummary>());
    _timer ??= Timer(const Duration(milliseconds: 40), _flush);
    return completer.future;
  }

  Future<void> _flush() async {
    _timer = null;
    final batch = Map.of(_pending);
    _pending.clear();

    for (final entry in batch.entries) {
      final ids = entry.value.keys.toList();
      for (var i = 0; i < ids.length; i += _maxIds) {
        final end = i + _maxIds > ids.length ? ids.length : i + _maxIds;
        final chunk = ids.sublist(i, end);
        try {
          final list = await _guard(() => _ds.summaries(entry.key, chunk));
          final byId = {for (final s in list) s.targetId: s};
          for (final id in chunk) {
            entry.value[id]!
                .complete(byId[id] ?? ReactionSummary.empty(entry.key, id));
          }
        } catch (e, st) {
          for (final id in chunk) {
            entry.value[id]!.completeError(e, st);
          }
        }
      }
    }
  }

  /// Đổi DioException thành AppException để tầng UI hiện đúng thông báo.
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  @override
  Future<ReactionSummary> react(String t, String id, ReactionKind kind) =>
      _guard(() => _ds.react(t, id, kind));

  @override
  Future<ReactionSummary> unreact(String t, String id) =>
      _guard(() => _ds.unreact(t, id));

  @override
  Future<CommentPage> comments(String t, String id, {int page = 1, int limit = 20}) =>
      _guard(() => _ds.comments(t, id, page: page, limit: limit));

  @override
  Future<CommentItem> addComment(String t, String id, String content) =>
      _guard(() => _ds.addComment(t, id, content));

  @override
  Future<void> deleteComment(String id) => _guard(() => _ds.deleteComment(id));
}

/// Lấy message hiển thị cho người dùng từ mọi loại lỗi.
String interactionErrorMessage(Object e) =>
    e is AppException ? e.message : 'Có lỗi xảy ra, thử lại sau';
