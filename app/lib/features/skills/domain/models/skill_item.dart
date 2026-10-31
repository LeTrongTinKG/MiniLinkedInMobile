import 'skill_confidence.dart';

/// Đại diện cho một kỹ năng trong hồ sơ ứng viên với cấp độ tin cậy.
class SkillItem {
  final String id;
  final String name;
  final SkillConfidence confidence;
  final List<String> evidenceUrls;
  final int endorsementsCount;

  const SkillItem({
    required this.id,
    required this.name,
    this.confidence = SkillConfidence.selfClaimed,
    this.evidenceUrls = const [],
    this.endorsementsCount = 0,
  });

  factory SkillItem.fromJson(Map<String, dynamic> json) {
    final rawEvidence = json['evidence'];
    final urls = <String>[];
    if (rawEvidence is List) {
      for (final e in rawEvidence) {
        if (e is Map && e['url'] != null) {
          urls.add(e['url'].toString());
        } else if (e is String) {
          urls.add(e);
        }
      }
    }
    return SkillItem(
      id: json['id']?.toString() ?? '',
      name: json['skillName']?.toString() ?? json['name']?.toString() ?? '',
      confidence: SkillConfidence.fromCode(json['confidence']?.toString()),
      evidenceUrls: urls,
      endorsementsCount: (json['endorsementsCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'skillName': name,
        'confidence': confidence.code,
        'evidence': evidenceUrls.map((u) => {'url': u}).toList(),
        'endorsementsCount': endorsementsCount,
      };
}

