import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/ui_kit/app_empty_state.dart';
import 'presentation/providers/student_applications_provider.dart';
import 'presentation/widgets/student_application_card.dart';

/// Tab "Đã ứng tuyển": theo dõi trạng thái các đơn đã nộp
class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentApplicationsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: AppColors.border),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          const BackButton(),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Đã ứng tuyển',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => context.read<StudentApplicationsProvider>().load(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<StudentApplicationsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.applications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null && provider.applications.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Lỗi tải đơn ứng tuyển',
            message: provider.errorMessage!,
            actionLabel: 'Thử lại',
            onAction: () => provider.load(),
          );
        }
        if (provider.applications.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Chưa có đơn ứng tuyển',
            message:
                'Bạn chưa nộp đơn cho vị trí nào.\nHãy khám phá cơ hội việc làm IT ngay hôm nay!',
            actionLabel: 'Khám phá việc làm',
            onAction: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.load,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.bottomContentPadding,
            ),
            itemCount: provider.applications.length,
            itemBuilder: (_, i) =>
                StudentApplicationCard(application: provider.applications[i]),
          ),
        );
      },
    );
  }
}
