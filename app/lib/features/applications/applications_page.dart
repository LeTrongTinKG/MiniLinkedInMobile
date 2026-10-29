import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
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
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh),
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
          return _message(Icons.error_outline, provider.errorMessage!);
        }
        if (provider.applications.isEmpty) {
          return _message(
            Icons.assignment_turned_in_outlined,
            'Bạn chưa ứng tuyển công việc nào.\nVào tab Việc làm để bắt đầu.',
          );
        }
        return RefreshIndicator(
          onRefresh: provider.load,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.applications.length,
            itemBuilder: (_, i) =>
                StudentApplicationCard(application: provider.applications[i]),
          ),
        );
      },
    );
  }

  Widget _message(IconData icon, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
}
