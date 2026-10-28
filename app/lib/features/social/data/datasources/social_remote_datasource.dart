import 'package:dio/dio.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/cursor_page.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import '../../domain/entities/reactor.dart';
import '../../domain/entities/uploaded_media.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../social_api_config.dart';
import 'image_check.dart';

/// Gọi API /api/social bằng Dio (giống axios). Mọi URL là URL tuyệt đối
/// nên vẫn đi qua interceptor gắn token của dioClient.
/// Lỗi ở đây là DioException; tầng repository sẽ dịch sang AppException.
class SocialRemoteDataSource {
  SocialRemoteDataSource(this._dio);
  final Dio _dio;

  Map<String, dynamic> _paging(String? cursor, int limit) =>
      {'limit': limit, if (cursor != null) 'cursor': cursor};

  // ---------- Bài viết ----------
  Future<CursorPage<Post>> getFeed({String? cursor, int limit = 10}) async {
    final res = await _dio.get(socialUrl('/posts'), queryParameters: _paging(cursor, limit));
    return pageFromResponse(res.data, postFromJson);
  }

  Future<CursorPage<Post>> getUserPosts(String userId, {String? cursor, int limit = 10}) async {
    final res = await _dio.get(socialUrl('/users/$userId/posts'),
        queryParameters: _paging(cursor, limit));
    return pageFromResponse(res.data, postFromJson);
  }

  Future<Post> getPost(String postId) async {
    final res = await _dio.get(socialUrl('/posts/$postId'));
    return postFromJson(asMap(res.data)['data']);
  }

  Future<Post> createPost(String content, List<String> mediaIds) async {
    final res = await _dio.post(socialUrl('/posts'),
        data: {'content': content, 'mediaIds': mediaIds});
    return postFromJson(asMap(res.data)['data']);
  }

  Future<Post> updatePost(String postId, {String? content, List<String>? mediaIds}) async {
    final res = await _dio.patch(socialUrl('/posts/$postId'), data: {
      if (content != null) 'content': content,
      if (mediaIds != null) 'mediaIds': mediaIds,
    });
    return postFromJson(asMap(res.data)['data']);
  }

  Future<void> deletePost(String postId) => _dio.delete(socialUrl('/posts/$postId'));

  Future<Post> sharePost(String postId, String content) async {
    final res = await _dio.post(socialUrl('/posts/$postId/shares'), data: {'content': content});
    return postFromJson(asMap(res.data)['data']);
  }

  // ---------- Ảnh ----------
  Future<UploadedMedia> uploadImage(List<int> bytes, String filename) async {
    checkImage(bytes, filename); // sai loại / quá 10MB thì dừng ngay, không gọi mạng
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(imageMime(bytes)),
      ),
    });
    final res = await _dio.post(socialUrl('/media'), data: form);
    return uploadedFromJson(asMap(res.data)['data']);
  }

  // ---------- Cảm xúc ----------
  Future<ReactionSummary> setReaction(String postId, ReactionKind kind) async {
    final res = await _dio.put(socialUrl('/posts/$postId/reaction'), data: {'type': kind.api});
    return summaryFromJson(asMap(res.data)['data']);
  }

  Future<ReactionSummary> removeReaction(String postId) async {
    final res = await _dio.delete(socialUrl('/posts/$postId/reaction'));
    return summaryFromJson(asMap(res.data)['data']);
  }

  Future<List<Reactor>> getReactions(String postId, {ReactionKind? kind}) async {
    final res = await _dio.get(socialUrl('/posts/$postId/reactions'),
        queryParameters: {if (kind != null) 'type': kind.api});
    final list = asMap(res.data)['data'];
    return [for (final x in (list is List ? list : const [])) reactorFromJson(x)];
  }

  Future<ReactionSummary> setCommentReaction(String commentId, ReactionKind kind) async {
    final res =
        await _dio.put(socialUrl('/comments/$commentId/reaction'), data: {'type': kind.api});
    return summaryFromJson(asMap(res.data)['data']);
  }

  Future<ReactionSummary> removeCommentReaction(String commentId) async {
    final res = await _dio.delete(socialUrl('/comments/$commentId/reaction'));
    return summaryFromJson(asMap(res.data)['data']);
  }

  // ---------- Bình luận ----------
  Future<CursorPage<Comment>> getComments(String postId, {String? cursor, int limit = 10}) async {
    final res = await _dio.get(socialUrl('/posts/$postId/comments'),
        queryParameters: _paging(cursor, limit));
    return pageFromResponse(res.data, commentFromJson);
  }

  Future<CursorPage<Comment>> getReplies(String commentId, {String? cursor, int limit = 10}) async {
    final res = await _dio.get(socialUrl('/comments/$commentId/replies'),
        queryParameters: _paging(cursor, limit));
    return pageFromResponse(res.data, commentFromJson);
  }

  Future<Comment> createComment(String postId, String content, {String? parentId}) async {
    final res = await _dio.post(socialUrl('/posts/$postId/comments'),
        data: {'content': content, if (parentId != null) 'parentId': parentId});
    return commentFromJson(asMap(res.data)['data']);
  }

  Future<Comment> updateComment(String commentId, String content) async {
    final res = await _dio.patch(socialUrl('/comments/$commentId'), data: {'content': content});
    return commentFromJson(asMap(res.data)['data']);
  }

  Future<void> deleteComment(String commentId) =>
      _dio.delete(socialUrl('/comments/$commentId'));
}
