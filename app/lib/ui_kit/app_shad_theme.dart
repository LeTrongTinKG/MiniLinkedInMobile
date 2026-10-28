import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'ui_tokens.dart';

// Cấu hình theme cho thư viện shadcn_ui (CHỈ bản sáng).
// Đây là file duy nhất "biết" shadcn_ui ở phần gốc app.
// Ví với React: giống <ThemeProvider theme={...}>.
ShadThemeData buildAppShadTheme() {
  return ShadThemeData(
    brightness: Brightness.light,
    // Lấy bảng màu Slate làm gốc, rồi đè màu chính + vài màu khác theo token
    colorScheme: const ShadSlateColorScheme.light(
      primary: UiTokens.primary,
      primaryForeground: UiTokens.primaryForeground,
      destructive: UiTokens.destructive,
      ring: UiTokens.primary,
      border: UiTokens.border,
      input: UiTokens.border,
    ),
    radius: const BorderRadius.all(Radius.circular(UiTokens.radius)),
  );
}
