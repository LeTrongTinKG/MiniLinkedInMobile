import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'ui_tokens.dart';

// Ô nhập 1 dòng hỗ trợ icon, nút ẩn hiện mật khẩu và hiển thị lỗi inline.
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
    this.trailingIcon,
    this.trailing,
    this.onTrailingTap,
    this.errorText,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final bool obscureText; // true = ô mật khẩu
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool enabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    Widget? trailingWidget = trailing;
    if (trailingWidget == null && trailingIcon != null) {
      trailingWidget = GestureDetector(
        onTap: onTrailingTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(trailingIcon, size: 18, color: UiTokens.mutedForeground),
        ),
      );
    }

    final inputWidget = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UiTokens.minTouchTarget),
      child: ShadInput(
        controller: controller,
        placeholder: placeholder == null ? null : Text(placeholder!),
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        enabled: enabled,
        leading: leadingIcon == null ? null : Icon(leadingIcon, size: 16),
        trailing: trailingWidget,
      ),
    );

    if (errorText == null || errorText!.isEmpty) {
      return inputWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        inputWidget,
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(
            errorText!,
            style: const TextStyle(
              color: UiTokens.destructive,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
