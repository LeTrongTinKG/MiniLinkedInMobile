import 'package:flutter/material.dart';
import 'package:app/core/theme/app_theme.dart';

class CvEmptyState extends StatelessWidget {
  final VoidCallback onUpload;

  const CvEmptyState({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceGray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.upload_file_outlined,
                size: 40,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có CV',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tải CV lên để app đọc kỹ năng của bạn\nvà tính % phù hợp với từng job.',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: onUpload,
                child: const Text('Tải CV lên'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chỉ nhận PDF, tối đa 5 MB',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
