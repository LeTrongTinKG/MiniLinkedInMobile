import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../../../consent/presentation/screens/analysis_consent_screen.dart';
import '../../../consent/presentation/viewmodels/consent_view_model.dart';
import '../viewmodels/repo_upload_view_model.dart';
import '../widgets/repo_suggestion_card.dart';

/// Màn hình "Up Repo thay thế CV" - cấp chứng thực bằng chứng năng lực
class RepoUploadScreen extends StatefulWidget {
  const RepoUploadScreen({super.key});

  @override
  State<RepoUploadScreen> createState() => _RepoUploadScreenState();
}

class _RepoUploadScreenState extends State<RepoUploadScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan() async {
    final consentVm = context.read<ConsentViewModel>();
    final repoVm = context.read<RepoUploadViewModel>();

    if (consentVm.granted != true) {
      final agreed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const AnalysisConsentScreen()),
      );
      if (agreed != true) return;
    }

    await repoVm.scanRepo(hasConsent: true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RepoUploadViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Up Repo thay vì CV'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'Chứng thực năng lực bằng Repository GitHub',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dán link Repo dự án thực tế của bạn. Hệ thống sẽ trích xuất ngôn ngữ và thư viện để đánh dấu mức độ tin cậy "Có hoạt động mã nguồn đáng kể".',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Link GitHub Repository',
                hintText: 'https://github.com/username/project',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusInput),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusInput),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusInput),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted),
                  onPressed: () {
                    _controller.clear();
                    vm.setRepoUrl('');
                  },
                ),
              ),
              onChanged: vm.setRepoUrl,
            ),
            if (vm.failure != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  vm.failure!.message,
                  style:
                      const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.analytics_outlined),
                label: Text(
                  vm.scanning
                      ? 'Đang phân tích...'
                      : 'Phân tích & Trích xuất Skill',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
                onPressed: vm.scanning ? null : _handleScan,
              ),
            ),
            if (vm.suggestions.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Kỹ năng tìm thấy từ Repo:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              for (final s in vm.suggestions)
                RepoSuggestionCard(
                  suggestion: s,
                  onAccept: () => vm.decide(s.id, accept: true),
                  onIgnore: () => vm.decide(s.id, accept: false),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
