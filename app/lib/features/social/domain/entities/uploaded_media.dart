/// Kết quả sau khi tải 1 ảnh lên: mediaId dùng để gắn vào bài khi tạo.
class UploadedMedia {
  const UploadedMedia({required this.mediaId, required this.url, this.thumbnailUrl});

  final String mediaId;
  final String url;
  final String? thumbnailUrl;
}

/// Ảnh người dùng vừa chọn (còn ở dạng bytes, chưa tải lên).
/// Dùng bytes vì trên web không có đường dẫn file.
class PickedImage {
  const PickedImage({required this.bytes, required this.filename});

  final List<int> bytes;
  final String filename;
}
