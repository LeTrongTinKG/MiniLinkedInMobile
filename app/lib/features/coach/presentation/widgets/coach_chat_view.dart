import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/coach_models.dart';
import '../coach_provider.dart';
import 'chat_suggestions.dart';

class CoachChatView extends StatelessWidget {
  final CoachProvider provider;
  final TextEditingController controller;
  final VoidCallback onAsk;

  const CoachChatView({
    super.key,
    required this.provider,
    required this.controller,
    required this.onAsk,
  });

  @override
  Widget build(BuildContext context) {
    final s = provider.settings!;
    final out = provider.lastAnswer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trợ lý kỹ năng',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: s.remaining > 0
                    ? AppColors.primaryContainer
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'còn ${s.remaining}/${s.limit} câu hôm nay',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: s.remaining > 0
                      ? AppColors.onPrimaryContainer
                      : AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ChatSuggestions(
          header: const ChatSuggestionsHeader(
            icon: Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
            title: 'Gợi ý câu hỏi',
            description: 'Chạm vào câu hỏi để trợ lý phân tích kỹ năng & lộ trình:',
          ),
          content: ChatSuggestionsContent(
            children: [
              for (final prompt in kCoachPrompts)
                ChatSuggestion(
                  label: prompt.label,
                  enabled: !provider.asking && s.remaining > 0,
                  onTap: () => provider.ask(intent: prompt.intent),
                ),
            ],
          ),
        ),
        const Divider(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.asking)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (provider.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                    ),
                  ),
                if (out != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          out.answer,
                          style: const TextStyle(fontSize: 14, height: 1.45),
                        ),
                        if (out.sources.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final src in out.sources)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Căn cứ: $src',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: 300,
          enabled: !provider.asking && s.remaining > 0,
          decoration: InputDecoration(
            hintText: s.remaining == 0
                ? 'Hết lượt hôm nay, hỏi lại ngày mai'
                : 'Hỏi ngắn về skill hoặc lộ trình',
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: provider.asking || s.remaining == 0 ? null : onAsk,
            ),
          ),
          onSubmitted: (_) => onAsk(),
        ),
      ],
    );
  }
}
