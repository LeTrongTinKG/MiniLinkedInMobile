import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';

/// Chữ cái đầu của tên công ty, dùng khi không có logo
String companyInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final words = trimmed.split(RegExp(r'[\s\-_]+'));
  if (words.length == 1) {
    return trimmed.substring(0, trimmed.length.clamp(0, 2)).toUpperCase();
  }
  return words.take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
}

/// Logo công ty 48x48: có URL thì tải ảnh, lỗi/không có thì hiện chữ cái đầu
class CompanyLogo extends StatelessWidget {
  final String? logoUrl;
  final String companyName;

  const CompanyLogo({super.key, required this.logoUrl, required this.companyName});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLogo),
        child: Container(
          width: 48,
          height: 48,
          color: AppColors.surface,
          child: Image.network(
            logoUrl!,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final colors = AppColors.logoColorsFor(companyName);
    final initials = companyInitials(companyName);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors[0],
        borderRadius: BorderRadius.circular(AppSpacing.radiusLogo),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: initials.length > 1 ? 16 : 20,
          fontWeight: FontWeight.w700,
          color: colors[1],
        ),
      ),
    );
  }
}
