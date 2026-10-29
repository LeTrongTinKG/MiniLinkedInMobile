import '../../domain/entities/cursor_page.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_author.dart';
import '../../domain/entities/post_media.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';

// Các hàm dưới đây đổi JSON (Map) của server thành entity.
// Field null/thiếu thì dùng giá trị mặc định, không để app crash.

Map<String, dynamic> asMap(Object? v) => v is Map<String, dynamic> ? v : <String, dynamic>{};
String asString(Object? v, [String fallback = '']) => v is String ? v : fallback;
int asInt(Object? v) => v is num ? v.toInt() : 0;
int? asIntOrNull(Object? v) => v is num ? v.toInt() : null;
DateTime? asDate(Object? v) => v is String ? DateTime.tryParse(v)?.toLocal() : null;

PostAuthor authorFromJson(Object? json) {
  final m = asMap(json);
  return PostAuthor(
    id: asString(m['id']),
    fullName: asString(m['fullName'], 'Người dùng'),
    avatarUrl: m['avatarUrl'] is String ? m['avatarUrl'] as String : null,
  );
}

PostMedia mediaFromJson(Object? json) {
  final m = asMap(json);
  return PostMedia(
    url: asString(m['url']),
    thumbnailUrl: m['thumbnailUrl'] is String ? m['thumbnailUrl'] as String : null,
    width: asIntOrNull(m['width']),
    height: asIntOrNull(m['height']),
  );
}

/// {total, counts:{LIKE:n,...}, top:[...], myReaction}
ReactionSummary summaryFromJson(Object? json) {
  final m = asMap(json);
  final counts = <ReactionKind, int>{};
  asMap(m['counts']).forEach((key, value) {
    final kind = ReactionKind.fromApi(key);
    if (kind != null) counts[kind] = asInt(value);
  });
  final top = <ReactionKind>[
    for (final t in (m['top'] is List ? m['top'] as List : const []))
      if (ReactionKind.fromApi(t?.toString()) != null) ReactionKind.fromApi(t.toString())!,
  ];
  return ReactionSummary(
    total: asInt(m['total']),
    counts: counts,
    top: top,
    myReaction: ReactionKind.fromApi(m['myReaction']?.toString()),
  );
}

Post postFromJson(Object? json) {
  final m = asMap(json);
  final author = authorFromJson(m['author']);

  // Bài gốc bị xóa: server trả {id, isDeleted:true, message} (không có author)
  if (m['isDeleted'] == true) {
    return Post(
      id: asString(m['id']),
      author: author,
      content: asString(m['message'], 'Bài viết gốc không còn tồn tại'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      isDeleted: true,
    );
  }

  final sharedJson = m['sharedPost'];
  return Post(
    id: asString(m['id']),
    author: author,
    content: asString(m['content']),
    media: [for (final x in (m['media'] is List ? m['media'] as List : const [])) mediaFromJson(x)],
    reactionSummary: summaryFromJson(m['reactionSummary']),
    commentCount: asInt(m['commentCount']),
    shareCount: asInt(m['shareCount']),
    isMine: m['isMine'] == true,
    sharedPost: sharedJson is Map ? postFromJson(sharedJson) : null,
    createdAt: asDate(m['createdAt']) ?? DateTime.now(),
    editedAt: asDate(m['editedAt']),
  );
}

/// Đọc cả phản hồi {data:[...], meta:{nextCursor, hasMore}} thành CursorPage.
CursorPage<T> pageFromResponse<T>(Object? body, T Function(Object?) parseItem) {
  final root = asMap(body);
  final meta = asMap(root['meta']);
  final list = root['data'] is List ? root['data'] as List : const [];
  return CursorPage<T>(
    items: [for (final x in list) parseItem(x)],
    nextCursor: meta['nextCursor'] is String ? meta['nextCursor'] as String : null,
    hasMore: meta['hasMore'] == true,
  );
}
