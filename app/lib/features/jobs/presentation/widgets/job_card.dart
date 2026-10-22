import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
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
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              Text(job.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    height: 1.25,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(job.companyName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  )),
                              const SizedBox(height: 2),
                              Text(meta,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.textMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
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
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(salary,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.salary)),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.xs),
                            ),
                            child: const Text('Mới',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent)),
                          ),
                      ],
                    ),
                    if (skills.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...skills.take(3).map((s) => _SkillChip(label: s)),
                          if (skills.length > 3)
                            _SkillChip(label: '+${skills.length - 3}'),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(job.timeAgo,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    // ReactionBar sẽ gắn ở đây
                    const SizedBox.shrink(),
                  ],
                ),
              ),
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

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary)),
    );
  }
}
