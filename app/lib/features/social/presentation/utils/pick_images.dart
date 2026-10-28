import 'package:file_picker/file_picker.dart';
import '../../domain/entities/uploaded_media.dart';
import '../social_strings.dart';

const maxImagesPerPost = 6;
const _maxBytes = 10 * 1024 * 1024;
const _okExtensions = ['jpg', 'jpeg', 'png', 'webp'];

/// Kết quả chọn ảnh: danh sách ảnh hợp lệ + (nếu có) 1 câu lỗi thân thiện.
class PickResult {
  PickResult(this.images, this.error);
  final List<PickedImage> images;
  final String? error;
}

/// Mở hộp chọn ảnh (chọn được nhiều ảnh). Đọc bytes bằng readAsBytes nên chạy cả mobile lẫn web.
/// `remaining` = còn được chọn thêm bao nhiêu ảnh.
Future<PickResult> pickImages(int remaining) async {
  final files = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: _okExtensions,
  );
  final images = <PickedImage>[];
  String? error;

  for (final f in files) {
    final ext = f.name.split('.').last.toLowerCase();
    final size = await f.length() ?? 0;
    if (!_okExtensions.contains(ext)) {
      error = SocialStrings.imageTypeError;
    } else if (size > _maxBytes) {
      error = SocialStrings.imageSizeError;
    } else if (images.length >= remaining) {
      error = SocialStrings.maxImagesError;
    } else {
      final bytes = await f.readAsBytes();
      images.add(PickedImage(bytes: bytes, filename: f.name));
    }
  }
  return PickResult(images, error);
}
