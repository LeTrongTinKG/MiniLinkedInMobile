import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'ui_tokens.dart';

// Ảnh đại diện: có ảnh mạng thì hiện ảnh, không thì hiện chữ cái đầu.
// Ví với React: <Avatar src={url} fallback="A" />
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.imageUrl, this.name = '', this.size = 40});

  final String? imageUrl;
  final String name; // dùng để lấy chữ cái đầu
  final double size;

  // Lấy chữ cái đầu của tên, không có tên thì hiện "?"
  String get _initial {
    final t = name.trim();
    return t.isEmpty ? '?' : t.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Khối chữ cái: dùng cho cả "không có ảnh" và "ảnh lỗi/đang tải"
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: UiTokens.muted,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: UiTokens.foreground,
        ),
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) return fallback;

    return ShadAvatar(
      url,
      size: Size(size, size),
      placeholder: fallback,
    );
  }
}
