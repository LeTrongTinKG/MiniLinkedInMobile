/// Chế độ làm việc
enum WorkMode {
  onsite,
  hybrid,
  remote;

  String get label {
    switch (this) {
      case WorkMode.onsite:
        return 'Tại văn phòng';
      case WorkMode.hybrid:
        return 'Linh hoạt (Hybrid)';
      case WorkMode.remote:
        return 'Từ xa (Remote)';
    }
  }

  static WorkMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hybrid':
        return WorkMode.hybrid;
      case 'remote':
        return WorkMode.remote;
      case 'onsite':
      default:
        return WorkMode.onsite;
    }
  }
}

/// Cấp bậc công việc
enum JobLevel {
  intern,
  fresher,
  junior;

  String get label {
    switch (this) {
      case JobLevel.intern:
        return 'Thực tập sinh (Intern)';
      case JobLevel.fresher:
        return 'Fresher';
      case JobLevel.junior:
        return 'Junior';
    }
  }

  static JobLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fresher':
        return JobLevel.fresher;
      case 'junior':
        return JobLevel.junior;
      case 'intern':
      default:
        return JobLevel.intern;
    }
  }
}

/// Thực thể công việc thuần túy (Domain Entity)
class JobEntity {
  final String id;
  final String recruiterId;
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
  });

  /// Chuỗi hiển thị mức lương thân thiện
  String get formattedSalary {
    if (salaryMin == null && salaryMax == null) {
      return 'Thỏa thuận';
    }
    if (salaryMin != null && salaryMax != null) {
      return '\$$salaryMin - \$$salaryMax/tháng';
    }
    if (salaryMin != null) {
      return 'Từ \$$salaryMin/tháng';
    }
    return 'Lên tới \$$salaryMax/tháng';
  }

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

