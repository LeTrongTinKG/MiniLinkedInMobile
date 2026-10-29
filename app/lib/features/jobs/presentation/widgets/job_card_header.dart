import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../../domain/entities/job_entity.dart';
import 'job_company_logo.dart';

/// Phần đầu thẻ job kiểu bài đăng: logo công ty + tên + thời gian + nút lưu
class JobCardHeader extends StatelessWidget {
  final JobEntity job;

  const JobCardHeader({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.xs, 0),
      child: Row(
        children: [
          CompanyLogo(logoUrl: job.companyLogoUrl, companyName: job.companyName),
          const SizedBox(width: AppSpacing.md),
          // Tên công ty (lấy từ companyName, không phụ thuộc recruiter) + thời gian đăng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 1),
                Text(job.timeAgo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded),
            iconSize: 22,
            color: AppColors.textMuted,
            tooltip: 'Lưu việc làm',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đã lưu: ${job.title}'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ],
      ),
    );
  }
}
