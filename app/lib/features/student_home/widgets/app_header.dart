import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/applications/applications_page.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/news/presentation/screens/news_page.dart';
import 'package:app/features/profile/profile_page.dart';
import 'package:app/features/student_home/logout_action.dart';
import 'package:app/features/student_home/student_nav.dart';
import 'package:app/ui_kit/ui_kit.dart';

/// Header dùng chung cho cả 3 tab: nút menu (mở Drawer) + logo + tiêu đề + avatar.
/// Giống 1 component <Header title="..."/> trong React.
class AppHeader extends StatelessWidget {
  final String title;

  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
          child: Row(
            children: [
              // Nút menu: bấm thì mở Drawer của shell.
              const StudentMenuButton(),
              const SizedBox(width: AppSpacing.xs),
              const _Logo(),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              const _CurvedMenuTrigger(),
              const SizedBox(width: AppSpacing.xs),
              const _UserAvatar(),
            ],
          ),
        ),
      ),
    );
  }
}

// Ô vuông "ML" màu chủ đạo.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: const Text(
        'ML',
        style: TextStyle(
          color: AppColors.surface,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

// Avatar người dùng đang đăng nhập. Bấm vào thì mở menu nhỏ (giống Facebook):
// tên + email ở trên, "Đăng xuất" ở dưới. Có ảnh đại diện thì hiện ảnh, không thì hiện chữ cái đầu.
class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final name = user?.displayName ?? '';

    return PopupMenuButton<String>(
      tooltip: name.isNotEmpty ? name : 'Tài khoản',
      offset: const Offset(0, 44), // menu mở bên dưới avatar, không che avatar
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == _logoutValue) confirmAndLogout(context);
      },
      itemBuilder: (_) => [
        // Dòng thông tin (không bấm được): tên và email
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : 'Người dùng',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              if (user != null)
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Dòng đăng xuất, icon và chữ màu đỏ để dễ nhận ra
        const PopupMenuItem<String>(
          value: _logoutValue,
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
              SizedBox(width: 12),
              Text(
                LogoutStrings.action,
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
      child: AppAvatar(imageUrl: user?.avatarUrl, name: name, size: 36),
    );
  }
}

const _logoutValue = 'logout';

class _CurvedMenuTrigger extends StatelessWidget {
  const _CurvedMenuTrigger();

  @override
  Widget build(BuildContext context) {
    return CurvedMenuButton(
      isActive: false,
      onTap: () {
        CurvedDrawer.show(
          context,
          items: [
            CurvedNavItem(
              title: 'Tin tức & AI',
              icon: Icons.article_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewsPage()),
              ),
            ),
            CurvedNavItem(
              title: 'Đã ứng tuyển',
              icon: Icons.assignment_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApplicationsPage()),
              ),
            ),
            CurvedNavItem(
              title: 'Hồ sơ & CV',
              icon: Icons.person_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),
          ],
        );
      },
    );
  }
}
