import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2952CC);
  static const Color primaryContainer = Color(0xFFDCE4F7);
  static const Color onPrimaryContainer = Color(0xFF1E3E9E);
  static const Color background = Color(0xFFF3F5F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E6EC);
  static const Color textPrimary = Color(0xFF18202B);
  static const Color textSecondary = Color(0xFF4A5565);
  static const Color textMuted = Color(0xFF5B6676);
  static const Color salary = Color(0xFF0F7B4A);
  static const Color accent = Color(0xFFC2410C);
  static const Color accentContainer = Color(0xFFFAEFEA);
  static const Color error = Color(0xFFB00020);
  static const Color iconMuted = Color(0xFFBBC3CE);

  // 8 stable logo colors: [background, foreground]
  static const List<List<Color>> _logoPalette = [
    [Color(0xFFDCE4F7), Color(0xFF1E3E9E)], // blue
    [Color(0xFFCCF0EC), Color(0xFF0D6B62)], // teal
    [Color(0xFFE9D8FF), Color(0xFF5B21B6)], // purple
    [Color(0xFFFFE4CC), Color(0xFF92400E)], // terracotta
    [Color(0xFFFFD6E4), Color(0xFF9D174D)], // deep pink
    [Color(0xFFD4EDDA), Color(0xFF155724)], // moss green
    [Color(0xFFFFF0CC), Color(0xFF78500A)], // amber
    [Color(0xFFDEE3EC), Color(0xFF1E3A5F)], // slate blue
  ];

  static List<Color> logoColorsFor(String companyName) {
    int hash = 5381;
    for (final c in companyName.codeUnits) {
      hash = ((hash << 5) + hash) ^ c;
      hash = hash & 0x7FFFFFFF;
    }
    return _logoPalette[hash % _logoPalette.length];
  }
}
