import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import '../providers/job_provider.dart';

// Dòng chào người dùng và số việc làm đang tuyển.
class JobGreetingRow extends StatelessWidget {
  final JobProvider provider;
  const JobGreetingRow({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final displayName = auth.currentUser?.displayName ?? '';
        final firstName = displayName.split(' ').last;
        final greeting = firstName.isNotEmpty ? 'Chào $firstName,' : 'Xin chào,';
        final count = provider.jobs.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              if (!provider.isLoading && count > 0)
                Text(
                  'Hôm nay có $count việc làm IT đang tuyển',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
            ],
          ),
        );
      },
    );
  }
}
