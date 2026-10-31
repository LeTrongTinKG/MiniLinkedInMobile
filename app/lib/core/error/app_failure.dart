/// Phân cấp lỗi type-safe cho toàn ứng dụng theo chuẩn Atom.
sealed class AppFailure {
  final String message;
  const AppFailure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Không có kết nối mạng, vui lòng thử lại']);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Không tìm thấy dữ liệu yêu cầu']);
}

class ValidationFailure extends AppFailure {
  final String code;
  const ValidationFailure(this.code, [super.message = 'Dữ liệu không hợp lệ']);
}

class QuotaFailure extends AppFailure {
  final DateTime? resetsAt;
  const QuotaFailure([this.resetsAt, super.message = 'Đã vượt quá hạn mức sử dụng']);
}

class ConsentRequiredFailure extends AppFailure {
  const ConsentRequiredFailure([
    super.message = 'Cần đồng ý điều khoản trước khi phân tích',
  ]);
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([
    super.message = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại',
  ]);
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Lỗi hệ thống máy chủ, vui lòng thử lại']);
}

