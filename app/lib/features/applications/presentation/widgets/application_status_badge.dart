import 'package:flutter/material.dart';
import '../../domain/entities/application_entity.dart';

/// Nhãn màu cho trạng thái đơn (chờ duyệt, đã xem, duyệt, từ chối...)
class ApplicationStatusBadge extends StatelessWidget {
  const ApplicationStatusBadge(this.status, {super.key});

  final ApplicationStatus status;

  (Color, Color) get _colors {
    switch (status) {
      case ApplicationStatus.submitted:
        return (const Color(0xFFFFF0CC), const Color(0xFF92600A));
      case ApplicationStatus.viewed:
        return (const Color(0xFFDCE4F7), const Color(0xFF1E3E9E));
      case ApplicationStatus.shortlisted:
        return (const Color(0xFFE9D8FF), const Color(0xFF5B21B6));
      case ApplicationStatus.accepted:
        return (const Color(0xFFD4EDDA), const Color(0xFF155724));
      case ApplicationStatus.rejected:
        return (const Color(0xFFFADADD), const Color(0xFFB00020));
      case ApplicationStatus.withdrawn:
        return (const Color(0xFFE2E6EC), const Color(0xFF4A5565));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
