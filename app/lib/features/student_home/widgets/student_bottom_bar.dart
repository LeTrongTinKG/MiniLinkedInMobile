import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';

/// Thanh 3 nút cố định ở dưới cùng: Việc làm / Mạng xã hội / Tin tức.
class StudentBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const StudentBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: AppColors.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.work_outline),
          selectedIcon: Icon(Icons.work),
          label: 'Việc làm',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Mạng xã hội',
        ),
        NavigationDestination(
          icon: Icon(Icons.newspaper_outlined),
          selectedIcon: Icon(Icons.newspaper),
          label: 'Tin tức',
        ),
      ],
    );
  }
}
