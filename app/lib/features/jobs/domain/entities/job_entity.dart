import 'job_enums.dart';
import 'job_labels.dart';

export 'job_enums.dart';
export 'job_labels.dart';

/// Thực thể công việc thuần túy (Domain Entity)
class JobEntity {
  final String id;
  final String recruiterId; // rỗng nếu job nguồn ngoài (không có recruiter)
  final String title;
  final String companyName;
  final String? companyLogoUrl;
  final String location;
  final WorkMode workMode;
  final JobLevel level;
  final int? salaryMin;
  final int? salaryMax;
  final String description;
  final List<String> requiredSkills;
  final List<String> niceToHave;
  final String status;
  final DateTime createdAt;
  final String source; // internal | jsearch | serpapi | remotive
  final String? applyUrl; // link nộp đơn gốc (job ngoài)
  final String? salaryCurrency; // VND | USD | null

  const JobEntity({
    required this.id,
    required this.recruiterId,
    required this.title,
    required this.companyName,
    this.companyLogoUrl,
    required this.location,
    required this.workMode,
    required this.level,
    this.salaryMin,
    this.salaryMax,
    required this.description,
    required this.requiredSkills,
    required this.niceToHave,
    required this.status,
    required this.createdAt,
    this.source = 'internal',
    this.applyUrl,
    this.salaryCurrency,
  });

  /// Chuỗi hiển thị mức lương theo đơn vị tiền
  String get formattedSalary => salaryLabel(salaryMin, salaryMax, salaryCurrency);

  /// Tên nguồn để hiện badge (LinkedIn, Remotive...)
  String get sourceName => sourceLabel(source, applyUrl);

  /// Job nguồn ngoài: nộp đơn qua link gốc, không apply trong app
  bool get isExternal => applyUrl != null && applyUrl!.isNotEmpty;

  /// Tính khoảng thời gian đăng tin (vd: "2 ngày trước")
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

