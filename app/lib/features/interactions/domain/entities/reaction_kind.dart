import 'package:flutter/material.dart';

enum ReactionKind {
  like('LIKE', 'Thích', Icons.thumb_up_alt_rounded, Color(0xFF2952CC)),
  celebrate('CELEBRATE', 'Chúc mừng', Icons.celebration_rounded, Color(0xFF2E7D32)),
  support('SUPPORT', 'Ủng hộ', Icons.volunteer_activism_rounded, Color(0xFF7B4FBF)),
  love('LOVE', 'Yêu thích', Icons.favorite_rounded, Color(0xFFC62828)),
  insightful('INSIGHTFUL', 'Sâu sắc', Icons.lightbulb_rounded, Color(0xFFB26A00)),
  funny('FUNNY', 'Hài hước', Icons.sentiment_very_satisfied_rounded, Color(0xFF00838F));

  const ReactionKind(this.api, this.label, this.icon, this.color);

  final String api;
  final String label;
  final IconData icon;
  final Color color;

  static ReactionKind? fromApi(String? value) {
    for (final k in values) {
      if (k.api == value) return k;
    }
    return null;
  }
}
