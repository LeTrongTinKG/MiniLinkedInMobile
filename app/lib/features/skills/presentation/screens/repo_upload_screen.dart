import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../consent/presentation/screens/analysis_consent_screen.dart';
import '../../../consent/presentation/viewmodels/consent_view_model.dart';
import '../../domain/models/skill_confidence.dart';
import '../viewmodels/repo_upload_view_model.dart';
import '../widgets/confidence_badge.dart';

/// Màn hình "Up Repo thay thế CV" - cho phép ứng viên cung cấp GitHub Repo làm bằng chứng năng lực.
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
      appBar: AppBar(title: const Text('Up Repo thay vì CV')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Chứng thực năng lực bằng Repository GitHub',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dán link Repo dự án thực tế của bạn. Hệ thống sẽ trích xuất ngôn ngữ và thư viện để cấp chứng nhận "Có bằng chứng" (Evidenced).',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Link GitHub Repository',
                hintText: 'https://github.com/username/project',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
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
                  style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.analytics_outlined),
                label: Text(vm.scanning ? 'Đang phân tích...' : 'Phân tích & Trích xuất Skill'),
                onPressed: vm.scanning ? null : _handleScan,
              ),
            ),
            if (vm.suggestions.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Kỹ năng tìm thấy từ Repo:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              for (final s in vm.suggestions)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              s.skillName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Spacer(),
                            const ConfidenceBadge(confidence: SkillConfidence.evidenced),
                          ],
                        ),
                        const SizedBox(height: 6),
                        for (final e in s.evidence)
                          Text(
                            '${e.repo}: ${e.signals.join(', ')}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => vm.decide(s.id, accept: false),
                              child: const Text('Bỏ qua'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => vm.decide(s.id, accept: true),
                              child: const Text('Thêm vào hồ sơ'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
