import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../data/skill_suggestion.dart';
import 'skill_suggestion_provider.dart';

/// Mục "Kỹ năng từ GitHub" trong hồ sơ: quét repo, xem bằng chứng, đồng ý hoặc bỏ qua.
class GithubSkillSection extends StatelessWidget {
  const GithubSkillSection({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SkillSuggestionProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kỹ năng từ GitHub',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton(
                onPressed: p.isBusy ? null : p.scan,
                child: Text(p.isBusy ? 'Đang quét...' : 'Quét GitHub'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Chỉ đề xuất khi repo có dấu hiệu rõ. Bạn duyệt từng kỹ năng.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          if (p.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                p.errorMessage!,
                style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
              ),
            ),
          if (p.scanned && p.suggestions.isEmpty && p.errorMessage == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Chưa có đề xuất mới.'),
            ),
          for (final s in p.suggestions) _SuggestionCard(suggestion: s),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final SkillSuggestion suggestion;
  const _SuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final p = context.read<SkillSuggestionProvider>();
    final busy = context.select<SkillSuggestionProvider, bool>((p) => p.isBusy);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            suggestion.skillName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          if (suggestion.confidenceLabel != null)
            Text(
              suggestion.confidenceLabel!,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.successGreen),
            ),
          const SizedBox(height: 4),
          for (final e in suggestion.evidence)
            Text(
              '${e.repo}: ${e.signals.map(signalLabel).join(', ')}',
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton(
                onPressed:
                    busy ? null : () => p.decide(suggestion.id, accept: true),
                child: const Text('Thêm vào hồ sơ'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed:
                    busy ? null : () => p.decide(suggestion.id, accept: false),
                child: const Text('Bỏ qua'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
