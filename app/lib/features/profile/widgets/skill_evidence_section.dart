import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import '../../skills/presentation/screens/skills_screen.dart';

/// Card phân loại 3 cấp độ kỹ năng theo thiết kế v0 (Evidenced, Supporting, Self-claimed).
class SkillEvidenceSection extends StatelessWidget {
  const SkillEvidenceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 14),
          _buildGroup(isDark, 'EVIDENCED', _Tone.emerald, const ['Flutter · 18 commits', 'Dart · 2.4k lines']),
          const SizedBox(height: 12),
          _buildGroup(isDark, 'SUPPORTING', _Tone.amber, const ['Provider · pubspec.yaml', 'Firebase · 6 imports']),
          const SizedBox(height: 12),
          _buildGroup(isDark, 'SELF-CLAIMED', _Tone.slate, const ['Figma', 'Agile']),
          const SizedBox(height: 12),
          _buildManageButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skill evidence',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Xác thực tự động từ GitHub & dự án',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user_rounded, size: 20, color: Color(0xFF10B981)),
        ),
      ],
    );
  }

  Widget _buildGroup(bool isDark, String label, _Tone tone, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: tone.dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(color: tone.bg(isDark), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tone == _Tone.emerald) ...[
                    Icon(Icons.check_rounded, size: 12, color: tone.fg(isDark)),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    item,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: tone.fg(isDark)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildManageButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SkillsScreen())),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Xem chi tiết & Quản lý kỹ năng',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

enum _Tone {
  emerald(Color(0xFF10B981)),
  amber(Color(0xFFF59E0B)),
  slate(Color(0xFF94A3B8));

  final Color dotColor;
  const _Tone(this.dotColor);

  Color bg(bool isDark) => switch (this) {
        emerald => isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFECFDF5),
        amber => isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFFFBEB),
        slate => isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      };

  Color fg(bool isDark) => switch (this) {
        emerald => isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
        amber => isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
        slate => isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
      };
}
