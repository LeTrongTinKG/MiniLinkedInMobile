import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/applications/presentation/providers/student_applications_provider.dart';

/// Nút "Ứng tuyển ngay" → sau khi nộp chuyển thành "Đã nộp đơn" (vô hiệu)
class JobApplyButton extends StatefulWidget {
  const JobApplyButton({super.key, required this.jobId});

  final String jobId;

  @override
  State<JobApplyButton> createState() => _JobApplyButtonState();
}

class _JobApplyButtonState extends State<JobApplyButton> {
  bool _submitting = false;

  Future<void> _apply() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submitting = true);
    final error = await context.read<StudentApplicationsProvider>().apply(widget.jobId);
    if (mounted) setState(() => _submitting = false);
    messenger.showSnackBar(SnackBar(
      content: Text(error ?? 'Đã nộp đơn ứng tuyển thành công'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final existing =
        context.watch<StudentApplicationsProvider>().activeApplicationFor(widget.jobId);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: existing != null || _submitting ? null : _apply,
            child: _submitting
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    existing != null
                        ? 'Đã nộp đơn (${existing.status.label})'
                        : 'Ứng tuyển ngay',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
