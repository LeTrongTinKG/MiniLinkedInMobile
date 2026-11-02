import 'package:flutter/material.dart';

import 'ui_tokens.dart';

// Bảng trượt từ dưới lên, bo góc trên 24dp chuẩn Clay, hỗ trợ kéo đóng.
// Ví với React: <Drawer open>...</Drawer>
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true, // true = cao được hơn nửa màn hình
  bool useSafeArea = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    showDragHandle: true, // thanh nhỏ ở trên để người dùng biết kéo được
    backgroundColor: backgroundColor ?? UiTokens.background,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(UiTokens.radiusSheet),
      ),
    ),
    builder: (ctx) => Padding(
      // Chừa chỗ cho bàn phím để ô nhập không bị che
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: builder(ctx),
    ),
  );
}
