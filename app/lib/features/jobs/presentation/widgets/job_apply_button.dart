import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/link_opener.dart';
import 'package:app/features/applications/presentation/providers/student_applications_provider.dart';
import '../../domain/entities/job_entity.dart';

/// Nút ứng tuyển ở cuối chi tiết job. Có 2 nhánh:
/// - Job ngoài (có applyUrl): mở link gốc bằng trình duyệt
/// - Job nội bộ: nộp đơn qua API, xong đổi thành "Đã nộp đơn"
class JobApplyButton extends StatefulWidget {
  const JobApplyButton({super.key, required this.job, this.opener = openExternalLink});

  final JobEntity job;
  final LinkOpener opener; // mặc định mở thật; test truyền hàm giả

  @override
  State<JobApplyButton> createState() => _JobApplyButtonState();
}

class _JobApplyButtonState extends State<JobApplyButton> {
  bool _submitting = false;

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // Mở link gốc, không mở được thì báo lỗi
  Future<void> _openLink(String url) async {
    final ok = await widget.opener(url);
    if (!ok && mounted) _toast('Không mở được link ứng tuyển');
  }

  // Nộp đơn nội bộ. Nếu server báo job ngoài (EXTERNAL_JOB_APPLY) thì mở link trong lỗi
  Future<void> _applyInternal() async {
    final provider = context.read<StudentApplicationsProvider>();
    setState(() => _submitting = true);
    final error = await provider.apply(widget.job.id);
    if (mounted) setState(() => _submitting = false);
    final externalUrl = provider.lastExternalApplyUrl;
    if (externalUrl != null) return _openLink(externalUrl);
    if (mounted) _toast(error ?? 'Đã nộp đơn ứng tuyển thành công');
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final existing =
        context.watch<StudentApplicationsProvider>().activeApplicationFor(job.id);

    // Chọn chữ và hành động cho nút
    final VoidCallback? onPressed;
    final String label;
    if (job.isExternal) {
      label = 'Ứng tuyển trên ${job.sourceName}';
      onPressed = () => _openLink(job.applyUrl!);
    } else if (existing != null) {
      label = 'Đã nộp đơn (${existing.status.label})';
      onPressed = null;
    } else {
      label = 'Ứng tuyển ngay';
      onPressed = _submitting ? null : _applyInternal;
    }

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
            onPressed: onPressed,
            child: _submitting
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
