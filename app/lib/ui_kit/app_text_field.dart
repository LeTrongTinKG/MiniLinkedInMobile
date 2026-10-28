import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Ô nhập 1 dòng. Ví với React: <input value onChange placeholder />
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
    this.enabled = true,
    this.leadingIcon,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final bool obscureText; // true = ô mật khẩu
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool enabled;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: controller,
      placeholder: placeholder == null ? null : Text(placeholder!),
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      enabled: enabled,
      leading: leadingIcon == null ? null : Icon(leadingIcon, size: 16),
    );
  }
}
