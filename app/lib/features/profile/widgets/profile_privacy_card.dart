import 'package:flutter/material.dart';
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
        color: isPriv ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: isPriv ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
        ),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(
              isPriv ? Icons.lock_rounded : Icons.lock_open_rounded,
              size: 18,
              color: isPriv ? const Color(0xFF16A34A) : const Color(0xFFD97706),
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
