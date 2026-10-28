import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/student_home/student_nav.dart';

/// Header dùng chung cho cả 3 tab: nút menu (mở Drawer) + logo + tiêu đề + avatar.
/// Giống 1 component <Header title="..."/> trong React.
class AppHeader extends StatelessWidget {
  final String title;

  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
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
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
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

// Avatar tròn lấy chữ cái đầu của tên người dùng đang đăng nhập.
class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().currentUser?.displayName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Tooltip(
      message: name.isNotEmpty ? name : 'Người dùng',
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
