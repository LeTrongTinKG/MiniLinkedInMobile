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

/// Cấp bậc công việc (6 giá trị server trả về)
enum JobLevel {
  intern,
  fresher,
  junior,
  mid,
  senior,
  lead;

  String get label {
    switch (this) {
      case JobLevel.intern:
        return 'Thực tập';
      case JobLevel.fresher:
        return 'Fresher';
      case JobLevel.junior:
        return 'Junior';
      case JobLevel.mid:
        return 'Mid';
      case JobLevel.senior:
        return 'Senior';
      case JobLevel.lead:
        return 'Lead';
    }
  }

  /// Giá trị lạ (server thêm level mới) không làm app crash: rơi về intern
  static JobLevel fromString(String value) {
    for (final lvl in JobLevel.values) {
      if (lvl.name == value.toLowerCase()) return lvl;
    }
    return JobLevel.intern;
  }
}
