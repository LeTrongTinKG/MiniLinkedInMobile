import 'package:app/features/social/data/models/comment_model.dart';
import 'package:app/features/social/data/models/post_model.dart';
import 'package:app/features/social/data/datasources/image_check.dart';
import 'package:app/features/social/domain/entities/reaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

// JSON mẫu đúng hình dạng server trả (theo post-view.service.js, reaction-summary.js).
const _author = {'id': 'u1', 'fullName': 'An Nguyen', 'avatarUrl': null};
const _summary = {
  'total': 3,
  'counts': {'LIKE': 2, 'LOVE': 1, 'HAHA': 0, 'WOW': 0, 'SAD': 0, 'ANGRY': 0},
  'top': ['LIKE', 'LOVE'],
  'myReaction': 'LOVE',
};

Map<String, dynamic> _post(String id, {Object? shared}) => {
      'id': id,
      'content': 'Xin chào',
      'author': _author,
      'media': [
        {'id': 'm1', 'url': 'http://x/a.webp', 'thumbnailUrl': 'http://x/t.webp', 'width': 800, 'height': 600, 'position': 0},
      ],
      'reactionSummary': _summary,
      'commentCount': 4,
      'shareCount': 1,
      'isMine': true,
      'editedAt': null,
      'createdAt': '2026-01-01T10:00:00.000Z',
      'sharedPost': shared,
    };

void main() {
  test('parse bài viết thường', () {
    final p = postFromJson(_post('p1'));
    expect(p.id, 'p1');
    expect(p.author.fullName, 'An Nguyen');
    expect(p.media.single.width, 800);
    expect(p.reactionSummary.total, 3);
    expect(p.reactionSummary.myReaction, ReactionKind.love);
    expect(p.reactionSummary.top, [ReactionKind.like, ReactionKind.love]);
    expect(p.commentCount, 4);
    expect(p.isMine, isTrue);
    expect(p.sharedPost, isNull);
    expect(p.editedAt, isNull);
  });

  test('parse bài chia sẻ: bài gốc còn / đã xóa', () {
    final alive = postFromJson(_post('p2', shared: _post('p1')));
    expect(alive.sharedPost!.id, 'p1');
    expect(alive.sharedPost!.isDeleted, isFalse);

    final dead = postFromJson(_post('p3', shared: {
      'id': 'p9',
      'isDeleted': true,
      'message': 'Bài viết gốc không còn tồn tại',
    }));
    expect(dead.sharedPost!.isDeleted, isTrue);
    expect(dead.sharedPost!.content, 'Bài viết gốc không còn tồn tại');
  });

  test('JSON thiếu field / null không crash', () {
    final p = postFromJson({'id': 'x'});
    expect(p.id, 'x');
    expect(p.media, isEmpty);
    expect(p.reactionSummary.total, 0);
    expect(postFromJson(null).id, '');
    expect(commentFromJson({'author': null}).content, '');
    expect(summaryFromJson({'myReaction': 'LẠ', 'counts': 5}).myReaction, isNull);
  });

  test('parse bình luận và trang phân trang', () {
    final page = pageFromResponse({
      'data': [
        {
          'id': 'c1', 'postId': 'p1', 'parentId': null, 'content': 'hay', 'author': _author,
          'replyCount': 2, 'reactionSummary': _summary, 'isMine': false,
          'editedAt': null, 'createdAt': '2026-01-01T10:00:00.000Z',
        },
      ],
      'meta': {'nextCursor': 'abc', 'hasMore': true},
    }, commentFromJson);
    expect(page.items.single.replyCount, 2);
    expect(page.nextCursor, 'abc');
    expect(page.hasMore, isTrue);
  });

  test('withMyReaction tính lại số đếm', () {
    final s = summaryFromJson(_summary).withMyReaction(ReactionKind.like);
    expect(s.counts[ReactionKind.love], 0);
    expect(s.counts[ReactionKind.like], 3);
    expect(s.total, 3);
    expect(s.withMyReaction(null).total, 2);
  });

  test('kiểm tra ảnh ở client', () {
    final png = [0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0, 0, 0];
    checkImage(png, 'a.png'); // hợp lệ, không ném lỗi
    expect(() => checkImage([1, 2, 3, 4, 5], 'a.txt'), throwsA(anything));
    expect(() => checkImage(List.filled(maxImageBytes + 1, 0xFF), 'a.jpg'), throwsA(anything));
  });
}
