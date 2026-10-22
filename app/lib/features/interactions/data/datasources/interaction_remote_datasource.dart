import 'package:dio/dio.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import '../models/interaction_models.dart';
import 'interaction_datasource.dart';

class InteractionRemoteDataSource implements InteractionDataSource {
  InteractionRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<ReactionSummary>> summaries(String targetType, List<String> ids) async {
    final res = await _dio.get('/reactions/summary',
        queryParameters: {'targetType': targetType, 'ids': ids.join(',')});
    return (res.data['data'] as List)
        .map((e) => ReactionSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReactionSummary> react(String targetType, String targetId, ReactionKind kind) async {
    final res = await _dio.put('/reactions',
        data: {'targetType': targetType, 'targetId': targetId, 'type': kind.api});
    return ReactionSummaryModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ReactionSummary> unreact(String targetType, String targetId) async {
    final res = await _dio.delete('/reactions',
        queryParameters: {'targetType': targetType, 'targetId': targetId});
    return ReactionSummaryModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<CommentPage> comments(String targetType, String targetId,
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/comments', queryParameters: {
      'targetType': targetType,
      'targetId': targetId,
      'page': page,
      'limit': limit,
    });
    final meta = res.data['meta'] as Map<String, dynamic>;
    return CommentPage(
      items: (res.data['data'] as List)
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (meta['page'] as num).toInt(),
      limit: (meta['limit'] as num).toInt(),
      total: (meta['total'] as num).toInt(),
    );
  }

  @override
  Future<CommentItem> addComment(String targetType, String targetId, String content) async {
    final res = await _dio.post('/comments',
        data: {'targetType': targetType, 'targetId': targetId, 'content': content});
    return CommentModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteComment(String id) => _dio.delete('/comments/$id');
}
