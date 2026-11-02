import '../../domain/entities/comment.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reactor.dart';
import '../../domain/entities/uploaded_media.dart';
import 'post_model.dart';

Comment commentFromJson(Object? json) {
  final m = asMap(json);
  return Comment(
    id: asString(m['id']),
    postId: m['postId'] is String ? m['postId'] as String : null,
    parentId: m['parentId'] is String ? m['parentId'] as String : null,
    author: authorFromJson(m['author']),
    content: asString(m['content']),
    replyCount: asInt(m['replyCount']),
    reactionSummary: summaryFromJson(m['reactionSummary']),
    isMine: m['isMine'] == true,
    createdAt: asDate(m['createdAt']) ?? DateTime.now(),
    editedAt: asDate(m['editedAt']),
  );
}

/// {type, createdAt, user:{id, fullName, avatarUrl}}
Reactor reactorFromJson(Object? json) {
  final m = asMap(json);
  return Reactor(
    user: authorFromJson(m['user']),
    kind: ReactionKind.fromApi(m['type']?.toString()) ?? ReactionKind.like,
  );
}

/// {mediaId, url, thumbnailUrl, width, height}
UploadedMedia uploadedFromJson(Object? json) {
  final m = asMap(json);
  return UploadedMedia(
    mediaId: asString(m['mediaId']),
    url: asString(m['url']),
    thumbnailUrl: m['thumbnailUrl'] is String ? m['thumbnailUrl'] as String : null,
  );
}
