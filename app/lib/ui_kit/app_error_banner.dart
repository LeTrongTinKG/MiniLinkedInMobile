import 'package:flutter/material.dart';
import 'ui_tokens.dart';

/// Banner thông báo lỗi nổi bật bo 12dp có nút thử lại.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Thử lại',
    this.onDismiss,
    this.icon = Icons.error_outline,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onDismiss;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Thông báo lỗi: $message',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(UiTokens.radius),
          border: Border.all(color: const Color(0xFFFECDD3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: UiTokens.destructive),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF991B1B),
                  height: 1.35,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: UiTokens.destructive,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  retryLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: const Color(0xFF991B1B),
                onPressed: onDismiss,
                tooltip: 'Đóng',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

