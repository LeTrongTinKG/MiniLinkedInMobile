import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Hộp thoại xác nhận. Trả về true nếu bấm "đồng ý", false nếu hủy/đóng.
// Ví với React: const ok = await confirm({ title, message })
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Đồng ý',
  String cancelLabel = 'Hủy',
  bool destructive = false, // true = nút đồng ý màu đỏ (xóa...)
}) async {
  final result = await showShadDialog<bool>(
    context: context,
    builder: (ctx) {
      // Nút hủy -> đóng và trả false
      final cancel = ShadButton.outline(
        onPressed: () => Navigator.of(ctx).pop(false),
        child: Text(cancelLabel),
      );
      // Nút đồng ý -> đóng và trả true
      final confirm = destructive
          ? ShadButton.destructive(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(confirmLabel))
          : ShadButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(confirmLabel));

      return ShadDialog.alert(
        title: Text(title),
        description: Text(message),
        actions: [cancel, confirm],
      );
    },
  );
  // Bấm ra ngoài để đóng -> result là null -> coi như false
  return result ?? false;
}
