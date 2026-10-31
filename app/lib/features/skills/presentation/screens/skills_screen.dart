import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
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
      appBar: AppBar(title: const Text('Kỹ năng & Bằng chứng')),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (vm.skills.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Chưa có kỹ năng nào. Bạn có thể tự thêm hoặc up repo bên dưới.'),
                    )
                  else
                    for (final s in vm.skills)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ConfidenceBadge(confidence: s.confidence, compact: true),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                          tooltip: 'Xóa kỹ năng',
                          onPressed: vm.saving ? null : () => vm.delete(s),
                        ),
                      ),
                  const Divider(height: 32),
                  const Text(
                    'Tự khai báo kỹ năng (Self-claimed)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          decoration: InputDecoration(
                            hintText: 'Nhập tên kỹ năng (VD: Docker, SQL...)',
                            errorText: vm.failure?.message,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: vm.saving
                              ? null
                              : () async {
                                  final ok = await vm.addSkill(_input.text);
                                  if (ok) _input.clear();
                                },
                          child: Text(vm.saving ? 'Đang lưu...' : 'Thêm'),
                        ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3 cấp độ tin cậy của kỹ năng:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text('• 👤 Tự khai (Self-claimed): Tự bạn thêm thủ công.'),
          const Text('• 🔗 Có bằng chứng (Evidenced): Trích xuất từ GitHub repo / dự án.'),
          const Text('• 🛡️ Được xác nhận (Endorsed): Đồng nghiệp có chuyên môn xác nhận.'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.code),
              label: const Text('Up Repo GitHub thay vì CV'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RepoUploadScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
