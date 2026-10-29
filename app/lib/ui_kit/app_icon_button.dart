import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_button.dart';

// Nút chỉ có icon (không chữ). Ví với React: <IconButton icon={<Heart/>} />
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.ghost,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final String? tooltip; // chữ hiện khi giữ lâu (hỗ trợ trợ năng)

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 18);

    // Chọn kiểu theo variant
    Widget button;
    switch (variant) {
      case AppButtonVariant.secondary:
        button = ShadIconButton.secondary(icon: iconWidget, onPressed: onPressed);
        break;
      case AppButtonVariant.outline:
        button = ShadIconButton.outline(icon: iconWidget, onPressed: onPressed);
        break;
      case AppButtonVariant.destructive:
        button =
            ShadIconButton.destructive(icon: iconWidget, onPressed: onPressed);
        break;
      case AppButtonVariant.primary:
        button = ShadIconButton(icon: iconWidget, onPressed: onPressed);
        break;
      case AppButtonVariant.ghost:
        button = ShadIconButton.ghost(icon: iconWidget, onPressed: onPressed);
        break;
    }

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
