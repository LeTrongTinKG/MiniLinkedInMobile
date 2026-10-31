import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../locale_view_model.dart';

/// Nút chuyển đổi ngôn ngữ tức thì vi/en (Ticket 03, F-017, F-019 A11y)
class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocaleViewModel>();
    final isVi = vm.isVietnamese;

    return Semantics(
      label: 'Chuyển đổi ngôn ngữ. Hiện tại: ${isVi ? "Tiếng Việt" : "English"}',
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => vm.toggleLanguage(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 18,
                  color: isVi ? AppColors.primary : const Color(0xFF007A3D),
                ),
                const SizedBox(width: 4),
                Text(
                  isVi ? 'VI' : 'EN',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
