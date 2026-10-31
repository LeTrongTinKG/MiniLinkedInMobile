import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../viewmodels/skills_view_model.dart';
import '../widgets/confidence_badge.dart';
import 'repo_upload_screen.dart';

/// Màn hình Quản lý Kỹ năng 3 cấp độ tin cậy (F-008, F-009, F-010 · Ticket 04).
class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkillsViewModel>().load();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SkillsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kỹ năng & Bằng chứng'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: vm.loading && vm.skills.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeaderCard(context),
                  const SizedBox(height: 16),
                  const Text(
                    'Kỹ năng của bạn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (vm.skills.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Chưa có kỹ năng nào. Bạn có thể tự thêm hoặc up repo bên dưới.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  else
                    for (final s in vm.skills)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ConfidenceBadge(confidence: s.confidence, compact: true),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              tooltip: 'Xóa kỹ năng',
                              onPressed: vm.saving ? null : () => vm.delete(s),
                            ),
                          ],
                        ),
                      ),
                  const Divider(height: 32),
                  const Text(
                    'Tự khai báo kỹ năng (Self-claimed)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _input,
                          placeholder: 'Nhập tên kỹ năng (VD: Docker, SQL...)',
                          errorText: vm.failure?.message,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        label: vm.saving ? 'Đang lưu...' : 'Thêm',
                        loading: vm.saving,
                        onPressed: () async {
                          final ok = await vm.addSkill(_input.text);
                          if (ok) _input.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3 cấp độ tin cậy của kỹ năng:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text('• 👤 Tự khai (Self-claimed): Tự bạn thêm thủ công.'),
          const Text('• 🔗 Có bằng chứng (Evidenced): Trích xuất từ GitHub repo / dự án.'),
          const Text('• 🛡️ Được xác nhận (Endorsed): Đồng nghiệp có chuyên môn xác nhận.'),
          const SizedBox(height: 12),
          AppButton(
            label: 'Up Repo GitHub thay vì CV',
            icon: Icons.code,
            variant: AppButtonVariant.outline,
            fullWidth: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RepoUploadScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
