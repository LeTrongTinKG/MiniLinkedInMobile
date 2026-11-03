import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/coach_models.dart';
import '../coach_provider.dart';
import 'chat_suggestions.dart';
import 'coach_answer_card.dart';
import 'coach_milestone_card.dart';

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
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: s.remaining > 0
                    ? AppColors.primaryContainer
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
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
            description:
                'Chạm vào câu hỏi để trợ lý phân tích kỹ năng & lộ trình:',
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
        const Divider(height: 16, color: AppColors.border),
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
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusChip),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(
                          color: AppTheme.errorRed, fontSize: 13),
                    ),
                  ),
                if (out != null) ...[
                  CoachAnswerCard(answer: out),
                  const SizedBox(height: 12),
                  CoachMilestoneCard(
                    onTap: () => provider.ask(question: 'Làm thế nào để hoàn thành Milestone 01: Build a test suite?'),
                  ),
                ] else if (!provider.asking) ...[
                  const SizedBox(height: 8),
                  CoachMilestoneCard(
                    onTap: () => provider.ask(question: 'Làm thế nào để hoàn thành Milestone 01: Build a test suite?'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField(s),
      ],
    );
  }

  Widget _buildInputField(CoachSettings s) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return TextField(
      controller: controller,
      maxLength: 300,
      enabled: !provider.asking && s.remaining > 0,
      decoration: InputDecoration(
        hintText: s.remaining == 0
            ? 'Hết lượt hôm nay, hỏi lại ngày mai'
            : 'Hỏi ngắn về skill hoặc lộ trình',
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send_rounded, color: AppColors.primary),
          onPressed: provider.asking || s.remaining == 0 ? null : onAsk,
        ),
      ),
      onSubmitted: (_) => onAsk(),
    );
  }
}
