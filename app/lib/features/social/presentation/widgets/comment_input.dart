import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../social_strings.dart';

/// Ô nhập bình luận cố định ở đáy sheet. Có dòng "Đang trả lời (tên) ✕" khi đang trả lời ai đó.
class CommentInput extends StatelessWidget {
  const CommentInput({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
    this.replyingTo,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final String? replyingTo; // tên người đang được trả lời (null = bình luận gốc)
  final VoidCallback? onCancelReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: UiTokens.border))),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null)
            Row(children: [
              Expanded(
                child: Text(SocialStrings.replyingTo(replyingTo!),
                    style: const TextStyle(fontSize: 12, color: UiTokens.mutedForeground)),
              ),
              InkWell(
                onTap: onCancelReply,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: UiTokens.mutedForeground),
                ),
              ),
            ]),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Ô nhập tự giãn 1-4 dòng
              Expanded(
                child: AppTextArea(
                  controller: controller,
                  placeholder: SocialStrings.commentHint,
                  enabled: !sending,
                  minHeight: 40,
                  maxHeight: 110,
                ),
              ),
              const SizedBox(width: 4),
              // Nút gửi chỉ sáng khi có chữ (ValueListenableBuilder ~ lắng nghe giá trị ô nhập)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final canSend = value.text.trim().isNotEmpty && !sending;
                  return AppIconButton(
                    icon: Icons.send,
                    tooltip: SocialStrings.send,
                    onPressed: canSend ? onSend : null,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
