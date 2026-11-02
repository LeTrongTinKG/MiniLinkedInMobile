import 'job_entity.dart';

/// Entity chứa tiêu chí tìm kiếm và lọc công việc
class JobFilter {
  final String keyword;
  final WorkMode? workMode;
  final JobLevel? level;
  final Set<String> selectedSkills;

  const JobFilter({
    this.keyword = '',
    this.workMode,
    this.level,
    this.selectedSkills = const {},
  });

  /// Kiểm tra xem có đang kích hoạt bộ lọc nào không
  bool get hasFilter =>
      keyword.trim().isNotEmpty ||
      workMode != null ||
      level != null ||
      selectedSkills.isNotEmpty;

  /// Đếm số tiêu chí lọc đang được kích hoạt (ngoại trừ thanh tìm kiếm keyword)
  int get activeFilterCount {
    int count = 0;
    if (workMode != null) count++;
    if (level != null) count++;
    if (selectedSkills.isNotEmpty) count += selectedSkills.length;
    return count;
  }

  /// Tạo bản sao với các thuộc tính mới
  JobFilter copyWith({
    String? keyword,
    WorkMode? Function()? workMode,
    JobLevel? Function()? level,
    Set<String>? selectedSkills,
  }) {
    return JobFilter(
      keyword: keyword ?? this.keyword,
      workMode: workMode != null ? workMode() : this.workMode,
      level: level != null ? level() : this.level,
      selectedSkills: selectedSkills ?? this.selectedSkills,
    );
  }

  /// Đặt lại toàn bộ bộ lọc
  JobFilter reset() {
    return const JobFilter();
  }

  /// Chuyển đổi sang JSON Map để lưu trữ bền vững (Persistence)
  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'workMode': workMode?.name,
      'level': level?.name,
      'selectedSkills': selectedSkills.toList(),
    };
  }

  /// Khôi phục từ JSON Map sau khi reload ứng dụng/trang web
  factory JobFilter.fromJson(Map<String, dynamic> json) {
    WorkMode? parsedWorkMode;
    if (json['workMode'] != null) {
      try {
        parsedWorkMode = WorkMode.fromString(json['workMode'].toString());
      } catch (_) {}
    }

    JobLevel? parsedLevel;
    if (json['level'] != null) {
      try {
        parsedLevel = JobLevel.fromString(json['level'].toString());
      } catch (_) {}
    }

    final rawSkills = json['selectedSkills'] as List<dynamic>?;
    final skills = rawSkills != null
        ? rawSkills.map((e) => e.toString()).toSet()
        : <String>{};

    return JobFilter(
      keyword: json['keyword'] as String? ?? '',
      workMode: parsedWorkMode,
      level: parsedLevel,
      selectedSkills: skills,
    );
  }
}
