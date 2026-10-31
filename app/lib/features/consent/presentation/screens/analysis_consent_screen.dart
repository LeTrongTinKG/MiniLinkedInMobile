import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../viewmodels/consent_view_model.dart';

/// Màn hình xin phép phân tích tự động theo chuẩn Atom (F-006, Ticket 14, ADR-0010).
/// Bảo đảm tiếp cận A11y Baseline (F-019) với vùng bấm tối thiểu 48x48 dp.
class AnalysisConsentScreen extends StatelessWidget {
  const AnalysisConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsentViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đồng ý phân tích tự động'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'Hệ thống sẽ đọc những dữ liệu sau:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const _BulletItem(
                text: 'Các repository GitHub công khai bạn liên kết hoặc cung cấp'),
            const _BulletItem(
                text: 'File khai báo thư viện (pubspec.yaml, package.json, requirements.txt)'),
            const _BulletItem(
                text: 'Nội dung README và cấu trúc mã nguồn ở thư mục gốc'),
            const _BulletItem(
                text: 'Mô tả công việc (Job Description) để đo khoảng cách kỹ năng'),
            const SizedBox(height: 20),
            const Text(
              'Cam kết không bao giờ đọc:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 10),
            const _BulletItem(
                text: 'Các repository riêng tư (Private repositories)'),
            const _BulletItem(text: 'Mật khẩu, token hoặc thông tin bí mật'),
            const _BulletItem(text: 'Dữ liệu lương hoặc liên hệ cá nhân'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'Quy tắc trích xuất chạy hoàn toàn nội bộ với chi phí 0 USD, không gửi dữ liệu ra nhà cung cấp bên thứ ba. Bạn có thể bật hoặc tắt lại bất cứ lúc nào trong Cài đặt.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            if (vm.failure != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  vm.failure!.message,
                  style:
                      const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onPressed: vm.busy
                          ? null
                          : () => _handleChoice(context, vm, false),
                      child: const Text('Từ chối'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                      ),
                      onPressed: vm.busy
                          ? null
                          : () => _handleChoice(context, vm, true),
                      child: Text(
                        vm.busy ? 'Đang lưu...' : 'Đồng ý & tiếp tục',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleChoice(
    BuildContext context,
    ConsentViewModel vm,
    bool agreed,
  ) async {
    final success = await vm.choose(agreed);
    if (success && context.mounted) {
      Navigator.of(context).pop(agreed);
    }
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
