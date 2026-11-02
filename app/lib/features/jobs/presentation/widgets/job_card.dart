import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/interactions/presentation/widgets/reaction_bar.dart';
import '../../domain/entities/job_entity.dart';
import 'job_badge.dart';
import 'job_card_header.dart';

String _shortLocation(String loc) {
  final i = loc.indexOf(' (');
  return i >= 0 ? loc.substring(0, i) : loc;
}

String _shortMode(WorkMode m) =>
    const {WorkMode.onsite: 'Tại VP', WorkMode.hybrid: 'Hybrid', WorkMode.remote: 'Remote'}[m]!;

/// Mô tả job ngoài có nhiều dòng: gộp thành 1 đoạn để card cắt gọn
String _flatten(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

/// Thẻ job trong danh sách (giống component JobCard bên React)
class JobCard extends StatefulWidget {
  final JobEntity job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _hovered = false; // ~ useState: chuột đang rê lên thẻ (web/desktop)
  JobEntity get job => widget.job;

  @override
  Widget build(BuildContext context) {
    final isNew = DateTime.now().difference(job.createdAt).inDays <= 3;
    final salary = job.formattedSalary;
    // Dòng địa điểm + hình thức (bỏ phần trống nếu job ngoài thiếu địa điểm)
    final meta = [_shortLocation(job.location), _shortMode(job.workMode)]
        .where((e) => e.isNotEmpty)
        .join(' · ');
    final description = _flatten(job.description);
    final skills = job.requiredSkills;

    return Semantics(
      label: '${job.title}, ${job.companyName}, ${_shortLocation(job.location)}, $salary',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: _hovered ? 12 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Logo + tên công ty + thời gian
                JobCardHeader(job: job),
                // 2. Nội dung: bấm vào để mở chi tiết
                Expanded(
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge nguồn + badge level
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              JobBadge(job.sourceName, highlight: true),
                              JobBadge(job.level.label),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(job.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              )),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(meta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.textSecondary)),
                          ],
                          const SizedBox(height: AppSpacing.xs),
                          // Lương + nhãn "Mới"
                          Row(
                            children: [
                              Flexible(
                                child: Text(salary,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.salary)),
                              ),
                              if (isNew) ...[
                                const SizedBox(width: AppSpacing.sm),
                                const JobBadge('Mới', highlight: true),
                              ],
                            ],
                          ),
                          // Mô tả cắt còn 2 dòng
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textMuted)),
                          ],
                          // Kỹ năng dạng hashtag
                          if (skills.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              skills
                                  .take(4)
                                  .map((s) => '#${s.replaceAll(RegExp(r'\s+'), '')}')
                                  .join('  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // 3. Thích / Bình luận / Chia sẻ
                ReactionBar(
                  targetId: job.id,
                  shareText: '${job.title} - ${job.companyName}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
