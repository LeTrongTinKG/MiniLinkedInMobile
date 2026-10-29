import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/cv/presentation/providers/cv_provider.dart';
import 'package:app/features/profile/widgets/profile_header.dart';
import 'package:app/features/profile/widgets/cv_section.dart';
import 'package:app/features/profile/edit_profile_page.dart';

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
      context.read<CvProvider>().loadCvs();
    });
  }

  Future<void> _handleUpload() async {
    // file_picker v12+: FilePicker.pickFiles() returns List<PlatformFile>
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
      final msg =
          context.read<CvProvider>().errorMessage ?? 'Tải lên thất bại';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;
          return Column(
            children: [
              _ProfileAppBar(onSettings: () {}),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(
                        name: user?.displayName ?? 'Người dùng',
                        headline:
                            'Sinh viên CNTT năm 4 · tìm thực tập Flutter',
                        location: 'TP. Hồ Chí Minh',
                        onEditProfile: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
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
                            onDelete: (id) => cv.deleteCv(id),
                            onSetDefault: (id) => cv.setDefault(id),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  final VoidCallback? onSettings;
  const _ProfileAppBar({this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          const BackButton(),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                'Hồ sơ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppTheme.textSecondary),
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}
