import 'package:app/core/error/app_exception.dart';
import 'package:app/features/social/domain/entities/comment.dart';
import 'package:app/features/social/domain/entities/cursor_page.dart';
import 'package:app/features/social/domain/entities/post.dart';
import 'package:app/features/social/domain/entities/post_author.dart';
import 'package:app/features/social/domain/entities/reaction_kind.dart';
import 'package:app/features/social/domain/entities/reaction_summary.dart';
import 'package:app/features/social/domain/entities/uploaded_media.dart';
import 'package:app/features/social/domain/repositories/social_repository.dart';
import 'package:app/features/social/presentation/providers/comments_provider.dart';
import 'package:app/features/social/presentation/providers/post_uploader.dart';
import 'package:app/features/social/presentation/providers/social_feed_provider.dart';
import 'package:flutter_test/flutter_test.dart';

const _me = PostAuthor(id: 'u1', fullName: 'Tôi');
Post _post(String id) => Post(id: id, author: _me, createdAt: DateTime(2026));
Comment _comment(String id, {String? parentId}) =>
    Comment(id: id, author: _me, content: 'c$id', createdAt: DateTime(2026), parentId: parentId);

/// Repository giả để test, không gọi mạng. Method nào không override thì ném lỗi.
class FakeRepo implements SocialRepository {
  final List<String> log = []; // ghi lại thứ tự các lời gọi
  Object? failWith; // đặt lỗi để mọi lệnh ghi/đọc chính ném ra
  List<List<Post>> feedPages = [];
  int feedCalls = 0;
  final Set<int> failUploadAt = {};

  @override
  Future<CursorPage<Post>> getFeed({String? cursor, int limit = 10}) async {
    log.add('feed:${cursor ?? '-'}');
    if (failWith != null) throw failWith!;
    final i = cursor == null ? 0 : int.parse(cursor);
    feedCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final more = i + 1 < feedPages.length;
    return CursorPage(items: feedPages[i], nextCursor: more ? '${i + 1}' : null, hasMore: more);
  }

  @override
  Future<UploadedMedia> uploadImage(List<int> bytes, String filename) async {
    log.add('upload:$filename');
    if (failUploadAt.contains(int.parse(filename))) throw const NetworkException();
    return UploadedMedia(mediaId: 'media-$filename', url: 'u');
  }

  @override
  Future<Post> createPost(String content, List<String> mediaIds) async {
    log.add('create:${mediaIds.join(',')}');
    return _post('new');
  }

  @override
  Future<ReactionSummary> setReaction(String postId, ReactionKind kind) async {
    if (failWith != null) throw failWith!;
    return ReactionSummary(total: 1, counts: {kind: 1}, top: [kind], myReaction: kind);
  }

  @override
  Future<CursorPage<Comment>> getComments(String postId, {String? cursor, int limit = 10}) async =>
      CursorPage(items: [_comment('1')]);

  @override
  Future<Comment> createComment(String postId, String content, {String? parentId}) async =>
      _comment('2', parentId: parentId);

  @override
  Future<CursorPage<Comment>> getReplies(String commentId, {String? cursor, int limit = 10}) async =>
      CursorPage(items: [_comment('r1', parentId: commentId)]);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('loadMore không trùng bài và không gọi chồng', () async {
    final repo = FakeRepo()
      ..feedPages = [
        [_post('a'), _post('b')],
        [_post('b'), _post('c')], // b trùng
      ];
    final feed = SocialFeedProvider(repo);
    await feed.loadInitial();
    expect(feed.posts.map((p) => p.id), ['a', 'b']);
    expect(feed.hasMore, isTrue);

    // Gọi 3 lần liên tiếp -> chỉ 1 request
    await Future.wait([feed.loadMore(), feed.loadMore(), feed.loadMore()]);
    expect(repo.feedCalls, 2);
    expect(feed.posts.map((p) => p.id), ['a', 'b', 'c']);
    expect(feed.hasMore, isFalse);
  });

  test('react lạc quan: đổi ngay, lỗi thì hoàn lại', () async {
    final repo = FakeRepo()..feedPages = [[_post('a')]];
    final feed = SocialFeedProvider(repo);
    await feed.loadInitial();

    final okFuture = feed.react('a', ReactionKind.love);
    expect(feed.posts.first.reactionSummary.myReaction, ReactionKind.love); // đổi ngay
    expect(await okFuture, isNull);

    repo.failWith = const NetworkException();
    final failFuture = feed.react('a', ReactionKind.haha);
    expect(feed.posts.first.reactionSummary.myReaction, ReactionKind.haha);
    expect(await failFuture, isNotNull);
    expect(feed.posts.first.reactionSummary.myReaction, ReactionKind.love); // hoàn lại
  });

  test('tạo bài có ảnh: upload trước rồi mới create', () async {
    final repo = FakeRepo()..feedPages = [[]];
    final feed = SocialFeedProvider(repo);
    await feed.loadInitial();
    final images = [
      const PickedImage(bytes: [1], filename: '0'),
      const PickedImage(bytes: [2], filename: '1'),
    ];
    repo.failUploadAt.add(1);

    var err = await feed.createPost('hi', images);
    expect(err, isNotNull); // ảnh 1 lỗi -> chưa tạo bài
    expect(repo.log.where((l) => l.startsWith('create')), isEmpty);
    expect(feed.uploads[0].status, UploadStatus.done);
    expect(feed.uploads[1].status, UploadStatus.failed);
    expect(feed.creating, isFalse);

    repo.failUploadAt.clear();
    err = await feed.createPost('hi', images);
    expect(err, isNull);
    // Ảnh 0 đã tải xong từ lần trước nên không tải lại
    expect(repo.log, ['feed:-', 'upload:0', 'upload:1', 'upload:1', 'create:media-0,media-1']);
    expect(feed.posts.first.id, 'new');
  });

  test('401 / TOKEN_EXPIRED không làm provider treo', () async {
    final repo = FakeRepo()
      ..feedPages = [[_post('a')]]
      ..failWith = const UnauthorizedException();
    final feed = SocialFeedProvider(repo);
    await feed.loadInitial();
    expect(feed.status, FeedStatus.error);
    expect(feed.loadingMore, isFalse);
    expect(feed.error, isNotNull);

    repo.failWith = null; // thử lại được
    await feed.refresh();
    expect(feed.status, FeedStatus.ready);
    expect(feed.posts, hasLength(1));
  });

  test('CommentsProvider: tải, thêm reply, báo số bình luận', () async {
    final repo = FakeRepo();
    final deltas = <int>[];
    final cp = CommentsProvider(repo, 'p1', onCountChanged: deltas.add);
    await cp.loadInitial();
    expect(cp.comments, hasLength(1));

    await cp.loadReplies('1');
    expect(cp.repliesOf('1').items.single.id, 'r1');

    expect(await cp.addComment('trả lời', parentId: '1'), isNull);
    expect(cp.comments.first.replyCount, 1);
    expect(cp.repliesOf('1').items, hasLength(2));
    expect(deltas, [1]);
    expect(await cp.addComment('   '), isNotNull); // rỗng bị chặn
  });
}
