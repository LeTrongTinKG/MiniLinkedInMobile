import '../../domain/entities/cv_entity.dart';

class CvModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final List<String> extractedSkills;
  final Map<String, String> evidence;
  final bool isDefault;
  final DateTime createdAt;

  const CvModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.extractedSkills,
    this.evidence = const {},
    required this.isDefault,
    required this.createdAt,
  });

  /// Server lưu kết quả AI dạng { skills: [...], evidence, education, experienceMonths };
  /// vẫn chấp nhận dạng danh sách thuần để tương thích dữ liệu cũ.
  static List<String> _readSkills(dynamic raw) {
    final list = raw is Map ? raw['skills'] : raw;
    return list is List ? list.map((e) => e.toString()).toList() : [];
  }

  /// evidence: [{ skill, quote }] -> { skill: quote }. CV cũ chưa có thì rỗng.
  static Map<String, String> _readEvidence(dynamic raw) {
    final list = raw is Map ? raw['evidence'] : null;
    if (list is! List) return {};
    return {
      for (final e in list.whereType<Map>())
        if (e['skill'] != null && e['quote'] != null)
          e['skill'].toString(): e['quote'].toString(),
    };
  }

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      extractedSkills: _readSkills(json['extractedSkills']),
      evidence: _readEvidence(json['extractedSkills']),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  CvEntity toEntity() => CvEntity(
        id: id,
        fileName: fileName,
        fileUrl: fileUrl,
        skills: extractedSkills,
        evidence: evidence,
        isDefault: isDefault,
        createdAt: createdAt,
      );
}
