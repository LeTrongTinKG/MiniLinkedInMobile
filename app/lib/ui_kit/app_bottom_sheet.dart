import 'package:flutter/material.dart';

import 'ui_tokens.dart';

// Bảng trượt từ dưới lên, bo góc trên, kéo được để đóng.
// Ví với React: <Drawer open>...</Drawer>
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true, // true = cao được hơn nửa màn hình
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: true, // thanh nhỏ ở trên để người dùng biết kéo được
    backgroundColor: UiTokens.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(UiTokens.radiusLarge),
      ),
    ),
    builder: (ctx) => Padding(
      // Chừa chỗ cho bàn phím để ô nhập không bị che
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: builder(ctx),
    ),
  );
}
