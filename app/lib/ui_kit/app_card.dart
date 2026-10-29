import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Thẻ có viền bo góc. Ví với React: <Card title="..."> nội dung </Card>
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.footer,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final String? title;
  final String? description;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap; // có thì cả thẻ bấm được

  @override
  Widget build(BuildContext context) {
    final card = ShadCard(
      title: title == null ? null : Text(title!),
      description: description == null ? null : Text(description!),
      footer: footer,
      padding: padding,
      width: double.infinity,
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}
