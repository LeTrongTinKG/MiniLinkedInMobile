/// Trạng thái đơn ứng tuyển (khớp enum ApplicationStatus của server)
enum ApplicationStatus {
  submitted,
  viewed,
  shortlisted,
  accepted,
  rejected,
  withdrawn;

  static ApplicationStatus fromString(String? value) {
    return ApplicationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ApplicationStatus.submitted,
    );
  }

  String get label {
    switch (this) {
      case ApplicationStatus.submitted:
        return 'Đã nộp';
      case ApplicationStatus.viewed:
        return 'Đã xem';
      case ApplicationStatus.shortlisted:
        return 'Vào vòng sau';
      case ApplicationStatus.accepted:
        return 'Đã duyệt';
      case ApplicationStatus.rejected:
        return 'Bị từ chối';
      case ApplicationStatus.withdrawn:
        return 'Đã rút đơn';
    }
  }

  /// Nhà tuyển dụng không còn đổi được trạng thái đơn đã rút
  bool get isClosed => this == ApplicationStatus.withdrawn;
}

class ApplicationEntity {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String location;
  final String studentName;
  final String studentSchool;
  final String studentMajor;
  final String cvFileName;
  final String cvFileUrl;
  final int matchScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final ApplicationStatus status;
  final DateTime createdAt;

  const ApplicationEntity({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.studentName,
    required this.studentSchool,
    required this.studentMajor,
    required this.cvFileName,
    required this.cvFileUrl,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.status,
    required this.createdAt,
  });

  ApplicationEntity copyWith({ApplicationStatus? status}) => ApplicationEntity(
        id: id,
        jobId: jobId,
        jobTitle: jobTitle,
        companyName: companyName,
        location: location,
        studentName: studentName,
        studentSchool: studentSchool,
        studentMajor: studentMajor,
        cvFileName: cvFileName,
        cvFileUrl: cvFileUrl,
        matchScore: matchScore,
        matchedSkills: matchedSkills,
        missingSkills: missingSkills,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  String get formattedDate {
    final d = createdAt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
