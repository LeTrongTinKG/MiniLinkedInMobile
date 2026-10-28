/// Người đăng bài / viết bình luận.
class PostAuthor {
  const PostAuthor({required this.id, required this.fullName, this.avatarUrl});

  final String id;
  final String fullName;
  final String? avatarUrl;
}
