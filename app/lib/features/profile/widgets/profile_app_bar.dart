import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/widgets/language_switch_button.dart';

/// Thanh AppBar tùy biến cho trang Hồ sơ cá nhân.
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key, this.onSettings});

  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
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
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const LanguageSwitchButton(),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

