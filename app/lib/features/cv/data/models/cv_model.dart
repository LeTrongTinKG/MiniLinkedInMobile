import '../../domain/entities/cv_entity.dart';

class CvModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final List<String> extractedSkills;
  final bool isDefault;
  final DateTime createdAt;

  const CvModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.extractedSkills,
    required this.isDefault,
    required this.createdAt,
  });

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      extractedSkills: (json['extractedSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
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
        isDefault: isDefault,
        createdAt: createdAt,
      );
}
