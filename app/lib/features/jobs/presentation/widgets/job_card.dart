import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/interactions/presentation/widgets/reaction_bar.dart';
import '../../domain/entities/job_entity.dart';

String _initials(String name) {
  final words = name.trim().split(RegExp(r'[\s\-_]+'));
  if (words.length == 1) {
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
  return words.take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
}

String _shortLocation(String loc) {
  final i = loc.indexOf(' (');
  return i >= 0 ? loc.substring(0, i) : loc;
}

String _formatSalary(int? min, int? max) {
  if (min == null && max == null) return 'Thoả thuận';
  String f(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  if (min != null && max != null) return '\$${f(min)} – \$${f(max)} / tháng';
  if (min != null) return 'Từ \$${f(min)} / tháng';
  return 'Lên tới \$${f(max!)} / tháng';
}

String _shortMode(WorkMode m) =>
    const {WorkMode.onsite: 'Tại VP', WorkMode.hybrid: 'Hybrid', WorkMode.remote: 'Remote'}[m]!;

class JobCard extends StatefulWidget {
  final JobEntity job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _hovered = false;
  JobEntity get job => widget.job;

  @override
  Widget build(BuildContext context) {
    final isNew = DateTime.now().difference(job.createdAt).inDays <= 3;
    final logoColors = AppColors.logoColorsFor(job.companyName);
    final salary = _formatSalary(job.salaryMin, job.salaryMax);
    final meta =
        '${_shortLocation(job.location)} · ${_shortMode(job.workMode)} · ${job.level.label}';
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
            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.16 : 0.10),
                blurRadius: _hovered ? 6 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header kiểu bài đăng: avatar công ty + tên + thời gian
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.xs, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _CompanyLogo(
                        logoUrl: job.companyLogoUrl,
                        initials: _initials(job.companyName),
                        colors: logoColors,
                      ),
                      const SizedBox(width: AppSpacing.md),
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
                            Row(
                              children: [
                                Flexible(
                                  child: Text(job.timeAgo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textMuted)),
                                ),
                                const Text(' · ',
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textMuted)),
                                const Icon(Icons.public,
                                    size: 12, color: AppColors.textMuted),
                              ],
                            ),
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
                ),
                // Nội dung bài đăng
                InkWell(
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            )),
                        const SizedBox(height: AppSpacing.xs),
                        Text(meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.xs),
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentContainer,
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.xs),
                                ),
                                child: const Text('Mới',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.accent)),
                              ),
                            ],
                          ],
                        ),
                        if (skills.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            skills
                                .take(4)
                                .map((s) => '#${s.replaceAll(RegExp(r'\s+'), '')}')
                                .join('  '),
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.primary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Thống kê + Thích / Bình luận / Chia sẻ
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

class _CompanyLogo extends StatelessWidget {
  final String? logoUrl;
  final String initials;
  final List<Color> colors;

  const _CompanyLogo({required this.logoUrl, required this.initials, required this.colors});

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

  Widget _fallback() => Container(
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
