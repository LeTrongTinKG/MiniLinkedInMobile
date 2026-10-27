import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import '../../domain/entities/application_entity.dart';
import '../providers/student_applications_provider.dart';
import 'application_status_badge.dart';
import 'match_score_chip.dart';

/// Thẻ một đơn đã nộp: vị trí, công ty, ngày nộp, điểm match, trạng thái
class StudentApplicationCard extends StatelessWidget {
  const StudentApplicationCard({super.key, required this.application});

  final ApplicationEntity application;

  Future<void> _withdraw(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<StudentApplicationsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rút đơn ứng tuyển?'),
        content: Text('Bạn sẽ rút đơn vào "${application.jobTitle}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Rút đơn')),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await provider.withdraw(application.id);
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Đã rút đơn ứng tuyển')));
  }

  @override
  Widget build(BuildContext context) {
    final canWithdraw = application.status == ApplicationStatus.submitted;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.jobTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              '${application.companyName} · ${application.location}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ApplicationStatusBadge(application.status),
                MatchScoreChip(application.matchScore),
                Text(
                  'Nộp ${application.formattedDate}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            if (canWithdraw) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _withdraw(context),
                  child: const Text('Rút đơn'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
