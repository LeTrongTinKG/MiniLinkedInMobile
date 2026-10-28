import '../../../../core/error/app_exception.dart';

const maxImageBytes = 10 * 1024 * 1024; // server cũng giới hạn 10MB

/// Kiểm tra ảnh ngay ở máy trước khi tải lên: đúng loại (jpg/png/webp) và ≤ 10MB.
/// Sai thì ném ApiException (giống lỗi server) để UI hiện thông báo như mọi lỗi khác.
void checkImage(List<int> bytes, String filename) {
  if (bytes.isEmpty) _fail('Ảnh rỗng');
  if (bytes.length > maxImageBytes) _fail('Ảnh không được vượt quá 10MB');
  if (!_isJpg(bytes) && !_isPng(bytes) && !_isWebp(bytes)) {
    _fail('Chỉ nhận ảnh JPG, PNG hoặc WebP');
  }
}

/// Tên mime để gắn vào multipart, suy ra từ nội dung file (không tin đuôi tên file).
String imageMime(List<int> bytes) {
  if (_isPng(bytes)) return 'image/png';
  if (_isWebp(bytes)) return 'image/webp';
  return 'image/jpeg';
}

// Nhận dạng bằng "chữ ký" vài byte đầu của file
bool _isJpg(List<int> b) => b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;
bool _isPng(List<int> b) =>
    b.length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47;
bool _isWebp(List<int> b) =>
    b.length > 12 &&
    String.fromCharCodes(b.sublist(0, 4)) == 'RIFF' &&
    String.fromCharCodes(b.sublist(8, 12)) == 'WEBP';

Never _fail(String message) =>
    throw ApiException(statusCode: 400, errorCode: 'INVALID_IMAGE', message: message);
