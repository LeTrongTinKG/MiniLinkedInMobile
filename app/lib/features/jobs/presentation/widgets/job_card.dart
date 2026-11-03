import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/interactions/presentation/widgets/reaction_bar.dart';
import '../../domain/entities/job_entity.dart';
import 'job_company_logo.dart';

String _shortLoc(String loc) =>
    loc.contains(' (') ? loc.substring(0, loc.indexOf(' (')) : loc;
String _mode(WorkMode m) =>
    const {WorkMode.onsite: 'Tại VP', WorkMode.hybrid: 'Hybrid', WorkMode.remote: 'Remote'}[m]!;

/// Thẻ Job thiết kế theo phong cách Clay Minimalist bo 24px từ v0.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salary = job.formattedSalary;
    final loc = _shortLoc(job.location);
    final skills = job.requiredSkills;

    return Semantics(
      label: '${job.title}, ${job.companyName}, $loc, $salary',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D4ED8).withValues(alpha: _hovered ? 0.12 : 0.05),
                blurRadius: _hovered ? 24 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(isDark, loc),
                _buildSalaryRow(isDark, salary),
                if (skills.isNotEmpty) _buildSkills(isDark, skills),
                _buildApplyButton(),
                const Divider(height: 1, thickness: 0.8),
                ReactionBar(targetId: job.id, shareText: '${job.title} - ${job.companyName}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, String loc) => InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyLogo(logoUrl: job.companyLogoUrl, companyName: job.companyName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          height: 1.25,
                        )),
                    const SizedBox(height: 3),
                    Text('${job.companyName} · $loc',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(job.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      );

  Widget _buildSalaryRow(bool isDark, String salary) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(salary,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                  )),
            ),
            Row(children: [
              Icon(Icons.public_rounded, size: 13, color: isDark ? Colors.white38 : Colors.black45),
              const SizedBox(width: 4),
              Text(_mode(job.workMode),
                  style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white54 : Colors.black54)),
            ]),
          ],
        ),
      );

  Widget _buildSkills(bool isDark, List<String> skills) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: skills.take(3).map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(tag,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                )),
          )).toList(),
        ),
      );

  Widget _buildApplyButton() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ứng tuyển ngay', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.north_east_rounded, size: 14),
              ],
            ),
          ),
        ),
      );
}
