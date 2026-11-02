import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_view_model.dart';
import '../../../../core/theme/app_colors.dart';
import 'dock_item.dart';

/// Floating Glassmorphic Dock Component - Lấy cảm hứng từ 21st.dev (@ruixen.ui/dock)
/// Hỗ trợ 3D arc perspective, hover/active scale, glowing indicator và theme toggle.
class StudentFloatingDock extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpenCoach;

  const StudentFloatingDock({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onOpenCoach,
  });

  @override
  Widget build(BuildContext context) {
    final themeVm = Provider.of<ThemeViewModel?>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      alignment: Alignment.bottomCenter,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0.04),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.75)
                    : Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DockItem(
                    icon: Icons.work_outline_rounded,
                    activeIcon: Icons.work_rounded,
                    label: 'Việc làm',
                    isActive: selectedIndex == 0,
                    onTap: () => onSelect(0),
                  ),
                  const SizedBox(width: 6),
                  DockItem(
                    icon: Icons.public_rounded,
                    activeIcon: Icons.public_rounded,
                    label: 'Mạng xã hội',
                    isActive: selectedIndex == 1,
                    onTap: () => onSelect(1),
                  ),
                  const SizedBox(width: 6),
                  DockItem(
                    icon: Icons.newspaper_rounded,
                    activeIcon: Icons.newspaper_rounded,
                    label: 'Tin tức',
                    isActive: selectedIndex == 2,
                    onTap: () => onSelect(2),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 28,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 8),
                  DockItem(
                    icon: Icons.auto_awesome_rounded,
                    activeIcon: Icons.auto_awesome_rounded,
                    label: 'Trợ lý AI',
                    highlightColor: Colors.amber,
                    isActive: false,
                    onTap: onOpenCoach,
                  ),
                  const SizedBox(width: 6),
                  DockItem(
                    icon: isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    activeIcon: isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    label: isDark ? 'Bật chế độ Sáng' : 'Bật chế độ Tối',
                    highlightColor: isDark ? Colors.orangeAccent : const Color(0xFF6366F1),
                    isActive: false,
                    onTap: () => themeVm?.toggleTheme(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
