class CvItem {
  final String id;
  final String fileName;
  final String uploadDate;
  final String fileSize;
  final List<String> skills;
  final bool isDefault;

  const CvItem({
    required this.id,
    required this.fileName,
    required this.uploadDate,
    required this.fileSize,
    required this.skills,
    required this.isDefault,
  });

  CvItem copyWith({bool? isDefault}) => CvItem(
        id: id,
        fileName: fileName,
        uploadDate: uploadDate,
        fileSize: fileSize,
        skills: skills,
        isDefault: isDefault ?? this.isDefault,
      );
}
