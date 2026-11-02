import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/applications/data/application_remote_datasource.dart';
import 'package:app/features/applications/domain/entities/application_entity.dart';
import 'package:app/features/applications/presentation/providers/recruiter_applications_provider.dart';
import 'package:app/ui_kit/app_empty_state.dart';
import 'widgets/recruiter_application_card.dart';

enum ApplicationFilter { all, pending, accepted, rejected }

/// Duyệt ứng viên, xếp theo điểm match giảm dần.
/// [jobId] null = ứng viên của tất cả job (tab "Ứng viên").
class RecruiterApplicationsPage extends StatelessWidget {
  const RecruiterApplicationsPage({super.key, this.jobId, this.jobTitle});

  final String? jobId;
  final String? jobTitle;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => RecruiterApplicationsProvider(
        ctx.read<ApplicationRemoteDataSource>(),
      )..load(jobId: jobId),
      child: _View(jobId: jobId, jobTitle: jobTitle),
    );
  }
}

class _View extends StatefulWidget {
  const _View({this.jobId, this.jobTitle});

  final String? jobId;
  final String? jobTitle;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  ApplicationFilter _filter = ApplicationFilter.all;

  bool _matches(ApplicationEntity a) {
    switch (_filter) {
      case ApplicationFilter.all:
        return true;
      case ApplicationFilter.pending:
        return a.status == ApplicationStatus.submitted ||
            a.status == ApplicationStatus.viewed;
      case ApplicationFilter.accepted:
        return a.status == ApplicationStatus.accepted ||
            a.status == ApplicationStatus.shortlisted;
      case ApplicationFilter.rejected:
        return a.status == ApplicationStatus.rejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.jobTitle ?? 'Ứng viên',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => context
                .read<RecruiterApplicationsProvider>()
                .load(jobId: widget.jobId),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              _chips(),
              const Divider(height: 1, color: AppColors.border),
            ],
          ),
        ),
      ),
      body: Consumer<RecruiterApplicationsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.applications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: 'Lỗi tải ứng viên',
              message: provider.errorMessage!,
              actionLabel: 'Thử lại',
              onAction: () => provider.load(jobId: widget.jobId),
            );
          }
          final items = provider.applications.where(_matches).toList();
          if (items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Chưa có ứng viên',
              message: 'Chưa có đơn ứng tuyển nào phù hợp với bộ lọc hiện tại.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            itemBuilder: (_, i) =>
                RecruiterApplicationCard(application: items[i]),
          );
        },
      ),
    );
  }

  Widget _chips() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _chip('Tất cả', ApplicationFilter.all),
            _chip('Chờ duyệt', ApplicationFilter.pending),
            _chip('Đã duyệt', ApplicationFilter.accepted),
            _chip('Từ chối', ApplicationFilter.rejected),
          ],
        ),
      );

  Widget _chip(String label, ApplicationFilter filter) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == filter,
          onSelected: (_) => setState(() => _filter = filter),
          selectedColor: AppColors.primaryContainer,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            color: _filter == filter
                ? AppColors.primary
                : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          checkmarkColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            side: BorderSide(
              color: _filter == filter ? AppColors.primary : AppColors.border,
            ),
          ),
        ),
      );
}
