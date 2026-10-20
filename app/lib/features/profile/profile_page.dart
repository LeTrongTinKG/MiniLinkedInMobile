import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/profile/cv_item.dart';
import 'package:app/features/profile/widgets/profile_header.dart';
import 'package:app/features/profile/widgets/cv_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock data — thay bằng API khi B4 hoàn thành
  List<CvItem> _cvs = const [
    CvItem(
      id: '1',
      fileName: 'CV_LanNguyen_Flutter....',
      uploadDate: '18/10',
      fileSize: '412 KB',
      skills: ['flutter', 'dart', 'git', 'firebase'],
      isDefault: true,
    ),
    CvItem(
      id: '2',
      fileName: 'CV_LanNguyen_Web.pdf',
      uploadDate: '02/10',
      fileSize: '380 KB',
      skills: ['react', 'nodejs', 'sql'],
      isDefault: false,
    ),
  ];

  void _handleDelete(String id) {
    setState(() => _cvs = _cvs.where((cv) => cv.id != id).toList());
  }

  void _handleSetDefault(String id) {
    setState(() {
      _cvs = _cvs.map((cv) => cv.copyWith(isDefault: cv.id == id)).toList();
    });
  }

  void _handleUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng đang phát triển')),
    );
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
                        onEditProfile: () {},
                      ),
                      const Divider(height: 1),
                      CvSection(
                        cvs: _cvs,
                        onUpload: _handleUpload,
                        onDelete: _handleDelete,
                        onSetDefault: _handleSetDefault,
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
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
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
