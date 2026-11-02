import '../domain/entities/application_entity.dart';

List<String> _strings(dynamic value) =>
    (value as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

/// Đọc JSON đơn ứng tuyển từ server. Các nhánh (job, student, cv) có thể
/// vắng mặt tuỳ endpoint nên đều có giá trị mặc định.
ApplicationEntity applicationFromJson(Map<String, dynamic> json) {
  final job = (json['job'] as Map<String, dynamic>?) ?? const {};
  final student = (json['student'] as Map<String, dynamic>?) ?? const {};
  final profile = (student['studentProfile'] as Map<String, dynamic>?) ?? const {};
  final cv = (json['cv'] as Map<String, dynamic>?) ?? const {};

  return ApplicationEntity(
    id: json['id']?.toString() ?? '',
    jobId: json['jobId']?.toString() ?? job['id']?.toString() ?? '',
    jobTitle: job['title']?.toString() ?? '',
    companyName: job['companyName']?.toString() ?? '',
    location: job['location']?.toString() ?? '',
    studentName: student['fullName']?.toString() ?? '',
    studentSchool: profile['school']?.toString() ?? '',
    studentMajor: profile['major']?.toString() ?? '',
    cvFileName: cv['fileName']?.toString() ?? '',
    cvFileUrl: cv['fileUrl']?.toString() ?? '',
    matchScore: (json['matchScore'] as num?)?.round() ?? 0,
    matchedSkills: _strings(json['matchedSkills']),
    missingSkills: _strings(json['missingSkills']),
    status: ApplicationStatus.fromString(json['status']?.toString()),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}
