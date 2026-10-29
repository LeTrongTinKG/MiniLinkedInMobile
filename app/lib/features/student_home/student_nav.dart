import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/applications/applications_page.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/profile/profile_page.dart';
import 'package:app/features/news/presentation/screens/news_page.dart';

/// Key của Scaffold chính trong StudentHomeScreen, để header mở được drawer.
final GlobalKey<ScaffoldState> studentScaffoldKey = GlobalKey<ScaffoldState>();

/// Nút hamburger mở drawer trượt từ trái.
class StudentMenuButton extends StatelessWidget {
  const StudentMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Menu',
      icon: const Icon(Icons.menu_rounded),
      color: AppColors.textPrimary,
      onPressed: () => studentScaffoldKey.currentState?.openDrawer(),
    );
  }
}

/// Drawer trượt từ trái: "Đã ứng tuyển", "Hồ sơ & CV" và Đăng xuất.
/// Chọn mục nào thì đóng drawer rồi mở trang đó đè lên shell (bấm Back để quay lại).
class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  // Đóng drawer rồi mở trang mới (giống navigate('/path') trong React Router).
  void _openPage(BuildContext context, Widget page) {
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(MaterialPageRoute(builder: (_) => Scaffold(body: page)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.currentUser?.displayName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Phần đầu: avatar + tên người dùng.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(initial,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimaryContainer)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name.isNotEmpty ? name : 'Người dùng',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Các trang phụ: mở bằng cách push route.
            _DrawerItem(
              icon: Icons.newspaper_rounded,
              label: 'Tin công nghệ & AI',
              onTap: () => _openPage(context, const NewsPage()),
            ),
            _DrawerItem(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Đã ứng tuyển',
              onTap: () => _openPage(context, const ApplicationsPage()),
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              label: 'Hồ sơ & CV',
              onTap: () => _openPage(context, const ProfilePage()),
            ),
            const Spacer(),
            const Divider(height: 1),
            // Đăng xuất rồi về màn đăng nhập.
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Đăng xuất',
              onTap: () async {
                final nav = Navigator.of(context);
                await context.read<AuthProvider>().logout();
                nav.pushNamedAndRemoveUntil('/login', (_) => false);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Một dòng trong drawer (icon + chữ).
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        onTap: onTap,
      ),
    );
  }
}
