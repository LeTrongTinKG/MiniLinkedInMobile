import 'package:flutter/material.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/cv/domain/entities/cv_entity.dart';

class CvCard extends StatelessWidget {
  final CvEntity cv;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  const CvCard({
    super.key,
    required this.cv,
    required this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: cv.isDefault ? AppTheme.primaryBlue : AppTheme.divider,
          width: cv.isDefault ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PdfIcon(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cv.fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (cv.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Mặc định',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tải lên ${cv.formattedDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cv.skills.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: cv.skills.map((s) => _SkillChip(skill: s)).toList(),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!cv.isDefault && onSetDefault != null) ...[
                OutlinedButton(
                  onPressed: onSetDefault,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(color: AppTheme.textPrimary),
                    foregroundColor: AppTheme.textPrimary,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Đặt mặc định'),
                ),
                const SizedBox(width: 12),
              ],
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppTheme.errorRed,
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                child: const Text('Xoá'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PdfIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E0),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.picture_as_pdf, color: Color(0xFFD94F3E), size: 20),
          SizedBox(height: 1),
          Text(
            'PDF',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD94F3E),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String skill;
  const _SkillChip({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGray,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        skill,
        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
      ),
    );
  }
}
