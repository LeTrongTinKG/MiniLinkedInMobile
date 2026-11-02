import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Ô nhập nhiều dòng, tự giãn theo nội dung (từ minHeight tới maxHeight).
// Ví với React: <textarea /> có auto-resize.
class AppTextArea extends StatelessWidget {
  const AppTextArea({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.maxLength,
    this.enabled = true,
    this.minHeight = 80,
    this.maxHeight = 240,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final int? maxLength; // giới hạn ký tự (không bắt buộc)
  final bool enabled;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ShadTextarea(
      controller: controller,
      placeholder: placeholder == null ? null : Text(placeholder!),
      onChanged: onChanged,
      maxLength: maxLength,
      enabled: enabled,
      minHeight: minHeight,
      maxHeight: maxHeight,
      resizable: false, // tắt tay kéo giãn trên web, chỉ tự giãn
    );
  }
}
