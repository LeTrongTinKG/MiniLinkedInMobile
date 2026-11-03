import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/cv/presentation/providers/cv_provider.dart';
import 'package:app/features/profile/widgets/profile_app_bar.dart';
import 'package:app/features/profile/widgets/profile_header.dart';
import 'package:app/features/profile/widgets/cv_section.dart';
import 'package:app/features/profile/widgets/proof_of_work_card.dart';
import 'package:app/features/profile/widgets/skill_evidence_section.dart';
import 'package:app/features/profile/edit_profile_page.dart';
import 'package:app/features/skills/presentation/github_skill_section.dart';
import 'package:app/features/skills/presentation/skill_suggestion_provider.dart';
import 'package:app/features/skills/presentation/screens/repo_upload_screen.dart';
import 'package:app/features/skills/presentation/screens/skills_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CvProvider>().loadCvs();
      context.read<SkillSuggestionProvider>().load();
    });
  }

  Future<void> _handleUpload() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (files.isEmpty || !mounted) return;

    final file = files.first;
    final fileSize = file.lengthSync() ?? await file.length();
    if (!mounted) return;
    if (fileSize != null && fileSize > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File không được vượt quá 5 MB')),
      );
      return;
    }

    final success = await context.read<CvProvider>().uploadCv(file);
    if (!mounted) return;
    if (!success) {
      final msg = context.read<CvProvider>().errorMessage ?? 'Tải lên thất bại';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.currentUser;
            return Column(
              children: [
                ProfileAppBar(onSettings: () {}),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, AppSpacing.bottomContentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPrivacyBanner(),
                        const SizedBox(height: 12),
                        ProfileHeader(
                          name: user?.displayName ?? 'Người dùng',
                          avatarUrl: user?.avatarUrl,
                          headline: 'Sinh viên CNTT · tìm thực tập Flutter',
                          location: 'TP. Hồ Chí Minh',
                          onEditProfile: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const ProofOfWorkCard(),
                        const SizedBox(height: 16),
                        const SkillEvidenceSection(),
                        const Divider(height: 24),
                        Consumer<CvProvider>(
                          builder: (context, cv, _) {
                            if (cv.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return CvSection(
                              cvs: cv.cvs,
                              onUpload: _handleUpload,
                              onUploadRepo: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RepoUploadScreen(),
                                  ),
                                );
                              },
                              onDelete: (id) => cv.deleteCv(id),
                              onSetDefault: (id) => cv.setDefault(id),
                            );
                          },
                        ),
                        if (auth.isStudent) ...[
                          const Divider(height: 24),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.stars_outlined, color: AppColors.primary),
                            title: const Text('Kỹ năng & Bằng chứng (3 cấp độ)', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Tự khai, có bằng chứng repo, hoặc được xác nhận', style: TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SkillsScreen()),
                              );
                            },
                          ),
                          const Divider(height: 24),
                          const GithubSkillSection(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrivacyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(color: AppColors.successBorder, width: 1),
      ),
      child: Row(
        children: const [
          Icon(Icons.lock, size: 16, color: AppColors.salary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hồ sơ bảo vệ riêng tư mặc định (Chuẩn Atom)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.successDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
