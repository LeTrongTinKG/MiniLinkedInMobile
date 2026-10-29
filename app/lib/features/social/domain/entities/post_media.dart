/// 1 ảnh của bài viết.
class PostMedia {
  const PostMedia({
    required this.url,
    this.thumbnailUrl,
    this.width,
    this.height,
  });

  final String url;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
}
