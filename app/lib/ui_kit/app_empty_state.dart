import 'package:flutter/material.dart';

import 'app_button.dart';
import 'ui_tokens.dart';

// Màn hình "trống": icon + tiêu đề + mô tả + nút hành động (tùy chọn).
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.gapLarge * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: UiTokens.mutedForeground),
            const SizedBox(height: UiTokens.gapLarge),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: UiTokens.foreground)),
            if (message != null) ...[
              const SizedBox(height: UiTokens.gap),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: UiTokens.mutedForeground)),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: UiTokens.gapLarge),
              AppButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
