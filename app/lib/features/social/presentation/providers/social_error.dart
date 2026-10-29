import '../../../../core/error/app_exception.dart';

/// Lấy câu thông báo để hiện cho người dùng từ mọi loại lỗi.
String socialErrorMessage(Object e) =>
    e is AppException ? e.message : 'Có lỗi xảy ra, thử lại sau';
