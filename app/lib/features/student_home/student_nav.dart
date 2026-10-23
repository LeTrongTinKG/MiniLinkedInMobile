import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

/// Key của Scaffold chính trong StudentHomeScreen, để các trang con mở drawer.
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

class StudentDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const StudentDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _items = <({IconData icon, IconData selectedIcon, String label})>[
    (icon: Icons.work_outline, selectedIcon: Icons.work, label: 'Việc làm'),
    (
      icon: Icons.assignment_turned_in_outlined,
      selectedIcon: Icons.assignment_turned_in,
      label: 'Đã ứng tuyển'
    ),
    (
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
      label: 'Hồ sơ & CV'
    ),
  ];

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
            for (var i = 0; i < _items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  selected: i == selectedIndex,
                  selectedTileColor: AppColors.primaryContainer,
                  selectedColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  leading: Icon(
                      i == selectedIndex ? _items[i].selectedIcon : _items[i].icon),
                  title: Text(_items[i].label,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(i);
                  },
                ),
              ),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Đăng xuất',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  final nav = Navigator.of(context);
                  await context.read<AuthProvider>().logout();
                  nav.pushNamedAndRemoveUntil('/login', (_) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
