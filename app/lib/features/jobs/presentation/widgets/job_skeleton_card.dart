import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';

class JobSkeletonCard extends StatefulWidget {
  const JobSkeletonCard({super.key});

  @override
  State<JobSkeletonCard> createState() => _JobSkeletonCardState();
}

class _JobSkeletonCardState extends State<JobSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(48, 48, radius: AppSpacing.radiusLogo),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _block(double.infinity, 16),
                        const SizedBox(height: 6),
                        _block(140, 13),
                        const SizedBox(height: 4),
                        _block(180, 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _block(22, 22, radius: 4),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _block(160, 14),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _block(60, 24, radius: 6),
                  const SizedBox(width: 6),
                  _block(60, 24, radius: 6),
                  const SizedBox(width: 6),
                  _block(60, 24, radius: 6),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              _block(80, 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _block(double w, double h, {double radius = 4}) => Container(
        width: w == double.infinity ? null : w,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
