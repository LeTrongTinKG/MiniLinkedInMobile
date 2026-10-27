import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/applications/domain/entities/application_entity.dart';
import 'package:app/features/applications/presentation/providers/recruiter_applications_provider.dart';
import 'package:app/features/applications/presentation/widgets/application_status_badge.dart';
import 'package:app/features/applications/presentation/widgets/match_score_chip.dart';

/// Thẻ ứng viên: tên, vị trí, điểm match, kỹ năng khớp/thiếu và nút Duyệt / Từ chối
class RecruiterApplicationCard extends StatelessWidget {
  const RecruiterApplicationCard({super.key, required this.application});

  final ApplicationEntity application;

  Future<void> _decide(BuildContext context, ApplicationStatus status, String verb) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<RecruiterApplicationsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$verb ứng viên?'),
        content: Text('${application.studentName} · ${application.jobTitle}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(verb)),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await provider.setStatus(application.id, status);
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Đã cập nhật: ${status.label}')));
  }

  @override
  Widget build(BuildContext context) {
    final a = application;
    final decided = a.status == ApplicationStatus.accepted ||
        a.status == ApplicationStatus.rejected ||
        a.status.isClosed;
    final initial = a.studentName.isEmpty ? '?' : a.studentName[0].toUpperCase();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(initial, style: const TextStyle(color: AppColors.primary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.studentName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        [a.studentMajor, a.studentSchool].where((s) => s.isNotEmpty).join(' · '),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                MatchScoreChip(a.matchScore),
              ],
            ),
            const SizedBox(height: 10),
            Text('${a.jobTitle} · nộp ${a.formattedDate}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            if (a.cvFileName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(a.cvFileName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ),
                ]),
              ),
            if (a.matchedSkills.isNotEmpty || a.missingSkills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4, children: [
                for (final s in a.matchedSkills)
                  _skill(s, const Color(0xFFD4EDDA), const Color(0xFF155724)),
                for (final s in a.missingSkills)
                  _skill('thiếu $s', const Color(0xFFFADADD), AppColors.error),
              ]),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                ApplicationStatusBadge(a.status),
                const Spacer(),
                if (!decided) ...[
                  OutlinedButton.icon(
                    onPressed: () => _decide(context, ApplicationStatus.rejected, 'Từ chối'),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Từ chối'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      // Theme đặt nút rộng vô hạn; trong Row phải thu về vừa nội dung
                      minimumSize: const Size(0, 40),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _decide(context, ApplicationStatus.accepted, 'Duyệt đơn'),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Duyệt đơn'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _skill(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
      );
}
