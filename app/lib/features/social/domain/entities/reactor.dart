import 'post_author.dart';
import 'reaction_kind.dart';

/// 1 người đã thả cảm xúc vào bài (dùng cho màn "ai đã react").
class Reactor {
  const Reactor({required this.user, required this.kind});

  final PostAuthor user;
  final ReactionKind kind;
}
