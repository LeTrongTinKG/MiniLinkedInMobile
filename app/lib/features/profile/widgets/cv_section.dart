import 'package:flutter/material.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/profile/cv_item.dart';
import 'package:app/features/profile/widgets/cv_card.dart';
import 'package:app/features/profile/widgets/cv_empty_state.dart';

class CvSection extends StatelessWidget {
  final List<CvItem> cvs;
  final VoidCallback onUpload;
  final void Function(String id) onDelete;
  final void Function(String id) onSetDefault;

  const CvSection({
    super.key,
    required this.cvs,
    required this.onUpload,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    if (cvs.isEmpty) {
      return CvEmptyState(onUpload: onUpload);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CV của tôi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${cvs.length} file',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: cvs
                .map((cv) => CvCard(
                      cv: cv,
                      onDelete: () => onDelete(cv.id),
                      onSetDefault:
                          cv.isDefault ? null : () => onSetDefault(cv.id),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_outlined, size: 18),
            label: const Text('Tải CV lên (PDF, tối đa 5 MB)'),
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'CV mặc định được dùng để tính % phù hợp khi bạn xem job.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Học vấn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
