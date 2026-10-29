import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/ui_kit/ui_kit.dart';

/// Chuỗi hiển thị của luồng đăng xuất (gom một chỗ, không rải trong code).
class LogoutStrings {
  LogoutStrings._();
  static const action = 'Đăng xuất';
  static const confirmTitle = 'Đăng xuất?';
  static const confirmMessage = 'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng.';
}

/// Hỏi xác nhận, rồi đăng xuất và đưa về màn đăng nhập.
/// Dùng chung cho menu avatar ở header và menu bên trái, để hai nơi cư xử giống nhau.
/// Ví với React: một hàm `handleLogout()` dùng lại ở nhiều component.
Future<void> confirmAndLogout(BuildContext context) async {
  // Lấy sẵn mọi thứ cần dùng TRƯỚC khi chờ (sau khi chờ, context có thể đã bị gỡ)
  final auth = context.read<AuthProvider>();
  final navigator = Navigator.of(context, rootNavigator: true);

  final confirmed = await showAppConfirmDialog(
    context,
    title: LogoutStrings.confirmTitle,
    message: LogoutStrings.confirmMessage,
    confirmLabel: LogoutStrings.action,
    destructive: true,
  );
  if (!confirmed) return; // bấm Hủy thì ở lại

  await auth.logout(); // xóa token (kể cả khi server lỗi vẫn đăng xuất phía app)
  navigator.pushNamedAndRemoveUntil('/login', (_) => false); // xóa hết trang cũ, về đăng nhập
}
