import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/cursor_page.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import '../../domain/entities/reactor.dart';
import '../../domain/entities/uploaded_media.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/social_remote_datasource.dart';

/// Gọi datasource và đổi mọi DioException thành AppException
/// ({error:{code,message}} -> ApiException, 401 -> UnauthorizedException).
class SocialRepositoryImpl implements SocialRepository {
  SocialRepositoryImpl(this._ds);
  final SocialRemoteDataSource _ds;

  // Giống try/catch quanh axios: bắt lỗi Dio rồi ném lại lỗi dễ hiểu
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  @override
  Future<CursorPage<Post>> getFeed({String? cursor, int limit = 10}) =>
      _guard(() => _ds.getFeed(cursor: cursor, limit: limit));

  @override
  Future<CursorPage<Post>> getUserPosts(String userId, {String? cursor, int limit = 10}) =>
      _guard(() => _ds.getUserPosts(userId, cursor: cursor, limit: limit));

  @override
  Future<Post> getPost(String postId) => _guard(() => _ds.getPost(postId));

  @override
  Future<Post> createPost(String content, List<String> mediaIds) =>
      _guard(() => _ds.createPost(content, mediaIds));

  @override
  Future<Post> updatePost(String postId, {String? content, List<String>? mediaIds}) =>
      _guard(() => _ds.updatePost(postId, content: content, mediaIds: mediaIds));

  @override
  Future<void> deletePost(String postId) => _guard(() => _ds.deletePost(postId));

  @override
  Future<Post> sharePost(String postId, String content) =>
      _guard(() => _ds.sharePost(postId, content));

  @override
  Future<UploadedMedia> uploadImage(List<int> bytes, String filename) =>
      _guard(() => _ds.uploadImage(bytes, filename));

  @override
  Future<ReactionSummary> setReaction(String postId, ReactionKind kind) =>
      _guard(() => _ds.setReaction(postId, kind));

  @override
  Future<ReactionSummary> removeReaction(String postId) =>
      _guard(() => _ds.removeReaction(postId));

  @override
  Future<List<Reactor>> getReactions(String postId, {ReactionKind? kind}) =>
      _guard(() => _ds.getReactions(postId, kind: kind));

  @override
  Future<CursorPage<Comment>> getComments(String postId, {String? cursor, int limit = 10}) =>
      _guard(() => _ds.getComments(postId, cursor: cursor, limit: limit));

  @override
  Future<CursorPage<Comment>> getReplies(String commentId, {String? cursor, int limit = 10}) =>
      _guard(() => _ds.getReplies(commentId, cursor: cursor, limit: limit));

  @override
  Future<Comment> createComment(String postId, String content, {String? parentId}) =>
      _guard(() => _ds.createComment(postId, content, parentId: parentId));

  @override
  Future<Comment> updateComment(String commentId, String content) =>
      _guard(() => _ds.updateComment(commentId, content));

  @override
  Future<void> deleteComment(String commentId) => _guard(() => _ds.deleteComment(commentId));

  @override
  Future<ReactionSummary> setCommentReaction(String commentId, ReactionKind kind) =>
      _guard(() => _ds.setCommentReaction(commentId, kind));

  @override
  Future<ReactionSummary> removeCommentReaction(String commentId) =>
      _guard(() => _ds.removeCommentReaction(commentId));
}
