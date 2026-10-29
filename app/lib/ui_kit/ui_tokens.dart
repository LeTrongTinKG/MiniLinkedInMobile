import 'package:flutter/material.dart';

// ===== TOKEN: nơi DUY NHẤT chứa màu / độ bo / khoảng cách của ui_kit =====
// Ví với React: giống file theme.js hoặc biến CSS (:root { --primary: ... }).
// Sang dự án khác chỉ cần sửa file này.
class UiTokens {
  UiTokens._();

  // Màu chính của thương hiệu
  static const Color primary = Color(0xFF2952CC);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // Màu trạng thái
  static const Color destructive = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  // Màu nền / chữ / viền
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF0F172A);
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // Độ bo góc
  static const double radius = 10;
  static const double radiusLarge = 16;

  // Khoảng cách chuẩn
  static const double gap = 8;
  static const double gapLarge = 16;
}
