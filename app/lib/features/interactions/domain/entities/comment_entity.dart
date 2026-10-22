class CommentAuthor {
  const CommentAuthor({required this.id, required this.fullName, this.avatarUrl});
  final String id;
  final String fullName;
  final String? avatarUrl;
}

class CommentItem {
  const CommentItem({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
    required this.isMine,
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final CommentAuthor author;
  final bool isMine;
}

class CommentPage {
  const CommentPage({
    required this.items,
    required this.page,
    required this.total,
    required this.limit,
  });
  final List<CommentItem> items;
  final int page;
  final int limit;
  final int total;
  bool get hasMore => page * limit < total;
}
