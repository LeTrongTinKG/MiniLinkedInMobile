import 'package:flutter/material.dart';

import 'ui_tokens.dart';

// Thông báo nhỏ hiện ở đáy màn hình. Ví với React: toast.success("Đã lưu")
void showAppToast(BuildContext context, String message, {bool isError = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar(); // tắt cái cũ để khỏi chồng nhau
  messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? UiTokens.destructive : UiTokens.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiTokens.radius),
      ),
    ),
  );
}

void showAppSuccess(BuildContext context, String message) =>
    showAppToast(context, message);

void showAppError(BuildContext context, String message) =>
    showAppToast(context, message, isError: true);
