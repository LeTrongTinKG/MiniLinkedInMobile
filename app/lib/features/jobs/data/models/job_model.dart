import '../../domain/entities/job_entity.dart';

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

/// DTO parse dữ liệu công việc từ JSON API / Mock
class JobModel {
  final String id;
  final String recruiterId;
  final String title;
  final String companyName;
  final String? companyLogoUrl;
  final String location;
  final String workMode;
  final String level;
  final int? salaryMin;
  final int? salaryMax;
  final String description;
  final List<String> requiredSkills;
  final List<String> niceToHave;
  final String status;
  final DateTime createdAt;
  final String source;
  final String? applyUrl;
  final String? salaryCurrency;

  const JobModel({
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

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      // recruiter null (job ngoài) -> không có recruiterId, để rỗng
      recruiterId: json['recruiterId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      companyLogoUrl: json['companyLogoUrl'] as String?,
      location: json['location'] as String? ?? '',
      workMode: json['workMode'] as String? ?? 'onsite',
      level: json['level'] as String? ?? 'intern',
      salaryMin: _readInt(json['salaryMin']),
      salaryMax: _readInt(json['salaryMax']),
      description: json['description'] as String? ?? '',
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      niceToHave: (json['niceToHave'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      source: json['source'] as String? ?? 'internal',
      applyUrl: json['applyUrl'] as String?,
      salaryCurrency: json['salaryCurrency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recruiterId': recruiterId,
      'title': title,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'location': location,
      'workMode': workMode,
      'level': level,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'description': description,
      'requiredSkills': requiredSkills,
      'niceToHave': niceToHave,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'source': source,
      'applyUrl': applyUrl,
      'salaryCurrency': salaryCurrency,
    };
  }

  /// Ánh xạ sang Entity nghiệp vụ
  JobEntity toEntity() {
    return JobEntity(
      id: id,
      recruiterId: recruiterId,
      title: title,
      companyName: companyName,
      companyLogoUrl: companyLogoUrl,
      location: location,
      workMode: WorkMode.fromString(workMode),
      level: JobLevel.fromString(level),
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      description: description,
      requiredSkills: requiredSkills,
      niceToHave: niceToHave,
      status: status,
      createdAt: createdAt,
      source: source,
      applyUrl: applyUrl,
      salaryCurrency: salaryCurrency,
    );
  }
}

