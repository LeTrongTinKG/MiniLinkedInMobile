import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/reaction_summary.dart';
import 'reaction_icon.dart';

/// Dưới bình luận: vài icon cảm xúc nhỏ + tổng số (cùng kiểu với dòng thống kê của bài).
class CommentReactionCount extends StatelessWidget {
  const CommentReactionCount({super.key, required this.summary});

  final ReactionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final kind in summary.top)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: ReactionIcon(kind: kind, size: 14),
          ),
        const SizedBox(width: 2),
        Text('${summary.total}', style: const TextStyle(fontSize: 12, color: UiTokens.mutedForeground)),
      ],
    );
  }
}
