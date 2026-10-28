import '../../domain/entities/uploaded_media.dart';
import '../../domain/repositories/social_repository.dart';
import 'social_error.dart';

enum UploadStatus { waiting, uploading, done, failed }

/// Trạng thái tải lên của 1 ảnh (UI đọc để hiện tiến độ / lỗi từng ảnh).
class UploadItem {
  UploadItem(this.image);
  final PickedImage image;
  UploadStatus status = UploadStatus.waiting;
  String? error;
  UploadedMedia? media;
}

/// Tải lần lượt từng ảnh lên server, lấy mediaId.
/// Ảnh đã tải xong được nhớ lại, nên bấm "Đăng" lần nữa sau khi lỗi chỉ tải lại ảnh lỗi.
class PostUploader {
  PostUploader(this._repo, this._onChange);
  final SocialRepository _repo;
  final void Function() _onChange; // giống setState: báo UI vẽ lại

  final Map<PickedImage, UploadItem> _byImage = {};
  List<UploadItem> items = [];

  /// Trả về danh sách mediaId (đúng thứ tự ảnh), hoặc null nếu có ảnh lỗi.
  Future<List<String>?> run(List<PickedImage> images) async {
    items = [for (final img in images) _byImage.putIfAbsent(img, () => UploadItem(img))];
    _onChange();

    var allOk = true;
    for (final item in items) {
      if (item.status == UploadStatus.done) continue;
      item.status = UploadStatus.uploading;
      item.error = null;
      _onChange();
      try {
        item.media = await _repo.uploadImage(item.image.bytes, item.image.filename);
        item.status = UploadStatus.done;
      } catch (e) {
        item.status = UploadStatus.failed;
        item.error = socialErrorMessage(e);
        allOk = false;
      }
      _onChange();
    }
    return allOk ? [for (final i in items) i.media!.mediaId] : null;
  }

  void clear() {
    _byImage.clear();
    items = [];
  }
}
