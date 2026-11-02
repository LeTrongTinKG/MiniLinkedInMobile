import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Composable ChatSuggestions widget phỏng theo thiết kế @Alwurts/chat-suggestions từ 21st.dev
/// Hiển thị danh sách câu hỏi gợi ý dạng nút bấm có bo góc, viền nhẹ và hiệu ứng tương tác.
class ChatSuggestions extends StatelessWidget {
  final Widget? header;
  final Widget content;
  final EdgeInsetsGeometry padding;

  const ChatSuggestions({
    super.key,
    this.header,
    required this.content,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: 8),
          ],
          content,
        ],
      ),
    );
  }
}

class ChatSuggestionsHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;

  const ChatSuggestionsHeader({
    super.key,
    required this.title,
    this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 2),
          Text(
            description!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class ChatSuggestionsContent extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ChatSuggestionsContent({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}

class ChatSuggestion extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool enabled;

  const ChatSuggestion({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = enabled && onTap != null;
    final borderColor = isClickable
        ? AppColors.border
        : AppColors.border.withValues(alpha: 0.5);
    final textColor = isClickable ? AppColors.textPrimary : AppColors.textMuted;
    final bgColor = isClickable ? AppColors.surface : AppColors.background;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: isClickable ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
