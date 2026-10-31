/// Ba cấp độ tin cậy của kỹ năng theo chuẩn Atom (F-008, F-009, F-010).
enum SkillConfidence {
  selfClaimed('self_claimed', 'Tự khai'),
  evidenced('evidenced', 'Có bằng chứng'),
  endorsed('endorsed', 'Được xác nhận');

  final String code;
  final String label;
  const SkillConfidence(this.code, this.label);

  static SkillConfidence fromCode(String? code) {
    switch (code) {
      case 'evidenced':
        return SkillConfidence.evidenced;
      case 'endorsed':
        return SkillConfidence.endorsed;
      case 'self_claimed':
      default:
        return SkillConfidence.selfClaimed;
    }
  }
}

