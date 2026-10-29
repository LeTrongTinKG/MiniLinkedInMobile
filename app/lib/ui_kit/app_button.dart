import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Các kiểu nút. Ví với React: <Button variant="outline" size="sm" />
enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

enum AppButtonSize { small, medium, large }

ShadButtonSize _toShadSize(AppButtonSize s) {
  switch (s) {
    case AppButtonSize.small:
      return ShadButtonSize.sm;
    case AppButtonSize.large:
      return ShadButtonSize.lg;
    case AppButtonSize.medium:
      return ShadButtonSize.regular;
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed; // null = nút bị tắt (disabled)
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon; // icon bên trái chữ
  final bool loading; // đang xử lý: hiện vòng xoay và KHÔNG bấm được
  final bool fullWidth; // true = chiếm hết chiều ngang

  @override
  Widget build(BuildContext context) {
    // 1) Loading thì coi như tắt nút (onPressed = null)
    final VoidCallback? handler = loading ? null : onPressed;

    // 2) Phần bên trái: vòng xoay (khi loading) hoặc icon
    Widget? leading;
    if (loading) {
      leading = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (icon != null) {
      leading = Icon(icon, size: 16);
    }

    // 3) Chữ trong nút + kích thước + chiều rộng
    final child = Text(label);
    final shadSize = _toShadSize(size);
    final width = fullWidth ? double.infinity : null;

    // 4) Chọn kiểu nút theo variant
    switch (variant) {
      case AppButtonVariant.secondary:
        return ShadButton.secondary(
            onPressed: handler, size: shadSize, width: width,
            leading: leading, child: child);
      case AppButtonVariant.outline:
        return ShadButton.outline(
            onPressed: handler, size: shadSize, width: width,
            leading: leading, child: child);
      case AppButtonVariant.ghost:
        return ShadButton.ghost(
            onPressed: handler, size: shadSize, width: width,
            leading: leading, child: child);
      case AppButtonVariant.destructive:
        return ShadButton.destructive(
            onPressed: handler, size: shadSize, width: width,
            leading: leading, child: child);
      case AppButtonVariant.primary:
        return ShadButton(
            onPressed: handler, size: shadSize, width: width,
            leading: leading, child: child);
    }
  }
}
