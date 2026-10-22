class CvEntity {
  final String id;
  final String fileName;
  final String fileUrl;
  final List<String> skills;
  final bool isDefault;
  final DateTime createdAt;

  const CvEntity({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.skills,
    required this.isDefault,
    required this.createdAt,
  });

  String get formattedDate {
    final d = createdAt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  CvEntity copyWith({bool? isDefault}) => CvEntity(
        id: id,
        fileName: fileName,
        fileUrl: fileUrl,
        skills: skills,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt,
      );
}
