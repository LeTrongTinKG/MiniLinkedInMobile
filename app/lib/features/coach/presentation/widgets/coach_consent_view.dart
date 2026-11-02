import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/coach_models.dart';

class CoachConsentView extends StatelessWidget {
  final CoachSettings? settings;
  final String? picked;
  final ValueChanged<String> onPick;
  final VoidCallback onEnable;
  final String? error;
  final bool busy;

  const CoachConsentView({
    super.key,
    required this.settings,
    required this.picked,
    required this.onPick,
    required this.onEnable,
    required this.error,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final roles = settings?.roles ?? const <CoachRole>[];
    return ListView(
      children: [
        const Text(
          'Trợ lý kỹ năng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Trợ lý chỉ đọc skill, CV và job của bạn trên máy nhóm. Bạn tắt lại được bất cứ lúc nào. Không lưu nội dung câu hỏi.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        const Text(
          'Chọn vị trí muốn theo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (final role in roles)
          ListTile(
            title: Text(role.title),
            selected: (picked ?? settings?.targetRole) == role.id,
            trailing: (picked ?? settings?.targetRole) == role.id
                ? const Icon(Icons.check)
                : null,
            onTap: busy ? null : () => onPick(role.id),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              error!,
              style: const TextStyle(color: AppTheme.errorRed),
            ),
          ),
        FilledButton(
          onPressed: busy || roles.isEmpty ? null : onEnable,
          child: Text(busy ? 'Đang lưu...' : 'Đồng ý và bắt đầu'),
        ),
      ],
    );
  }
}
