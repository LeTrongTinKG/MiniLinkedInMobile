import 'package:flutter/material.dart';

import 'app_button.dart';
import 'ui_tokens.dart';

/// Màn hình "trống": icon trong khối tròn + tiêu đề + mô tả + nút hành động giải cứu luồng cụt.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.gapLarge * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: UiTokens.muted,
                shape: BoxShape.circle,
                border: Border.all(color: UiTokens.border, width: 1),
              ),
              child: Center(
                child: Icon(icon, size: 36, color: UiTokens.mutedForeground),
              ),
            ),
            const SizedBox(height: UiTokens.gapLarge),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: UiTokens.foreground,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: UiTokens.gap),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: UiTokens.mutedForeground,
                  height: 1.4,
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: UiTokens.gapLarge),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.medium,
              ),
            ],
            if (secondaryActionLabel != null) ...[
              const SizedBox(height: UiTokens.gap),
              AppButton(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Alias thuận tiện để gọi theo tên tài liệu đặc tả
typedef EmptyStateView = AppEmptyState;
