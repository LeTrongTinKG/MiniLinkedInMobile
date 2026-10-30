/// Một repo GitHub làm bằng chứng cho skill, kèm các dấu hiệu tìm thấy (ADR-0005).
class SkillEvidence {
  final String repo;
  final String url;
  final List<String> signals;

  const SkillEvidence({
    required this.repo,
    required this.url,
    required this.signals,
  });

  factory SkillEvidence.fromJson(Map<String, dynamic> json) => SkillEvidence(
        repo: json['repo']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        signals: (json['signals'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

/// Skill server đề xuất từ GitHub, chờ người dùng đồng ý hoặc bỏ qua.
class SkillSuggestion {
  final String id;
  final String skillName;
  final List<SkillEvidence> evidence;
  final String confidence;

  const SkillSuggestion({
    required this.id,
    required this.skillName,
    required this.evidence,
    this.confidence = 'self_claimed',
  });

  factory SkillSuggestion.fromJson(Map<String, dynamic> json) =>
      SkillSuggestion(
        id: json['id'] as String,
        skillName: json['skillName'] as String,
        evidence: (json['evidence'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SkillEvidence.fromJson)
            .toList(),
        confidence: json['confidence']?.toString() ?? 'self_claimed',
      );

  /// ADR-0007: không viết "thành thạo". Chỉ nói khi commit đủ ngưỡng.
  String? get confidenceLabel =>
      confidence == 'evidenced' ? 'Có hoạt động mã nguồn đáng kể' : null;
}

/// Đổi mã dấu hiệu của server ("dependency:pub:provider") thành câu dễ đọc.
String signalLabel(String signal) {
  final parts = signal.split(':');
  final value = parts.last;
  switch (parts.first) {
    case 'language':
      return 'viết chủ yếu bằng $value';
    case 'dependency':
      return 'dùng thư viện $value';
    case 'topic':
      return 'gắn chủ đề $value';
    case 'file':
      return 'có file $value';
    case 'keyword':
      return 'README nhắc "$value"';
    default:
      return signal;
  }
}
