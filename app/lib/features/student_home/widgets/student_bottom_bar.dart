import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';

/// Thanh điều hướng nổi dạng pill bo 28dp phong cách Clay Minimalist.
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppSpacing.radiusDock),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 64,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.primaryContainer,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelect,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.work_outline),
                  selectedIcon: Icon(Icons.work, color: AppColors.primary),
                  label: 'Việc làm',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups, color: AppColors.primary),
                  label: 'Mạng xã hội',
                ),
                NavigationDestination(
                  icon: Icon(Icons.newspaper_outlined),
                  selectedIcon: Icon(Icons.newspaper, color: AppColors.primary),
                  label: 'Tin tức',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
