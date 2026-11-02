import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../presentation/viewmodels/profile_edit_view_model.dart';

class ProfilePrivacyCard extends StatelessWidget {
  const ProfilePrivacyCard({super.key, required this.vm});

  final ProfileEditViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isPriv = vm.profile.isPrivate;
    return Container(
      decoration: BoxDecoration(
        color: isPriv ? AppColors.successContainer : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: isPriv ? AppColors.successBorder : AppColors.warningBorder,
        ),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(
              isPriv ? Icons.lock_rounded : Icons.lock_open_rounded,
              size: 18,
              color: isPriv ? AppColors.salary : AppColors.warningDark,
            ),
            const SizedBox(width: 8),
            const Text(
              'Hồ sơ riêng tư (Mặc định)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        subtitle: const Text(
          'Khi bật, hồ sơ được bảo vệ riêng tư theo chuẩn Atom. Nhà tuyển dụng cần bạn đồng ý trước khi xem chi tiết.',
          style: TextStyle(fontSize: 12),
        ),
        value: isPriv,
        onChanged: (val) => vm.updateField(isPrivate: val),
      ),
    );
  }
}
