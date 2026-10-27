/// Độ phù hợp giữa CV mặc định của sinh viên và một job (do AI/mock tính)
class JobMatch {
  final int score;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final String suggestion;

  const JobMatch({
    required this.score,
    required this.matchedSkills,
    required this.missingSkills,
    required this.suggestion,
  });

  factory JobMatch.fromJson(Map<String, dynamic> json) {
    List<String> strings(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return JobMatch(
      score: (json['score'] as num?)?.round() ?? 0,
      matchedSkills: strings(json['matchedSkills']),
      missingSkills: strings(json['missingSkills']),
      suggestion: json['suggestion']?.toString() ?? '',
    );
  }
}
