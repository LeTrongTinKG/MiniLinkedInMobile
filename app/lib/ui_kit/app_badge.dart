import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum AppBadgeVariant { primary, secondary, outline, destructive }

// Nhãn nhỏ (ví dụ "Mới", "Remote"). Ví với React: <Badge variant="outline">Mới</Badge>
class AppBadge extends StatelessWidget {
  const AppBadge(this.label,
      {super.key, this.variant = AppBadgeVariant.secondary});

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final text = Text(label);
    switch (variant) {
      case AppBadgeVariant.primary:
        return ShadBadge(child: text);
      case AppBadgeVariant.outline:
        return ShadBadge.outline(child: text);
      case AppBadgeVariant.destructive:
        return ShadBadge.destructive(child: text);
      case AppBadgeVariant.secondary:
        return ShadBadge.secondary(child: text);
    }
  }
}
