class CoachRole {
  final String id;
  final String title;
  const CoachRole({required this.id, required this.title});

  factory CoachRole.fromJson(Map<String, dynamic> json) => CoachRole(
        id: json['id'] as String,
        title: json['title'] as String,
      );
}

class CoachSettings {
  final bool consent;
  final String? targetRole;
  final List<CoachRole> roles;
  final int remaining;
  final int limit;
  final String? resetsAt;

  const CoachSettings({
    required this.consent,
    required this.targetRole,
    required this.roles,
    required this.remaining,
    required this.limit,
    this.resetsAt,
  });

  factory CoachSettings.fromJson(Map<String, dynamic> json) => CoachSettings(
        consent: json['consent'] == true,
        targetRole: json['targetRole'] as String?,
        roles: (json['roles'] as List<dynamic>? ?? [])
            .map((e) => CoachRole.fromJson(e as Map<String, dynamic>))
            .toList(),
        remaining: (json['remaining'] as num?)?.toInt() ?? 0,
        limit: (json['limit'] as num?)?.toInt() ?? 10,
        resetsAt: json['resetsAt'] as String?,
      );

  bool get ready => consent && targetRole != null;
}

class CoachAnswer {
  final String answer;
  final List<String> sources;
  final String mode;
  final bool refused;
  final int remaining;

  const CoachAnswer({
    required this.answer,
    required this.sources,
    required this.mode,
    required this.refused,
    required this.remaining,
  });

  factory CoachAnswer.fromJson(Map<String, dynamic> json) => CoachAnswer(
        answer: json['answer'] as String? ?? '',
        sources: (json['sources'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        mode: json['mode'] as String? ?? 'rules',
        refused: json['refused'] == true,
        remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      );
}

class CoachPrompt {
  final String label;
  final String intent;
  const CoachPrompt(this.label, this.intent);
}

const kCoachPrompts = [
  CoachPrompt('Tôi còn thiếu skill gì?', 'missing_skills'),
  CoachPrompt('Tôi đang ở bước mấy?', 'current_step'),
  CoachPrompt('Tuần này nên học gì?', 'next_learn'),
  CoachPrompt('Skill nào đã có bằng chứng?', 'evidence_status'),
  CoachPrompt('Làm sao để có bằng chứng?', 'how_evidence'),
  CoachPrompt('Job đang xem còn thiếu skill nào?', 'job_gap'),
  CoachPrompt('Dự án nhỏ nào nên làm?', 'project_for'),
  CoachPrompt('Còn khoảng bao lâu nữa?', 'time_left'),
];
