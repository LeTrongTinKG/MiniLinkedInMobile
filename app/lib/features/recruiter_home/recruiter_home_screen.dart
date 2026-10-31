import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/ui_kit/app_button.dart';
import 'package:app/ui_kit/app_empty_state.dart';
import 'recruiter_applications_page.dart';
import 'recruiter_jobs_page.dart';

class RecruiterHomeScreen extends StatefulWidget {
  const RecruiterHomeScreen({super.key});

  @override
  State<RecruiterHomeScreen> createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends State<RecruiterHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const RecruiterJobsPage(),
      const RecruiterApplicationsPage(),
      const AppEmptyState(
        icon: Icons.post_add_outlined,
        title: 'Đăng tin tuyển dụng',
        message:
            'Tạo bài đăng tuyển dụng mới để tiếp cận hàng ngàn ứng viên tiềm năng.',
        actionLabel: 'Tạo tin mới',
      ),
      const AppEmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Chưa có thông báo',
        message:
            'Các hoạt động ứng tuyển và tương tác mới sẽ xuất hiện tại đây.',
      ),
      const _RecruiterProfileView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Việc đăng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              label: 'Ứng viên',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              label: 'Đăng việc',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded),
              label: 'Thông báo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}

class _RecruiterProfileView extends StatelessWidget {
  const _RecruiterProfileView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final initial = (user?.displayName ?? '?')[0].toUpperCase();

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'Nhà tuyển dụng',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Chip(
                  label: const Text(
                    'Nhà tuyển dụng',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  side: BorderSide.none,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: AppButton(
                    label: 'Đăng xuất',
                    variant: AppButtonVariant.outline,
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
