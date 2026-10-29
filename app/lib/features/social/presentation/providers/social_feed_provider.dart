import 'package:flutter/foundation.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import '../../domain/entities/reactor.dart';
import '../../domain/entities/uploaded_media.dart';
import '../../domain/repositories/social_repository.dart';
import 'post_uploader.dart';
import 'social_error.dart';

enum FeedStatus { loading, ready, error }

/// State của bảng tin. Giống 1 component React dùng useState:
/// ChangeNotifier ~ state + hàm cập nhật, notifyListeners() ~ setState.
/// Các hàm hành động (react, xóa, sửa...) trả về String? = thông báo lỗi, null = thành công.
class SocialFeedProvider extends ChangeNotifier {
  SocialFeedProvider(this._repo, {this.pageSize = 10}) {
    uploader = PostUploader(_repo, notifyListeners);
  }

  final SocialRepository _repo;
  final int pageSize;
  late final PostUploader uploader; // tiến độ tải ảnh khi tạo bài

  // ---- state UI đọc ----
  List<Post> posts = [];
  FeedStatus status = FeedStatus.loading;
  String? error; // lỗi tải feed (status=error) hoặc lỗi làm mới khi đã có bài
  bool loadingMore = false;
  bool hasMore = false;
  bool creating = false;
  String? createError;

  bool get isEmpty => status == FeedStatus.ready && posts.isEmpty;
  List<UploadItem> get uploads => uploader.items;

  String? _cursor;
  int _gen = 0; // tăng mỗi lần refresh để bỏ kết quả của request cũ
  final Set<String> _reacting = {}; // bài đang gửi react (chống bấm chồng)

  // ---- tải feed ----
  Future<void> loadInitial() => refresh();

  Future<void> refresh() async {
    final gen = ++_gen;
    loadingMore = false;
    if (posts.isEmpty) {
      status = FeedStatus.loading;
      notifyListeners();
    }
    try {
      final page = await _repo.getFeed(limit: pageSize);
      if (gen != _gen) return;
      posts = page.items;
      _cursor = page.nextCursor;
      hasMore = page.hasMore;
      status = FeedStatus.ready;
      error = null;
    } catch (e) {
      if (gen != _gen) return;
      error = socialErrorMessage(e);
      if (posts.isEmpty) status = FeedStatus.error;
    }
    notifyListeners();
  }

  /// Kéo xuống cuối thì gọi. Đang tải / hết bài thì bỏ qua (chống gọi trùng).
  Future<void> loadMore() async {
    if (loadingMore || !hasMore || status != FeedStatus.ready || _cursor == null) return;
    final gen = _gen;
    loadingMore = true;
    notifyListeners();
    try {
      final page = await _repo.getFeed(cursor: _cursor, limit: pageSize);
      if (gen != _gen) return;
      final have = posts.map((p) => p.id).toSet();
      posts = [...posts, ...page.items.where((p) => !have.contains(p.id))];
      _cursor = page.nextCursor;
      hasMore = page.hasMore;
      error = null; // tải thêm thành công thì xóa lỗi cũ
    } catch (e) {
      if (gen != _gen) return;
      error = socialErrorMessage(e);
    }
    loadingMore = false;
    notifyListeners();
  }

  // ---- tạo / sửa / xóa / chia sẻ ----
  /// Tải ảnh lên trước, rồi mới tạo bài. Ảnh lỗi thì dừng, xem `uploads` để biết ảnh nào.
  Future<String?> createPost(String content, List<PickedImage> images) async {
    final text = content.trim();
    if (text.isEmpty && images.isEmpty) return 'Hãy nhập nội dung hoặc chọn ảnh';
    if (creating) return null;
    creating = true;
    createError = null;
    notifyListeners();
    try {
      final mediaIds = await uploader.run(images);
      if (mediaIds == null) throw 'Có ảnh tải lên bị lỗi, hãy thử lại';
      final post = await _repo.createPost(text, mediaIds);
      posts = [post, ...posts];
      status = FeedStatus.ready;
      uploader.clear();
      return null;
    } catch (e) {
      createError = e is String ? e : socialErrorMessage(e);
      return createError;
    } finally {
      creating = false;
      notifyListeners();
    }
  }

  Future<String?> updatePost(String postId, String content) =>
      _act(() async => _replace(await _repo.updatePost(postId, content: content.trim())));

  Future<String?> deletePost(String postId) => _act(() async {
        await _repo.deletePost(postId);
        posts = posts.where((p) => p.id != postId).toList();
      });

  Future<String?> sharePost(String postId, String content) => _act(() async {
        final shared = await _repo.sharePost(postId, content.trim());
        _update(postId, (p) => p.copyWith(shareCount: p.shareCount + 1));
        posts = [shared, ...posts];
      });

  // ---- cảm xúc (cập nhật lạc quan) ----
  /// kind = null nghĩa là bỏ cảm xúc. Đổi UI NGAY, lỗi thì hoàn lại như cũ.
  Future<String?> react(String postId, ReactionKind? kind) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index < 0 || !_reacting.add(postId)) return null;
    final before = posts[index].reactionSummary;
    _setSummary(postId, before.withMyReaction(kind)); // 1. đổi ngay
    try {
      final real = kind == null
          ? await _repo.removeReaction(postId)
          : await _repo.setReaction(postId, kind);
      _setSummary(postId, real); // 2. lấy số liệu chuẩn của server
      return null;
    } catch (e) {
      _setSummary(postId, before); // 3. lỗi: hoàn lại
      return socialErrorMessage(e);
    } finally {
      _reacting.remove(postId);
    }
  }

  Future<List<Reactor>> loadReactors(String postId, {ReactionKind? kind}) =>
      _repo.getReactions(postId, kind: kind);

  /// CommentsProvider gọi khi thêm/xóa bình luận để số bình luận ở feed khớp.
  void bumpCommentCount(String postId, int delta) =>
      _update(postId, (p) => p.copyWith(commentCount: (p.commentCount + delta).clamp(0, 1 << 30)));

  // ---- hàm nội bộ ----
  Future<String?> _act(Future<void> Function() job) async {
    try {
      await job();
      notifyListeners();
      return null;
    } catch (e) {
      return socialErrorMessage(e);
    }
  }

  void _setSummary(String id, ReactionSummary s) =>
      _update(id, (p) => p.copyWith(reactionSummary: s));

  void _replace(Post post) => _update(post.id, (_) => post);

  void _update(String id, Post Function(Post) change) {
    posts = [for (final p in posts) p.id == id ? change(p) : p];
    notifyListeners();
  }
}
